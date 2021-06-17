//
//  AppDelegate.m
//  Blockchain Wallet
//
//  Created by Panerly on 2020/12/24.
//

#import "AppDelegate.h"
#import "PJTabVC.h"
#import "PJNav.h"
#import "SelectWalletVC.h"
#import "Wallet+CoreDataClass.h"
#import <walletsdk/Walletsdk.h>
#import "SDKConfigTool.h"
#import "Blockchain_Wallet-Swift.h"
#import "TradesListViewController.h"
#import "UIViewControllerCJHelper.h"
#import "WOCrashProtectorManager.h"


@interface AppDelegate ()<ApiParamCallback>

@property (nonatomic, strong) PJTabVC *tab;
@property (nonatomic, strong) PJNav *navi;
@property (nonatomic, strong) UIVisualEffectView *effectView;

@end

@implementation AppDelegate

void printEnv(void)
{
    char *env = getenv("DYLD_INSERT_LIBRARIES");
    NSString *envString = [NSString stringWithFormat:@"%s", env];
    if ([envString isEqualToString:@"(null)"]) {
        DLog(@"设备没有越狱");
    }else{
        DLog(@"设备已经越狱了");
        [PJHud showWithString:@"设备环境不安全" BackGroudnColor:[UIColor redColor] loading:NO duration:3 AutoHide:YES];
//        sleep(2);
        exit(0);
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    printEnv();
    
    [self configWalletSDK];
    [self configLanguage];
    [self configCoreData];
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    SelectWalletVC *signVC = [[SelectWalletVC alloc]init];
    PJNav *navi = [[PJNav alloc] initWithRootViewController:signVC];
    self.window.rootViewController = navi;
    [self.window makeKeyAndVisible];
    
    if ([Wallet MR_findAll].count > 0) {
        [self enterHomeSuccess];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterHomeSuccess) name:LOGINSELECTCENTERINDEX object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_presentLogin) name:LOGINOFFSELECTCENTERINDEX object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentTafLogin) name:PRESENTTAFLOGIN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DAppConnectRequestNoti:) name:@"All WVJB RCVD" object:nil];
    
    return YES;
}

//配置更新
- (void)configCoreData{
    
    //获取Documents路径
    NSArray *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsPath = [[document objectAtIndex:0] stringByAppendingPathComponent:@"keystore"];
    DLog(@"keystore地址：%@", documentsPath);
    
    NSString *path = [[NSPersistentStore MR_urlForStoreName:@"WalletDatas.sqlite"] absoluteString];
    path = [path stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
    DLog(@"钱包路径：%@", path);
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"WalletDatas.sqlite"];
}

//MARK:配置钱包SDK（是否是测试）
- (void)success:(ApiParamResponse *)p0{

    [PTool saveValue:p0.net forKey:@"WalletSDKConfig"];
    DLog(@"oldSDK钱包配置：%@", p0.net);
}

- (void)failure:(NSError *)err{

    DLog(@"钱包SDK配置失败");
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [self saveContext];
    //关闭数据库
    [MagicalRecord cleanUp];
}

//获取当前手机语言，并存储到NSUserDefaults。
- (void)configLanguage{

//    [PTool saveValue:@"zh-Hans" forKey:@"appLanguage"];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"appLanguage"]) {

        NSArray *languages = [NSLocale preferredLanguages];
        NSString *language = [languages objectAtIndex:0];

        if ([language hasPrefix:@"zh-Hans"]) {
            //开头匹配
            [PTool saveValue:@"zh-Hans" forKey:@"appLanguage"];
        }else{

            [PTool saveValue:@"en" forKey:@"appLanguage"];
        }
    }
    
    NSString *selectedCurrencyUnit = (NSString *)[PTool getValueFromKey:@"selectedCurrencyUnit"];
    if ([selectedCurrencyUnit containsString:@"null"]) {
        [PTool saveValue:@"CNY" forKey:@"selectedCurrencyUnit"];
    }
}

