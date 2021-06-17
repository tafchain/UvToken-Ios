//
//  TransInfoViewController.m
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/12.
//

#import "TransInfoViewController.h"
#import "TransInfoCell.h"
#import "BeneficiaryAddrVC.h"
#import "TransViewController.h"
#import "MnemonicVC.h"
#import "SecurityUtil.h"
#import "SDKGetBlockHeader.h"
#import "GetAllTransInfoTool.h"
#import "TransDetailViewController.h"
#import "TransInfoHeaderView.h"
#import "TRXTransViewController.h"

@interface TransInfoViewController ()
<
UITableViewDelegate,
UITableViewDataSource
>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) NSMutableArray *transInfoArr;

@end

@implementation TransInfoViewController

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self getTransData:YES];
    
    [self getAllTxHashData];
    
#warning clean data
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"address=%@", self.addressStr];
//    [Record MR_deleteAllMatchingPredicate:predicate];
//    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setUI];
}

- (void)setUI{
    
    if (![self.coinTagString containsString:@"null"]) {//代币
        
        self.titleLabel.text = [NSString stringWithFormat:@"%@(%@)", self.currencyType, [self.coinTagString containsString:@"null"]?@"":self.coinTagString];
    }else{
        self.titleLabel.text = self.currencyType;
    }
    self.addrLabel.text = [self hideMiddleString:self.addressStr];
    self.addrTitleLabel.text = Localized(@"地址");
    [self.collectionBtn setTitle:Localized(@"收款") forState:UIControlStateNormal];
    [self.transBtn setTitle:Localized(@"转账") forState:UIControlStateNormal];
    [self.currencyImgView sd_setImageWithURL:[NSURL URLWithString:self.imageStr] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"icon_%@", [self.currencyType lowercaseString]]]];
    self.recordTitleLabel.text = Localized(@"记录");
    self.noDataLabel.text = Localized(@"暂无数据");
    self.balanceLabel.text = [self.balanceString containsString:@"null"]?@"0":self.balanceString;
    [PTool addBorderWithView:self.collectionBtn Color:[UIColor blackColor] BorderWidth:1 CornerRadius:5];
}

//获取所有的交易数据
- (void)getTransData:(BOOL)stopGettingMoreInfo{
    
    [self.dataArr removeAllObjects];
    
    NSArray *arr = [Record MR_findByAttribute:@"address" withValue:self.addressStr];
    
    for (Record *record in arr) {
        
        if ([record.name isEqualToString:self.currencyType] && [record.address isEqualToString:self.addressStr]) {
            
            [self.dataArr addObject:record];
        }
    }
    
    if (self.dataArr.count < 1) {
        self.noDataView.hidden = NO;
    }else{
        self.noDataView.hidden = YES;
        
        if (!stopGettingMoreInfo) {
            NSMutableArray *txhashsArr = [[NSMutableArray alloc] initWithCapacity:0];
            for (int i = 0; i < self.dataArr.count; i++) {
                
                NSString *time = ((Record *)self.dataArr[i]).time;
                NSString *miner_fee = ((Record *)self.dataArr[i]).miner_fee;
                NSInteger confirmations = [((Record *)self.dataArr[i]).confirmations integerValue];
                
                if (nil == time || time.length < 7 || nil == miner_fee) {
                    
                    //ERC20代币需要判断confirmations小于等于6才能最终确认交易详情
                    if ([self.coinTagString isEqualToString:@"ERC20"] && confirmations <= 6) {
                        
                        [txhashsArr addObject:((Record *)self.dataArr[i]).tx_id];
                    }else{
                        
                        [txhashsArr addObject:((Record *)self.dataArr[i]).tx_id];
                    }
                }else{
                    
                    NSString *txID = ((Record *)self.dataArr[i]).tx_id;
                    DLog(@"已经存在的txhash：%@", txID);
                }
            }
            if (txhashsArr.count > 0) {
                [self getTransInfoWithTxId:txhashsArr];
            }
        }
    }
    for (int i = 0; i < self.dataArr.count; i++) {
        Record *record = ((Record *)self.dataArr[i]);
        if (!record.to_address || record.to_address.length < 7 || !record.address || record.address.length < 7) {
            [self.dataArr removeObject:self.dataArr[i]];
        }
    }
    
    NSArray *array = [self.dataArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        Record *record = obj1;
        Record *record2 = obj2;

        if (!record2.time) {
            return NSOrderedDescending;
        }
        if ([self compareDate:record.time withDate:record2.time] == 1) {
            return NSOrderedDescending;
        }
        return NSOrderedAscending;
    }];
    [self.dataArr removeAllObjects];
    [self.dataArr addObjectsFromArray:array];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TransInfoCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"TransCellID"];
    [self.tableView reloadData];
    if (self.dataArr.count > 0) {
        
        self.tableView.bounces = YES;
    }else{
        
        self.tableView.bounces = NO;
    }
}

