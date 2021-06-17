//
//  WalletViewController.m
//  Blockchain Wallet
//
//  Created by Panerly on 2020/12/24.
//

#import "WalletViewController.h"
#import "UIViewController+CWLateralSlide.h"
#import "LeftViewController.h"
#import "QRCodeResultVC.h"
#import <AVFoundation/AVFoundation.h>
#import "ScanViewController.h"
#import "WalletSettingVC.h"
#import "HomeCell.h"
#import "CreateWalletVC.h"
#import "ImportViewController.h"
#import "TransInfoViewController.h"
#import "MnemonicVC.h"
#import "UpdateView.h"
#import "SecurityUtil.h"
#import "SearchViewController.h"
#import <walletsdk/Walletsdk.h>
#import "CommonWebViewController.h"

@interface WalletViewController ()<UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, ApiGetAddressBalanceCallback>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) NSMutableArray *rateArr;
@property (nonatomic, strong) NSString *totalTransBalanceStr;
@property (nonatomic, strong) NSString *tafBalanceStr;
@property (nonatomic, strong) NSString *tafTransBalanceStr;

@end

@implementation WalletViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.edgesForExtendedLayout = UIRectEdgeAll;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (self.dataArr.count > 0) {
        
        [self getWalletBalance];
    }
    [self subscriptionAction];
    
//    NSString *defaultWallet = (NSString *)[PTool getValueFromKey:@"defaultWalletAddress"];
//    NSArray *coinArr = [Coin MR_findByAttribute:@"wallet_id" withValue:defaultWallet];
//    for (Coin *coin in coinArr) {
//        coin.balance = @"0";
//    }
//    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

//MARK:当前钱包未备份，提醒备份
- (void)showBackupTipsView{
    
    CGFloat height = [PTool sizeWithText:Localized(@"安全提醒内容") font:[UIFont systemFontOfSize:11] maxSize:CGSizeMake(KScreenWidth-10*4, KScreenHeight)].height;
    self.tipsViewHeightConstraint.constant = 10*2+14+5*2+height+30+14+14;
    
    [UIView animateWithDuration:.3 animations:^{
        
        self.tipsView.transform = CGAffineTransformIdentity;
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self getHomeData];
    [self setUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUI) name:CHANGELANGUAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getHomeData) name:LOGINSELECTCENTERINDEX object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getHomeData) name:CHANGECURRENCY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isShowBackUpTips) name:CHANGEWALLET object:nil];
    [self performSelector:@selector(checkVersion) withObject:self afterDelay:1];
    [self isShowBackUpTips];
}

- (void)setUI{
    
    self.zczzLabel.text = Localized(@"资产总值");
    self.aqtxLabel.text = Localized(@"安全提醒");
    self.aqtxContentLabel.text = Localized(@"安全提醒内容");
    self.zcLabel.text = Localized(@"资产");
    [self.backupBtn setTitle:Localized(@"立即备份") forState:UIControlStateNormal];
    
//    CGFloat height = [PTool sizeWithText:Localized(@"安全提醒内容") font:[UIFont systemFontOfSize:11] maxSize:CGSizeMake(KScreenWidth-10*4, KScreenHeight)].height;
//    self.tipsViewHeightConstraint.constant = 10*2+14+5*2+height+30+14+14;
    [self isShowBackUpTips];
    
    self.totalTransBalanceStr = @"";
    self.tafBalanceStr = @"0";
    self.tafTransBalanceStr = @"0";
    
    if (kIsBangsScreen) {
        self.headerViewHeight.constant = 200;
    }else{
        self.headerViewHeight.constant = 200-49;
    }
    
    [self.tableView registerNib:[UINib nibWithNibName:@"HomeCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"HomeCellID"];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getHomeData)];
    
    [self getNetworkStatusInfo];
}

- (void)getNetworkStatusInfo{
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case -1:
                NSLog(@"未知网络");
                break;
            case 0:
                NSLog(@"网络不可达");
                break;
            case 1:
                NSLog(@"GPRS网络");
                break;
            case 2:
                NSLog(@"wifi网络");
                break;
            default:
                break;
        }
        if(status == AFNetworkReachabilityStatusReachableViaWWAN || status == AFNetworkReachabilityStatusReachableViaWiFi) {
            NSLog(@"有网");
            self.networkStatusLabel.hidden = YES;
        } else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:Localized(@"设备已离线") message:Localized(@"网络已断开，请检查网络链接。") delegate:self cancelButtonTitle:Localized(@"知道了") otherButtonTitles:nil, nil];
            [alert show];
            self.networkStatusLabel.text = Localized(@"离线中");
            self.networkStatusLabel.hidden = NO;
        }
    }];
}

