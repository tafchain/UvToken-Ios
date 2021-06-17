//
//  HomeViewController.m
//  Blockchain Wallet
//
//  Created by Panerly on 2021/4/13.
//

#import "HomeViewController.h"
#import "HomeHeaderView.h"
#import "HomeSectionView.h"
#import "UIViewController+CWLateralSlide.h"
#import "LeftViewController.h"
#import "QRCodeResultVC.h"
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
#import "CommonWebViewController.h"
#import "BackupTipsView.h"

@interface HomeViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    HomeHeaderView *_homeHeader;
    NSInteger flagCount;//当余额请求数量达到币的个数的时候再去调用汇率接口
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) NSMutableArray *rateArr;
@property (nonatomic, strong) NSString *totalTransBalanceStr;
@property (nonatomic, strong) NSString *tafBalanceStr;
@property (nonatomic, strong) NSString *tafTransBalanceStr;
@property (nonatomic, assign) BOOL networkAvailable;
@property (nonatomic, assign) BOOL showBackupTips;
@property (nonatomic, assign) BOOL isSupportERC20;

@end

@implementation HomeViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.edgesForExtendedLayout = UIRectEdgeAll;
    
#warning 仅测试库使用，正式服不要使用
    //数据库删除
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name=%@", @"trx"];
//    [Wallet MR_deleteAllMatchingPredicate:predicate];
//    [Coin MR_deleteAllMatchingPredicate:predicate];
//    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (self.dataArr.count > 0) {
        
        [self getWalletBalance];
    }
    [self subscriptionAction];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self getHomeData];
    [self setUI];
    [self performSelector:@selector(checkVersion) withObject:self afterDelay:1];
    [self isShowBackUpTips];
    [self addNotification];
}

- (void)addNotification{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUI) name:CHANGELANGUAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getHomeData) name:LOGINSELECTCENTERINDEX object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getHomeData) name:CHANGECURRENCY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isShowBackUpTips) name:CHANGEWALLET object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectWalletAction:) name:@"SELECTETHWALLETNOTI" object:nil];
}

- (void)setUI{
    
    [self isShowBackUpTips];
    
    self.totalTransBalanceStr = @"";
    self.tafBalanceStr = @"0";
    self.tafTransBalanceStr = @"0";
    self.title = Localized(@"钱包");
    
    [self.tableView registerNib:[UINib nibWithNibName:@"HomeCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"HomeCellID"];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getHomeData)];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    
    [self getNetworkStatusInfo];
    CGFloat statusHeight = [PTool getStatusBarHight];
    self.tableViewToTop.constant = - statusHeight;
    self.toolViewToHeight.constant = 44+statusHeight;
    [self.tableView reloadData];
    
    
    //兼容旧数据 增加默认值：change index coin account
    NSArray *arr = [Coin MR_findAll];
    if (arr.count > 0) {
        [[PWallet shareInstance] compatibleOldData];
    }
}

- (void)getNetworkStatusInfo{
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    PWS(weakSelf);
    [[AFNetworkReachabilityManager sharedManager ] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
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
        if(status == AFNetworkReachabilityStatusReachableViaWWAN || status == AFNetworkReachabilityStatusReachableViaWiFi){
            NSLog(@"有网");
            weakSelf.networkAvailable = YES;
            [weakSelf.tableView reloadData];
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:Localized(@"设备已离线") message:Localized(@"网络已断开，请检查网络链接。") delegate:self cancelButtonTitle:Localized(@"知道了") otherButtonTitles:nil, nil];
            [alert show];
            weakSelf.networkAvailable = NO;
            [weakSelf.tableView reloadData];
        }
    }];
}

//判断钱包是否备份
- (void)isShowBackUpTips{
    
    NSString *defaultWallet = (NSString *)[PTool getValueFromKey:@"defaultWalletAddress"];
    NSArray *selectedArr = [Wallet MR_findByAttribute:@"wallet_id" withValue:defaultWallet];
    for (Wallet *wallet in selectedArr) {
        if (!wallet.is_backup && [wallet.type isEqualToString:@"Multi"]) {
            self.showBackupTips = YES;
        }else{
            self.showBackupTips = NO;
        }
    }
    if (selectedArr.count < 1) {
        
        self.showBackupTips = NO;
    }
    [self.tableView reloadData];
}

