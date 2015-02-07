//
//  UPKTwitsAndUsersContainer.h
//  TwitterCachedST
//
//  Created by Pavel Akhrameev on 07.02.15.
//  Copyright (c) 2015 Pavel Akhrameev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UPKTwitsAndUsersContainer : NSObject
@property (nonatomic, strong, readonly) NSDictionary *users;
@property (nonatomic, strong, readonly) NSArray *twits;
- (instancetype)containerMergedWithContainer:(UPKTwitsAndUsersContainer *)container;
- (instancetype)containerMergedWithContainer:(UPKTwitsAndUsersContainer *)container keepJustOneUserWithIdString:(NSString *)userIdString;
- (instancetype)initWithRemoteObjectsArray:(NSArray *)objects;
- (instancetype)initWithObjectsArray:(NSArray *)objects;
- (instancetype)copy;
@end
