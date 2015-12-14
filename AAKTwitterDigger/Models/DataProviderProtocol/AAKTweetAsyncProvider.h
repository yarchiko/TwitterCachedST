//
//  AAKTweetAsyncProvider.h
//  AAKTwitterDigger
//
//  Created by Andrey Konstantinov on 20/11/15.
//  Copyright © 2015 8of. All rights reserved.
//

@protocol AAKTweetAsyncProvider <NSObject>

- (void)twitListForUserScreenName:(NSString *)userScreenName withMaxId:(NSString *)maxTwitId orSinceId:(NSString *)sinceId andCount:(NSUInteger)count andNotification:(NSString *)notification;

/// Got NSData from cache - if no data - query server for it inside method
- (NSData *)dataForUrlString:(NSString *)urlString andNotification:(NSString *)notification;

@end