//判断钱包是否备份
- (void)isShowBackUpTips{
    
    NSString *defaultWallet = (NSString *)[PTool getValueFromKey:@"defaultWalletAddress"];
    NSArray *selectedArr = [Wallet MR_findByAttribute:@"wallet_id" withValue:defaultWallet];
    for (Wallet *wallet in selectedArr) {
        if (!wallet.is_backup && [wallet.type isEqualToString:@"Multi"]) {
            [self showBackupTipsView];
        }else{
            [self removeTips:nil];
        }
    }
    if (selectedArr.count < 1) {
        
        [self removeTips:nil];
    }
}

//MARK:获取当前钱包信息
- (void)getHomeData{
    
    NSString *currency = (NSString *)[PTool getValueFromKey:@"selectedCurrencyUnit"];
    [self.currencyImgView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"icon_home_%@",[currency lowercaseString]]]];
    
    [self.dataArr removeAllObjects];
    [self.tableView reloadData];
    
    NSArray *arr = [Wallet MR_findAll];
    NSString *defaultWallet = (NSString *)[PTool getValueFromKey:@"defaultWalletAddress"];
    
    NSString *tempWallet = @"default";
    if (arr.count > 0) {
        tempWallet = ((Wallet *)arr[0]).wallet_id;
    }
    
    if (defaultWallet.length > 6) {
        tempWallet = defaultWallet;
    }
    
    NSArray *selectedArr = [Wallet MR_findByAttribute:@"wallet_id" withValue:tempWallet];
    for (Wallet *wallet in selectedArr) {
        
        [self.walletNameBtn setTitle:[NSString stringWithFormat:@"   %@", wallet.name] forState:UIControlStateNormal];
    }
    
    NSArray *subCoinArr = [Coin MR_findByAttribute:@"wallet_id" withValue:tempWallet];
    
    BOOL isSupportERC20 = NO;
    for (int i = 0; i < subCoinArr.count; i++) {
        
        NSString *coinNameStr = ((Coin *)subCoinArr[i]).name;
        if ([coinNameStr isEqualToString:@"ETH"]) {
            isSupportERC20 = YES;
        }
#warning remove AECO Coin
        if (![coinNameStr isEqualToString:@"AECO"]) {
            
            BaseModel *model = [[BaseModel alloc] init];
            model.hidden = @"NO";
            model.imgName = [NSString stringWithFormat:@"icon_%@", [((Coin *)subCoinArr[i]).name lowercaseString]];
            model.transBalance = @"0";
            model.balance = [NSString stringWithFormat:@"%@", ((Coin *)subCoinArr[i]).balance];
            model.type = coinNameStr;
            model.address = ((Coin *)subCoinArr[i]).address;
            model.coinTag = ((Coin *)subCoinArr[i]).coin_tag;
            model.image = ((Coin *)subCoinArr[i]).image;
            model.contactAddress = ((Coin *)subCoinArr[i]).contact_address;
            model.keyID = ((Coin *)subCoinArr[i]).key_id;
            [self.dataArr addObject:model];
        }
    }
    
    self.addCurrencyBtn.hidden = !isSupportERC20;
    self.addCurrencyBtn.hidden = YES;
    if (self.dataArr.count < 1) {
        
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
        return;
    }
    
    if (self.showBalanceBtn.selected) {
        [self.dataArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ((BaseModel *)self.dataArr[idx]).hidden = @"YES";
        }];
    }else{
        [self.dataArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ((BaseModel *)self.dataArr[idx]).hidden = @"NO";
        }];
    }
    
    [self.tableView reloadData];
    [self.tableView.mj_header endRefreshing];
    
//    for (Wallet *wallet in selectedArr) {
//        if (!wallet.is_backup && [wallet.type isEqualToString:@"Multi"]) {
//            [self showBackupTipsView];
//        }else{
//            [self removeTips:nil];
//        }
//    }
//    if (selectedArr.count < 1) {
//
//        [self removeTips:nil];
//    }
    
    [self getWalletBalance];
}

- (BOOL)isCantainsStr:(NSString *)str Arr:(NSArray *)arr{
    
    for (int i = 0; i < arr.count; i++) {
        NSString *addr = ((Wallet *)arr[i]).wallet_id;
        if ([addr isEqualToString:str]) {
            return YES;
        }
    }
    return NO;
}

