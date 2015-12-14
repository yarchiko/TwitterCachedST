//
//  AAKTweetCell.h
//  AAKTwitterDigger
//
//  Created by Andrey Konstantinov on 20/11/15.
//  Copyright © 2015 8of. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AAKTweetCell : UITableViewCell

- (void)prepareCellWithUsername:(NSString *)username andTweetText:(NSString *)tweetText andAvatarUrlString:(NSString *)avatarUrlString;

/// Manual cell height calculation - the fastest way
+ (CGFloat)cellHeightWithText:(NSString *)text andSuperviewWidth:(CGFloat)superviewWidth;

@end