//MARK:获取当前钱包信息
- (void)getHomeData{
    
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
        if ([coinNameStr isEqualToString:@"ETH"] || [coinNameStr isEqualToString:@"TRX"]) {
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
            model.decimals = ((Coin *)subCoinArr[i]).decimals;
            [self.dataArr addObject:model];
        }
    }
    self.isSupportERC20 = isSupportERC20;
    if (self.dataArr.count < 1) {
        
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
        return;
    }
    
    [self.tableView reloadData];
    [self.tableView.mj_header endRefreshing];
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
    
    flagCount = 0;
    
    for (Coin *coin in arr) {
        
        NSString *coinType = @"";
        NSString *tokenType = @"";
        NSString *tokenAddress = @"";
        
        if ([coin.name isEqualToString:@"BTC"]) {
            coinType = coin.name;
        }else if ([coin.name isEqualToString:@"ETH"]) {
            coinType = @"ETH";
        }else if ([coin.name isEqualToString:@"TRX"]) {
            coinType = @"TRX";
        }else{
            if ([coin.coin_tag isEqualToString:@"OMNI"]) {
                
                tokenType = @"USDT";
                coinType = @"BTC";
            }else if ([coin.coin_tag isEqualToString:@"ERC20"]){
                
                tokenType = coin.name;
                coinType = @"ETH";
                tokenAddress = coin.contact_address;
            }else if ([coin.coin_tag isEqualToString:@"TRC20"]){
                
                tokenType = coin.name;
                coinType = @"TRX";
                tokenAddress = coin.contact_address;
            }
        }
        
        DLog(@"需要请求的币的余额：address:%@----tokenAddress:%@----coinType:%@----tokenType:%@",coin.address, tokenAddress, coinType, tokenType);
        PWS(weakSelf);
        [[PWallet shareInstance] getWalletBalanceWithAddress:coin.address TokenAddress:tokenAddress CoinType:coinType TokenType:tokenType response:^(AddCoinModel * _Nonnull response) {
            
            DLog(@"请求返回的cointype：%@ tokenType:%@ address:%@ balance:%@", response.coinType, response.tokenType, response.address, response.balanceAmount);
            NSString *defaultWallet = (NSString *)[PTool getValueFromKey:@"defaultWalletAddress"];
            NSArray *arr = [Coin MR_findByAttribute:@"wallet_id" withValue:defaultWallet];
            for (Coin *coin in arr) {
                if ([response.tokenType isEqualToString:@"USDT"] && [response.coinType isEqualToString:@"BTC"]) {//btc的usdt代币
                    for (int i = 0; i < self.dataArr.count; i++) {
                        NSString *type = ((BaseModel *)self.dataArr[i]).type;
                        NSString *coin_tag = ((BaseModel *)self.dataArr[i]).coinTag;
                        if ([type isEqualToString:coin.name]&&[coin_tag isEqualToString:@"OMNI"]&&[coin.coin_tag isEqualToString:@"OMNI"]) {
                            ((BaseModel *)self.dataArr[i]).balance = [PTool removeFloatAllZeroByString:response.balanceAmount];
                            coin.balance = [PTool removeFloatAllZeroByString:response.balanceAmount];
                            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                        }
                    }
                }else if ([response.tokenType isEqualToString:@"USDT"] && [response.coinType isEqualToString:@"ETH"]){//ETH的usdt代币
                    
                    for (int i = 0; i < self.dataArr.count; i++) {
                        NSString *type = ((BaseModel *)self.dataArr[i]).type;
                        NSString *coin_tag = ((BaseModel *)self.dataArr[i]).coinTag;
                        NSString *decimals = ((BaseModel *)self.dataArr[i]).decimals;
                        if ([type isEqualToString:coin.name] && [coin_tag isEqualToString:@"ERC20"]&&[coin.coin_tag isEqualToString:@"ERC20"] && [response.tokenType isEqualToString:type]) {
                            
                            NSDecimalNumber *balanceD = [NSDecimalNumber decimalNumberWithString:response.balanceAmount];
                            for (int i = 0; i < [decimals integerValue]; i++) {
                                balanceD = [balanceD decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"10"]];
                            }
                            NSString *balanceString = [NSString stringWithFormat:@"%@", balanceD];
                            
                            ((BaseModel *)self.dataArr[i]).balance = [PTool removeFloatAllZeroByString:balanceString];
                            coin.balance = [PTool removeFloatAllZeroByString:balanceString];
                            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                        }
                    }
                }else if ([response.coinType isEqualToString:@"ETH"] && response.tokenType && response.tokenType.length > 0){//ERC20其他代币
                    DLog(@"ERC20代币：tokenType%@--balanceAmount%@--coinType%@", response.tokenType, response.balanceAmount, response.coinType);
                    for (int i = 0; i < self.dataArr.count; i++) {
                        NSString *type = ((BaseModel *)self.dataArr[i]).type;
                        NSString *coin_tag = ((BaseModel *)self.dataArr[i]).coinTag;
                        NSString *decimals = ((BaseModel *)self.dataArr[i]).decimals;
                        
                        if ([type isEqualToString:coin.name] && [coin_tag isEqualToString:@"ERC20"]&&[coin.coin_tag isEqualToString:@"ERC20"] && [response.tokenType isEqualToString:coin.name] && [response.address isEqualToString:coin.address]) {
                            DLog(@"要更改的行数据，列表type:%@--返回金额%@--返回tokenType%@", type, response.balanceAmount, response.tokenType);
                            NSDecimalNumber *balanceD = [NSDecimalNumber decimalNumberWithString:response.balanceAmount];
                            for (int i = 0; i < [decimals integerValue]; i++) {
                                balanceD = [balanceD decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"10"]];
                            }
                            NSString *balanceString = [NSString stringWithFormat:@"%@", balanceD];
                            ((BaseModel *)self.dataArr[i]).balance = [PTool removeFloatAllZeroByString:balanceString];
                            coin.balance = [PTool removeFloatAllZeroByString:balanceString];
                            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                        }
                    }
                }else if ([response.coinType isEqualToString:@"TRX"] && response.tokenType && response.tokenType.length > 0){//TRC20其他代币
                    DLog(@"TRC20代币：tokenType%@--balanceAmount%@--coinType%@", response.tokenType, response.balanceAmount, response.coinType);
                    for (int i = 0; i < self.dataArr.count; i++) {
                        NSString *type = ((BaseModel *)self.dataArr[i]).type;
                        NSString *coin_tag = ((BaseModel *)self.dataArr[i]).coinTag;
                        
                        if ([type isEqualToString:coin.name] && [coin_tag isEqualToString:@"TRC20"]&&[coin.coin_tag isEqualToString:@"TRC20"] && [response.tokenType isEqualToString:coin.name] && [response.address isEqualToString:coin.address]) {
                            DLog(@"要更改的行数据，列表type:%@--返回金额%@--返回tokenType%@", type, response.balanceAmount, response.tokenType);
                            NSString *balanceString = [NSString stringWithFormat:@"%@", response.balanceAmount];
                            ((BaseModel *)self.dataArr[i]).balance = [PTool removeFloatAllZeroByString:balanceString];
                            coin.balance = [PTool removeFloatAllZeroByString:balanceString];
                            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                        }
                    }
                }else{//主币余额
                    DLog(@"主币信息：coinType%@---balanceAmount%@---tokenType%@", response.coinType, response.balanceAmount, response.tokenType);
                    if ([coin.name isEqualToString:response.coinType] && [coin.address isEqualToString:response.address]) {
                        for (int i = 0; i < self.dataArr.count; i++) {
                            NSString *type = ((BaseModel *)self.dataArr[i]).type;
                            if ([type isEqualToString:coin.name]) {
                                if ([response.coinType isEqualToString:@"ETH"]){
                                    
                                    NSDecimalNumber *balanceD = [NSDecimalNumber decimalNumberWithString:[PTool removeFloatAllZeroByString:response.balanceAmount]];
                                    NSDecimalNumber *transBalanceD = [balanceD decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:ETHTOWEI]];
                                    ((BaseModel *)self.dataArr[i]).balance = [NSString stringWithFormat:@"%@", transBalanceD];
                                    coin.balance = [NSString stringWithFormat:@"%@", transBalanceD];
                                    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                                }else {
                                    
                                    ((BaseModel *)self.dataArr[i]).balance = [PTool removeFloatAllZeroByString:response.balanceAmount];
                                    coin.balance = [PTool removeFloatAllZeroByString:response.balanceAmount];
                                    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                                }
                            }
                        }
                    }
                }
            }
            self->flagCount++;
            if (self->flagCount>=weakSelf.dataArr.count) {
                [self getExchangeRate];
            }
        } failure:^(NSError * _Nonnull failure) {
            DLog(@"SDK查询余额失败:%@", failure.localizedDescription);
            self->flagCount++;
            if (self->flagCount>=weakSelf.dataArr.count) {
                [self getExchangeRate];
            }
            [self.tableView.mj_header endRefreshing];
        }];
    }
}