//MARK:获取余额币
- (void)getWalletBalance{
    
    NSString *defaultWallet = (NSString *)[PTool getValueFromKey:@"defaultWalletAddress"];
    NSArray *arr = [Coin MR_findByAttribute:@"wallet_id" withValue:defaultWallet];
    
    for (Coin *coin in arr) {
        
        ApiGetAddressBalanceRequest *req = [[ApiGetAddressBalanceRequest alloc] init];
        req.address = coin.address;
        if ([coin.name isEqualToString:@"BTC"]) {
            
            req.coinType = coin.name;
        }
        if ([coin.name isEqualToString:@"USDT"]) {
            
            if ([coin.coin_tag isEqualToString:@"OMNI"]) {
                
                req.tokenType = @"USDT";
                req.coinType = @"BTC";
            }else if ([coin.coin_tag isEqualToString:@"ERC20"]){
                
                req.tokenType = @"USDT";
                req.coinType = @"ETH";
            }
        }
        if ([coin.name isEqualToString:@"ETH"]) {
            req.coinType = @"ETH";
        }
        DLog(@"请求前的cointype----%@ tokentype：%@ address:%@", req.coinType, req.tokenType, req.address);
        dispatch_queue_t queue = dispatch_queue_create("com.vbhledger.tafwallet.getbalance", DISPATCH_QUEUE_SERIAL);
        dispatch_async(queue, ^{
            
            SdkGetAddressBalance(req, self);
        });
    }
    
    
    
//    if ([addressStr containsString:@"null"]) {
//        DLog(@"地址不存在");
//        [self.tableView.mj_header endRefreshing];
//        return;
//    }
//    ApiGetAddressBalanceRequest *req = [[ApiGetAddressBalanceRequest alloc] init];
//    req.address = addressStr;
//    req.coinType = @"BTC";
//    req.tokenType = @"";
//    SdkGetAddressBalance(req, self);
    
}

//MARK:ApiGetAddressBalanceCallback
- (void)success:(ApiGetAddressBalanceResponse *)p0{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        DLog(@"请求返回的cointype：%@ tokenType:%@ address:%@ balance:%@", p0.coinType, p0.tokenType, p0.address, p0.balanceAmount);
        NSString *defaultWallet = (NSString *)[PTool getValueFromKey:@"defaultWalletAddress"];
        NSArray *arr = [Coin MR_findByAttribute:@"wallet_id" withValue:defaultWallet];
        for (Coin *coin in arr) {
            if ([p0.tokenType isEqualToString:@"USDT"] && [p0.coinType isEqualToString:@"BTC"]) {

                for (int i = 0; i < self.dataArr.count; i++) {
                    NSString *type = ((BaseModel *)self.dataArr[i]).type;
                    NSString *coin_tag = ((BaseModel *)self.dataArr[i]).coinTag;
                    if ([type isEqualToString:coin.name]&&[coin_tag isEqualToString:@"OMNI"]&&[coin.coin_tag isEqualToString:@"OMNI"]) {
                        ((BaseModel *)self.dataArr[i]).balance = [PTool removeFloatAllZeroByString:p0.balanceAmount];
                        coin.balance = [PTool removeFloatAllZeroByString:p0.balanceAmount];
                        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                        [self getExchangeRate];
                    }
                }
            }else if ([p0.tokenType isEqualToString:@"USDT"] && [p0.coinType isEqualToString:@"ETH"]){
                
                for (int i = 0; i < self.dataArr.count; i++) {
                    NSString *type = ((BaseModel *)self.dataArr[i]).type;
                    NSString *coin_tag = ((BaseModel *)self.dataArr[i]).coinTag;
                    if ([type isEqualToString:coin.name] && [coin_tag isEqualToString:@"ERC20"]&&[coin.coin_tag isEqualToString:@"ERC20"]) {
                        ((BaseModel *)self.dataArr[i]).balance = [PTool removeFloatAllZeroByString:p0.balanceAmount];
                        coin.balance = [PTool removeFloatAllZeroByString:p0.balanceAmount];
                        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                        [self getExchangeRate];
                    }
                }
            }else{
                if ([coin.name isEqualToString:p0.coinType] && [coin.address isEqualToString:p0.address]) {
                    for (int i = 0; i < self.dataArr.count; i++) {
                        NSString *type = ((BaseModel *)self.dataArr[i]).type;
                        if ([type isEqualToString:coin.name]) {
                            if ([p0.coinType isEqualToString:@"ETH"]){
                                
                                NSDecimalNumber *balanceD = [NSDecimalNumber decimalNumberWithString:[PTool removeFloatAllZeroByString:p0.balanceAmount]];
                                NSDecimalNumber *transBalanceD = [balanceD decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:ETHTOWEI]];
                                ((BaseModel *)self.dataArr[i]).balance = [NSString stringWithFormat:@"%@", transBalanceD];
                                coin.balance = [NSString stringWithFormat:@"%@", transBalanceD];
                                [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                            }else{
                                
                                ((BaseModel *)self.dataArr[i]).balance = [PTool removeFloatAllZeroByString:p0.balanceAmount];
                                coin.balance = [PTool removeFloatAllZeroByString:p0.balanceAmount];
                                [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                            }
                            [self getExchangeRate];
                        }
                    }
                }
            }
        }
    });
}

- (void)failure:(NSError *)err{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        DLog(@"获取余额失败");
        [self.tableView.mj_header endRefreshing];
    });
}

