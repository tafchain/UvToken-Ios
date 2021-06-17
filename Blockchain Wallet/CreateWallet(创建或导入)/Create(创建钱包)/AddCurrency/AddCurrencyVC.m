//
//  AddCurrencyVC.m
//  Blockchain Wallet
//
//  Created by Panerly on 2020/12/28.
//

#import "AddCurrencyVC.h"
#import "CurrencyModel.h"
#import "AddCurrencyCell.h"
#import "NewAddingCurrencyView.h"
#import "PTimer.h"
#import "BackupTipsVC.h"
#import "RepeatImportVC.h"
#import <walletsdk/Api.objc.h>
#import "SDKImportMnemonic.h"
#import "RepeatImportVC.h"
#import "SecurityUtil.h"

static NSString * const myTimer = @"creatingWalletTimer";

@interface AddCurrencyVC ()
<UITableViewDelegate, UITableViewDataSource>
{
    NewAddingCurrencyView *addingView;
    int creatingIndex;
    BOOL startAni;
}
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) NSMutableArray *imgArr;
@property (nonatomic, strong) NSMutableArray *addDataArr;
@property (nonatomic, strong) NSString *wallet_id;

@end

@implementation AddCurrencyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setUI];
    [self createData];
    startAni = NO;
}

- (void)setUI{
    
    self.titleLabel.text = Localized(@"添加币种");
    self.subTitleLabel.text = Localized(@"即将支持更多主链币种");
    [self.createBtn setTitle:Localized(@"创建") forState:UIControlStateNormal];
    
    [self.tableview registerNib:[UINib nibWithNibName:@"AddCurrencyCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"AddCurrencyCellID"];
}

- (IBAction)backAction:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createData{
    NSArray *name;
    NSArray *des;
    NSArray *icon;
    if ([AECOConfig isEqualToString:@"show"]) {
        
        name = @[@"BTC", @"ETH", @"TRX", @"AECO"];
        des  = @[@"Bitcoin", @"Ethereum", @"TRON", @"Arthur-ex"];
        icon = @[@"icon_btc", @"icon_eth", @"icon_trx", @"icon_aeco"];
    }else{
        
        name = @[@"BTC", @"ETH", @"TRX"];
        des  = @[@"Bitcoin", @"Ethereum", @"TRON"];
        icon = @[@"icon_btc", @"icon_eth", @"icon_trx"];
//        name = @[@"BTC", @"ETH"];
//        des  = @[@"Bitcoin", @"Ethereum"];
//        icon = @[@"icon_btc", @"icon_eth"];
    }
    
    //从搜索添加更多币种而来
    if (self.comeFromeAddingMore) {
        
        NSString *currentWalletId = (NSString *)[PTool getValueFromKey:@"defaultWalletAddress"];
        NSArray *allCoin = [Coin MR_findByAttribute:@"wallet_id" withValue:currentWalletId];
        for (int i = 0; i < name.count; i++) {
            CurrencyModel *model = [[CurrencyModel alloc] init];
            model.name = name[i];
            model.des  = des[i];
            model.icon = icon[i];
            model.selectStatus = 1;
            for (Coin *coin in allCoin) {
                if ([coin.name isEqualToString:name[i]]) {
                    model.selectStatus = 0;
                }
            }
            [self.dataArr addObject:model];
        }
    }else{
        
        for (int i = 0; i < name.count; i++) {
            
            CurrencyModel *model = [[CurrencyModel alloc] init];
            model.name = name[i];
            model.des  = des[i];
            //0:不可选择 1:未选中 2：已选中
            model.selectStatus = 2;
            model.icon = icon[i];
            [self.dataArr addObject:model];
        }
    }
    [self.tableview reloadData];
}

//MARK:UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 75;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AddCurrencyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddCurrencyCellID" forIndexPath:indexPath];
    cell.model = self.dataArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.comeFromeAddingMore) {
        //0:不可选择 1:未选中 2：已选中
        if (((CurrencyModel *)self.dataArr[indexPath.row]).selectStatus == 0) {
            return;
        }else if (((CurrencyModel *)self.dataArr[indexPath.row]).selectStatus == 1) {
            ((CurrencyModel *)self.dataArr[indexPath.row]).selectStatus = 2;
        }else if (((CurrencyModel *)self.dataArr[indexPath.row]).selectStatus == 2) {
            ((CurrencyModel *)self.dataArr[indexPath.row]).selectStatus = 1;
        }
        [self.tableview reloadData];
    }
}

