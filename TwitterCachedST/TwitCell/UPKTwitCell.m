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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeight;
@end

@implementation UPKTwitCell

// если не написать это, то автолейаут не пытается получать размер внутреннего contentView и обновлять свой размер исходя из него
- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentView layoutIfNeeded];
    self.twitText.preferredMaxLayoutWidth = CGRectGetWidth(self.twitText.frame);

}

- (CGFloat)imgSide {
    return 60.0;
}

- (void)prepareForReuse {
    [self setNeedsUpdateConstraints];
    [self.layer removeAllAnimations];
}

- (void)prepareViewWithUserScreenName:(NSString *)screenName andText:(NSString *)text andImgData:(NSData *)imgData animated:(BOOL)animated {
    
    if (imgData) {
        self.twitImgView.image = [UIImage imageWithData:imgData];
    }
    
    BOOL showAvatar = (imgData != nil) && [UPKPreferences sharedPreferences].avatarsEnabled;
    
    self.imageWidth.constant = showAvatar ? self.imgSide : 0;
    self.imageHeight.constant = self.imageWidth.constant;
    if (showAvatar) {
        __weak UPKTwitCell *weakSelf = self;
        [UIView animateWithDuration:0.01 animations:^{
            [weakSelf layoutIfNeeded];
        } completion:^(BOOL finished) {
            weakSelf.imageWidth.constant = showAvatar ? weakSelf.imgSide : 0;
            weakSelf.imageHeight.constant = weakSelf.imageWidth.constant;
            [weakSelf layoutIfNeeded];
        }];
    } else {
        [self layoutIfNeeded];
    }
    
    self.twitUserScreenName.text = screenName;
    self.twitText.text = text;
}

@end