//比较时间字符串大小
-(int)compareDate:(NSString*)date01 withDate:(NSString*)date02{
    
    int ci;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *dt1 = [[NSDate alloc] init];
    
    NSDate *dt2 = [[NSDate alloc] init];
    
    dt1 = [df dateFromString:date01];
    
    dt2 = [df dateFromString:date02];
    
    NSComparisonResult result = [dt1 compare:dt2];
    
    switch (result){
            //date02比date01大
        case NSOrderedAscending: ci=1; break;
            
            //date02比date01小
        case NSOrderedDescending: ci=-1; break;
            
            //date02=date01
            
        case NSOrderedSame: ci=0; break;
            
        default: NSLog(@"erorr dates %@, %@", dt2, dt1); break;
    }
    
    return ci;
}


//把多个json字符串转为一个json字符串
- (NSString *)objArrayToJSON:(NSArray *)array {
    
    NSString *jsonStr = @"[";
    
    for (NSInteger i = 0; i < array.count; ++i) {
        if (i != 0) {
            jsonStr = [jsonStr stringByAppendingString:@","];
        }
        jsonStr = [jsonStr stringByAppendingString:array[i]];
    }
    jsonStr = [jsonStr stringByAppendingString:@"]"];
    
    return jsonStr;
}

- (NSString *)hideMiddleString:(NSString *)string{
    
    if (string.length < 15) {
        return string;
    }
    NSString *newStr = @"";
    NSString *middleStr = [string substringWithRange:NSMakeRange(7, string.length-7)];
    NSString *lastStr = [string substringFromIndex:string.length-7];
    newStr = [string stringByReplacingOccurrencesOfString:middleStr withString:@"..."];
    newStr = [newStr stringByAppendingString:lastStr];
    return newStr;
}

//复制地址
- (IBAction)addrCopyAction:(UIButton *)sender {
    [UIPasteboard generalPasteboard].string = self.addressStr;
    [PJToastView showInView:self.view text:Localized(@"复制成功") duration:2 autoHide:YES];
}