//MARK:给钱包SDK配置文件目录
- (void)configWalletSDK{
    
    //配置keystore路径
    NSArray *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsPath = [[document objectAtIndex:0] stringByAppendingPathComponent:@"keystore"];
    DLog(@"keystore沙盒路径：%@", documentsPath);
    
    [[PHTTPClient shareInstance] requestMethod:METHOD_GET parameters:@{} url:@"https://www.baidu.com" success:^(id  _Nonnull responseObject) {
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
    
    [PTool saveValue:SDKConfig forKey:@"WalletSDKConfig"];
    DLog(@"钱包配置：%@", SDKConfig);
    if ([SDKConfig containsString:@"test"]) {
        
        [PTool saveValue:@"http://192.168.0.110:8008" forKey:walletHttpAPI];
        CGSize frame = [UIApplication sharedApplication].statusBarFrame.size;
        UILabel *testLabel = [[UILabel alloc] initWithFrame:CGRectMake(KScreenWidth/2-100, frame.height, 200, 22)];
        testLabel.text = @"测试版(仅测试版显示)";
        testLabel.textAlignment = NSTextAlignmentCenter;
        testLabel.textColor = [UIColor redColor];
        [[UIApplication sharedApplication].keyWindow addSubview:testLabel];
    }else{
        [PTool saveValue:@"https://wallet.uvtoken.com" forKey:walletHttpAPI];
        [WOCrashProtectorManager makeAllEffective];
    }
    
    SDKConfigTool *configTool = [[SDKConfigTool alloc] init];
    configTool.configBlock = ^(NSString * _Nonnull httpUrl, NSString * _Nonnull net) {

    };

    ApiParamRequest *req = [[ApiParamRequest alloc] init];
    req.net = SDKConfig;
    dispatch_queue_t queue = dispatch_queue_create("com.vbhledger.uvtoken.config", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{

        SdkParamConfig(req, configTool);
    });
    
    [[PWallet shareInstance] configWithNet:SDKConfig response:^(NSString * _Nonnull response) {
        [PTool saveValue:response forKey:@"WalletSDKConfig"];
        DLog(@"钱包配置：%@", response);
    }];
}

//调起登录
- (void)p_presentLogin{
    
    SelectWalletVC *selectVC = [[SelectWalletVC alloc]init];
    PJNav *navi = [[PJNav alloc] initWithRootViewController:selectVC];
//    [UIApplication sharedApplication].keyWindow.rootViewController = navi;
    
    
//    CATransition *transtition = [CATransition animation];
//    transtition.duration = 0.5;
//    transtition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
//    [UIApplication sharedApplication].keyWindow.rootViewController = navi;
//    [[UIApplication sharedApplication].keyWindow.layer addAnimation:transtition forKey:@"animation"];
    
    
    navi.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    Animation animation = ^{

        BOOL oldState = [UIView areAnimationsEnabled];

        [UIView setAnimationsEnabled:NO];

        [UIApplication sharedApplication].keyWindow.rootViewController = navi;

        [UIView setAnimationsEnabled:oldState];

    };

    [UIView transitionWithView:[UIApplication sharedApplication].keyWindow

                         duration:0.9f

                          options:UIViewAnimationOptionTransitionCurlDown

                       animations:animation

                       completion:nil];
    
    NSString *WalletSDKConfig = (NSString *)[PTool getValueFromKey:@"WalletSDKConfig"];
    if ([WalletSDKConfig isEqualToString:@"regtest"]) {
        CGSize frame = [UIApplication sharedApplication].statusBarFrame.size;
        UILabel *testLabel = [[UILabel alloc] initWithFrame:CGRectMake(KScreenWidth/2-100, frame.height, 200, 22)];
        testLabel.text = @"测试版(仅测试版显示)";
        testLabel.textAlignment = NSTextAlignmentCenter;
        testLabel.textColor = [UIColor redColor];
        [[UIApplication sharedApplication].keyWindow addSubview:testLabel];
    }
}

#warning login taf
- (void)presentTafLogin{
    
    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:logStatus];
    
    Class loginVC =  NSClassFromString(@"LoginAccountVC");
    
    PJNav *navi = [[PJNav alloc] initWithRootViewController:[loginVC new]];
    navi.modalPresentationStyle = 0;
    [[PTool p_getCurrentVC] presentViewController:navi animated:YES completion:^{
        
    }];
}

- (void)enterHomeSuccess{
    
    
    PJTabVC *tab = [[PJTabVC alloc] init];
//    //左侧菜单
//    LeftViewController *leftVC = [[LeftViewController alloc] init];
//    //创建滑动菜单
//    XLSlideMenu *slideMenu = [[XLSlideMenu alloc] initWithRootViewController:tab];
//    //设置左右菜单
//    slideMenu.leftViewController = leftVC;t
    
    
    [UIApplication sharedApplication].keyWindow.rootViewController = tab;
    NSString *WalletSDKConfig = (NSString *)[PTool getValueFromKey:@"WalletSDKConfig"];
    if ([WalletSDKConfig isEqualToString:@"regtest"]) {
        CGSize frame = [UIApplication sharedApplication].statusBarFrame.size;
        UILabel *testLabel = [[UILabel alloc] initWithFrame:CGRectMake(KScreenWidth/2-100, frame.height, 200, 22)];
        testLabel.text = @"测试版(仅测试版显示)";
        testLabel.textAlignment = NSTextAlignmentCenter;
        testLabel.textColor = [UIColor redColor];
        [[UIApplication sharedApplication].keyWindow addSubview:testLabel];
    }
    return;
    
//    tab.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
//    Animation animation = ^{
//
//        BOOL oldState = [UIView areAnimationsEnabled];
//
//        [UIView setAnimationsEnabled:NO];
//
//        [UIApplication sharedApplication].keyWindow.rootViewController = tab;
//
//        [UIView setAnimationsEnabled:oldState];
//
//    };
//
//    [UIView transitionWithView:[UIApplication sharedApplication].keyWindow
//
//                      duration:0.9f
//
//                       options:UIViewAnimationOptionTransitionCurlUp
//
//                    animations:animation
//
//                    completion:nil];
//
//    NSString *WalletSDKConfig = (NSString *)[PTool getValueFromKey:@"WalletSDKConfig"];
//    if ([WalletSDKConfig isEqualToString:@"regtest"]) {
//        CGSize frame = [UIApplication sharedApplication].statusBarFrame.size;
//        UILabel *testLabel = [[UILabel alloc] initWithFrame:CGRectMake(KScreenWidth/2-100, frame.height, 200, 22)];
//        testLabel.text = @"测试版(仅测试版显示)";
//        testLabel.textAlignment = NSTextAlignmentCenter;
//        testLabel.textColor = [UIColor redColor];
//        [[UIApplication sharedApplication].keyWindow addSubview:testLabel];
//    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"程序进入后台" object:nil];
    [self addBlurEffectWithUIVisualEffectView];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"程序进入前台" object:nil];
    //统计日活
    [PTool dailyCount];
    [self removeBlurEffectWithUIVisualEffectView];
}