//MARK:LAZY
- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

- (NSMutableArray *)imgArr{
    if (!_imgArr) {
        _imgArr = [NSMutableArray array];
    }
    return _imgArr;
}

- (NSMutableArray *)addDataArr{
    if (!_addDataArr) {
        _addDataArr = [NSMutableArray array];
    }
    return _addDataArr;
}

//MARK:开始创建钱包
- (IBAction)startCreatingAction:(UIButton *)sender {
    creatingIndex = 0;
    NSMutableArray *imgArrs = [NSMutableArray array];
    [imgArrs removeAllObjects];
    NSString *type = (NSString *)[PTool getValueFromKey:@"ComeFromType"];
    
    NSMutableArray *addData = [NSMutableArray array];
    for (CurrencyModel *model in self.dataArr) {
        //0:不可选择 1:未选中 2：已选中
        if (model.selectStatus == 2) {
            [addData addObject:model];
        }
    }
    if (self.comeFromeAddingMore) {
        for (CurrencyModel *model in addData) {
            [imgArrs addObject:[UIImage imageNamed:[NSString stringWithFormat:@"icon_%@", [model.name lowercaseString]]]];
        }
    }else{
        if ([AECOConfig isEqualToString:@"show"]) {
            NSArray *aecoArr = @[
                [UIImage imageNamed:@"icon_btc"],
                [UIImage imageNamed:@"icon_eth"],
                [UIImage imageNamed:@"icon_trx"],
                [UIImage imageNamed:@"icon_aeco"]];
            [imgArrs addObjectsFromArray:aecoArr];
        }else{
            NSArray *creatingArr = @[
                [UIImage imageNamed:@"icon_btc"],
                [UIImage imageNamed:@"icon_eth"],
                [UIImage imageNamed:@"icon_trx"]];
//            NSArray *creatingArr = @[
//                [UIImage imageNamed:@"icon_btc"],
//                [UIImage imageNamed:@"icon_eth"]];
            [imgArrs addObjectsFromArray:creatingArr];
        }
    }
    
    [self.imgArr removeAllObjects];
    [self.imgArr addObjectsFromArray:imgArrs];
    if (self.imgArr.count < 1) {
        DLog(@"没有选中需要增加的币种");
        return;
    }
    //MARK:从搜索进入添加更多主币
    if (self.comeFromeAddingMore) {
        NSString *defaultWallet = (NSString *)[PTool getValueFromKey:@"defaultWalletAddress"];
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        PwdInputView *inputView = [[PwdInputView alloc] initWithFrame:keyWindow.bounds];
        inputView.titleLabel.text = Localized(@"输入钱包密码");
        inputView.inputString = ^(NSString * _Nonnull str) {
            [LSStatusBarHUD showLoading:Localized(@"loadingStr")];
            [[PWallet shareInstance] verifyWalletPwdWithWalletID:defaultWallet Pwd:str valid:^(BOOL valid) {
                if (valid) {
                    self->addingView = [NewAddingCurrencyView showAddingCurrencyViewWithImgsArray:imgArrs block:^(BOOL isEnd) {
                        [self end];
                    }];
                    [self->addingView beginAnimationWithIndex:self->creatingIndex];
                    [LSStatusBarHUD hideLoading];
                    [self addingMoreCoinWithPwd:str WalletId:defaultWallet];
                } else {
                    [LSStatusBarHUD showMessageAndImage:Localized(@"密码错误")];
                }
            }];
        };
        [keyWindow addSubview:inputView];
        return;
    }
    self->addingView = [NewAddingCurrencyView showAddingCurrencyViewWithImgsArray:imgArrs block:^(BOOL isEnd) {
        [self end];
    }];
    [self->addingView beginAnimationWithIndex:self->creatingIndex];
    
    //MARK:导入助记词
    if ([type isEqualToString:@"ComeFromMnemonic"]) {
        [self importMnemonicWallet];
        return;
    }
    //MARK:创建钱包
    [self createWallet];
}

