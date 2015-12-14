//
//  AAKDAO.m
//  AAKTwitterDigger
//
//  Created by Andrey Konstantinov on 20/11/15.
//  Copyright © 2015 8of. All rights reserved.
//

#import "FMDB.h"

#import "AAKConstants.h"
#import "AAKDAO.h"
#import "AAKClient.h"
#import "AAKTweetsAndUsersContainer.h"
#import "AAKTweet.h"
#import "AAKUser.h"

NSString *const AAKDataFromDB = @"AAKDataFromDB";

@interface AAKDAO () {
    dispatch_queue_t _dbRequestQueue;
}

@property (nonatomic, strong) FMDatabaseQueue *fmdbQueue;
/// Avatars cache
@property (nonatomic, strong) NSMutableDictionary *dataDictionary;

@end

@implementation AAKDAO

+ (instancetype)sharedDAO
{
    static AAKDAO *__dao = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __dao = [[self alloc] init];
        __dao->_dataDictionary = [NSMutableDictionary dictionary];
        __dao->_dbRequestQueue = dispatch_queue_create("AAK.DAO.DB.Request.Queue", DISPATCH_QUEUE_SERIAL);
    });
    return __dao;
}

- (NSData *)dataForUrlString:(NSString *)urlString andNotification:(NSString *)notification
{
    // Method is fast enough, so no problem with calling it on Main Thread
    NSData *data = self.dataDictionary[urlString];
    if (!data.length) {
        if (data) {
            // Query in process
        } else {
            // Query to server
            AAKClient *client = [AAKClient sharedClient];
            [client dataForUrlString:urlString
                     andNotification:notification];

            // Async searching data in DB
            FMDatabaseQueue *queue = self.fmdbQueue;
            dispatch_async(_dbRequestQueue, ^{
                [queue inDatabase:^(FMDatabase *db) {
                    // Return from DB
                    FMResultSet *rs =[db executeQuery:@"select * from data where urlString in (?)", urlString];
                    while ([rs next]) {
                        NSData *data = [rs dataForColumn:@"data"];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            // Write data to cache to prevent constant queries to DB
                            [self setData:data forUrlString:urlString];
                            [[NSNotificationCenter defaultCenter] postNotificationName:notification
                                                                                object:urlString
                                                                              userInfo:@{AAKDataFromDB:@(YES)}];
                            // Do not stop server query here - maybe data has changed on server side
                        });
                        break;
                    }
                    [rs close];
                }];
            });
        }
    } else { // If Data cached - return it instantly
        return data;
    }
    return nil;
}

/// Cache data
- (void)setData:(NSData *)data forUrlString:(NSString *)urlString
{
    [self.dataDictionary setObject:data forKey:urlString];
}

/// Save avatar data to DB
- (void)finishedLoadingUrlString:(NSString *)urlString withData:(NSData *)data andNotification:(NSString *)notification
{
    if (data && urlString) {
        [self.dataDictionary setObject:data forKey:urlString];
        FMDatabaseQueue *queue = self.fmdbQueue;
        dispatch_async(_dbRequestQueue, ^{
            // Rewrite data if exist
            [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
                BOOL success = [db executeUpdate:@"delete from 'data' where urlString=(?)", urlString];
                if (success) {
                    success = [db executeUpdate:@"insert into 'data' (urlString,data) values (?,?)", urlString, data];
                }
                if (!success) {
                    *rollback = YES;
                    return;
                }
            }];
        });
        [[NSNotificationCenter defaultCenter] postNotificationName:notification
                                                            object:urlString];
    }
}

#pragma mark - Tweets

