//
//  UPKTwitCell.m
//  TwitterCachedST
//
//  Created by Pavel Akhrameev on 06.02.15.
//  Copyright (c) 2015 Pavel Akhrameev. All rights reserved.
//

#import "UPKTwitCell.h"
#import "UPKPreferences.h"

@interface UPKTwitCell ()
@property (weak, nonatomic) IBOutlet UIImageView *twitImgView;
@property (weak, nonatomic) IBOutlet UILabel *twitUserScreenName;
@property (weak, nonatomic) IBOutlet UILabel *twitText;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageWidth;
@end

@implementation UPKTwitCell

- (void)prepareForReuse {
    [self setNeedsUpdateConstraints];
    [self.layer removeAllAnimations];
}

- (void)prepareViewWithUserScreenName:(NSString *)screenName andText:(NSString *)text andImgData:(NSData *)imgData {
    if (imgData) {
        self.twitImgView.image = [UIImage imageWithData:imgData];
    }
    BOOL showAvatar = (imgData != nil) && [UPKPreferences sharedPreferences].avatarsEnabled;
    self.imageWidth.constant = showAvatar ? self.twitImgView.frame.size.height : 0;
    if (showAvatar) {
        __weak UPKTwitCell *weakSelf = self;
        [UIView animateWithDuration:0.01 animations:^{
            [weakSelf layoutIfNeeded];
        } completion:^(BOOL finished) {
            weakSelf.imageWidth.constant = showAvatar ? weakSelf.twitImgView.frame.size.height : 0;
            [weakSelf layoutIfNeeded];
        }];
    } else {
        [self layoutIfNeeded];
    }
    self.twitUserScreenName.text = screenName;
    self.twitText.text = text;
}

@end
