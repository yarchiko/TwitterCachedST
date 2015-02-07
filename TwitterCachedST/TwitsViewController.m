//
//  FirstViewController.m
//  TwitterCachedST
//
//  Created by Pavel Akhrameev on 02.02.15.
//  Copyright (c) 2015 Pavel Akhrameev. All rights reserved.
//

#import "TwitsViewController.h"
#import "UPKDAO.h"
#import "UPKTwit.h"
#import "UPKUser.h"
#import "UPKTwitCell.h"
#import "UPKPreferences.h"

const NSString *UpdateTwitsNotificationIdentifier   = @"UpdateTwitsNotificationIdentifier";
const NSString *GotImageDataNotificationIdentifier  = @"GotImageDataNotificationIdentifier";

@interface TwitsViewController () <UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *twits;
@property (nonatomic, strong) NSDictionary *twitUsersDic;
@property (weak, nonatomic) IBOutlet UILabel *timerIndicator;
@property (nonatomic, strong) NSTimer *reloadTimer;
@property (nonatomic, assign) NSUInteger numberOfTicks;
@property (weak, nonatomic) IBOutlet UITextField *screenNameTextField;
@end

@implementation TwitsViewController

- (NSUInteger)maxNumberOfTicks {
    //костанта перед умножением на ticksPerSecond - количество секунд
#if (DEBUG)
    return 20 * [self ticksPerSecond];
#endif
    return 60 * [self ticksPerSecond];
}

- (NSUInteger)ticksPerSecond {
    //сколько раз в секунду стоит срабатывать таймеру, чтобы мы наиболее точно отсчитывали время
    return 2;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTwits:) name:[UpdateTwitsNotificationIdentifier copy] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotImageData:) name:[GotImageDataNotificationIdentifier copy] object:nil];
    [self.tableView setTableFooterView:[UIView new]];
    //чтобы не было некрасивых линий внизу таблицы
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)]];
    [self loadIt:nil];
}

- (void)tap:(UIGestureRecognizer *)tapGestre {
    //для того, чтобы на айфоне можно было скрыть клавиатуру
    //обычно использую TPKeyboardAvoidingView - но здесь я поместил поле ввода в верх экрана, хватит просто рекогнайзера
    [self.view endEditing:YES];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
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
    //такая реализация та   мера мне больше всего нравится. Из-за скролла таблицы может отложить немного обновление данных - но мне кажется, что это не большая проблема.
    //зато такой подход устойчив к смене времени на девайсе
    //правда, твиттер и сам проследит, чтобы timestamp не сильно отставал от текущего времени
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
    //пришли данные - пора их локально сохранить и обновить табличку
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
        //загрузка данных на самом деле асинхронна - когда данные новые прийдут, прийдет оповещение и я вызову обновление нужных ячеек таблицы
        imgData = [[UPKDAO sharedDAO] dataForUrlString:user.profileImgUrl andNotification:[GotImageDataNotificationIdentifier copy]];
        //если же данные есть в кеше - то разу их помещу на экран
    }
    [cell prepareViewWithUserScreenName:userScreenName andText:twitText andImgData:imgData];
    return cell;
}

#pragma mark - gotImageData notification

- (void)gotImageData:(NSNotification *)note {
    //пришли данные картинки
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
        //эти ячейки связаны с этой картинкой - их пора обновить
        [self.tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

@end