//收款
- (IBAction)collectionAction:(UIButton *)sender {
    
    BeneficiaryAddrVC *baVC = [BeneficiaryAddrVC new];
    baVC.addressStr = self.addressStr;
    baVC.typeStr = self.currencyType;
    baVC.coinTagStr = self.coinTagString;
    [self.navigationController pushViewController:baVC animated:YES];
}
//转账
- (IBAction)transAction:(UIButton *)sender {
    
    TransViewController *trans = [TransViewController new];
    TRXTransViewController *trxTrans = [TRXTransViewController new];
    trans.keyIDString      = self.keyIDString;
    trans.typeString       = self.currencyType;
    trans.coinTagString    = self.coinTagString;
    trans.balanceString    = self.balanceString;
    trans.addressString    = self.addressStr;
    trxTrans.keyIDString   = self.keyIDString;
    trxTrans.typeString    = self.currencyType;
    trxTrans.coinTagString = self.coinTagString;
    trxTrans.balanceString = self.balanceString;
    trxTrans.addressString = self.addressStr;
    
    NSString *defaultWallet = (NSString *)[PTool getValueFromKey:@"defaultWalletAddress"];
    NSArray *selectedArr = [Wallet MR_findByAttribute:@"wallet_id" withValue:defaultWallet];
    for (Wallet *wallet in selectedArr) {
        if (!wallet.is_backup && [wallet.type isEqualToString:@"Multi"]) {
            
            PJAlert *alert = [[PJAlert alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds Title:Localized(@"安全提醒") Content:Localized(@"您的钱包尚未备份，如果出现忘记密码、删除应用或手机丢失等情况将会导致您的资产出现损失，请立即备份钱包！") Confirm:Localized(@"立即备份")];
            alert.showTwoBtn = YES;
            alert.titleHidden = NO;
            alert.confirm = ^(BOOL confirm) {
                [self startBackup];
            };
            [[UIApplication sharedApplication].keyWindow addSubview:alert];
            
        }else{
            if ([self.coinTagString isEqualToString:@"TRC20"] || [self.currencyType isEqualToString:@"TRX"]) {
                
                [self.navigationController pushViewController:trxTrans animated:YES];
            }else{
                
                [self.navigationController pushViewController:trans animated:YES];
            }
        }
    }
}

- (void)startBackup{
    
    PWS(weakSelf);
    NSString *defaultWallet = (NSString *)[PTool getValueFromKey:@"defaultWalletAddress"];
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    PwdInputView *inputView = [[PwdInputView alloc] initWithFrame:keyWindow.bounds];
    inputView.titleLabel.text = Localized(@"输入钱包密码");
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


- (IBAction)backAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//MARK:UITableViewDelegate, UITableViewDataSource

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 44)];
    header.backgroundColor = [UIColor whiteColor];
    if (section == 0) {
        TransInfoHeaderView *view = [[TransInfoHeaderView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 193+10)];
        view.addrLabel.text = [self hideMiddleString:self.addressStr];
        view.addrStr = self.addressStr;
        view.balanceLabel.text = [self.balanceString containsString:@"null"]?@"0":self.balanceString;
        [view.currencyImgView sd_setImageWithURL:[NSURL URLWithString:self.imageStr] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"icon_%@", [self.currencyType lowercaseString]]]];
        return view;
    }
    UILabel *sectionTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, KScreenWidth, 44)];
    sectionTitle.text = Localized(@"记录");
    [header addSubview:sectionTitle];
    
    return header;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    }
    return self.dataArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 193+10;
    }
    return 44;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    return [self canSpeedUpWithRecord:self.dataArr[indexPath.row]]?110:70;
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TransInfoCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"TransCellID" forIndexPath:indexPath];
    cell.model = self.dataArr[indexPath.row];
    if ([self canSpeedUpWithRecord:self.dataArr[indexPath.row]]) {
        cell.pendingLabel.hidden = NO;
        cell.speedUpBtn.hidden = NO;
        cell.cancelSpeedUpBtn.hidden = NO;
        cell.speedUpBtn.tag = indexPath.row;
        cell.cancelSpeedUpBtn.tag = indexPath.row;
        [cell.speedUpBtn addTarget:self action:@selector(speedupAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.cancelSpeedUpBtn addTarget:self action:@selector(cancelTransAction:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        cell.speedUpBtn.hidden = YES;
        cell.cancelSpeedUpBtn.hidden = YES;
        cell.pendingLabel.hidden = YES;
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self pushToDetailWithAction:2 AtIndex:indexPath.row];
}

//加速交易
- (void)speedupAction:(UIButton *)sender{
    [self pushToDetailWithAction:1 AtIndex:sender.tag];
}
//取消交易
- (void)cancelTransAction:(UIButton *)sender{
    [self pushToDetailWithAction:0 AtIndex:sender.tag];
}

//MARK:LAZY
- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}
- (NSMutableArray *)transInfoArr{
    if (!_transInfoArr) {
        _transInfoArr = [NSMutableArray array];
    }
    return _transInfoArr;
}

//进入交易详情
- (void)pushToDetailWithAction:(NSInteger)action AtIndex:(NSInteger)index{
    
    Record *record = (Record *)self.dataArr[index];
    TransDetailViewController *detailVC = [[TransDetailViewController alloc] init];
    detailVC.currencyType = self.currencyType;
    detailVC.coinTagString = self.coinTagString;
    detailVC.minerFeeStr = record.miner_fee;
    detailVC.tradeNumStr = record.tx_id;
    detailVC.addrStr = self.addressStr;
    detailVC.timeStr = record.time;
    detailVC.memoStr = record.memo;
    detailVC.gasPrice = record.gas_price;
    //如果是收款 to_address对方的地址 address是自己的地址 那么address为收款地址
    
    DLog(@"add:%@----toaddr%@  validate:%@", record.address, record.to_address, record.valid);
    
    if ([record.type isEqualToString:@"收款"]) {
        detailVC.receiveAddrStr = record.address;
        detailVC.payAddrStr = record.to_address;
        detailVC.moneyStr = [NSString stringWithFormat:@"+%@", record.amount];
    }else if ([record.type isEqualToString:@"转账"]) {
        detailVC.receiveAddrStr = record.to_address;
        detailVC.payAddrStr = record.address;
        detailVC.moneyStr = [NSString stringWithFormat:@"-%@", record.amount];
    }else{
        detailVC.receiveAddrStr = record.address;
        detailVC.payAddrStr = record.to_address;
        detailVC.type = @"矿工账号";
        detailVC.moneyStr = record.amount;
    }
    if ([self.currencyType isEqualToString:@"BTC"] || [self.coinTagString isEqualToString:@"OMNI"]) {
        
        if (record.time.length <= 6) {
            
            if ([self.currencyType isEqualToString:@"BTC"]) {
                
                if ([record.result isEqualToString:@"0"]) {
                    
                    detailVC.status = @"失败";
                }else{
                    
                    detailVC.status = @"提交成功";
                }
            }else{
                
                detailVC.status = @"提交成功";
            }
        }else{
            if ([self.coinTagString isEqualToString:@"OMNI"]) {
            
                DLog(@"%@", record.valid);
                if ([record.valid isEqualToString:@"0"]) {
                    
                    detailVC.status = @"失败";
                }else{
                    
                    detailVC.status = @"成功";
                }
            }else{
                
                detailVC.status = @"成功";
            }
        }
    }else{
        
        if (record.time.length <= 6) {
            
            detailVC.status = @"提交成功";
        }else{
            
            if ([record.result isEqualToString:@"1"]) {
                
                detailVC.status = @"成功";
            }else if ([record.result isEqualToString:@"0"]) {
                detailVC.status = @"失败";
            }else{
                detailVC.status = @"提交成功";
            }
        }
    }
    detailVC.action = action;
    if ([self canSpeedUpWithRecord:record]) {
        detailVC.showSpeedUpBtnView = YES;
    }else{
        detailVC.showSpeedUpBtnView = NO;
    }
    [self.navigationController pushViewController:detailVC animated:YES];
}

//MARK:HTTP请求获取指定区块高度内的所有txhash
- (void)getAllTxHashData{
    
    if ([self.currencyType isEqualToString:@"TRX"] || [self.coinTagString isEqualToString:@"TRC20"]) {
        
        NSString *url = @"https://api.trongrid.io/v1/accounts";
        if ([SDKConfig isEqualToString:@"regtest"]) {
            url = @"https://api.shasta.trongrid.io/v1/accounts";
        }
        url = [NSString stringWithFormat:@"%@/%@/transactions", url, self.addressStr];
        DLog(@"请求的波场交易详情URL：%@", url);
        [[PHTTPClient shareInstance] requestMethod:METHOD_GET parameters:@{@"limit":@200} url:url success:^(id  _Nonnull responseObject) {
            
            BOOL success = [[responseObject objectForKey:@"success"] boolValue];
            if (success) {
                NSArray *txhashs = [responseObject objectForKey:@"data"];
                NSMutableArray *txhashsArr = [NSMutableArray array];
                if ([PTool isArray:txhashs]) {
                    
                    for (NSDictionary *dic in txhashs) {
                        //所有交易hash
                        NSString *tx_id = [dic objectForKey:@"txID"];
                        //TriggerSmartContract:代币交易 TransferContract:主币交易
                        NSString *type = [[[[dic objectForKey:@"raw_data"] objectForKey:@"contract"] objectAtIndex:0] objectForKey:@"type"];
                        //TRX主币交易hash
                        if ([type isEqualToString:@"TransferContract"] && [self.currencyType isEqualToString:@"TRX"]) {
                            [txhashsArr addObject:tx_id];
                        }else if ([type isEqualToString:@"TriggerSmartContract"] && [self.coinTagString isEqualToString:@"TRC20"]){
                            //代币交易hash
                            NSString *contract_address = [[[[[[dic objectForKey:@"raw_data"] objectForKey:@"contract"] objectAtIndex:0] objectForKey:@"parameter"] objectForKey:@"value"] objectForKey:@"contract_address"];
                            //匹配当前查询的合约地址的交易hash
                            if ([[PWallet convertTrxAddress:contract_address] isEqualToString:self.contactAddressStr]) {
                                [txhashsArr addObject:tx_id];
                            }
                        }
                    }
                }
                if (txhashsArr.count > 0) {
                    
                    //向数据库里Record塞入不存在的txhash
                    [self saveTxIdToLocalDB:txhashsArr];
                }else{
                    [self getTransData:NO];
                }
            }
        } failure:^(NSError * _Nonnull error) {
            DLog(@"查询TRX交易hash失败")
        }];
    }
    
    NSString *coinType = self.currencyType;
    if ([self.currencyType isEqualToString:@"USDT"]) {
        coinType = [NSString stringWithFormat:@"USDT_%@", self.coinTagString];
    }
    
    //从数据库中查询出当前address的记录中的最大区块高度
    NSString *blockHeight = @"0";
    NSArray *arr = [Record MR_findByAttribute:@"address" withValue:self.addressStr];
    for (Record *record in arr) {
        DLog(@"block_height:%@", record.block_height);
        if ([record.block_height integerValue] > 0 && [record.name isEqualToString:self.currencyType]) {
            if ([blockHeight integerValue] < [record.block_height integerValue]) {
                blockHeight = record.block_height;
            }
        }
    }
    
    PWS(weakSelf);
    //查询BTC区块高度内的所有tx_hash
    if ([self.currencyType isEqualToString:@"BTC"] || [self.coinTagString isEqualToString:@"OMNI"]) {
        ApiGetAddressesTxIdsRequest *req = [[ApiGetAddressesTxIdsRequest alloc] init];
        req.addresses = self.addressStr;
        req.startHeight = 0;
        if ([self.coinTagString isEqualToString:@"OMNI"]) {//代币
            req.coinType = @"BTC";
            req.tokenType = @"USDT";
        }else{
            req.coinType = @"BTC";
        }
        dispatch_queue_t queue = dispatch_queue_create("com.vbhledger.tafwallet.getallbtctxids", DISPATCH_QUEUE_CONCURRENT);
        dispatch_async(queue, ^{
            NSError *error = nil;
            ApiGetAddressesTxIdsResponse *res = Uv1GetAddressesTxIds(req, &error);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (res.txIds.length > 0) {
                    DLog(@"查询txid成功%@", res.txIds);
                    NSArray *txHashArr = [res.txIds componentsSeparatedByString:@","];
                    if (txHashArr.count > 0) {
                        [weakSelf saveTxIdToLocalDB:txHashArr];
                    }
                }else{
                    DLog(@"查询BTC的txid失败");
                }
            });
        });
        return;
    }
    
    NSArray *coinArr = [Coin MR_findByAttribute:@"address" withValue:self.addressStr];
    NSString *tokenAddress = @"";
    for (Coin *coin in coinArr) {
        if ([coin.coin_tag isEqualToString:@"ERC20"] && [coin.name isEqualToString:self.currencyType]) {
            tokenAddress = coin.contact_address;
        }
        if ([coin.coin_tag isEqualToString:@"TRC20"] && [coin.name isEqualToString:self.currencyType]) {
            tokenAddress = coin.contact_address;
        }
    }
    //查询ETH区块高度内的所有tx_hash
    NSString *urlRoot = [NSString stringWithFormat:@"%@/wallet/transaction/ethhashs/v2?", (NSString *)[PTool getValueFromKey:walletHttpAPI]];
    
    NSString *url = @"";
    
    //代币需要加上合约地址才能查询到交易哈希
    if ([self.coinTagString isEqualToString:@"ERC20"]||[self.coinTagString isEqualToString:@"TRC20"]) {
        url = [NSString stringWithFormat:@"%@coinType=%@&address=%@&fromBlock=%@&tokenAddress=%@&confirmations=1", urlRoot, coinType, self.addressStr, blockHeight?blockHeight:@"0", tokenAddress];
    }else{
        url = [NSString stringWithFormat:@"%@coinType=%@&address=%@&fromBlock=%@&confirmations=1", urlRoot, coinType, self.addressStr, blockHeight?blockHeight:@"0"];
    }
    DLog(@"获取所有交易hash接口：%@", url);
    [[PHTTPClient shareInstance] requestMethod:METHOD_GET parameters:@{} url:url success:^(id  _Nonnull responseObject) {
        
        NSInteger code = [[responseObject objectForKey:@"code"] intValue];
        if (0 == code) {
            NSArray *txhashs = [[responseObject objectForKey:@"data"] objectForKey:@"txhashs"];
            NSMutableArray *txhashsArr = [NSMutableArray array];
            if ([PTool isArray:txhashs]) {
                
                for (NSDictionary *dic in txhashs) {
                    
                    [txhashsArr addObject:[dic objectForKey:@"hash"]];
                }
            }
            if (txhashsArr.count > 0) {
                
                //向数据库里Record塞入不存在的txhash
                [weakSelf saveTxIdToLocalDB:txhashsArr];
            }else{
                [weakSelf getTransData:NO];
            }
        }
    } failure:^(NSError * _Nonnull error) {
        DLog(@"查询交易hash失败")
    }];
}

