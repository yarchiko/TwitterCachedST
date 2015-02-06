//
//  FirstViewController.m
//  TwitterCachedST
//
//  Created by Pavel Akhrameev on 02.02.15.
//  Copyright (c) 2015 Pavel Akhrameev. All rights reserved.
//

#import "FirstViewController.h"
#import "UPKDAO.h"
#import "UPKTwit.h"
#import "UPKUser.h"
#import "UPKTwitCell.h"
#import "UPKPreferences.h"

const NSString *UpdateTwitsNotificationIdentifier   = @"UpdateTwitsNotificationIdentifier";
const NSString *GotImageDataNotificationIdentifier  = @"GotImageDataNotificationIdentifier";

@interface FirstViewController () <UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *twits;
@property (nonatomic, strong) NSDictionary *twitUsersDic;
@property (weak, nonatomic) IBOutlet UILabel *timerIndicator;
@property (nonatomic, strong) NSTimer *reloadTimer;
@property (nonatomic, assign) NSUInteger numberOfTicks;
@property (weak, nonatomic) IBOutlet UITextField *screenNameTextField;
@end

@implementation FirstViewController

- (NSUInteger)maxNumberOfTicks {
#if (DEBUG)
    return 20 * [self ticksPerSecond];
#endif
    return 60 * [self ticksPerSecond];
}

- (NSUInteger)ticksPerSecond {
    return 2;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTwits:) name:[UpdateTwitsNotificationIdentifier copy] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotImageData:) name:[GotImageDataNotificationIdentifier copy] object:nil];
    [self.tableView setTableFooterView:[UIView new]];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)]];
    [self loadIt:nil];
}

- (void)tap:(UIGestureRecognizer *)tapGestre {
    [self.view endEditing:YES];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [self.view setNeedsUpdateConstraints];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateTimerIndicatorValue];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loadIt:(id)sender {
    if (!self.reloadTimer) {
        self.reloadTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/[self ticksPerSecond] target:self selector:@selector(reloadTimerTick:) userInfo:nil repeats:YES];
    }
    NSString *screenNameTextFieldText = [self.screenNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *screenName = screenNameTextFieldText.length ? screenNameTextFieldText : @"ksenks";
    [[UPKDAO sharedDAO] twitListForUserScreenName:screenName withMaxId:nil andCount:20 andNotification:[UpdateTwitsNotificationIdentifier copy]];
}

- (void)updateTimerIndicatorValue {
    self.timerIndicator.text = self.numberOfTicks ? [@(self.numberOfTicks/[self ticksPerSecond]) stringValue] : @"";
}

- (void)reloadTimerTick:(NSTimer *)timer {
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

- (void)updateTwits:(NSNotification *)note {
    NSArray *objects = note.object;
    if (objects.count) {
        NSMutableArray *twits = [NSMutableArray array];
        NSMutableDictionary *twitUsers = [NSMutableDictionary dictionary];
        for (id obj in objects) {
            if ([obj isKindOfClass:[UPKTwit class]]) {
                [twits addObject:obj];
            } else if ([obj isKindOfClass:[UPKUser class]]) {
                [twitUsers setObject:obj forKey:[obj valueForKey:@"idString"]];
            }
        }
        self.twitUsersDic = twitUsers;
        self.twits = twits;
        [self.tableView reloadData];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.twits.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"twitCell";
    UPKTwitCell *cell = (UPKTwitCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    UPKTwit *twit = [self.twits objectAtIndex:indexPath.row];
    NSString *twitText = twit.text;
    UPKUser *user = [self.twitUsersDic objectForKey:twit.userIdString];
    NSString * userScreenName = user.screenName;
    NSData *imgData = nil;
    if ([[UPKPreferences sharedPreferences] avatarsEnabled]) {
        imgData = [[UPKDAO sharedDAO] dataForUrlString:user.profileImgUrl andNotification:[GotImageDataNotificationIdentifier copy]];
    }
    [cell prepareViewWithUserScreenName:userScreenName andText:twitText andImgData:imgData];
    return cell;
}

#pragma mark - gotImageData notification

- (void)gotImageData:(NSNotification *)note {
    if (![[UPKPreferences sharedPreferences] avatarsEnabled]) {
        return;
    }
    NSString *urlString = note.object;
    NSDictionary *users = [self.twitUsersDic copy];
    NSMutableSet *userIds = [NSMutableSet set];
    for (NSString *idString in users) {
        UPKUser *user = [users objectForKey:idString];
        if ([user.profileImgUrl isEqualToString:urlString]) {
            [userIds addObject:idString];
        }
    }
    NSArray *twits = [self.twits copy];
    NSArray *twitsTouchedByThisImg = [twits filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"userIdString in %@", userIds]];
    NSMutableArray *rowsToReload = [NSMutableArray array];
    for (UPKTwit *twit in twitsTouchedByThisImg) {
        NSUInteger index = [twits indexOfObject:twit];
        if (index != NSNotFound) {
            [rowsToReload addObject:[NSIndexPath indexPathForRow:index inSection:0]];
        }
    }
    if (rowsToReload.count) {
        [self.tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

@end
