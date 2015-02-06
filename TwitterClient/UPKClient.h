//
//  UPKClient.h
//  TwitterCachedST
//
//  Created by Pavel Akhrameev on 03.02.15.
//  Copyright (c) 2015 Pavel Akhrameev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UPKTwitAsyncProvider.h"

#ifndef UPK_TWITTER_OAUTH_PARAMS
    #define UPK_TWITTER_OAUTH_PARAMS
    #define UPK_TWITTER_OAUTH_CONSUMER_KEY  @""
    #define UPK_TWITTER_OAUTH_NONCE         @""
    #define UPK_TWITTER_OAUTH_SIGNATURE     @""
    #define UPK_TWITTER_OAUTH_TIMESTAMP     @""
    #define UPK_TWITTER_OAUTH_TOKEN         @""
#endif

extern NSString* const UPKRequestUrlString;

@interface UPKClient : NSObject <UPKTwitAsyncProvider>

+(instancetype)sharedClient;

@end