//MARK:从服务器获取交易详情
- (void)getTransInfoWithTxId:(NSMutableArray *)arr{
    
    NSString *type = @"ETH";
    NSString *blockType = @"eth";
    if ([self.currencyType isEqualToString:@"BTC"] || [self.coinTagString isEqualToString:@"OMNI"]) {//查询BTC链交易详情
        if ([self.coinTagString isEqualToString:@"OMNI"] && [self.currencyType isEqualToString:@"USDT"]) {
            
            type = @"USDT_OMNI";
        }else{
            
            type = @"BTC";
        }
        blockType = @"btc";
    }else if([self.coinTagString isEqualToString:@"ERC20"] && [self.currencyType isEqualToString:@"USDT"]){
        
        type = @"USDT_ERC20";
    }else if([self.currencyType isEqualToString:@"TRX"] || [self.coinTagString isEqualToString:@"TRC20"]){
        
       NSDictionary *param = @{
           @"address":self.addressStr,
           @"currencyType":self.currencyType,
           @"coinTagString":self.coinTagString,
           @"contractAddress":self.contactAddressStr
       };
       [[PWallet shareInstance] getTRXHashWithTXIDs:[arr componentsJoinedByString:@","] Param:param success:^(BOOL success) {
           if (success) {
               //刷新数据，不继续查询hash、更新hash以及更新获取详情（打破循环）
               [self getTransData:YES];
           }
       } failure:^(NSError * _Nonnull failure) {
           DLog(@"获取TRX交易详情失败,交易hash：%@", [arr componentsJoinedByString:@","]);
       }];
       return;
    }
    NSString *url = [NSString stringWithFormat:@"%@/wallet/transaction/%@/v2?coinType=%@", (NSString *)[PTool getValueFromKey:walletHttpAPI], blockType, type];
    for (int i = 0; i < arr.count; i++) {
        url = [NSString stringWithFormat:@"%@&hash=%@", url,arr[i]];
    }
    DLog(@"查询交易详情URL：%@", url);
    PWS(weakSelf);
    [[PHTTPClient shareInstance] requestMethod:METHOD_GET parameters:@{} url:url success:^(id  _Nonnull responseObject) {
        
        NSInteger code = [[responseObject objectForKey:@"code"] intValue];
        if (0 == code) {
            //BTC数据解析
            if ([weakSelf.currencyType isEqualToString:@"BTC"]||[weakSelf.coinTagString isEqualToString:@"OMNI"]) {
                
                [weakSelf showDetailData:[[[responseObject objectForKey:@"data"] objectForKey:@"list"] objectForKey:@"txhashs"] Type:type];
            }else{//ETH数据解析
                
                [weakSelf showDetailData:[[responseObject objectForKey:@"data"] objectForKey:@"txhashs"] Type:type];
            }
        }
    } failure:^(NSError * _Nonnull error) {
        DLog(@"根据txhash查询交易详情失败%@", error.localizedDescription);
    }];
}

