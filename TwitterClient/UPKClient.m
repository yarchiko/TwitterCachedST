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
#import "UPKTwit.h"
#import "UPKUser.h"

NSString* const UPKRequestUrlString = @"UPKRequestUrlString";

#define USE_DUMP_RESPONSE 1

@interface UPKClient () {
    dispatch_queue_t _requestQueue;
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
            [[NSNotificationCenter defaultCenter] addObserver:__client selector:@selector(removeCapsule:) name:UPKSingleRequestCapsuleFinishedWorking object:nil];
        }
    });
    return __client;
}

- (NSData *)dataForUrlString:(NSString *)urlString andNotification:(NSString *)notification {
    dispatch_async(_requestQueue, ^{
        UPKSingleRequestCapsule *capsule = [[UPKSingleRequestCapsule alloc] initWithUrlString:urlString timeoutInterval:50 headers:nil requestParams:nil notifyOnResponse:notification];
        [_capsules addObject:capsule];
    });
    return nil;
}

- (void)twitListForUserScreenName:(NSString *)screenName withMaxId:(NSString *)maxTwitId andCount:(NSUInteger)count andNotification:(NSString *)notification {
    dispatch_async(_requestQueue, ^{
        NSString *urlString = @"https://api.twitter.com/1.1/statuses/user_timeline.json";//@"http://requestb.in/nnsd18nn";
        NSString *oauth_consumer_key = UPK_TWITTER_OAUTH_CONSUMER_KEY;
        NSString *oauth_nonce = UPK_TWITTER_OAUTH_NONCE;
        NSString *oauth_signature = UPK_TWITTER_OAUTH_SIGNATURE;
        NSString *oauth_timestamp = UPK_TWITTER_OAUTH_TIMESTAMP;
        NSString *oauth_token = UPK_TWITTER_OAUTH_TOKEN;
        NSString *authValue = [NSString stringWithFormat:@"OAuth oauth_consumer_key=\"%@\", oauth_nonce=\"%@\", oauth_signature=\"%@\", oauth_signature_method=\"HMAC-SHA1\", oauth_timestamp=\"%@\", oauth_token=\"%@\", oauth_version=\"1.0\"", oauth_consumer_key, oauth_nonce, oauth_signature, oauth_timestamp, oauth_token];
        NSDictionary *headers = @{@"Authorization":authValue};
        NSDictionary *requestParams = @{@"count":@"10",@"screen_name":screenName};
        UPKSingleRequestCapsule *capsule = [[UPKSingleTwitRequestCapsule alloc] initWithUrlString:urlString timeoutInterval:50 headers:headers requestParams:requestParams notifyOnResponse:notification];
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
    if (finished && responseData) {
        if ([capsule isKindOfClass:[UPKSingleTwitRequestCapsule class]]) {
            id obj = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
#if (DEBUG)
            NSLog(@"Got: %@", obj);
#endif
            if ([obj isKindOfClass:[NSArray class]]) {
                
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
            NSMutableArray *twits = [NSMutableArray array];
            NSMutableDictionary *users = [NSMutableDictionary dictionary];
            for (NSDictionary *twitObj in obj) {
                if (![twitObj isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                NSArray *twitAndUser = [UPKTwit twitAndUserAfterProcessingObject:twitObj];
                if (twitAndUser.count >= 2) {
                    UPKTwit *twit = [twitAndUser firstObject];
                    UPKUser *user = twitAndUser[1];
                    [twits addObject:twit];
                    [users setObject:user forKey:user.idString];
                }
            }
            NSMutableArray *objects = [NSMutableArray arrayWithArray:twits];
            [objects addObjectsFromArray:[users allValues]];
            [[NSNotificationCenter defaultCenter] postNotificationName:notification object:objects userInfo:@{UPKRequestUrlString:capsule.urlString}];
        } else {
            [[UPKDAO sharedDAO] finishedLoadingUrlString:capsule.urlString withData:responseData andNotification:notification];
        }
    }
}

@end
