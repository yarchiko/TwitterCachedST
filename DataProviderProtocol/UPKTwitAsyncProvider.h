//
//  UPKTwitAsyncProvider.h
//  TwitterCachedST
//
//  Created by Pavel Akhrameev on 03.02.15.
//  Copyright (c) 2015 Pavel Akhrameev. All rights reserved.
//

#ifndef TwitterCachedST_UPKTwitAsyncProvider_h
#define TwitterCachedST_UPKTwitAsyncProvider_h

@protocol UPKTwitAsyncProvider <NSObject>

- (void)twitListForUserScreenName:(NSString *)userScreenName withMaxId:(NSString *)maxTwitId orSinceId:(NSString *)sinceId andCount:(NSUInteger)count andNotification:(NSString *)notification;

//- (void)twitListForSearch:(NSString *)search  withMaxId:(NSString *)maxTwitId andCount:(NSUInteger)count andNotification:(NSString *)notification;

- (NSData *)dataForUrlString:(NSString *)urlString andNotification:(NSString *)notification;
//возвращается NSData, если она уже в памяти - если не было, а теперь появилась - можно перезапросить

@end

#endif