//MARK:UITableViewDelegate, UITableViewDataSource

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *type = [NSString stringWithFormat:@"%@", ((BaseModel *)self.dataArr[indexPath.row]).coinTag];
    if ([type isEqualToString:@"ERC20"]||[type isEqualToString:@"TRC20"]) {
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
    
    NSString *coinTag = [NSString stringWithFormat:@"%@", ((BaseModel *)self.dataArr[indexPath.row]).coinTag];
    NSString *type = [NSString stringWithFormat:@"%@", ((BaseModel *)self.dataArr[indexPath.row]).type];
    NSString *defaultWallet = (NSString *)[PTool getValueFromKey:@"defaultWalletAddress"];
    
    if ([coinTag isEqualToString:@"ERC20"] || [coinTag isEqualToString:@"TRC20"]) {
        
        [LSStatusBarHUD showLoading:Localized(@"正在删除...")];
        
        NSArray *arr = [Coin MR_findByAttribute:@"wallet_id" withValue:defaultWallet];
        for (Coin *coin in arr) {
            if ([coin.name isEqualToString:type] && [coin.coin_tag isEqualToString:coinTag]) {
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.showBackupTips) {
        return 3;
    }
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    }
    if (self.showBackupTips && section == 1) {
        return 0;
    }
    return self.dataArr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        if (kIsBangsScreen) {
            return 180;
        }
        return 150;
    }
    if (self.showBackupTips && section == 1) {
        CGFloat height = [PTool sizeWithText:Localized(@"安全提醒内容") font:[UIFont systemFontOfSize:11] maxSize:CGSizeMake(KScreenWidth-10*4, KScreenHeight)].height;
        return 10*2+14+5*2+height+30+14+14;
    }
    return 50;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        _homeHeader = [[HomeHeaderView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 180)];
        _homeHeader.backgroundColor = baseColor;
        _homeHeader.assetTitleLabel.text = Localized(@"资产总值");
        NSString *currency = (NSString *)[PTool getValueFromKey:@"selectedCurrencyUnit"];
        _homeHeader.currencyLabel.text = [NSString stringWithFormat:@"(%@)", currency];
        _homeHeader.networkStatusLabel.text = Localized(@"离线中");
        _homeHeader.networkStatusLabel.hidden = self.networkAvailable;
        PWS(weakSelf);
        NSString *showBalance = (NSString *)[PTool getValueFromKey:@"showBalance"];
        if ([showBalance isEqualToString:@"NO"]) {
            _homeHeader.balanceLabel.text = @"*****";
            [_homeHeader.showBlanceBtn setImage:[UIImage imageNamed:@"icon_eye_off"] forState:UIControlStateNormal];
        }else{
            _homeHeader.balanceLabel.text = [self showBalance];
            [_homeHeader.showBlanceBtn setImage:[UIImage imageNamed:@"icon_eye_on"] forState:UIControlStateNormal];
        }
        _homeHeader.showBalanceBlock = ^{
            
            [weakSelf.tableView reloadData];
        };
        
        return _homeHeader;
    }else if (section == 1 && self.showBackupTips){
        CGFloat height = [PTool sizeWithText:Localized(@"安全提醒内容") font:[UIFont systemFontOfSize:11] maxSize:CGSizeMake(KScreenWidth-10*4, KScreenHeight)].height;
        BackupTipsView *tipsView = [[BackupTipsView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 10*2+14+5*2+height+30+14+14)];
        PWS(weakSelf);
        tipsView.backupBlock = ^{
            [weakSelf backupWalletAction];
        };
        tipsView.closeBlock = ^{
            weakSelf.showBackupTips = NO;
            [weakSelf.tableView reloadData];
        };
        return tipsView;
    }
    HomeSectionView *header = [[HomeSectionView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 50)];
    PWS(weakSelf);
    if (!self.isSupportERC20) {
        header.addBtn.hidden = YES;
    }
    header.addBlock = ^{
        [weakSelf addCurrencyAction];
    };
    return header;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HomeCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"HomeCellID" forIndexPath:indexPath];
    cell.balanceLabel.hidden = NO;
    cell.transBalanceLabel.hidden = NO;
    cell.tagImgView.hidden = NO;
    cell.transCurrencyTypeImgView.hidden = NO;
    cell.model = self.dataArr[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *type = [NSString stringWithFormat:@"%@", ((BaseModel *)self.dataArr[indexPath.row]).type];
    NSString *address = [NSString stringWithFormat:@"%@", ((BaseModel *)self.dataArr[indexPath.row]).address];
    NSString *imageStr = [NSString stringWithFormat:@"%@", ((BaseModel *)self.dataArr[indexPath.row]).image];
    NSString *contactAddressStr = [NSString stringWithFormat:@"%@", ((BaseModel *)self.dataArr[indexPath.row]).contactAddress];
    NSString *keyIDStr = [NSString stringWithFormat:@"%@", ((BaseModel *)self.dataArr[indexPath.row]).keyID];
    NSString *coinTagStr = [NSString stringWithFormat:@"%@", ((BaseModel *)self.dataArr[indexPath.row]).coinTag];
    NSString *balanceStr = [NSString stringWithFormat:@"%@", ((BaseModel *)self.dataArr[indexPath.row]).balance];
    
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
- (void)tableView:(UITableView *)tableView willDisplayCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}
//渐变导航栏
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGFloat y = scrollView.contentOffset.y;
    if (y < -[PTool getStatusBarHight]) {//下拉刷新
        
        self.toolView.hidden = YES;
    }else{//向上滑动
        self.toolView.hidden = NO;
        self.toolView.backgroundColor = [UIColor colorWithDisplayP3Red:20/255.0f green:23/255.0f blue:41/255.0f alpha:(y+[PTool getStatusBarHight])/[PTool getStatusBarHight]];
    }
}