//MARK:是否展示资产
- (IBAction)showBlance:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        
        [sender setImage:[UIImage imageNamed:@"icon_eye_off"] forState:UIControlStateNormal];
        self.balanceLabel.text = @"*****";
        self.equalLabel.hidden = YES;
        self.currencyImgView.hidden = YES;
        self.balanceToLeftConstraint.constant = 30;
        
        [self.dataArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ((BaseModel *)self.dataArr[idx]).hidden = @"YES";
        }];
    }else{
        
        [sender setImage:[UIImage imageNamed:@"icon_eye_on"] forState:UIControlStateNormal];
        self.balanceLabel.text = self.totalTransBalanceStr;
        self.equalLabel.hidden = NO;
        self.currencyImgView.hidden = NO;
        self.balanceToLeftConstraint.constant = 73;
        [self.dataArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ((BaseModel *)self.dataArr[idx]).hidden = @"NO";
        }];
    }
    [self.tableView reloadData];
}

//MARK:开始备份
- (IBAction)backupAction:(UIButton *)sender {
    
    NSString *defaultWallet = (NSString *)[PTool getValueFromKey:@"defaultWalletAddress"];
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    PwdInputView *inputView = [[PwdInputView alloc] initWithFrame:keyWindow.bounds];
    inputView.titleLabel.text = Localized(@"输入钱包密码");
    inputView.inputString = ^(NSString * _Nonnull str) {
        
        NSString *pwdStr = [PTool getWalletInfo:defaultWallet Type:@"password"];
        if ([str isEqualToString:[SecurityUtil decryptAESData:pwdStr]]) {
            
            MnemonicVC *mnemonicVC = [MnemonicVC new];
            mnemonicVC.backupConfig = @"comeFromHome";
            mnemonicVC.wallet_id = defaultWallet;
            [self.navigationController pushViewController:mnemonicVC animated:YES];
        }else{
            [LSStatusBarHUD showMessageAndImage:Localized(@"密码错误")];
        }
    };
    [keyWindow addSubview:inputView];
}

//MARK:移除备份提醒
- (IBAction)removeTips:(UIButton *)sender {
    
    
    [UIView animateWithDuration:.3 animations:^{
            
        self.tipsView.transform = CGAffineTransformMakeTranslation(-KScreenWidth, 0);
//        self.tipsView.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        self.tipsViewHeightConstraint.constant = 0;
    }];
}

//MARK:管理钱包
- (IBAction)showLeft:(id)sender {
    
    PWS(weakSelf);
    
    WalletSettingVC *setting = [[WalletSettingVC alloc] init];
    CreateWalletVC *createNewWallet = [CreateWalletVC new];
    ImportViewController *importWallet = [ImportViewController new];
    
//    createNewWallet.navigationController.navigationBar.hidden = YES;
//    importWallet.navigationController.navigationBar.hidden = YES;
//    setting.navigationController.navigationBar.hidden = YES;
    createNewWallet.type = ComeFromCreating;
    
    
    LeftViewController *left = [[LeftViewController alloc] init];
    left.selectedWallet = ^(NSString * _Nonnull walletName, NSString * _Nonnull type) {
        if ([type isEqualToString:@"changeWallet"]) {
            
            [weakSelf.walletNameBtn setTitle:[NSString stringWithFormat:@" %@", walletName] forState:UIControlStateNormal];
            [self getHomeData];
            [self isShowBackUpTips];
        }else if ([type isEqualToString:@"createWallet"]){

            [self.navigationController pushViewController:createNewWallet animated:YES];
        }else if ([type isEqualToString:@"importWallet"]){
            
            [self.navigationController pushViewController:importWallet animated:YES];
        }else if ([type isEqualToString:@"管理AECO"]){
            
            setting.type = @"AECO";
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            setting.wallet_id = walletName;
            
            [weakSelf.navigationController pushViewController:setting animated:YES];
        } else{
            
            NSArray *arr = [Wallet MR_findByAttribute:@"wallet_id" withValue:walletName];
            for (Wallet *wallet in arr) {
                setting.type = wallet.type;
            }
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            setting.wallet_id = walletName;
            
            [weakSelf.navigationController pushViewController:setting animated:YES];
        }
    };
    
    CWLateralSlideConfiguration *config = [CWLateralSlideConfiguration defaultConfiguration];
    config.distance = 0.82*KScreenWidth;
    [self cw_showDrawerViewController:left animationType:CWDrawerAnimationTypeDefault configuration:config];
}

//MARK:添加币种
- (IBAction)addCurrencyAction:(UIButton *)sender {
    
    SearchViewController *searchVC = [SearchViewController new];
    NSString *defaultWalletID = (NSString *)[PTool getValueFromKey:@"defaultWalletAddress"];
    searchVC.wallet_id = defaultWalletID;
    searchVC.addCoinBlock = ^(BOOL success) {
        if (success) {
            [self getHomeData];
        }
    };
    
    NSArray *arr = [Coin MR_findByAttribute:@"name" withValue:@"ETH"];
    for (Coin *coin in arr) {
        if ([coin.wallet_id isEqualToString:defaultWalletID]) {
            searchVC.addressStr = coin.address;
            searchVC.keyIDStr = coin.key_id;
        }
    }
    
    [self.navigationController pushViewController:searchVC animated:NO];
}


