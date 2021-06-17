//
//  TransDetailViewController.m
//  Blockchain Wallet
//
//  Created by Panerly on 2021/3/2.
//

#import "TransDetailViewController.h"
#import "CommonWebViewController.h"
#import "SDKGetBTCDetailTool.h"

@interface TransDetailViewController ()
{
    NSDecimalNumber *recRateD;
    NSDecimalNumber *fastRateD;
    BOOL isFastGasPrice;
    BOOL isCancelTrade;
}
@end

@implementation TransDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setUI];
}

- (void)setUI{
    
    self.titleLabel.text = Localized(@"详情");
    self.moneyTitleLabel.text = Localized(@"金额");
    self.minerFeeTitleLabel.text = Localized(@"矿工费");
    self.receiveAddrTitleLabel.text = Localized(@"toAddress");
    self.payAddrTitleLabel.text = Localized(@"fromAddress");
    self.tradeNumTitleLabel.text = Localized(@"交易哈希");
    self.queryDetailTitleLabel.text = Localized(@"查询详情");
    self.memoTitleLabel.text = Localized(@"备注（Memo）");
    self.memoLabel.text = self.memoStr;
    
    //set Value
    if (!self.minerFeeStr) {
        self.minerFeeStr = @"0";
    }
    if ([self.coinTagString isEqualToString:@"OMNI"]) {
        
        self.minerFeeLabel.text = [NSString stringWithFormat:@"%@ BTC", [PTool removeFloatAllZeroByString:self.minerFeeStr]];
    }else{
        if ([self.coinTagString isEqualToString:@"ERC20"]) {
            
            self.minerFeeLabel.text = [NSString stringWithFormat:@"%@ ETH", [PTool removeFloatAllZeroByString:self.minerFeeStr]];
        }else if ([self.coinTagString isEqualToString:@"TRC20"] || [self.currencyType isEqualToString:@"TRX"]) {
            
            self.minerFeeLabel.text = [NSString stringWithFormat:@"%@ TRX", [PTool removeFloatAllZeroByString:self.minerFeeStr]];
        }else{
            
            self.minerFeeLabel.text = [NSString stringWithFormat:@"%@ %@", [PTool removeFloatAllZeroByString:self.minerFeeStr], self.currencyType];
        }
    }
    self.moneyLabel.text = [NSString stringWithFormat:@"%@ %@", self.moneyStr, self.currencyType];
    self.receiveAddrLabel.text = self.receiveAddrStr;
    self.payAddrLabel.text = self.payAddrStr;
    self.tradeNumLabel.text = self.tradeNumStr;
    self.timeLabel.text = self.timeStr;
    
    if ([self.type isEqualToString:@"矿工账号"]) {
        self.payAddrLabel.text = @"Coinbase";
        self.minerFeeTitleLabel.hidden = YES;
        self.minerFeeLabel.hidden = YES;
        self.baseViewHeight.constant = 500;
        self.minerFeeLineViewPadding.constant = -15*2;
        self.minerFeeLineView.alpha = 0;
        self.payAddrCopyBtn.hidden = YES;
    }
    
    if ([self.status isEqualToString:@"成功"]) {
        
        self.statusLabel.text = Localized(@"成功");
        self.statusLabel.textColor = COLORRGB(0, 193, 162);
        [self.statusImgView setImage:[UIImage imageNamed:@"icon_trans_success"]];
    }else if ([self.status isEqualToString:@"失败"]){
        
        self.statusLabel.text = Localized(@"失败");
        self.statusLabel.textColor = COLORRGB(246, 92, 90);
        [self.statusImgView setImage:[UIImage imageNamed:@"icon_trans_fail"]];
    }else{
        
        self.statusLabel.text = Localized(@"等待确认");
        self.statusLabel.textColor = COLORRGB(0, 193, 162);
        [self.statusImgView setImage:[UIImage imageNamed:@"icon_trans_success"]];
    }
    
    //如果状态为待确认的时候再次请求详情
    if ([self.currencyType isEqualToString:@"BTC"]) {
        if ([self.status isEqualToString:@"提交成功"]) {
            [self getBtcTransDetail];
        }
    }
    
    //以太坊取消或者加速服务
    if ([self.currencyType isEqualToString:@"ETH"] || [self.coinTagString isEqualToString:@"ERC20"]) {
        
        if (!self.showSpeedUpBtnView) {
            self.speedupBtnView.hidden = YES;
            return;
        }
        self.speedupBtnView.hidden = NO;
        //交易加速或者取消
        [PTool addBorderWithView:self.cancelSpeedBtn Color:[UIColor blackColor] BorderWidth:1 CornerRadius:5];
        self.sTitleLabel.text = Localized(@"交易加速");
        self.sPayInfoTitle.text = Localized(@"支付信息");
        self.sReceiveTitleLabel.text = Localized(@"收款地址");
        self.sPayAddrTitleLabel.text = Localized(@"付款地址");
        self.sTxIdTitleLabel.text = Localized(@"交易哈希");
        self.sSpeedUpTitleLabel.text = Localized(@"加速交易");
        self.sBeforeTitleLabel.text = Localized(@"加速前");
        self.sAfterTitleLabel.text = Localized(@"加速后");
        self.sMinerFeeTitleLabel.text = Localized(@"矿工费");
        [self.sConfirmSpeedUpBtn setTitle:Localized(@"确认加速") forState:UIControlStateNormal];
        [self.cancelSpeedBtn setTitle:Localized(@"取消") forState:UIControlStateNormal];
        [self.speedBtn setTitle:Localized(@"加速") forState:UIControlStateNormal];
        self.sRecommandLabel.text = Localized(@"推荐(约3分钟)");
        self.sFastLabel.text = Localized(@"急速(约15秒)");
        
        self.sReceiveLabel.text = self.receiveAddrStr;
        self.sPayAddrLabel.text = self.payAddrStr;
        self.sTxIdLabel.text = self.tradeNumStr;
        NSString *amountS = [self.moneyStr containsString:@"+"]?[self.moneyStr stringByReplacingOccurrencesOfString:@"+" withString:@""]:[self.moneyStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
        self.sAmountLabel.text = [NSString stringWithFormat:@"%@ ETH", amountS];
        NSDecimalNumber *gasPriceD = [NSDecimalNumber decimalNumberWithString:self.gasPrice];
        self.sBeforeLabel.text = [NSString stringWithFormat:@"%@ GWEI", [gasPriceD decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:GWEITOWEI]]];
        
        isFastGasPrice = NO;
        switch (self.action) {
            case 0:
                
                [self cancelTransAction:nil];
                break;
            case 1:
                
                [self speedupAction:nil];
                break;
                
            default:
                break;
        }
    }
}

