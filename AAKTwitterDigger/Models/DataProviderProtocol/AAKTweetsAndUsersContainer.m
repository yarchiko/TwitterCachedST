//
//  AAKTwitsAndUsersContainer.m
//  AAKTwitterDigger
//
//  Created by Andrey Konstantinov on 20/11/15.
//  Copyright © 2015 8of. All rights reserved.
//

#import "AAKTweetsAndUsersContainer.h"
#import "AAKTweet.h"
#import "AAKUser.h"

@implementation AAKTweetsAndUsersContainer

- (instancetype)containerMergedWithContainer:(AAKTweetsAndUsersContainer *)container
{
    AAKUser *user = [[container.users allValues] firstObject];
    if (!user) {
        user = [[self.users allValues] firstObject];
    }
    return [self containerMergedWithContainer:container keepJustOneUserWithIdString:user.idString];
}

- (instancetype)containerMergedWithContainer:(AAKTweetsAndUsersContainer *)container keepJustOneUserWithIdString:(NSString *)userIdString
{
    if (!container || (!container.users.count && !container.twits.count)) {
        return self;
    }
    NSMutableArray *objects = nil;
    if (userIdString.length) {
        NSPredicate *twitsPredicate = [NSPredicate predicateWithFormat:@"userIdString == %@", userIdString];
        NSPredicate *usersPredicate = [NSPredicate predicateWithFormat:@"idString == %@", userIdString];
        objects = [[self.twits filteredArrayUsingPredicate:twitsPredicate] mutableCopy];
        [objects addObjectsFromArray:[container.twits filteredArrayUsingPredicate:twitsPredicate]];
        // Sort while only tweets in array
        [objects sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"idString" ascending:NO]]];
        [objects addObjectsFromArray:[self.users.allValues filteredArrayUsingPredicate:usersPredicate]];
        [objects addObjectsFromArray:[container.users.allValues filteredArrayUsingPredicate:usersPredicate]];
    } else {
        objects = [self.twits mutableCopy];
        [objects addObjectsFromArray:container.twits];
        // Sort while only tweets in array
        [objects sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"idString" ascending:NO]]];
        [objects addObjectsFromArray:self.users.allValues];
        [objects addObjectsFromArray:container.users.allValues];
    }
    return [[self.class alloc] initWithObjectsArray:objects];
}

- (instancetype)copy
{
    return self;
}

- (instancetype)initWithRemoteObjectsArray:(NSArray *)objects
{
    NSMutableArray *twits = [@[] mutableCopy];
    NSMutableDictionary *users = [@{} mutableCopy];
    for (NSDictionary *twitObj in objects) {
        if (![twitObj isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        NSArray *twitAndUser = [AAKTweet twitAndUserAfterProcessingObject:twitObj];
        if (twitAndUser.count >= 2) {
            AAKTweet *tweet = [twitAndUser firstObject];
            AAKUser *user = twitAndUser[1];
            [twits addObject:tweet];
            [users setObject:user forKey:user.idString];
        }
    }
    _twits = [twits copy];
    _users = [users copy];
    return self;
}

- (instancetype)initWithObjectsArray:(NSArray *)objects
{
    NSMutableArray *twits = [@[] mutableCopy];
    NSMutableDictionary *users = [@{} mutableCopy];
    NSMutableSet *twitsIdsSet = [NSMutableSet set];
    for (id obj in objects) {
        if ([obj isKindOfClass:[AAKTweet class]]) {
            AAKTweet *tweet = obj;
            if (![twitsIdsSet containsObject:tweet.idString]) {
                [twits addObject:tweet];
                [twitsIdsSet addObject:tweet.idString];
            }
        } else if ([obj isKindOfClass:[AAKUser class]]) {
            AAKUser *user = obj;
            [users setObject:user forKey:user.idString];
        }
    }
    _twits = [twits copy];
    _users = [users copy];
    return self;
}

@end