//MARK:开启扫码
- (IBAction)qrcodeAction:(UIButton *)sender {
    [PTool isCamCanOpenWithBlock:^(BOOL canOpen) {
        if (canOpen) {
            ScanViewController *codeVC = [[ScanViewController alloc] init];
            [self.navigationController pushViewController:codeVC animated:YES];
        }
    }];
}

//MARK:UITableViewDelegate, UITableViewDataSource

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == self.dataArr.count) {
        return YES;
    }
    NSString *type = [NSString stringWithFormat:@"%@", ((BaseModel *)self.dataArr[indexPath.row]).coinTag];
    if ([type isEqualToString:@"ERC20"]) {
        return YES;
    }
    return NO;
}
// 定义编辑样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

// 进入编辑模式，按下出现的编辑按钮后,进行删除操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.dataArr.count == indexPath.row) {
        NSString *statusStr = (NSString *)[PTool getValueFromKey:logStatus];
        if (![statusStr isEqualToString:@"YES"]) {
            [self clickTafAction];
            return;
        }
        [PTool saveValue:@"error" forKey:@"emailAddr"];
        [PTool saveValue:@"error" forKey:@"token"];
        [PTool saveValue:@"NO" forKey:logStatus];
        return;
    }
    NSString *coinTag = [NSString stringWithFormat:@"%@", ((BaseModel *)self.dataArr[indexPath.row]).coinTag];
    NSString *type = [NSString stringWithFormat:@"%@", ((BaseModel *)self.dataArr[indexPath.row]).type];
    NSString *defaultWallet = (NSString *)[PTool getValueFromKey:@"defaultWalletAddress"];
    
    if ([coinTag isEqualToString:@"ERC20"]) {
        
        [LSStatusBarHUD showLoading:Localized(@"正在删除...")];
        
        NSArray *arr = [Coin MR_findByAttribute:@"wallet_id" withValue:defaultWallet];
        for (Coin *coin in arr) {
            if ([coin.name isEqualToString:type] && [coin.coin_tag isEqualToString:@"ERC20"]) {
                [coin MR_deleteEntity];
            }
        }
        
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        
        [LSStatusBarHUD showMessage:Localized(@"删除成功")];
        
        [self getHomeData];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.dataArr.count == indexPath.row) {
        
        NSString *statusStr = (NSString *)[PTool getValueFromKey:logStatus];
        if (![statusStr isEqualToString:@"YES"]) {
            return Localized(@"loginStr");
        }
        return Localized(@"logoutStr");
    }
    return Localized(@"删除");
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return self.dataArr.count+1;
    return self.dataArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
//    return 2;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HomeCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"HomeCellID" forIndexPath:indexPath];

//    if (indexPath.row == self.dataArr.count) {
//
//        [cell.currencyTypeImgView setImage:[UIImage imageNamed:@"icon_taf"]];
//        cell.typeLabel.text = @"TAF";
////        cell.balanceLabel.text = self.tafBalanceStr;
////        cell.transBalanceLabel.text = self.tafTransBalanceStr;
//        cell.balanceLabel.hidden = YES;
//        cell.transBalanceLabel.hidden = YES;
//        cell.tagImgView.hidden = YES;
//        cell.transCurrencyTypeImgView.hidden = YES;
//    }else{
//
//        cell.balanceLabel.hidden = NO;
//        cell.transBalanceLabel.hidden = NO;
//        cell.tagImgView.hidden = NO;
//        cell.transCurrencyTypeImgView.hidden = NO;
//        cell.model = self.dataArr[indexPath.row];
//    }
    
    cell.balanceLabel.hidden = NO;
    cell.transBalanceLabel.hidden = NO;
    cell.tagImgView.hidden = NO;
    cell.transCurrencyTypeImgView.hidden = NO;
    cell.model = self.dataArr[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (indexPath.row == self.dataArr.count) {
////        CommonWebViewController *web = [[CommonWebViewController alloc] init];
////        web.webUrl = @"http://192.168.0.60:9009";
////        [self.navigationController pushViewController:web animated:YES];
//        [self clickTafAction];
//        return;
//    }
    
    NSString *type = [NSString stringWithFormat:@"%@", ((BaseModel *)self.dataArr[indexPath.row]).type];
    NSString *address = [NSString stringWithFormat:@"%@", ((BaseModel *)self.dataArr[indexPath.row]).address];
    NSString *imageStr = [NSString stringWithFormat:@"%@", ((BaseModel *)self.dataArr[indexPath.row]).image];
    NSString *contactAddressStr = [NSString stringWithFormat:@"%@", ((BaseModel *)self.dataArr[indexPath.row]).contactAddress];
    NSString *keyIDStr = [NSString stringWithFormat:@"%@", ((BaseModel *)self.dataArr[indexPath.row]).keyID];
    NSString *coinTagStr = [NSString stringWithFormat:@"%@", ((BaseModel *)self.dataArr[indexPath.row]).coinTag];
    NSString *balanceStr = [NSString stringWithFormat:@"%@", ((BaseModel *)self.dataArr[indexPath.row]).balance];
    
    if ([coinTagStr isEqualToString:@"ERC20"]) {
        return;
    }
    
    TransInfoViewController *trans = [TransInfoViewController new];
    trans.currencyType = type;
    trans.addressStr = address;
    trans.imageStr = imageStr;
    trans.contactAddressStr = contactAddressStr;
    trans.keyIDString = keyIDStr;
    trans.coinTagString = coinTagStr;
    trans.balanceString = balanceStr;
    [self.navigationController pushViewController:trans animated:YES];
}

//MARK:LAZY
- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}
- (NSMutableArray *)rateArr{
    if (!_rateArr) {
        _rateArr = [NSMutableArray array];
    }
    return _rateArr;
}

