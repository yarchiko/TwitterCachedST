//
//  AAKPreferences.h
//  AAKTwitterDigger
//
//  Created by Andrey Konstantinov on 20/11/15.
//  Copyright © 2015 8of. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AAKPreferences : NSObject

+ (BOOL)isAvatarsEnabled;
+ (void)launchPreparation;
+ (void)setAvatarsEnabled:(BOOL)enabled;

@end