//更改BTC交易状态
- (void)getBtcTransDetail{
    
    PWS(weakSelf);
    ApiGetBtcTransactionRequest *req = [[ApiGetBtcTransactionRequest alloc] init];
    req.txid = self.tradeNumStr;
    dispatch_queue_t queue = dispatch_queue_create("com.vbhledger.uvtoken.getBtcTrans", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        
        NSError *error = nil;
        ApiGetBtcTransactionResponse *res = Uv1GetBtcTransaction(req, &error);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (res.confirmations == -1) {
                if (res.trusted == 0) {
                    //交易失败
                    [weakSelf setRecordFailStatus];
                    weakSelf.statusLabel.text = Localized(@"失败");
                    weakSelf.statusLabel.textColor = COLORRGB(246, 92, 90);
                    [weakSelf.statusImgView setImage:[UIImage imageNamed:@"icon_trans_fail"]];
                }
            }
        });
    });
}

- (void)setRecordFailStatus{
    
    NSArray *arr = [Record MR_findByAttribute:@"address" withValue:self.addrStr];
    for (Record *record in arr) {
        if ([record.name isEqualToString:@"BTC"]) {
            record.result = @"0";
        }
    }
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

- (IBAction)backAction:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)hashCopyAction:(UIButton *)sender {
    
    [UIPasteboard generalPasteboard].string = self.tradeNumStr;
    [PJToastView showInView:self.view text:Localized(@"已复制此交易hash值") duration:2 autoHide:YES];
}
- (IBAction)receiveCopyAction:(UIButton *)sender {
    
    [UIPasteboard generalPasteboard].string = self.receiveAddrLabel.text;
    [PJToastView showInView:self.view text:Localized(@"已复制") duration:2 autoHide:YES];
}
- (IBAction)payAddressCopyAction:(UIButton *)sender {
    
    [UIPasteboard generalPasteboard].string = self.payAddrLabel.text;
    [PJToastView showInView:self.view text:Localized(@"已复制") duration:2 autoHide:YES];
}

