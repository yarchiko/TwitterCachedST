//
//  UPKPreferences.m
//  TwitterCachedST
//
//  Created by Pavel Akhrameev on 06.02.15.
//  Copyright (c) 2015 Pavel Akhrameev. All rights reserved.
//

#import "UPKPreferences.h"

@implementation UPKPreferences

NSString *const UPKAvatarsEnabled = @"UPKAvatarsEnabled";

+ (instancetype)sharedPreferences {
    static UPKPreferences *__prefs = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __prefs = [self new];
    });
    return __prefs;
}

+ (void) initialize {
    NSMutableDictionary  *defaultValues = [NSMutableDictionary dictionary];
    //
    // Устанавливаем начальные значения
    //
    [defaultValues setObject:@(NO) forKey:UPKAvatarsEnabled];
    
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    [defs registerDefaults: defaultValues];
    [defs synchronize];
}

- (NSUserDefaults *)defs {
    return [NSUserDefaults standardUserDefaults];
}

- (BOOL)avatarsEnabled {
    return [self.defs boolForKey:UPKAvatarsEnabled];
}

- (void)setAvatarsEnabled:(BOOL)enabled {
    [self.defs setBool:enabled forKey:UPKAvatarsEnabled];
    [self.defs synchronize];
}

@end