//添加更多主链币
- (void)addingMoreCoinWithPwd:(NSString *)password WalletId:(NSString *)wallet_id{
    NSMutableArray *addData = [NSMutableArray array];
    for (CurrencyModel *model in self.dataArr) {
        //0:不可选择 1:未选中 2：已选中
        if (model.selectStatus == 2) {
            [addData addObject:model];
        }
    }
    if (addData.count < 1) {
        DLog(@"没有选中需要增加的币种");
        return;
    }
    for (int i = 0; i < addData.count; i++) {
        
        NSString *type = ((CurrencyModel *)addData[i]).name;
        [[PWallet shareInstance] createCoin:type Password:password WalletID:wallet_id CoinModel:^(AddCoinModel * _Nonnull coinModel) {
            if (coinModel && coinModel.walletID) {
                
                Coin *coin = [Coin MR_createEntity];
                coin.wallet_id = coinModel.walletID;
                coin.name = [coinModel.coinType uppercaseString];
                coin.address = coinModel.address;
                coin.is_backup = NO;
                coin.coin = coinModel.coin;
                coin.change = coinModel.change;
                coin.index = coinModel.index;
                coin.account = coinModel.account;
                if ([coinModel.coinType isEqualToString:@"BTC"]) {
                    
                    Coin *coin_usdt = [Coin MR_createEntity];
                    coin_usdt.wallet_id = coinModel.walletID;
                    coin_usdt.name = @"USDT";
                    coin_usdt.address = coinModel.address;
                    coin_usdt.coin_tag = @"OMNI";
                    coin_usdt.is_backup = NO;
                    coin_usdt.coin = coinModel.coin;
                    coin_usdt.change = coinModel.change;
                    coin_usdt.index = coinModel.index;
                    coin_usdt.account = coinModel.account;
                }
                [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                self->creatingIndex++;
                [self refresh];
            }
        } createCoinfailure:^(NSError * _Nonnull error) {
            
        }];
    }
}

//MARK:刷新创建动画
- (void)refresh{
    if (creatingIndex < self.imgArr.count + 1) {
        [self->addingView beginAnimationWithIndex:self->creatingIndex];
    }
}

- (void)end{
    creatingIndex = 0;
    [LSStatusBarHUD showMessage:Localized(@"创建成功")];
    if (self.comeFromeAddingMore) {
        [self performSelector:@selector(delayEnterHome) withObject:nil afterDelay:1];
    }else{
        [self backupAction];
    }
}

- (void)backupAction{
    NSString *type = (NSString *)[PTool getValueFromKey:@"ComeFromType"];
    if ([type isEqualToString:@"ComeFromCreating"]) {
        
        [self performSelector:@selector(delayEnterBackup) withObject:nil afterDelay:1];
    } else if ([type isEqualToString:@"ComeFromPK"]) {
        
    } else if ([type isEqualToString:@"ComeFromMnemonic"]) {
        [PTool saveValue:self.wallet_id forKey:@"defaultWalletAddress"];
        [self performSelector:@selector(delayEnterHome) withObject:nil afterDelay:1];
    }
}

- (void)delayEnterHome{
    [addingView removeFromSuperview];
    addingView = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:LOGINSELECTCENTERINDEX object:nil];
}

- (void)delayEnterBackup{
    [addingView removeFromSuperview];
    addingView = nil;
    BackupTipsVC *backupVC = [BackupTipsVC new];
    backupVC.backupConfig = @"fromCreate";
    backupVC.wallet_id = self.wallet_id;
    backupVC.pwdStr = self.passwordString;
    [self.navigationController pushViewController:backupVC animated:YES];
}

