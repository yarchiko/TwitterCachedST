//
//  AAKClient.m
//  AAKTwitterDigger
//
//  Created by Andrey Konstantinov on 20/11/15.
//  Copyright © 2015 8of. All rights reserved.
//

#include <stdlib.h>

#import "AAKClient.h"
#import "AAKDAO.h"
#import "AAKSingleRequestCapsule.h"
#import "AAKSingleTweetRequestCapsule.h"
#import "AAKTweetsAndUsersContainer.h"

NSString* const AAKRequestUrlString = @"AAKRequestUrlString";

@interface AAKClient () {
    dispatch_queue_t _requestQueue;
    // Queries
    NSMutableArray *_capsules;
}

@property (nonatomic, strong) NSString *authToken;

@end

@implementation AAKClient

+ (instancetype)sharedClient
{
    static AAKClient *__client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __client = [self new];
        if (__client) {
            __client->_requestQueue = dispatch_queue_create("AAK.Client.Request.Queue", DISPATCH_QUEUE_SERIAL);
            __client->_capsules = [@[] mutableCopy];
            [[NSNotificationCenter defaultCenter] addObserver:__client
                                                     selector:@selector(removeCapsule:)
                                                         name:AAKSingleRequestCapsuleFinishedWorking
                                                       object:nil];
        }
    });
    return __client;
}

- (NSData *)dataForUrlString:(NSString *)urlString andNotification:(NSString *)notification
{
    dispatch_async(_requestQueue, ^{
        AAKSingleRequestCapsule *capsule = [[AAKSingleRequestCapsule alloc] initWithUrlString:urlString
                                                                              timeoutInterval:50
                                                                                requestParams:nil
                                                                             notifyOnResponse:notification];
        [_capsules addObject:capsule];
    });
    return nil;
}

- (void)twitListForUserScreenName:(NSString *)screenName withMaxId:(NSString *)maxTwitId orSinceId:(NSString *)sinceId andCount:(NSUInteger)count andNotification:(NSString *)notification
{
    dispatch_async(_requestQueue, ^{
        NSString *urlString = @"https://api.twitter.com/1.1/statuses/user_timeline.json";
        NSMutableDictionary *requestParams = [@{@"count":[@(count) stringValue], @"screen_name":screenName} mutableCopy];
        if (maxTwitId) {
            requestParams[@"max_id"] = maxTwitId;
        }
        AAKSingleRequestCapsule *capsule = [[AAKSingleTweetRequestCapsule alloc] initWithUrlString:urlString
                                                                                   timeoutInterval:50
                                                                                     requestParams:[requestParams copy]
                                                                                  notifyOnResponse:notification];
        [_capsules addObject:capsule];
    });
}

- (void)removeCapsule:(NSNotification *)note
{
    AAKSingleRequestCapsule *capsule = note.object;
    NSAssert([capsule isKindOfClass:[AAKSingleRequestCapsule class]], @"No nil object here");
    NSString *notification = capsule.notification;
    NSError *error = capsule.error;
    NSData *responseData = capsule.responseData;
    BOOL finished = capsule.finished;
    dispatch_async(_requestQueue, ^{
        [capsule cancel];
        [_capsules removeObject:capsule];
    });
    if (finished) {
        if ([capsule isKindOfClass:[AAKSingleTweetRequestCapsule class]]) {
            NSArray *objects = responseData ? [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error] : nil;

            if ([objects isKindOfClass:[NSArray class]]) {
            } else {
                responseData = nil;
            }
            AAKTweetsAndUsersContainer *container = [[AAKTweetsAndUsersContainer alloc] initWithRemoteObjectsArray:objects];
            [[NSNotificationCenter defaultCenter] postNotificationName:notification object:container userInfo:@{AAKRequestUrlString:capsule.urlString}];
        } else if (responseData) {
            [[AAKDAO sharedDAO] finishedLoadingUrlString:capsule.urlString withData:responseData andNotification:notification];
        }
    }
}

@end
