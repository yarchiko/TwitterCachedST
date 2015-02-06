//
//  UPKUser.h
//  TwitterCachedST
//
//  Created by Pavel Akhrameev on 02.02.15.
//  Copyright (c) 2015 Pavel Akhrameev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UPKUser : NSObject

@property (nonatomic, strong) NSString *idString;
@property (nonatomic, strong) NSString *screenName;
@property (nonatomic, strong) NSString *profileImgUrl;

@end