//MARK:创建币种钱包
- (void)createWallet{
    PWS(weakSelf);
    NSString *coinTypes = [AECOConfig isEqualToString:@"show"]?@"BTC,ETH,TRX,AECO":@"BTC,ETH,TRX";
    [[PWallet shareInstance] createWalletWithCoinType:coinTypes Password:self.passwordString WalletID:^(NSString * _Nonnull walletID) {
        if (walletID.length > 0 && walletID) {
            Wallet *wallet = [Wallet MR_createEntity];
            wallet.name = weakSelf.nameString;
            wallet.type = @"Multi";//Multi
            wallet.wallet_id = walletID;
            wallet.is_backup = NO;
            weakSelf.wallet_id = walletID;
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        }
    } AddCoinModel:^(AddCoinModel * _Nonnull coinModel) {
        if (coinModel && coinModel.walletID) {
            Coin *coin = [Coin MR_createEntity];
            coin.wallet_id = coinModel.walletID;
            coin.name = [coinModel.coinType uppercaseString];
            coin.address = coinModel.address;
            coin.is_backup = NO;
            coin.coin = coinModel.coin;
            coin.change = coinModel.change;
            coin.index = coinModel.index;
            coin.account = coinModel.account;
            if ([coinModel.coinType isEqualToString:@"BTC"]) {
                Coin *coin_usdt = [Coin MR_createEntity];
                coin_usdt.wallet_id = coinModel.walletID;
                coin_usdt.name = @"USDT";
                coin_usdt.address = coinModel.address;
                coin_usdt.coin_tag = @"OMNI";
                coin_usdt.is_backup = NO;
                coin_usdt.coin = coinModel.coin;
                coin_usdt.change = coinModel.change;
                coin_usdt.index = coinModel.index;
                coin_usdt.account = coinModel.account;
            }
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            self->creatingIndex++;
            [weakSelf refresh];
        }
    } failure:^(NSError * _Nonnull failure) {
        [LSStatusBarHUD showMessageAndImage:Localized(@"创建失败，请重试")];
        [self->addingView removeFromSuperview];
        self->addingView = nil;
    }];
}

//MARK:导入助记词钱包
- (void)importMnemonicWallet{
    PWS(weakSelf);
    [[PWallet shareInstance] importMnemonicWithCoinTypes:[AECOConfig isEqualToString:@"show"]?@"BTC,ETH,TRX,AECO":@"BTC,ETH,TRX" Password:self.passwordString Mnemonics:self.mnemonicString WalletID:^(NSString * _Nonnull walletID) {
        if (walletID) {
            
            Wallet *wallet = [Wallet MR_createEntity];
            wallet.name = weakSelf.nameString;
            wallet.type = @"Multi";//Multi
            wallet.wallet_id = walletID;
            wallet.is_backup = YES;
            weakSelf.wallet_id = walletID;
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        }
    } AddCoinModel:^(AddCoinModel * _Nonnull coinModel) {
        if (coinModel && coinModel.walletID) {
            Coin *coin = [Coin MR_createEntity];
            coin.wallet_id = coinModel.walletID;
            coin.name = [coinModel.coinType uppercaseString];
            coin.address = coinModel.address;
            coin.is_backup = NO;
            coin.account = coinModel.account;
            coin.index = coinModel.index;
            coin.change = coinModel.change;
            coin.coin = coinModel.coin;
            if ([coinModel.coinType isEqualToString:@"BTC"]) {//创建BTC代币USDT
                Coin *coin_usdt = [Coin MR_createEntity];
                coin_usdt.wallet_id = coinModel.walletID;
                coin_usdt.name = @"USDT";
                coin_usdt.address = coinModel.address;
                coin_usdt.coin_tag = @"OMNI";
                coin.is_backup = NO;
                coin.account = coinModel.account;
                coin.index = coinModel.index;
                coin.change = coinModel.change;
                coin.coin = coinModel.coin;
            }
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            weakSelf.wallet_id = coinModel.walletID;
            self->creatingIndex++;
            [weakSelf refresh];
        }
    } failure:^(NSError * _Nonnull failure) {
        if ([failure.localizedDescription isEqualToString:@"address already exists"]) {
            RepeatImportVC *repeatImport = [RepeatImportVC new];
            [weakSelf.navigationController pushViewController:repeatImport animated:YES];
        }else{
            [LSStatusBarHUD showMessageAndImage:Localized(@"创建失败，请重试")];
        }
        [self->addingView removeFromSuperview];
    }];
}
@end