//完善本地数据库交易详情
- (void)showDetailData:(id)data Type:(NSString *)type{
    
    NSArray *txhashsArr = data;
    if (![PTool isArray:txhashsArr]) {
        return;
    }
    if (txhashsArr.count < 1) {
        return;
    }
    NSArray *coinArr = [Coin MR_findByAttribute:@"address" withValue:self.addressStr];
    NSString *decimals = @"1";
    for (Coin *coin in coinArr) {
        if ([coin.name isEqualToString:self.currencyType]) {
            decimals = coin.decimals;
        }
    }
    //ETH以及代币解析数据
    if ([self.currencyType isEqualToString:@"ETH"] || [self.coinTagString isEqualToString:@"ERC20"]) {
        [[PWallet shareInstance] saveEthRecordToLocalDBWithArr:txhashsArr CoinTagString:self.coinTagString ContactAddressStr:self.contactAddressStr AddressStr:self.addressStr CurrencyType:self.currencyType Decimals:decimals];
    }
    
    //TRX以及代币解析数据
    if ([self.currencyType isEqualToString:@"TRX"] || [self.coinTagString isEqualToString:@"TRC20"]) {
        
    }
    
    //BTC以及代币解析数据
    if ([self.currencyType isEqualToString:@"BTC"]||[self.coinTagString isEqualToString:@"OMNI"]) {
        [[PWallet shareInstance] saveBtcRecordWithTxhashsArr:txhashsArr AddressStr:self.addressStr CurrencyType:self.currencyType CoinTagString:self.coinTagString];
    }
    
    //刷新数据，不继续查询hash、更新hash以及更新获取详情（打破循环）
    [self getTransData:YES];
}

