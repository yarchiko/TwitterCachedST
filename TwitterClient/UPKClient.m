//
//  UPKClient.m
//  TwitterCachedST
//
//  Created by Pavel Akhrameev on 03.02.15.
//  Copyright (c) 2015 Pavel Akhrameev. All rights reserved.
//

#import "UPKClient.h"
#import "UPKDAO.h"
#import "UPKSingleRequestCapsule.h"
#import "UPKSingleTwitRequestCapsule.h"
#import "UPKTwitsAndUsersContainer.h"
#include <stdlib.h>

NSString* const UPKRequestUrlString = @"UPKRequestUrlString";

@interface UPKClient () {
    dispatch_queue_t _requestQueue;
    //капсулы - это запросы. Обычно я бы использовал AFNetworking с их операциями, но здесь я сделал пару своих странных классов, чтобы не тянуть мощный фреймворк
    NSMutableArray *_capsules;
}
@property (nonatomic, strong) NSString *authToken;
@end

@implementation UPKClient
+ (instancetype)sharedClient {
    static UPKClient *__client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __client = [self new];
        if (__client) {
            __client->_requestQueue = dispatch_queue_create("UPK.Client.Request.Queue", DISPATCH_QUEUE_SERIAL);
            __client->_capsules = [NSMutableArray array];
            //клиент хранит капсулы и следаит сам за тем, когда им пора очищаться
            [[NSNotificationCenter defaultCenter] addObserver:__client selector:@selector(removeCapsule:) name:UPKSingleRequestCapsuleFinishedWorking object:nil];
        }
    });
    return __client;
}

- (NSData *)dataForUrlString:(NSString *)urlString andNotification:(NSString *)notification {
    dispatch_async(_requestQueue, ^{
        UPKSingleRequestCapsule *capsule = [[UPKSingleRequestCapsule alloc] initWithUrlString:urlString timeoutInterval:50 requestParams:nil notifyOnResponse:notification];
        [_capsules addObject:capsule];
    });
    return nil;
}

- (void)twitListForUserScreenName:(NSString *)screenName withMaxId:(NSString *)maxTwitId orSinceId:(NSString *)sinceId andCount:(NSUInteger)count andNotification:(NSString *)notification {
    dispatch_async(_requestQueue, ^{
        NSString *urlString = @"https://api.twitter.com/1.1/statuses/user_timeline.json";
        NSDictionary *requestParams = @{@"count":[@(count) stringValue], @"screen_name":screenName};
        UPKSingleRequestCapsule *capsule = [[UPKSingleTwitRequestCapsule alloc] initWithUrlString:urlString timeoutInterval:50 requestParams:requestParams notifyOnResponse:notification];
        [_capsules addObject:capsule];
    });
}

- (void)removeCapsule:(NSNotification *)note {
    UPKSingleRequestCapsule *capsule = note.object;
    NSAssert([capsule isKindOfClass:[UPKSingleRequestCapsule class]], @"Капсула должна была прийти!");
    NSString *notification = capsule.notification;
    NSError *error = capsule.error;
    NSData *responseData = capsule.responseData;
    BOOL finished = capsule.finished;
    dispatch_async(_requestQueue, ^{
        [capsule cancel];
        [_capsules removeObject:capsule];
    });
    if (finished) {
        if ([capsule isKindOfClass:[UPKSingleTwitRequestCapsule class]]) {
            NSArray *objects = responseData ? [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error] : nil;
#if (DEBUG)
            NSLog(@"Got: %@", objects);
#endif
            if ([objects isKindOfClass:[NSArray class]]) {
#if (USE_DUMP_RESPONSE)
            } else {
                NSString *filePath = [[NSBundle mainBundle] pathForResource:@"TestResponse" ofType:@"json"];
                responseData = [NSData dataWithContentsOfFile:filePath];
                obj = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
#else 
            } else {
                responseData = nil;
#endif
            }
            UPKTwitsAndUsersContainer *container = [[UPKTwitsAndUsersContainer alloc] initWithRemoteObjectsArray:objects];
            [[NSNotificationCenter defaultCenter] postNotificationName:notification object:container userInfo:@{UPKRequestUrlString:capsule.urlString}];
        } else if (responseData) {
            [[UPKDAO sharedDAO] finishedLoadingUrlString:capsule.urlString withData:responseData andNotification:notification];
        }
    }
}

@end