#pragma mark - 版本更新提示
-(void)checkVersion {

    PWS(weakSelf);

    NSString *url = [NSString stringWithFormat:@"%@/wallet/version/upgrade", [PTool getValueFromKey:walletHttpAPI]];

    NSString *current_version =  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSDictionary *dic = @{
        @"device_type":@2,
        @"current_version":current_version
    };
    [[PHTTPClient shareInstance] bodyRequestMethod:METHOD_POST parameters:dic url:url success:^(id _Nonnull responseObject) {
        
        NSInteger code = [[responseObject objectForKey:@"code"] intValue];
        if (code == 0) {
            NSString *content       = [NSString stringWithFormat:@"%@", [[responseObject objectForKey:@"data"] objectForKey:@"content"]];
            NSString *app_link      = [NSString stringWithFormat:@"%@", [[responseObject objectForKey:@"data"] objectForKey:@"app_link"]];
            NSString *last_version  = [NSString stringWithFormat:@"%@", [[responseObject objectForKey:@"data"] objectForKey:@"last_version"]];
            NSString *force_upgrade = [NSString stringWithFormat:@"%@", [[responseObject objectForKey:@"data"] objectForKey:@"force_upgrade"]];
            
            DLog(@"升级接口返回版本：%@", last_version);
            
            if (![last_version isEqualToString:current_version]) {//需要升级
                
                if ([force_upgrade isEqualToString:@"0"]) {//0:常规升级 1：强制升级
                    
                    [weakSelf showUpdataViewWithForceUpdate:NO UpdateContent:content Version:last_version UpgradeUrl:app_link];
                }else{
                    
                    [weakSelf showUpdataViewWithForceUpdate:YES UpdateContent:content Version:last_version UpgradeUrl:app_link];
                }
            }
        }else{
            DLog(@"升级接口：%@", [responseObject objectForKey:@"msg"]);
        }
    } failure:^(NSError * _Nonnull error) {
        
        DLog(@"升级接口获取失败：%@", error.localizedDescription);
    }];
}

- (void)showUpdataViewWithForceUpdate:(BOOL)force UpdateContent:(NSString *)content Version:(NSString *)version UpgradeUrl:(NSString *)url{

    UpdateView *updateView = [[UpdateView alloc] initWithFrame:self.view.window.bounds];

    updateView.upgradeUrl = url;

    updateView.isForceUpdate = force;

    updateView.versionLabel.text = [NSString stringWithFormat:@"V%@", version];

    updateView.contentTextView.text = content;

    [self.view.window addSubview:updateView];
}

//MARK:获取汇率
- (void)getExchangeRate{
    
    [self.tableView reloadData];
    
    //获取所有币名称
    NSMutableArray *rateCoinArr = [NSMutableArray array];
    NSString *defaultWallet = (NSString *)[PTool getValueFromKey:@"defaultWalletAddress"];
    NSArray *arr = [Coin MR_findByAttribute:@"wallet_id" withValue:defaultWallet];
    for (Coin *coin in arr) {
        if (![coin.name isEqualToString:@"AECO"]) {
            
            [rateCoinArr addObject:coin.name];
        }
    }
    if (rateCoinArr.count < 1) {
        return;
    }
    
    //将币拼接成请求链接
    NSString *url = [NSString stringWithFormat:@"%@/wallet/market/tokenticker?", (NSString *)[PTool getValueFromKey:walletHttpAPI]];
    for (int i = 0; i < rateCoinArr.count; i++) {
        url = [NSString stringWithFormat:@"%@&id=%@", url, rateCoinArr[i]];
    }
    
    DLog(@"汇率请求URL = %@", url);
    
    PWS(weakSelf);
    [self.rateArr removeAllObjects];
    
    [[PHTTPClient shareInstance] requestMethod:METHOD_GET parameters:@{} url:url success:^(id  _Nonnull responseObject) {
        
        [weakSelf.tableView.mj_header endRefreshing];
        NSInteger code = [[responseObject objectForKey:@"code"] intValue];
        if (0 == code) {
            
            DLog(@"获取汇率成功");
            NSArray *list = [[responseObject objectForKey:@"data"] objectForKey:@"list"];
            if ([PTool isArray:list] && list.count > 0) {
                
                for (NSDictionary *dic in list) {
                    
                    BaseModel *model = [[BaseModel alloc] initWithDictionary:dic error:nil];
                    [weakSelf.rateArr addObject:model];
                }
            }
            if (weakSelf.rateArr.count > 0) {
                [weakSelf showBalance];
            }
        }else{
            
            DLog(@"获取汇率失败");
//            [weakSelf showHomeData];
        }
    } failure:^(NSError * _Nonnull error) {
        
//        [weakSelf showHomeData];
        [weakSelf.tableView.mj_header endRefreshing];
        DLog(@"获取汇率失败");
    }];
}

