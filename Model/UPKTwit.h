//
//  UPKTwit.h
//  TwitterCachedST
//
//  Created by Pavel Akhrameev on 02.02.15.
//  Copyright (c) 2015 Pavel Akhrameev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UPKTwit : NSObject
@property (nonatomic, strong) NSString *idString;
@property (nonatomic, strong) NSString *userIdString;
@property (nonatomic, strong) NSString *text;

+ (NSArray *)twitAndUserAfterProcessingObject:(NSDictionary *)obj;
@end
