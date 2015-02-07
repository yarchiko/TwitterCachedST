//
//  UPKTwitsAndUsersContainer.m
//  TwitterCachedST
//
//  Created by Pavel Akhrameev on 07.02.15.
//  Copyright (c) 2015 Pavel Akhrameev. All rights reserved.
//

#import "UPKTwitsAndUsersContainer.h"
#import "UPKTwit.h"
#import "UPKUser.h"

@implementation UPKTwitsAndUsersContainer

- (instancetype)containerMergedWithContainer:(UPKTwitsAndUsersContainer *)container {
    UPKUser *user = [[container.users allValues] firstObject];
    if (!user) {
        user = [[self.users allValues] firstObject];
    }
    return [self containerMergedWithContainer:container keepJustOneUserWithIdString:user.idString];
}

- (instancetype)containerMergedWithContainer:(UPKTwitsAndUsersContainer *)container keepJustOneUserWithIdString:(NSString *)userIdString {
    if (!container || (!container.users.count && !container.twits.count)) {
        return self;
    }
    NSMutableArray *objects = nil;
    if (userIdString.length) {
        NSPredicate *twitsPredicate = [NSPredicate predicateWithFormat:@"userIdString == %@", userIdString];
        NSPredicate *usersPredicate = [NSPredicate predicateWithFormat:@"idString == %@", userIdString];
        objects = [[self.twits filteredArrayUsingPredicate:twitsPredicate] mutableCopy];
        [objects addObjectsFromArray:[container.twits filteredArrayUsingPredicate:twitsPredicate]];
        [objects sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"idString" ascending:NO]]];    //сортировка, пока в массиве только твиты
        [objects addObjectsFromArray:[self.users.allValues filteredArrayUsingPredicate:usersPredicate]];
        [objects addObjectsFromArray:[container.users.allValues filteredArrayUsingPredicate:usersPredicate]];
    } else {
        objects = [self.twits mutableCopy];
        [objects addObjectsFromArray:container.twits];
        [objects sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"idString" ascending:NO]]];    //сортировка, пока в массиве только твиты
        [objects addObjectsFromArray:self.users.allValues];
        [objects addObjectsFromArray:container.users.allValues];
    }
    return [[self.class alloc] initWithObjectsArray:objects];
}

- (instancetype)copy {
    return self;    //структура не изменяемая
}

- (instancetype)initWithRemoteObjectsArray:(NSArray *)objects {
    NSMutableArray *twits = [NSMutableArray array];
    NSMutableDictionary *users = [NSMutableDictionary dictionary];
    for (NSDictionary *twitObj in objects) {
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
    _twits = [twits copy];
    _users = [users copy];
    return self;
}

- (instancetype)initWithObjectsArray:(NSArray *)objects {
    NSMutableArray *twits = [NSMutableArray array];
    NSMutableDictionary *users = [NSMutableDictionary dictionary];
    NSMutableSet *twitsIdsSet = [NSMutableSet set];
    for (id obj in objects) {
        if ([obj isKindOfClass:[UPKTwit class]]) {
            UPKTwit *twit = obj;
            if (![twitsIdsSet containsObject:twit.idString]) {
                [twits addObject:twit];
                [twitsIdsSet addObject:twit.idString];
            }
        } else if ([obj isKindOfClass:[UPKUser class]]) {
            UPKUser *user = obj;
            [users setObject:user forKey:user.idString];
        }
    }
    _twits = [twits copy];
    _users = [users copy];
    return self;
}

@end