//MARK:备份钱包
- (void)backupWalletAction{
    
    NSString *defaultWallet = (NSString *)[PTool getValueFromKey:@"defaultWalletAddress"];
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    PwdInputView *inputView = [[PwdInputView alloc] initWithFrame:keyWindow.bounds];
    inputView.titleLabel.text = Localized(@"输入钱包密码");
    PWS(weakSelf);
    inputView.inputString = ^(NSString * _Nonnull str) {
        
        [LSStatusBarHUD showLoading:Localized(@"loadingStr")];
        [[PWallet shareInstance] verifyWalletPwdWithWalletID:defaultWallet Pwd:str valid:^(BOOL valid) {
            if (valid) {
                [LSStatusBarHUD hideLoading];
                MnemonicVC *mnemonicVC = [MnemonicVC new];
                mnemonicVC.backupConfig = @"comeFromHome";
                mnemonicVC.wallet_id = defaultWallet;
                mnemonicVC.pwdStr = str;
                [weakSelf.navigationController pushViewController:mnemonicVC animated:YES];
            }else{
                [LSStatusBarHUD showMessageAndImage:Localized(@"密码错误")];
            }
        }];
    };
    [keyWindow addSubview:inputView];
}
//MARK:添加币种
- (void)addCurrencyAction{
    
    SearchViewController *searchVC = [SearchViewController new];
    NSString *defaultWalletID = (NSString *)[PTool getValueFromKey:@"defaultWalletAddress"];
    searchVC.wallet_id = defaultWalletID;
    searchVC.addCoinBlock = ^(BOOL success) {
        if (success) {
            [self getHomeData];
        }
    };
    
    [self.navigationController pushViewController:searchVC animated:NO];
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

    NSString *url = [NSString stringWithFormat:@"%@v2/wallet/version/upgrade", [PTool getValueFromKey:walletHttpAPI]];

    NSString *current_version =  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *currentLanguage = (NSString *)[PTool getValueFromKey:@"appLanguage"];
    NSDictionary *dic = @{
        @"device_type":@2,
        @"current_version":current_version,
        @"lang_type":[currentLanguage isEqualToString:@"zh-Hans"]?@"cn":@"en"
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
        
        [weakSelf.rateArr removeAllObjects];
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
        }
    } failure:^(NSError * _Nonnull error) {
        [weakSelf.tableView.mj_header endRefreshing];
        DLog(@"获取汇率失败");
    }];
}