- (void)showHomeData{
    
    NSString *defaultWallet = (NSString *)[PTool getValueFromKey:@"defaultWalletAddress"];
    
    NSArray *subCoinArr = [Coin MR_findByAttribute:@"wallet_id" withValue:defaultWallet];
    
    BOOL isSupportERC20 = NO;
    
    [self.dataArr removeAllObjects];
    
    for (int i = 0; i < subCoinArr.count; i++) {
        
        NSString *coinNameStr = ((Coin *)subCoinArr[i]).name;
        if ([coinNameStr isEqualToString:@"ETH"]) {
            isSupportERC20 = YES;
        }
#warning remove AECO Coin
        if (![coinNameStr isEqualToString:@"AECO"]) {
            
            BaseModel *model = [[BaseModel alloc] init];
            model.hidden = @"NO";
            model.imgName = [NSString stringWithFormat:@"icon_%@", [((Coin *)subCoinArr[i]).name lowercaseString]];
            model.transBalance = @"0";
            model.balance = [NSString stringWithFormat:@"%@", ((Coin *)subCoinArr[i]).balance];
            model.type = coinNameStr;
            model.address = ((Coin *)subCoinArr[i]).address;
            model.coinTag = ((Coin *)subCoinArr[i]).coin_tag;
            model.image = ((Coin *)subCoinArr[i]).image;
            model.contactAddress = ((Coin *)subCoinArr[i]).contact_address;
            model.keyID = ((Coin *)subCoinArr[i]).key_id;
            [self.dataArr addObject:model];
        }
    }
    [self.tableView reloadData];
}

//MARK:计算所选择汇率后的余额
- (void)showBalance{
    
    for (int i = 0; i < self.dataArr.count; i++) {
        
        NSString *type = [NSString stringWithFormat:@"%@", ((BaseModel *)self.dataArr[i]).type];
        NSString *balance = [NSString stringWithFormat:@"%@", ((BaseModel *)self.dataArr[i]).balance];
        NSDecimalNumber *balanceD = [NSDecimalNumber decimalNumberWithString:[balance containsString:@"null"]?@"0":balance];
        
        for (int j = 0; j < self.rateArr.count; j++) {
            
            NSString *symbol = [((BaseModel *)self.rateArr[j]).symbol uppercaseString];
            NSString *usdStr = ((BaseModel *)self.rateArr[j]).price_usd;
            NSString *cnyStr = ((BaseModel *)self.rateArr[j]).price_cny;
            NSString *eurStr = ((BaseModel *)self.rateArr[j]).price_eur;
            NSDecimalNumber *priceUSD = [NSDecimalNumber decimalNumberWithString:usdStr];
            NSDecimalNumber *priceCNY = [NSDecimalNumber decimalNumberWithString:cnyStr];
            NSDecimalNumber *priceEUR = [NSDecimalNumber decimalNumberWithString:eurStr];
            
            if ([type isEqualToString:symbol]) {//当前币=当前币汇率，计算当前余额
                
                NSString *selectedCurrencyUnit = (NSString *)[PTool getValueFromKey:@"selectedCurrencyUnit"];
                NSDecimalNumber *transBalance;
                
                if ([selectedCurrencyUnit isEqualToString:@"CNY"]) {
                    
                    transBalance = [balanceD decimalNumberByMultiplyingBy:priceCNY];
                }else if ([selectedCurrencyUnit isEqualToString:@"EUR"]){
                    
                    transBalance = [balanceD decimalNumberByMultiplyingBy:priceEUR];
                }else if ([selectedCurrencyUnit isEqualToString:@"USD"]){
                    
                    transBalance = [balanceD decimalNumberByMultiplyingBy:priceUSD];
                }
                
                NSString *transBalanceStr = [NSString stringWithFormat:@"%@", transBalance];
                ((BaseModel *)self.dataArr[i]).transBalance = [PTool notRounding:transBalanceStr afterPoint:2];
            }
        }
    }
    
    NSDecimalNumber *totalTransBlanceD = [NSDecimalNumber decimalNumberWithString:@"0"];
    
    for (int i = 0; i < self.dataArr.count; i++) {
        NSString *transBalanceStr = ((BaseModel *)self.dataArr[i]).transBalance;
        totalTransBlanceD = [totalTransBlanceD decimalNumberByAdding:[NSDecimalNumber decimalNumberWithString:transBalanceStr]];
    }
    
    NSString *transBalanceStr = [NSString stringWithFormat:@"%@", totalTransBlanceD];
    self.totalTransBalanceStr = [PTool notRounding:transBalanceStr afterPoint:2];
    
    if (!self.showBalanceBtn.selected) {
        
        self.balanceLabel.text = self.totalTransBalanceStr;
    }
    [self.tableView reloadData];
}