//调用区块浏览器
- (IBAction)showMoreAction:(UIButton *)sender {

    CommonWebViewController *web = [[CommonWebViewController alloc] init];
    
    if ([self.currencyType isEqualToString:@"ETH"]||[self.coinTagString isEqualToString:@"ERC20"]) {
        
        web.webUrl = [NSString stringWithFormat:@"https://m-eth.btc.com/txinfo/%@", self.tradeNumStr];
    }else if ([self.currencyType isEqualToString:@"TRX"]||[self.coinTagString isEqualToString:@"TRC20"]) {
        
        NSString *language = (NSString *)[PTool getValueFromKey:@"appLanguage"];
        //https://trx.tokenview.com/cn/tx/fade2492003216712ad7b56273d5e03fa923b4dba0b1c0bbf6c0cbfa2d0facb4
        web.webUrl = [NSString stringWithFormat:@"https://trx.tokenview.com/%@/tx/%@", [language isEqualToString:@"zh-Hans"]?@"cn":@"en", self.tradeNumStr];
        if ([SDKConfig containsString:@"test"]) {
            web.webUrl = [NSString stringWithFormat:@"https://shasta.tronscan.org/#/transaction/%@", self.tradeNumStr];
        }
    }else{
        
        web.webUrl = [NSString stringWithFormat:@"https://btc.com/%@", self.tradeNumStr];
    }
    [self.navigationController pushViewController:web animated:YES];
}

//MARK:加速服务
- (IBAction)speedupAction:(UIButton *)sender {
    
    [self getEthGasPrice];
    [[PWallet shareInstance] validTransactionWithTx_id:self.tradeNumStr valid:^(bool valid) {
        
        if (valid) {
            
            [SVProgressHUD showInfoWithStatus:Localized(@"交易已完成，无法加速")];
            [SVProgressHUD dismissWithDelay:2];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self showSpeedupViewWithCancel:NO];
        }
    } failure:^(NSError * _Nonnull failure) {
        DLog(@"验证交易hash失败：%@", failure.localizedDescription);
        [PJToastView showInView:self.view text:Localized(@"retryAlertStr") duration:2 autoHide:YES];
    }];
}

- (IBAction)cancelTransAction:(UIButton *)sender {
    
    [self getEthGasPrice];
    [[PWallet shareInstance] validTransactionWithTx_id:self.tradeNumStr valid:^(bool valid) {
        if (valid) {
            
            [SVProgressHUD showInfoWithStatus:Localized(@"交易已完成，无法取消")];
            [SVProgressHUD dismissWithDelay:2];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self showSpeedupViewWithCancel:YES];
        }
    } failure:^(NSError * _Nonnull failure) {
        
        DLog(@"验证交易hash失败：%@", failure.localizedDescription);
        [PJToastView showInView:self.view text:Localized(@"retryAlertStr") duration:2 autoHide:YES];
    }];
}

