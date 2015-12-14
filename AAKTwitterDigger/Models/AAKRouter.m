//
//  AAKRouter.m
//  AAKTwitterDigger
//
//  Created by Andrey Konstantinov on 20/11/15.
//  Copyright © 2015 8of. All rights reserved.
//

#import "AAKRouter.h"

#import "AAKSettingsViewController.h"

@implementation AAKRouter

+ (void)presentSettingsViewControllerInViewController:(UIViewController *)viewController
{
    UIStoryboard *mainSB = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
    AAKSettingsViewController *settingsVC = [mainSB instantiateViewControllerWithIdentifier:[NSString stringWithFormat:@"%@", [AAKSettingsViewController class]]];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    [viewController presentViewController:navigationController
                                 animated:YES
                               completion:nil];
}

@end