#warning 增加 Taf APP功能
- (void)clickTafAction{
    
    NSString *statusStr = (NSString *)[PTool getValueFromKey:logStatus];
    if (![statusStr isEqualToString:@"YES"]) {
        
        PJAlert *alert = [[PJAlert alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds Title:Localized(@"请先登录") Content:@"" Confirm:Localized(@"确定")];
        alert.showTwoBtn = YES;
        alert.titleHidden = NO;
        [alert.cancelBtn setTitle:Localized(@"loginStr") forState:UIControlStateNormal];
        alert.confirm = ^(BOOL confirm) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PRESENTTAFLOGIN object:nil];
        };
        [[UIApplication sharedApplication].keyWindow addSubview:alert];
        
        return;
    }
    
    Class PerSaleVC = NSClassFromString(@"MyPerSaleVC");
    [self.navigationController pushViewController:[PerSaleVC new] animated:YES];
}

//MARK:查询未订阅的地址进行订阅
- (void)subscriptionAction{
    
    NSArray *arr = [Coin MR_findAll];
    NSMutableArray *subscriptionArr = [NSMutableArray array];
    
    for (Coin *coin in arr) {
        if (!coin.is_backup) {//去除已备份的
            if (![coin.name isEqualToString:@"AECO"]) {//去除掉AECO
                if ([coin.name isEqualToString:@"USDT"] && [coin.coin_tag isEqualToString:@"OMNI"]) {
                    
                    [subscriptionArr addObject:@{@"coinType":@"USDT_OMNI", @"address":coin.address}];
                }else if ([coin.name isEqualToString:@"USDT"] && [coin.coin_tag isEqualToString:@"ERC20"]) {
                    
                    [subscriptionArr addObject:@{@"coinType":@"USDT_ERC20", @"address":coin.address}];
                }else{
                    
                    [subscriptionArr addObject:@{@"coinType":coin.name, @"address":coin.address}];
                }
            }
        }
    }
    
    if (subscriptionArr.count < 1) {
        DLog(@"无可订阅的地址");
        return;
    }
//    [self updateBackup:subscriptionArr];
//    return;
    NSString *url = [NSString stringWithFormat:@"%@/wallet/subscription/coin", (NSString *)[PTool getValueFromKey:walletHttpAPI]];
    PWS(weakSelf);
    NSDictionary *dic = @{@"coins":subscriptionArr};
    [[PHTTPClient shareInstance] bodyRequestMethod:METHOD_POST parameters:dic url:url success:^(id _Nonnull responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] intValue];
        if (code == 0) {
            DLog(@"订阅成功：%@", subscriptionArr);
            [weakSelf updateBackup:subscriptionArr];
        }
    } failure:^(NSError * _Nonnull error) {
        DLog(@"订阅失败%@", error.localizedDescription);
    }];
}

//订阅完成 更新本地数据库
- (void)updateBackup:(NSMutableArray *)arr{
    
    NSArray *allCoin = [Coin MR_findAll];
    
    for (Coin *coin in allCoin) {
        
        for (int i = 0; i < arr.count; i++) {
            
            NSString *address = [arr[i] objectForKey:@"address"];
            NSString *coinType = [arr[i] objectForKey:@"coinType"];
            
            if ([coinType isEqualToString:@"USDT_OMNI"]) {
                
                if ([coin.address isEqualToString:address] && [coin.name isEqualToString:@"USDT"]&&[coin.coin_tag isEqualToString:@"OMNI"]) {
                    
                    coin.is_backup = YES;
                    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                }
            }else if ([coinType isEqualToString:@"USDT_ERC20"]) {

                if ([coin.address isEqualToString:address] && [coin.name isEqualToString:@"USDT"]&&[coin.coin_tag isEqualToString:@"ERC20"]) {
                    
                    coin.is_backup = YES;
                    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                }
            }
            if ([coin.address isEqualToString:address] && [coin.name isEqualToString:coinType]) {
                coin.is_backup = YES;
                [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            }
        }
    }
}

@end
