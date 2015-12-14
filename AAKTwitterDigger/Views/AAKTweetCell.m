//
//  AAKTweetCell.m
//  AAKTwitterDigger
//
//  Created by Andrey Konstantinov on 20/11/15.
//  Copyright © 2015 8of. All rights reserved.
//

#import "AAKPreferences.h"
#import "AAKDAO.h"

#import "AAKTweetCell.h"

static CGFloat const kAvatarWidth = 40.;
static CGFloat const kAvatarHeight = 40.;
static CGFloat const kCellMarginBetweenElements = 10.;
static CGFloat const kFontSize = 15.;

static NSString *const kGotImageDataNotificationIdentifier  = @"kGotImageDataNotificationIdentifier";
static NSString *const kAvatarPlaceholderImageName = @"AvatarPlaceholder";

@interface AAKTweetCell ()

@property (nonatomic, weak) IBOutlet UILabel *usernameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, weak) IBOutlet UILabel *tweetLabel;

@property (nonatomic, strong) NSString *avatarUrlString;

// Constraints
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *avatarWidthConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *avatarHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *avatarRightMarginConstraint;

@end

@implementation AAKTweetCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotImageData:)
                                                 name:kGotImageDataNotificationIdentifier
                                               object:nil];

    _usernameLabel.font = [UIFont systemFontOfSize:kFontSize];
    _tweetLabel.font = [UIFont systemFontOfSize:kFontSize];
    _avatarImageView.image = [self.class placeholderImage];
    [self changeConstraintsToEnableAvatars:[AAKPreferences isAvatarsEnabled]];
}

- (void)prepareForReuse
{
    [super prepareForReuse];

    [self changeConstraintsToEnableAvatars:[AAKPreferences isAvatarsEnabled]];
    _avatarImageView.image = [self.class placeholderImage];
    _usernameLabel.text = nil;
    _tweetLabel.text = nil;
}

- (void)changeConstraintsToEnableAvatars:(BOOL)enable
{
    _avatarWidthConstraint.constant = enable ? kAvatarWidth : 0.;
    _avatarHeightConstraint.constant = enable ? kAvatarHeight : 0.;
    _avatarRightMarginConstraint.constant = enable ? kCellMarginBetweenElements : 0.;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)prepareCellWithUsername:(NSString *)username andTweetText:(NSString *)tweetText andAvatarUrlString:(NSString *)avatarUrlString
{
    _usernameLabel.text = username;
    _tweetLabel.text = tweetText;

    if (avatarUrlString) {
        if ([AAKPreferences isAvatarsEnabled]) {
            /* If data for avatar is already here - get it,
             * othervise- provide notification name to use it when data will be ready
             */
            NSData *imgData = [[AAKDAO sharedDAO] dataForUrlString:avatarUrlString
                                                   andNotification:kGotImageDataNotificationIdentifier];
            if (imgData) {
                self.avatarImageView.image = [[UIImage alloc] initWithData:imgData];
            } else {
                self.avatarUrlString = avatarUrlString;
            }
        }
    }
}

+ (UIImage *)placeholderImage
{
    static UIImage *__img = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __img = [UIImage imageNamed:kAvatarPlaceholderImageName];
    });
    return __img;
}

#pragma mark  got img data

/// Got avatar data
- (void)gotImageData:(NSNotification *)note
{
    if (![AAKPreferences isAvatarsEnabled]) {
        return;
    }
    NSString *urlString = note.object;
    if ([self.avatarUrlString isEqualToString:urlString]) {
        NSData *imgData = [[AAKDAO sharedDAO] dataForUrlString:urlString
                                               andNotification:kGotImageDataNotificationIdentifier];
        // If image data cached already - show it instantly
        if (imgData) {
            self.avatarImageView.image = [[UIImage alloc] initWithData:imgData];
        }
    }
}

+ (CGFloat)cellHeightWithText:(NSString *)text andSuperviewWidth:(CGFloat)superviewWidth
{
    CGFloat widthLeftForText = superviewWidth;

    // Full cell width minus two margins (left and right)
    widthLeftForText = widthLeftForText - 2 * kCellMarginBetweenElements;

    // If avatar is visible - subtract additinal margin between avatar image and text and avatar width
    if ([AAKPreferences isAvatarsEnabled]) {
        widthLeftForText = widthLeftForText - (kAvatarWidth + kCellMarginBetweenElements);
    }

    // Calculate how much space it takes to store text with params
    CGRect textRect = [text boundingRectWithSize:CGSizeMake(widthLeftForText, CGFLOAT_MAX)
                                         options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                      attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kFontSize]}
                                         context:nil];

    /* Total height for cell =
     * height of text + 3 * margins
     * (top margin height + bottom margin height + margin height between tweet text label and avatar text label) + 
     * avatar label height
     */
    CGFloat heightToReturn = textRect.size.height + 3 * kCellMarginBetweenElements + [self usernameLabelHeight] + 1;


    return heightToReturn < [self minimumCellHeight] ? [self minimumCellHeight] : heightToReturn;
}

/// Height of username label
+ (CGFloat)usernameLabelHeight
{
    // Need only height from here - so it doesnt matter what text as long as it short string - just using short placeholder
    CGRect nameRect =  [@"usernamePlaceholder" boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                            options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                         attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kFontSize]}
                                                            context:nil];
    return nameRect.size.height;
}

/* Minimum cell height
 * Different for cases with avatar of without it
 */
+ (CGFloat)minimumCellHeight
{
    CGFloat minimumHeightToReturn = [self usernameLabelHeight] + 3 * kCellMarginBetweenElements;

    if ([AAKPreferences isAvatarsEnabled]) {
        minimumHeightToReturn = minimumHeightToReturn + kAvatarHeight;
    }

    return minimumHeightToReturn;
}

@end
