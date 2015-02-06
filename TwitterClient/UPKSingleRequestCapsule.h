//
//  UPKSingleRequestCapsule.h
//  TwitterCachedST
//
//  Created by Pavel Akhrameev on 04.02.15.
//  Copyright (c) 2015 Pavel Akhrameev. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const UPKSingleRequestCapsuleFinishedWorking;

@interface UPKSingleRequestCapsule : NSObject
- (instancetype)initWithUrlString:(NSString *)urlString timeoutInterval:(NSTimeInterval)timeoutInterval headers:(NSDictionary *)headersDic requestParams:(NSDictionary *)requestParams notifyOnResponse:(NSString *)notification;
- (void)cancel;
@property (nonatomic, assign, readonly) BOOL finished;
@property (nonatomic, copy, readonly) NSString *notification;
- (NSError *)error;
- (NSData *)responseData;
- (NSString *)urlString;
@end