//确认加速或者确认取消
- (IBAction)confirmSpeedupAction:(UIButton *)sender {
    
    PwdInputView *inputView = [[PwdInputView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    inputView.inputString = ^(NSString * _Nonnull str) {
        
        NSArray *arr = [Coin MR_findByAttribute:@"address" withValue:self.addrStr];
        NSString *wallet_id = @"";
        for (Coin *coin in arr) {
            wallet_id = coin.wallet_id;
        }
        [LSStatusBarHUD showLoading:Localized(@"loadingStr")];
        [[PWallet shareInstance] verifyWalletPwdWithWalletID:wallet_id Pwd:str valid:^(BOOL valid) {
            
            if (valid) {
                
                [LSStatusBarHUD hideLoading];
                [self transferAction:str GasPrice:[NSString stringWithFormat:@"%@", [self getRightGasPrice]]];
            }else{
                [LSStatusBarHUD showMessageAndImage:Localized(@"密码错误")];
            }
        }];
    };
    [[UIApplication sharedApplication].keyWindow addSubview:inputView];
}

- (IBAction)closeSpeedView:(UIButton *)sender {
    
    [UIView animateWithDuration:.7 delay:.1 usingSpringWithDamping:.5f initialSpringVelocity:.1f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.speedDarkBgView.alpha = 0;
        self.speedupContentView.transform = CGAffineTransformMakeTranslation(0, KScreenHeight);
        self.speedupLogo.transform = CGAffineTransformMakeTranslation(0, KScreenHeight);
    } completion:^(BOOL finished) {
        
        self.speedView.hidden = YES;
    }];
}


//MARK:SDK进行转账
- (void)transferAction:(NSString *)password GasPrice:(NSString *)gasPrice{
    
    //获取Documents路径
    NSArray *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsPath = [[document objectAtIndex:0] stringByAppendingPathComponent:@"keystore"];
    [SVProgressHUD showWithStatus:Localized(@"提交中...")];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    
    NSArray *recordArr = [Record MR_findByAttribute:@"tx_id" withValue:self.tradeNumStr];
    NSString *amount = @"";NSString *nonce = @"";
    for (Record *record in recordArr) {
        if ([record.name isEqualToString:self.currencyType] && [self.addrStr isEqualToString:record.address]) {
            amount = record.amount;
            nonce = record.nonce;
        }
    }
    
    NSArray *arr = [Coin MR_findByAttribute:@"address" withValue:self.addrStr];
    NSString *type = [PTool getWalletInfo:((Coin *)arr[0]).wallet_id Type:@"type"];
    
    ApiTransferRequest *req = [[ApiTransferRequest alloc] init];
    req.amount = isCancelTrade?@"0":amount;
    req.coinType = self.currencyType;
    req.feeRate = gasPrice;
    req.keyId = ((Coin *)arr[0]).wallet_id;
    req.keystoreDir = documentsPath;
    req.toAddress = self.receiveAddrStr;
    req.passphrase = password;
    req.nonce = nonce;
    
    if ([self.currencyType isEqualToString:@"ETH"]) {
        
        NSDecimalNumber *ethAmountD = [NSDecimalNumber decimalNumberWithString:amount];
        NSDecimalNumber *amountD = [ethAmountD decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:ETHTOWEI]];
        req.amount = isCancelTrade?@"0":[NSString stringWithFormat:@"%@", amountD];
    }else if([self.coinTagString isEqualToString:@"ERC20"]){//ETH代币
        
        for (Coin *coin in arr) {
            
            if ([self.currencyType isEqualToString:coin.name]) {
                req.coinType = @"ETH";
                req.tokenType = coin.name;
                req.tokenAddress = coin.contact_address;
                NSDecimalNumber *amountD = [NSDecimalNumber decimalNumberWithString:amount];
                for (int i = 0; i < [coin.decimals intValue]; i++) {
                    amountD  = [amountD decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"10"]];
                }
                req.amount = isCancelTrade?@"0":[NSString stringWithFormat:@"%@", amountD];
            }
        }
    }
    
    PWS(weakSelf);
    
    dispatch_queue_t queue = dispatch_queue_create("com.uvtoken.transfer", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        
        NSError *error = nil;
        
        if ([type isEqualToString:@"Multi"]) {
            
            for (Coin *coin in arr) {
                
                if ([self.currencyType isEqualToString:coin.name]) {
                    
                    ApiTransferFromHdWalletRequest *hdReq = [[ApiTransferFromHdWalletRequest alloc] init];
                    hdReq.transferRequest = req;
                    hdReq.account = coin.account;
                    hdReq.change = coin.change;
                    hdReq.index = coin.index;
                    hdReq.coin = coin.coin;
                    
                    ApiTransferFromHdWalletResponse *hdRes = Uv1TransferFromHdWallet(hdReq, &error);
                    DLog(@"提交失败信息：%@", error.localizedDescription);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if (hdRes.transferResponse.keyId) {
                            if (hdRes.transferResponse.txId.length > 0) {
                                
                                [weakSelf saveTransInfoToLocalDBWithTxID:hdRes.transferResponse.txId Nonce:hdRes.transferResponse.nonce Amount:req.amount GasPrice:req.feeRate];
                            }else{
                                [LSStatusBarHUD showMessageAndImage:Localized(@"提交失败")];
                                [SVProgressHUD dismiss];
                            }
                        }else{
                            
                            if ([error.localizedDescription isEqualToString:@"insufficient funds available to construct transaction"]) {
                                
                                UIAlertController *alertC = [UIAlertController alertControllerWithTitle:Localized(@"主币余额不足以支付矿工费") message:nil preferredStyle:(UIAlertControllerStyleAlert)];
                                UIAlertAction *alertA = [UIAlertAction actionWithTitle:Localized(@"确定") style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                                    
                                }];
                                
                                [alertC addAction:alertA];
                                [self presentViewController:alertC animated:YES completion:nil];
                            }else if ([error.localizedDescription containsString:@"maybe some parameter is missing"]){
                                //矿工费获取失败，请检查网络
                            }else{
                                
                                if ([SDKConfig isEqualToString:@"regtest"] || [SDKConfig isEqualToString:@"test"]) {
                                    
                                    [LSStatusBarHUD showMessageAndImage:[NSString stringWithFormat:@"%@:%@", Localized(@"提交失败"), error.localizedDescription]];
                                }else{
                                    
                                    [LSStatusBarHUD showMessageAndImage:Localized(@"提交失败")];
                                }
                            }
                            [SVProgressHUD dismiss];
                        }
                    });
                }
            }
            return;
        }
        
        //单链钱包
        ApiTransferResponse *res = Uv1TransferFromKey(req, &error);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (res.txId) {
                if (res.txId.length > 0) {
                    [weakSelf saveTransInfoToLocalDBWithTxID:res.txId Nonce:res.nonce Amount:req.amount GasPrice:req.feeRate];
                }else{
                    [LSStatusBarHUD showMessageAndImage:Localized(@"提交失败")];
                    [SVProgressHUD dismiss];
                }
            }else{
                if ([error.localizedDescription isEqualToString:@"insufficient funds available to construct transaction"]) {
                    
                    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:Localized(@"主币余额不足以支付矿工费") message:nil preferredStyle:(UIAlertControllerStyleAlert)];
                    UIAlertAction *alertA = [UIAlertAction actionWithTitle:Localized(@"确定") style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                        
                    }];
                    
                    [alertC addAction:alertA];
                    [self presentViewController:alertC animated:YES completion:nil];
                }else if ([error.localizedDescription containsString:@"maybe some parameter is missing"]){
                    //矿工费获取失败，请检查网络
                }else{
                    
                    if ([SDKConfig isEqualToString:@"regtest"] || [SDKConfig isEqualToString:@"test"]) {
                        
                        [LSStatusBarHUD showMessageAndImage:[NSString stringWithFormat:@"%@:%@", Localized(@"提交失败"), error.localizedDescription]];
                    }else{
                        
                        [LSStatusBarHUD showMessageAndImage:Localized(@"提交失败")];
                    }
                }
                [SVProgressHUD dismiss];
            }
        });
    });
}


