//
//  SecondViewController.m
//  TwitterCachedST
//
//  Created by Pavel Akhrameev on 02.02.15.
//  Copyright (c) 2015 Pavel Akhrameev. All rights reserved.
//

#import "PreferencesViewController.h"
#import "UPKPreferences.h"

@interface PreferencesViewController ()
@property (weak, nonatomic) IBOutlet UIView *hideAvatarsView;
@property (weak, nonatomic) IBOutlet UISwitch *hideAvatarsSwitcher;
@property (weak, nonatomic) IBOutlet UILabel *hideAvatarsLabel;

@end

@implementation PreferencesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"avatarfacepreview"]];
    BOOL avatarsEnabled = [UPKPreferences sharedPreferences].avatarsEnabled;
    self.hideAvatarsView.hidden = avatarsEnabled;
    [self.hideAvatarsSwitcher setOn:avatarsEnabled];
    // Do any additional setup after loading the view, typically from a nib.
}


- (IBAction)hideAvatarsSwitcher:(UISwitch *)switcher {
    [self.view.layer removeAllAnimations];
    [[UPKPreferences sharedPreferences] setAvatarsEnabled:switcher.isOn];
    __weak UIView *hideAvatarsView = self.hideAvatarsView;
    BOOL hide = switcher.isOn;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                             if (hide) {
                                 hideAvatarsView.alpha=0;
                             } else {
                                 hideAvatarsView.hidden= NO;
                                 hideAvatarsView.alpha=1;
                             }
                         } completion:^(BOOL b) {
                             hideAvatarsView.hidden= hide;
                         }];
}

@end
