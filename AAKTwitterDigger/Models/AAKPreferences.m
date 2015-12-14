//
//  AAKPreferences.m
//  AAKTwitterDigger
//
//  Created by Andrey Konstantinov on 20/11/15.
//  Copyright © 2015 8of. All rights reserved.
//

#import "AAKConstants.h"
#import "AAKPreferences.h"

@implementation AAKPreferences

+ (void)launchPreparation
{
    NSDictionary *registerDefaultsDictionary = @{ DEFAULTS_KEY_IS_AVATARS_ENABLED : @YES };
    [[NSUserDefaults standardUserDefaults] registerDefaults:registerDefaultsDictionary];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isAvatarsEnabled
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:DEFAULTS_KEY_IS_AVATARS_ENABLED];
}

+ (void)setAvatarsEnabled:(BOOL)enabled
{
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:DEFAULTS_KEY_IS_AVATARS_ENABLED];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