//保存交易信息
- (void)saveTransInfoToLocalDBWithTxID:(NSString *)txid Nonce:(NSString *)nonce Amount:(NSString *)amount GasPrice:(NSString *)gasPrice{
    
    NSArray *arr = [Record MR_findByAttribute:@"tx_id" withValue:self.tradeNumStr];
    for (Record *record in arr) {
        if ([record.name isEqualToString:self.currencyType] && [self.addrStr isEqualToString:record.address]) {
            
            record.address = self.addrStr;
            record.to_address = self.receiveAddrStr;
            record.amount = [NSString stringWithFormat:@"%@", [[NSDecimalNumber decimalNumberWithString:amount] decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:ETHTOWEI]]];
            record.type = @"转账";
            record.tx_id = txid;
            record.name = self.currencyType;
            record.coin_tag = self.coinTagString;
            record.memo = @"";
            record.start_time = [PTool getNowTimeTimestamp];
            record.nonce = nonce;
            record.gas_price = gasPrice;
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        }
    }
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    [SVProgressHUD showSuccessWithStatus:Localized(@"提交成功")];
    [SVProgressHUD dismissWithDelay:1];
    
    [self.navigationController popViewControllerAnimated:YES];
}


//MARK:获取以太坊转账费率
- (void)getEthGasPrice{
    
    NSString *url = @"https://www.gasnow.org/api/v3/gas/price";
    [PJNet requestAFURL:url parameters:@{} method:METHOD_GET succeed:^(id result) {
        
        NSInteger code = [[result objectForKey:@"code"] integerValue];
        if (code == 200) {
            
            NSDictionary *data = [result objectForKey:@"data"];
            if ([PTool isDictionary:data]) {
                
                NSString *fastFee = [NSString stringWithFormat:@"%@", [data objectForKey:@"rapid"]];
                NSString *standardFee = [NSString stringWithFormat:@"%@", [data objectForKey:@"standard"]];
                self->fastRateD = [NSDecimalNumber decimalNumberWithString:fastFee];
                self->recRateD = [NSDecimalNumber decimalNumberWithString:standardFee];
                [self getMinerFeeInfo];
            }else{
                [self SDKGetEthFee];
            }
        }else{
            [self SDKGetEthFee];
        }
    } failure:^(NSError *error) {
        
        [self SDKGetEthFee];
    }];
}

