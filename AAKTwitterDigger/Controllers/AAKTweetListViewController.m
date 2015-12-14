//
//  AAKTweetListViewController.m
//  AAKTwitterDigger
//
//  Created by Andrey Konstantinov on 20/11/15.
//  Copyright © 2015 8of. All rights reserved.
//

#import "AAKConstants.h"
#import "AAKDAO.h"
#import "AAKTweet.h"
#import "AAKUser.h"
#import "AAKTweetsAndUsersContainer.h"
#import "AAKRouter.h"

#import "AAKTweetListViewController.h"

#import "AAKTweetCell.h"

@interface AAKTweetListViewController ()

@property (nonatomic, strong) AAKTweetsAndUsersContainer *container;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *timerIndicator;

@property (nonatomic, strong) NSTimer *reloadTimer;
@property (nonatomic, assign) NSUInteger numberOfTicks;
@property (nonatomic, weak) IBOutlet UITextField *screenNameTextField;

@end

@implementation AAKTweetListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initialPreparation];
}

- (void)initialPreparation
{
    _screenNameTextField.text = DEFAULT_TWITTER_USERNAME;

    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTwits:)
                                                 name:NOTIFICATION_IDENTIFIER_UPDATE_TWEETS
                                               object:nil];

    // Clear useless lines when no more cells to render
    [self.tableView setTableFooterView:[UIView new]];
    [self loadIt:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateTimerIndicatorValue];
    [self.tableView reloadData];
}

#pragma mark - loading initiators

- (void)loadOldTwits:(id)sender
{
    NSString *screenName = [self screenNameForGatheringMoreData:YES];

    // Get last tweet in list
    AAKTweet *lastTwit = [self.container.twits lastObject];
    NSString *lastTwitIdString = lastTwit.idString;
    [[AAKDAO sharedDAO] twitListForUserScreenName:screenName
                                        withMaxId:lastTwitIdString
                                        orSinceId:nil
                                         andCount:20
                                  andNotification:NOTIFICATION_IDENTIFIER_UPDATE_TWEETS];
}

- (NSString *)screenNameForGatheringMoreData:(BOOL)gatherMoreData
{
    NSString *screenNameToReturn = nil;

    // New user - get name from field
    if (!gatherMoreData) {
        NSString *screenNameTextFieldText = [self.screenNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        screenNameToReturn = screenNameTextFieldText;
    }
    // More data for current user
    if (!screenNameToReturn.length) {
        AAKUser *user = [self.container.users.allValues firstObject];
        screenNameToReturn = user.screenName;
    }

    // Take default user if no username provided in TextField
    if (!screenNameToReturn.length) {
        screenNameToReturn = DEFAULT_TWITTER_USERNAME;
    }
    return screenNameToReturn;
}

#pragma mark - loading twits finished method

/// Save locally tweets data after receiving
- (void)updateTwits:(NSNotification *)note
{
    AAKTweetsAndUsersContainer *container = note.object;
    self.container = self.container ? [self.container containerMergedWithContainer:container] : container;
    [self.tableView reloadData];
}

#pragma mark - timing methods

- (NSUInteger)maxNumberOfTicks
{
    return 60 * [self ticksPerSecond];
}

/// Count of ticks per second for timer
- (NSUInteger)ticksPerSecond
{
    return 2;
}

- (void)updateTimerIndicatorValue
{
    self.timerIndicator.title = self.numberOfTicks ? [@(self.numberOfTicks/[self ticksPerSecond]) stringValue] : @"";
}

- (void)reloadTimerTick:(NSTimer *)timer
{
    // Prevent bugs with device time changing
    if (!self.numberOfTicks) {
        self.numberOfTicks = [self maxNumberOfTicks];
    } else {
        --self.numberOfTicks;
    }
    if (!self.numberOfTicks) {
        [self loadIt:nil];
        self.numberOfTicks = [self maxNumberOfTicks];
    }
    [self updateTimerIndicatorValue];
}

#pragma mark - UITableViewDataSource & Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.container.twits.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AAKTweetCell *cell = [tableView dequeueReusableCellWithIdentifier:TWEET_CELL_IDENTIFIER
                                                         forIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AAKTweet *tweet = self.container.twits[indexPath.row];
    return [AAKTweetCell cellHeightWithText:tweet.text
                          andSuperviewWidth:self.tableView.frame.size.width];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Separator insets to zero

    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }

    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }

    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }

    // Cell data binding
    [self configureCell:cell
      forRowAtIndexPath:indexPath];

    NSInteger lastRowIndex = [tableView numberOfRowsInSection:0] - 1;
    if (indexPath.row == lastRowIndex) {
        [self loadOldTwits:nil];
    }
}

#pragma mark - Cell configuration

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[AAKTweetCell class]]) {
        AAKTweetCell *confCell = (AAKTweetCell *)cell;
        AAKTweet *tweet = self.container.twits[indexPath.row];
        AAKUser *user = self.container.users[tweet.userIdString];

        [confCell prepareCellWithUsername:user.screenName
                             andTweetText:tweet.text
                       andAvatarUrlString:user.profileImgUrl];
    }
}

#pragma mark - Actions

/// Action to update tweets list and end editiong of username field
- (IBAction)loadIt:(id)sender
{
    [_screenNameTextField resignFirstResponder];

    // Start timer in main thread
    if (!self.reloadTimer) {
        self.reloadTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/[self ticksPerSecond]
                                                            target:self
                                                          selector:@selector(reloadTimerTick:)
                                                          userInfo:nil
                                                           repeats:YES];
    }

    NSString *screenName = [self screenNameForGatheringMoreData:NO];
    [[AAKDAO sharedDAO] twitListForUserScreenName:screenName
                                        withMaxId:nil
                                        orSinceId:nil
                                         andCount:20
                                  andNotification:NOTIFICATION_IDENTIFIER_UPDATE_TWEETS];
}
- (IBAction)presentSettingsAction:(id)sender
{
    [AAKRouter presentSettingsViewControllerInViewController:self];
}

@end
