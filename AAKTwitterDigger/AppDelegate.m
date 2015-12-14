//
//  AppDelegate.m
//  AAKTwitterDigger
//
//  Created by Andrey Konstantinov on 20/11/15.
//  Copyright © 2015 8of. All rights reserved.
//

#import "AppDelegate.h"
#import "AAKDAO.h"
#import "AAKPreferences.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [AAKPreferences launchPreparation];
    [[AAKDAO sharedDAO] dbCreateAndCheck];
    return YES;
}

@end