//接口获取失败切换为SDK获取费用
- (void)SDKGetEthFee{
    
    PWS(weakSelf);
    //获取以太坊费率
    ApiEstimateEthGasPriceRequest *req = [[ApiEstimateEthGasPriceRequest alloc] init];
    dispatch_queue_t queue = dispatch_queue_create("com.vbhledger.tafwallet.getEthFee", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        
        NSError *error = nil;
        ApiEstimateEthGasPriceResponse *res = Uv1EstimateEthGasPrice(req, &error);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (res.feeRate > 0) {

                self->recRateD  = [[NSDecimalNumber decimalNumberWithString:res.feeRate] decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"0.85"]];
                self->fastRateD = [NSDecimalNumber decimalNumberWithString:res.feeRate];

                [weakSelf getMinerFeeInfo];
            }
            if (error) {
                self->recRateD = [NSDecimalNumber decimalNumberWithString:@"0"];
                self->fastRateD = [NSDecimalNumber decimalNumberWithString:@"0"];
                [weakSelf getMinerFeeInfo];
            }
        });
    });
}

//MARK:获取并计算矿工费
- (void)getMinerFeeInfo{
    
    if ([self.currencyType isEqualToString:@"ETH"] || [self.coinTagString isEqualToString:@"ERC20"]) {
        
        NSDecimalNumber *selectedD = [self getRightGasPrice];
        self.sAfterLabel.text = [NSString stringWithFormat:@"%@ GWEI", [selectedD decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:GWEITOWEI]]];
        NSDecimalNumber *minnerFee = [selectedD decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:ETHTOWEI]];
        NSDecimalNumber *showFeeD = [minnerFee decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"21000"]];
        NSString *feeS = [NSString stringWithFormat:@"%@", showFeeD];
        self.sMinerFeeLabel.text = [NSString stringWithFormat:@"%@ ETH", [PTool notRounding:feeS afterPoint:8]];
        self.sMinerFeeDesLabel.text = [NSString stringWithFormat:@"≈Gas(21000)*Gas Price(%@)", self.sAfterLabel.text];
    }
}