//MARK:将数据库里不存在的tx_id存在数据库里
- (void)saveTxIdToLocalDB:(NSArray *)tx_id_arr{
    
    //获取完所有交易，开始匹配数据库里的数据，没有相应记录的插入数据，有残缺数据的改为完整的数据，有完整数据的不进行操作
    NSArray *arrAll = [Record MR_findByAttribute:@"address" withValue:self.addressStr];
    NSMutableArray *arr = [NSMutableArray array];
    for (Record *record in arrAll) {
        if ([self.coinTagString isEqualToString:@"OMNI"] && [record.coin_tag isEqualToString:@"OMNI"]) {
            [arr addObject:record];
        }else if ([self.currencyType isEqualToString:@"BTC"] && [record.name isEqualToString:@"BTC"]){
            [arr addObject:record];
        }else if ([self.currencyType isEqualToString:@"ETH"] && [self.coinTagString containsString:@"null"]){//仅ETH
            [arr addObject:record];
        }else if ([self.currencyType isEqualToString:@"TRX"] && [self.coinTagString containsString:@"null"]){//仅TRX
            [arr addObject:record];
        }else if ([self.coinTagString isEqualToString:@"ERC20"]){
            [arr addObject:record];
        }else if ([self.coinTagString isEqualToString:@"TRC20"]){
            [arr addObject:record];
        }
    }
    __block NSMutableArray *difObject = [NSMutableArray arrayWithCapacity:0];
    if (arr.count > 0) {//数据库里有数据
        
        [tx_id_arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            __block BOOL isHave = NO;
            
            for (Record *record in arr) {
                if ([record.tx_id isEqual:obj] && [record.name isEqualToString:self.currencyType]) {
                    isHave = YES;
                    DLog(@"本地数据库已经存在的交易hash：%@--%@", record.tx_id, record.name);
                }
            }
            if (!isHave) {
                [difObject addObject:obj];
            }
        }];
        
        if (difObject.count > 0) {
            for (int i = 0; i < difObject.count; i++) {
                
                Record *record = [Record MR_createEntity];
                record.address = self.addressStr;
                record.tx_id = difObject[i];
                record.name = self.currencyType;
                record.coin_tag = [self.coinTagString containsString:@"null"]?@"":self.coinTagString;
                [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            }
        }
    }else{//数据库里没有txhash数据，直接将所有数据插入当前address表里
        for (int i = 0; i < tx_id_arr.count; i++) {
            
            Record *record = [Record MR_createEntity];
            record.address = self.addressStr;
            record.tx_id = tx_id_arr[i];
            record.name = self.currencyType;
            record.coin_tag = [self.coinTagString containsString:@"null"]?@"":self.coinTagString;
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        }
    }
    
    [self getTransData:NO];
}

//判断当前记录是否可以加速
- (BOOL)canSpeedUpWithRecord:(Record *)record{
    
    //发起交易时间超过1分钟
    if ([PTool isOver1MinuteWithPastTime:record.start_time]) {
        
        //发起的交易是以太坊交易
        if ([self.currencyType isEqualToString:@"ETH"] || [self.coinTagString isEqualToString:@"ERC20"]) {
            
            //是自己发起的交易
            if ([record.type isEqualToString:@"转账"]) {
                
                //发起的交易的gasprice存在
                if (record.gas_price && record.gas_price.length > 0 && ![record.gas_price containsString:@"null"]) {
                    
                    //交易未完成
                    if (nil == record.time || record.time.length < 7 || nil == record.miner_fee) {
                        
                        return YES;
                    }
                }
            }
        }
    }
    return NO;
}
@end
