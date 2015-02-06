//
//  UPKPreferences.h
//  TwitterCachedST
//
//  Created by Pavel Akhrameev on 06.02.15.
//  Copyright (c) 2015 Pavel Akhrameev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UPKPreferences : NSObject

+(instancetype)sharedPreferences;

@property (nonatomic, assign) BOOL avatarsEnabled;

@end