//获取转账gasprice
- (NSDecimalNumber *)getRightGasPrice{
    
    NSDecimalNumber *selectedD = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@", self.sFastBtn.selected?fastRateD:recRateD]];
    
    NSArray *recordArr = [Record MR_findByAttribute:@"tx_id" withValue:self.tradeNumStr];
    NSDecimalNumber *gasPriceD = [NSDecimalNumber decimalNumberWithString:@"0"];
    for (Record *record in recordArr) {
        if ([record.name isEqualToString:self.currencyType] && [self.addrStr isEqualToString:record.address]) {
            gasPriceD = [NSDecimalNumber decimalNumberWithString:record.gas_price];
        }
    }
    //如果推荐的值比以前交易的小 那么1.2或者1.5乘以以前的gasprice
    if ([gasPriceD compare:selectedD] == NSOrderedDescending) {
        if (self.sFastBtn.selected) {
            
            selectedD = [gasPriceD decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"1.5"]];
        }else{
            
            selectedD = [gasPriceD decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"1.25"]];
        }
    }
    return selectedD;
}

- (IBAction)selectGasPriceAction:(UIButton *)sender {
    
    [sender setImage:[UIImage imageNamed:@"icon_black_select"] forState:UIControlStateNormal];
    sender.selected = YES;
    
    if (sender == self.sRecommandBtn) {
        
        [self.sFastBtn setImage:[UIImage imageNamed:@"icon_unselect"] forState:UIControlStateNormal];
        self.sFastBtn.selected = NO;
    }else{
        
        [self.sRecommandBtn setImage:[UIImage imageNamed:@"icon_unselect"] forState:UIControlStateNormal];
        self.sRecommandBtn.selected = NO;
    }
    [self getEthGasPrice];
}
- (void)showSpeedupViewWithCancel:(BOOL)cancel{
    
    isCancelTrade = cancel;
    if (cancel) {
        
        self.speedupLogo.hidden = YES;
        self.sSpeedUpTitleLabel.text = Localized(@"取消交易");
        self.sTitleLabel.text = Localized(@"取消交易");
        self.sTitleLabel.font = [UIFont boldSystemFontOfSize:18];
        self.sTitleLabel.transform = CGAffineTransformMakeTranslation(0, -20);
        [self.sConfirmSpeedUpBtn setTitle:Localized(@"取消") forState:UIControlStateNormal];
    }else{
        
        self.speedupLogo.hidden = NO;
        self.sSpeedUpTitleLabel.text = Localized(@"加速交易");
        self.sTitleLabel.text = Localized(@"交易加速");
        self.sTitleLabel.font = [UIFont systemFontOfSize:14];
        self.sTitleLabel.transform = CGAffineTransformIdentity;
        [self.sConfirmSpeedUpBtn setTitle:Localized(@"确认加速") forState:UIControlStateNormal];
    }
    
    self.speedView.hidden = NO;
    self.speedDarkBgView.alpha = 0;
    self.speedupContentView.transform = CGAffineTransformMakeTranslation(0, KScreenHeight);
    self.speedupLogo.transform = CGAffineTransformMakeTranslation(0, KScreenHeight);
    
    /*duration：动画的持续时间
     delay：动画延时几秒执行
     dampingRatio ：动画阻尼系数
     velocity：动画开始速度
     options：动画效果参数
     completion：动画执行完成的回调
     其中：dampingRatio(动画阻尼系数)和velocity(动画开始速度)是需要重点了解的。阻尼系数（0~1），衡量阻力大小的一个标准，阻尼系数越大则说明阻力越大，动画的减速越开, 如果设为一的话，几乎没有弹簧的效果。而velocity(动画开始速度：0～1)想对来说比较好理解，就是弹簧动画开始时的速度。*/
    [UIView animateWithDuration:.5f delay:.1 usingSpringWithDamping:.7f initialSpringVelocity:.1f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.speedupContentView.transform = CGAffineTransformIdentity;
        self.speedupLogo.transform = CGAffineTransformIdentity;
        self.speedDarkBgView.alpha = 0.4f;
    } completion:^(BOOL finished) {
        
    }];
}

@end
