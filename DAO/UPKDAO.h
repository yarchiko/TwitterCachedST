//
//  UPKDAO.h
//  TwitterCachedST
//
//  Created by Pavel Akhrameev on 02.02.15.
//  Copyright (c) 2015 Pavel Akhrameev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UPKTwitAsyncProvider.h"

extern NSString* const UPKDataFromDB;

@protocol UPKFinishedLoadingUrlProtocol <NSObject>

- (void)finishedLoadingUrlString:(NSString *)urlString withData:(NSData *)data andNotification:(NSString *)notification;

@end

@interface UPKDAO : NSObject <UPKTwitAsyncProvider, UPKFinishedLoadingUrlProtocol>

+ (instancetype)sharedDAO;
- (NSString *)dbPath;
- (BOOL)dbCreateAndCheck;

@end