- (void)twitListForUserScreenName:(NSString *)screenName withMaxId:(NSString *)maxTwitId orSinceId:(NSString *)sinceId andCount:(NSUInteger)count andNotification:(NSString *)notification
{
    AAKClient *client = [AAKClient sharedClient];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:notification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(processTwits:)
                                                 name:notification
                                               object:nil];
    [client twitListForUserScreenName:screenName
                            withMaxId:maxTwitId
                            orSinceId:sinceId
                             andCount:count
                      andNotification:notification];

    // Get local data
    __block NSMutableArray *twitsAndUsers = [NSMutableArray arrayWithCapacity:count];
    FMDatabaseQueue *queue = self.fmdbQueue;
    dispatch_async(_dbRequestQueue, ^{
        // Get from DB
        [queue inDatabase:^(FMDatabase *db) {
            FMResultSet *rs =[db executeQuery:@"select * from twits limit (?)", @(count)];
            NSMutableSet *userIdsInUse = [NSMutableSet set];
            while ([rs next]) {
                AAKTweet *tweet = [AAKTweet new];
                tweet.idString = [rs stringForColumn:@"idString"];
                tweet.userIdString = [rs stringForColumn:@"userIdString"];
                tweet.text = [rs stringForColumn:@"text"];
                [twitsAndUsers addObject:tweet];
                [userIdsInUse addObject:tweet.userIdString];
            }
            [rs close];
            if (userIdsInUse.count) {
                rs = [db executeQuery:@"select * from users where idString in (?)", [userIdsInUse.allObjects componentsJoinedByString:@","]];
                while ([rs next]) {
                    AAKUser *user = [AAKUser new];
                    user.idString = [rs stringForColumn:@"idString"];
                    user.screenName = [rs stringForColumn:@"screenName"];
                    user.profileImgUrl = [rs stringForColumn:@"profileImgUrl"];
                    [twitsAndUsers addObject:user];
                }
                [rs close];
            }
        }];
        AAKTweetsAndUsersContainer *container = [[AAKTweetsAndUsersContainer alloc] initWithObjectsArray:twitsAndUsers];
        dispatch_async(dispatch_get_main_queue(), ^{
            // Send notification with array with users (one user in this case) and tweets
            [[NSNotificationCenter defaultCenter] postNotificationName:notification
                                                                object:container
                                                              userInfo:@{AAKDataFromDB : @(YES)}];
        });
    });
}

- (void)processTwits:(NSNotification *)note
{
    // Skip notification from itself
    if ([note.userInfo[AAKDataFromDB] boolValue]) {
        return;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:note.name
                                                  object:nil];

    // Save to DB - delete old data and save new one
    AAKTweetsAndUsersContainer *container = note.object;
    FMDatabaseQueue *queue = self.fmdbQueue;

    // No need to write anything if no data provided
    if (container.twits.count == 0 || container.users.count == 0) {
        return;
    }

    dispatch_async(_dbRequestQueue, ^{
        [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            BOOL success = [db executeStatements:@"delete from 'users'; delete from 'twits'"];
            if (!success) {
                *rollback = YES;
                return;
            }
            for (AAKTweet *tweet in container.twits) {
                success = [db executeUpdate:@"insert into 'twits' (idString, userIdString, text) values (?, ?, ?)", tweet.idString, tweet.userIdString, tweet.text];
                if (!success) {
                    *rollback = YES;
                    return;
                }
            }
            for (NSString *userIdString in container.users) {
                AAKUser *user = container.users[userIdString];
                success = [db executeUpdate:@"insert into 'users' (idString, screenName, profileImgUrl) values (?,?,?)", user.idString, user.screenName, user.profileImgUrl];
                if (!success) {
                    *rollback = YES;
                    return;
                }
            }
        }];
    });
}

#pragma mark - DB methods

- (FMDatabaseQueue *)fmdbQueue
{
    if (!_fmdbQueue) {
        _fmdbQueue = [FMDatabaseQueue databaseQueueWithPath:self.dbPath];
    }
    return _fmdbQueue;
}

- (BOOL)dbCreateAndCheck
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success = [fileManager fileExistsAtPath:self.dbPath];
    if(success) {
        return YES;
    }
    NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"AAKTweetDefault.db"];
    NSError *error = nil;
    [fileManager copyItemAtPath:databasePathFromApp toPath:self.dbPath error:&error];
    if (error) {
        NSLog(@"Error in db file: %@", error);
    }
    return !error;
}

- (NSString *)dbPath
{
    static NSString *__dbPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *dbName = @"AAKTweet.db";
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDir = [documentPaths firstObject];
        __dbPath = [documentDir stringByAppendingPathComponent:dbName];
    });
    return __dbPath;
}

@end