//MARK:添加模糊蒙层
- (UIVisualEffectView *)effectView {
    if (!_effectView) {
        // 毛玻璃view 视图
        _effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        // 设置模糊透明度
        _effectView.alpha = 1.f;
        _effectView.frame = [UIScreen mainScreen].bounds;
    }
    
    return _effectView;
}

-(void)addBlurEffectWithUIVisualEffectView {
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.effectView];
}

-(void)removeBlurEffectWithUIVisualEffectView {
    [UIView animateWithDuration:0.5 animations:^{
        [self.effectView removeFromSuperview];
    }];
}

#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"Blockchain_Wallet"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

- (UIViewController *)getVC{
    UIViewController *currentShowViewController = [UIViewControllerCJHelper findCurrentShowingViewController];
    return currentShowViewController;
}

//MARK:DApp连接
- (void)DAppConnectRequestNoti:(NSNotification *)noti{
    
    if ([noti.object containsString:@"wc:"]) {
        
        [[WalletApproveTool shared] disConnectAction];
        
        PWS(weakSelf);
        PJAlert *alert = [[PJAlert alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds Title:Localized(@"DApp连接请求") Content:Localized(@"dappAlertContent") Confirm:Localized(@"授权")];
        alert.showTwoBtn = YES;
        alert.titleHidden = NO;
        [alert.confirmBtn setTitle:Localized(@"拒绝") forState:UIControlStateNormal];
        [alert.cancelBtn setTitle:Localized(@"授权") forState:UIControlStateNormal];
        alert.confirm = ^(BOOL confirm) {
            [SVProgressHUD showWithStatus:Localized(@"连接中...")];
            [weakSelf connectWalletWithWCString:noti.object];
        };
        [[UIApplication sharedApplication].keyWindow addSubview:alert];
    }
}

- (void)connectWalletWithWCString:(NSString *)wcString{
    
    [[WalletConnectTool shared] didScan:wcString];
    return;
    TradesListViewController *tradeVC = [TradesListViewController new];
    
    WalletApproveTool *tool = [WalletApproveTool shared];
    tool.wcString = wcString;
    tool.privateKeyStr = nil;
    NSString *defaultWallet = (NSString *)[PTool getValueFromKey:@"defaultWalletAddress"];
    NSArray *arr = [Coin MR_findByAttribute:@"wallet_id" withValue:defaultWallet];
    Coin *ethCoin = nil;
    for (Coin *coin in arr) {
        if ([coin.name isEqualToString:@"ETH"]) {
            ethCoin = coin;
        }
    }
    if (nil == ethCoin) {
        [LSStatusBarHUD showMessageAndImage:Localized(@"请选择ETH钱包后重试")];
        [SVProgressHUD dismiss];
        return;
    }
    tool.ethAddressStr = ethCoin.address;
    [tool connectTapped];
    tool.transParamBlock = ^(NSDictionary * _Nonnull param, int64_t requestId) {
        tradeVC.dic = param;
        tradeVC.requestId = requestId;
        [[self getVC].navigationController pushViewController:tradeVC animated:YES];
    };
}

@end
