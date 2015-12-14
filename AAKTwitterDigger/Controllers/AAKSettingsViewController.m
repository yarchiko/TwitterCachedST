//
//  AAKSettingsViewController.m
//  AAKTwitterDigger
//
//  Created by Andrey Konstantinov on 20/11/15.
//  Copyright © 2015 8of. All rights reserved.
//

#import "AAKConstants.h"
#import "AAKPreferences.h"

#import "AAKSettingsViewController.h"

@interface AAKSettingsViewController ()

@property (nonatomic, weak) IBOutlet UISwitch *avatarSwicther;

@end

@implementation AAKSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_avatarSwicther setOn:[AAKPreferences isAvatarsEnabled]];
}

#pragma mark - Actions

- (IBAction)avatarSwitchValueChangedAction:(id)sender
{
    [AAKPreferences setAvatarsEnabled:[sender isOn]];
}

- (IBAction)dismissControllerAction:(id)sender
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

@end