//MARK:计算所选择汇率后的余额
- (NSString *)showBalance{
    
    //筛选出来不支持的币 显示的时候做波浪
    __block NSMutableArray *difObject = [NSMutableArray arrayWithCapacity:0];
    if (self.dataArr.count > 0 && self.rateArr.count > 0) {//
        
        [self.dataArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            __block BOOL isHave = NO;
            
            for (BaseModel *model in self.rateArr) {
                if ([[model.symbol uppercaseString] isEqual:((BaseModel *)obj).type]) {
                    isHave = YES;
                }
            }
            if (!isHave) {
                //将不支持的币种添加到筛选数组中
                [difObject addObject:obj];
            }
        }];
    }
    
    for (int i = 0; i < self.dataArr.count; i++) {
        
        NSString *type = [NSString stringWithFormat:@"%@", ((BaseModel *)self.dataArr[i]).type];
        NSString *balance = [NSString stringWithFormat:@"%@", ((BaseModel *)self.dataArr[i]).balance];
        DLog(@"汇率计算：type:%@--余额:%@", type, balance);
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
    
    if (self.rateArr.count > 0 && difObject.count > 0) {
        //标记不支持的币种
        for (int i = 0; i < difObject.count; i++) {
            
            NSString *diffType = [NSString stringWithFormat:@"%@", ((BaseModel *)difObject[i]).type];
            for (int j = 0; j < self.dataArr.count; j++) {
                
                NSString *type = [NSString stringWithFormat:@"%@", ((BaseModel *)self.dataArr[j]).type];
                if ([diffType isEqualToString:type]) {
                    
                    ((BaseModel *)self.dataArr[j]).unsupportCoin = @"YES";
                }
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
    return self.totalTransBalanceStr;
}

//MARK:查询未订阅的地址进行订阅
- (void)subscriptionAction{
    
    NSArray *arr = [Coin MR_findAll];
    NSMutableArray *subscriptionArr = [NSMutableArray array];
    
    for (Coin *coin in arr) {
        
        if (!coin.is_backup && coin.address) {//去除已备份的
            
            if (![coin.name isEqualToString:@"AECO"]) {//去除掉AECO
                
                if ([coin.name isEqualToString:@"USDT"] && [coin.coin_tag isEqualToString:@"OMNI"]) {

                    [subscriptionArr addObject:@{@"coinType":@"USDT_OMNI", @"address":coin.address}];
                }else if ([coin.coin_tag isEqualToString:@"ERC20"] || [coin.name isEqualToString:@"ETH"]) {
                    
                    [subscriptionArr addObject:@{@"coinType":@"ETH", @"address":coin.address}];
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
        
        if (!coin.is_backup && ![coin.name isEqualToString:@"AECO"]) {
            
            coin.is_backup = YES;
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        }
    }
}
//MARK:打开所有钱包
- (IBAction)selectWalletAction:(UIButton *)sender {
    PWS(weakSelf);
    
    WalletSettingVC *setting = [[WalletSettingVC alloc] init];
    CreateWalletVC *createNewWallet = [CreateWalletVC new];
    ImportViewController *importWallet = [ImportViewController new];
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
//MARK:扫码
- (IBAction)scanAction:(UIButton *)sender {
    [PTool isCamCanOpenWithBlock:^(BOOL canOpen) {
        if (canOpen) {
            ScanViewController *codeVC = [[ScanViewController alloc] init];
            [self.navigationController pushViewController:codeVC animated:YES];
        }
    }];
}
@end
