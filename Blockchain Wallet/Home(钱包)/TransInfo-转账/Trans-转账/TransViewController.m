//
//  TransViewController.m
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/13.
//

#import "TransViewController.h"
#import "ScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AddressViewController.h"
#import "StepSlider.h"
#import "SDKTransTool.h"
#import "FeeRate.h"
#import "GetEthPriceTool.h"
#import "SecurityUtil.h"
#import "SDKCheckAddrTool.h"

@interface TransViewController ()<UITextFieldDelegate>
{
    //ETH
    NSDecimalNumber *slowRateD;
    NSDecimalNumber *midRateD;
    NSDecimalNumber *fastRateD;
    //BTC
    NSUInteger slowRate;
    NSUInteger midRate;
    NSUInteger fastRate;
    BOOL isEthCustomPrice;
    StepSlider *pslider;
}

@property (nonatomic, strong) NSString *selectedRate;
@property (nonatomic, strong) NSDecimalNumber *minnerFee;
@property (nonatomic, strong) NSDecimalNumber *ethFeeDeciNum;

@end

@implementation TransViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setUI];
    [self getFee];
}

- (void)setUI{
    
    if (![self.coinTagString containsString:@"null"]) {//代币
        
        NSString *coinTag = [NSString stringWithFormat:@"%@",  [self.coinTagString containsString:@"null"]?@"":self.coinTagString];
        self.titleLabel.text = [NSString stringWithFormat:@"%@(%@) %@",self.typeString, coinTag, Localized(@"转账")];
    }else{
        self.titleLabel.text = [NSString stringWithFormat:@"%@ %@",self.typeString, Localized(@"转账")];
    }
    self.assetsLabel.text = [NSString stringWithFormat:@"%@ %@ %@", Localized(@"资产"), self.balanceString, self.typeString];
    self.transAddrTitleLabel.text = Localized(@"转账地址");
    self.transAmountTitleLabel.text = Localized(@"转账金额");
    [self.allAmountBtn setTitle:Localized(@"全部") forState:UIControlStateNormal];
    self.memoTitleLabel.text = Localized(@"备注（Memo）");
    self.memoTextField.placeholder = Localized(@"非必填");
    self.minerFeeTitleLabel.text = Localized(@"矿工费");
    self.slowLabel.text = Localized(@"较慢");
    self.recommendLabel.text = Localized(@"推荐");
    self.fastLabel.text = Localized(@"快速");
    [self.customFeeBtn setTitle:[NSString stringWithFormat:@"%@    ", Localized(@"自定义")] forState:UIControlStateNormal];
    [self.submitBtn setTitle:Localized(@"提交") forState:UIControlStateNormal];
    
    //交易详情view
    self.detailTitleLabel.text = Localized(@"转账详情");
    self.detailLeftToAddrLabel.text = Localized(@"转账地址");
    self.detailLeftMinerFeeLabel.text = Localized(@"矿工费");
    self.detailLeftRemarksLabel.text = Localized(@"备注（Memo）");
    [self.alertConfirmBtn setTitle:Localized(@"确定") forState:UIControlStateNormal];
    
    
    slowRateD = [NSDecimalNumber decimalNumberWithString:@"0"];
    midRateD  = [NSDecimalNumber decimalNumberWithString:@"0"];
    fastRateD = [NSDecimalNumber decimalNumberWithString:@"0"];
    
    slowRate = 0;
    midRate = 0;
    fastRate = 0;
    self.minerFeeTransCurrencyLabel.text = @"0";
    
    self.selectedRate = @"0";
    
    if ([self.typeString isEqualToString:@"BTC"] || [self.coinTagString isEqualToString:@"OMNI"]) {
        
        self.slowRateLabel.text = [NSString stringWithFormat:@"%@ sat/b %@60%@", slowRateD, Localized(@"预计"), Localized(@"分钟")];
        self.recommendRateLabel.text = [NSString stringWithFormat:@"%@ sat/b %@30%@", midRateD, Localized(@"预计"), Localized(@"分钟")];
        self.fastRateLabel.text = [NSString stringWithFormat:@"%@ sat/b %@10%@", fastRateD, Localized(@"预计"), Localized(@"分钟")];
        self.gasView.hidden = YES;
        self.unitLabel.text = @"sat/b";
    }else{
        
        self.slowRateLabel.text = [NSString stringWithFormat:@"%@ GWEI %@60%@", slowRateD, Localized(@"预计"), Localized(@"分钟")];
        self.recommendRateLabel.text = [NSString stringWithFormat:@"%@ GWEI %@30%@", midRateD, Localized(@"预计"), Localized(@"分钟")];
        self.fastRateLabel.text = [NSString stringWithFormat:@"%@ GWEI %@10%@", fastRateD, Localized(@"预计"), Localized(@"分钟")];
        self.gasView.hidden = NO;
        self.unitLabel.text = @"GWEI";
        self.ethFeeDeciNum = [[NSDecimalNumber alloc] initWithString:@"0"];
        isEthCustomPrice = NO;
    }
    
    
//    CLLSlideView *slideView = [[CLLSlideView alloc] initWithFrame:CGRectMake(0, 0, self.sliderView.frame.size.width, 14)];
//    slideView.backgroundColor = UIColor.whiteColor;
//    slideView.MyValue = ^(double value) {
//        NSLog(@"%lf",value);
//    };
//    [self.sliderView addSubview:slideView];
    
    pslider = [[StepSlider alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth-35*2, 44)];
    [pslider setMaxCount:3];
    [pslider setIndex:1];
    [pslider setTrackColor:UIColor.lightGrayColor];
    [pslider setTintColor:baseColor];
    [pslider setTrackCircleImage:[UIImage imageNamed:@"unselected_dot"] forState:UIControlStateNormal];
    [pslider setTrackCircleImage:[UIImage imageNamed:@"selected_dot"] forState:UIControlStateSelected];
    [pslider setSliderCircleImage:[UIImage imageNamed:@"icon_slider"]];
    [pslider setSliderCircleColor:[UIColor orangeColor]];
    if (@available(iOS 13.0, *)) {
        [pslider setLargeContentImage:[UIImage imageNamed:@"icon_slider_large"]];
        [pslider setScalesLargeContentImage:YES];
    }
    [pslider addTarget:self action:@selector(sliderDidChanged:) forControlEvents:UIControlEventValueChanged];
    [self.sliderView addSubview:pslider];
    
    [PTool addBorderWithView:self.gasPriceView Color:COLORRGB(232, 232, 235) BorderWidth:1 CornerRadius:5];
    [PTool addBorderWithView:self.gasView Color:COLORRGB(232, 232, 235) BorderWidth:1 CornerRadius:5];
    
    [self.addrTextField addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.transAmountTextField addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.gasPriceTextField addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.gasTextField addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
    self.transAmountTextField.delegate = self;
}

- (void)sliderDidChanged:(StepSlider *)stepSlider{
    
    DLog(@"选中了第%ld个", stepSlider.index);
    
    self.customFeeView.hidden = YES;
    self.feeAlertLabel.hidden = YES;
    [self.arrImgView setImage:[UIImage imageNamed:@"icon_arr_down_yellow"]];
    isEthCustomPrice = NO;
    
    if ([self.typeString isEqualToString:@"ETH"]) {
        
        switch (stepSlider.index) {
            case 0:
                self.selectedRate = [NSString stringWithFormat:@"%@", slowRateD];
                break;
            case 1:
                self.selectedRate = [NSString stringWithFormat:@"%@", midRateD];
                break;
            case 2:
                self.selectedRate = [NSString stringWithFormat:@"%@", fastRateD];
                break;
                
            default:
                break;
        }
    }else{
        
        switch (stepSlider.index) {
            case 0:
                self.selectedRate = [NSString stringWithFormat:@"%lu", (unsigned long)slowRate];
                break;
            case 1:
                self.selectedRate = [NSString stringWithFormat:@"%lu", (unsigned long)midRate];
                break;
            case 2:
                self.selectedRate = [NSString stringWithFormat:@"%lu", (unsigned long)fastRate];
                break;
                
            default:
                break;
        }
    }
    
    [self getFee];
}

- (void)textFieldDidChanged:(UITextField *)textField{
    
    if (self.addrTextField.text.length > 0 && self.transAmountTextField.text.length > 0) {
        
        self.submitBtn.alpha = 1;
        self.submitBtn.userInteractionEnabled = YES;
    }else{
        
        self.submitBtn.alpha = 0.3f;
        self.submitBtn.userInteractionEnabled = NO;
    }
    if (self.gasPriceTextField == textField) {
        if (textField.text.length > 0) {
            self.selectedRate = textField.text;
            if ([self.typeString isEqualToString:@"ETH"]) {
                
                NSDecimalNumber *selectedRateD = [[NSDecimalNumber decimalNumberWithString:self.gasPriceTextField.text] decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:GWEITOWEI]];
                self.selectedRate = [NSString stringWithFormat:@"%@", selectedRateD];
                [self getMinerFeeInfo];
                
                if ([self.slowRateLabel.text floatValue] > 0) {
                    if ([textField.text floatValue] < [self.slowRateLabel.text floatValue]) {
                        self.feeAlertLabel.hidden = NO;
                        self.feeAlertLabel.text = Localized(@"矿工费率过低，将会影响交易确认时间");
                    }else if ([textField.text floatValue] > [self.fastRateLabel.text floatValue]) {
                        self.feeAlertLabel.hidden = NO;
                        self.feeAlertLabel.text = Localized(@"矿工费率过高，将会造成矿工费浪费");
                    }else{
                        self.feeAlertLabel.hidden = YES;
                    }
                }
            }else{//BTC自定义价格
                [self getFee];
                
                if ([self.slowRateLabel.text floatValue] > 0) {
                    if ([textField.text floatValue] < [self.slowRateLabel.text floatValue]) {
                        self.feeAlertLabel.hidden = NO;
                        self.feeAlertLabel.text = Localized(@"矿工费率过低，将会影响交易确认时间");
                    }else if ([textField.text floatValue] > [self.fastRateLabel.text floatValue]) {
                        self.feeAlertLabel.hidden = NO;
                        self.feeAlertLabel.text = Localized(@"矿工费率过高，将会造成矿工费浪费");
                    }else{
                        self.feeAlertLabel.hidden = YES;
                    }
                }
            }
        }else{
            self.selectedRate = 0;
            [self getFee];
        }
    }
}
//时时获取输入框输入的新内容   return NO：输入内容清空   return YES：输入内容不清空， string 输入内容 ，range输入的范围
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    //限制只能输入数字
    BOOL isHaveDian = YES;
    if ([string isEqualToString:@" "]) {
        return NO;
    }
    if ([textField.text rangeOfString:@"."].location == NSNotFound) {
        isHaveDian = NO;
    }
    if ([string length] > 0) {
        unichar single = [string characterAtIndex:0];//当前输入的字符
        if ((single >= '0' && single <= '9') || single == '.') {
            //数据格式正确
            if([textField.text length] == 0){
                if(single == '.') {
                    [textField.text stringByReplacingCharactersInRange:range withString:@""];
                    return NO;
                }
            }
            //输入的字符是否是小数点
            if (single == '.') {
                if(!isHaveDian) {
                    //text中还没有小数点
                    isHaveDian = YES;
                    return YES;
                }else{
                    [textField.text stringByReplacingCharactersInRange:range withString:@""];
                    return NO;
                }
            }else{
                //存在小数点
                if (isHaveDian) {
                    //判断小数点的位数，2 代表位数，可以
                    NSRange ran = [textField.text rangeOfString:@"."];
                    
                    NSArray *arr = [Coin MR_findByAttribute:@"address" withValue:self.addressString];
                    NSString *decimals = @"8";
                    for (Coin *coin in arr) {
                        
                        if ([self.typeString isEqualToString:coin.name] && [self.coinTagString isEqualToString:@"ERC20"]) {
                            decimals = coin.decimals;
                        }
                    }
                    if (range.location - ran.location <= [decimals integerValue]) {
                        return YES;
                    }else{
                        return NO;
                    }
                }else{
                    return YES;
                }
            }
        }else{
            //输入的数据格式不正确
            [textField.text stringByReplacingCharactersInRange:range withString:@""];
            return NO;
        }
    }
    return YES;
}

//选择转账地址
- (IBAction)selectAddrAction:(UIButton *)sender {
    
    PWS(weakSelf);
    AddressViewController *addrVC = [AddressViewController new];
    addrVC.type = @"comeFromTrans";
    addrVC.filterStr = self.typeString;
    addrVC.coinTagStr = self.coinTagString;
    addrVC.selectAddress = ^(NSString * _Nonnull address) {
        if (address.length > 0) {
            self.addrTextField.text = address;
            [weakSelf textFieldDidChanged:nil];
        }
    };
    [self.navigationController pushViewController:addrVC animated:YES];
}
//选择全部资产
- (IBAction)selectAllBalanceAction:(UIButton *)sender {
    
    self.transAmountTextField.text = self.balanceString;
}


- (IBAction)backAction:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

//MARK:自定义矿工费
- (IBAction)customFeeAction:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        
        self.customFeeView.hidden = NO;
        [self.arrImgView setImage:[UIImage imageNamed:@"icon_arr_up_yellow"]];
        isEthCustomPrice = YES;
        [self textFieldDidChanged:self.gasPriceTextField];
    }else{
        
        self.customFeeView.hidden = YES;
        [self.arrImgView setImage:[UIImage imageNamed:@"icon_arr_down_yellow"]];
        isEthCustomPrice = NO;
        self.feeAlertLabel.hidden = YES;
        [self sliderDidChanged:pslider];
    }
}

//MARK:扫码
- (IBAction)scanAction:(UIButton *)sender {
    [PTool isCamCanOpenWithBlock:^(BOOL canOpen) {
        if (canOpen) {
            [self _startQRCodeAction];
        }
    }];
}

- (void)_startQRCodeAction{
    
    ScanViewController *codeVC = [[ScanViewController alloc] init];
    codeVC.returnRes = @"YES";
    PWS(weakSelf);
    codeVC.scanBlock = ^(NSString * _Nonnull scanResultStr) {
        weakSelf.addrTextField.text = scanResultStr;
    };
    [self.navigationController pushViewController:codeVC animated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

//MARK:提交
- (IBAction)submitAction:(UIButton *)sender {
    
    if (self.addrTextField.text.length < 1 || self.transAmountTextField.text.length < 1) {
        return;
    }
    
    if (self.selectedRate == 0) {
        [self getFee];
        [LSStatusBarHUD showMessage:@"请重试"];
    }
    
    if ([self.addressString isEqualToString:self.addrTextField.text]) {
        [PJToastView showInView:self.view text:Localized(@"不能给自己转账") duration:2 autoHide:YES];
        return;
    }
    
    [self validateAddress];
}

//MARK:展示转账详情数据
- (void)showTransDetailView{
    
    self.detailToAddrLabel.text = self.addrTextField.text;
    self.detailAmountLabel.text = self.transAmountTextField.text;
    self.detailRemarksLabel.text = self.memoTextField.text;
    self.detailTypeLabel.text = self.typeString;
    self.detailMinerFeeLabel.text = self.minerFeeLabel.text;
    
    self.darkBgView.hidden = NO;
    self.darkBgView.alpha = 0;
    self.transDetailView.hidden = NO;
    self.transDetailView.transform = CGAffineTransformMakeTranslation(0, 500);
    [UIView animateWithDuration:.3 animations:^{
        self.darkBgView.alpha = 0.4f;
        self.transDetailView.transform = CGAffineTransformIdentity;
    }];
}
- (IBAction)hideTransDetailView:(UIButton *)sender{
    
    [UIView animateWithDuration:.3 animations:^{
        self.darkBgView.alpha = 0;
        self.transDetailView.transform = CGAffineTransformMakeTranslation(0, 500);
    }completion:^(BOOL finished) {
        self.darkBgView.hidden = YES;
        self.transDetailView.hidden = YES;
        self.darkBgView.alpha = 0;
    }];
}
- (IBAction)detailConfirmAction:(UIButton *)sender {
    
    [self hideTransDetailView:nil];
    
    PWS(weakSelf);
    
    PwdInputView *inputView = [[PwdInputView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    inputView.inputString = ^(NSString * _Nonnull str) {
        
        
        NSArray *arr = [Coin MR_findByAttribute:@"address" withValue:self.addressString];
        NSString *wallet_id = @"";
        for (Coin *coin in arr) {
            wallet_id = coin.wallet_id;
        }
        
        [LSStatusBarHUD showLoading:Localized(@"loadingStr")];
        [[PWallet shareInstance] verifyWalletPwdWithWalletID:wallet_id Pwd:str valid:^(BOOL valid) {
            if (valid) {
                [LSStatusBarHUD hideLoading];
                [weakSelf transferAction:str];
            }else{
                [LSStatusBarHUD showMessageAndImage:Localized(@"密码错误")];
            }
        }];
    };
    [[UIApplication sharedApplication].keyWindow addSubview:inputView];
}

//MARK:SDK进行转账
- (void)transferAction:(NSString *)password{
    
    //获取Documents路径
    NSArray *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsPath = [[document objectAtIndex:0] stringByAppendingPathComponent:@"keystore"];
    PWS(weakSelf);
    [SVProgressHUD showWithStatus:Localized(@"提交中...")];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    
    
    NSArray *arr = [Coin MR_findByAttribute:@"address" withValue:self.addressString];
    NSString *type = [PTool getWalletInfo:((Coin *)arr[0]).wallet_id Type:@"type"];
    
    ApiTransferRequest *req = [[ApiTransferRequest alloc] init];
    req.amount = weakSelf.transAmountTextField.text;
    req.coinType = weakSelf.typeString;
    req.feeRate = weakSelf.selectedRate;
    req.keyId = ((Coin *)arr[0]).wallet_id;
    req.keystoreDir = documentsPath;
    req.toAddress = weakSelf.addrTextField.text;
    req.passphrase = password;
    
    if ([weakSelf.typeString isEqualToString:@"USDT"]) {
        
        if ([weakSelf.coinTagString isEqualToString:@"OMNI"]) {//USDT_OMNI
            
            req.coinType = @"BTC";
            req.tokenType = @"USDT";
        }else{//USDT_ERC20
            
            req.coinType = @"ETH";
            req.tokenType = @"USDT";
            
            if (self->isEthCustomPrice) {//自定义价格
                
                NSDecimalNumber *gasPriceD = [NSDecimalNumber decimalNumberWithString:self.gasPriceTextField.text];
                NSDecimalNumber *totalRateD = [gasPriceD decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:GWEITOWEI]];
                req.feeRate = [NSString stringWithFormat:@"%@", totalRateD];
            }else{
                
                req.feeRate = weakSelf.selectedRate;
            }
            for (Coin *coin in arr) {
                
                if ([weakSelf.typeString isEqualToString:coin.name]) {
                    req.tokenAddress = coin.contact_address;
                    NSDecimalNumber *amountD = [NSDecimalNumber decimalNumberWithString:weakSelf.transAmountTextField.text];
                    for (int i = 0; i < [coin.decimals intValue]; i++) {
                        amountD  = [amountD decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"10"]];
                    }
                    req.amount = [NSString stringWithFormat:@"%@", amountD];
                }
            }
        }
    }else{//ETH
        
        if (self->isEthCustomPrice) {//自定义价格
            
            NSDecimalNumber *gasPriceD = [NSDecimalNumber decimalNumberWithString:self.gasPriceTextField.text];
            NSDecimalNumber *totalRateD = [gasPriceD decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:GWEITOWEI]];
            req.feeRate = [NSString stringWithFormat:@"%@", totalRateD];
        }else{
            
            req.feeRate = weakSelf.selectedRate;
        }
        if ([weakSelf.typeString isEqualToString:@"ETH"]) {
            
            NSDecimalNumber *ethAmountD = [NSDecimalNumber decimalNumberWithString:weakSelf.transAmountTextField.text];
            NSDecimalNumber *amountD = [ethAmountD decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:ETHTOWEI]];
            req.amount = [NSString stringWithFormat:@"%@", amountD];
        }else if([self.coinTagString isEqualToString:@"ERC20"]){//ETH代币
            
            for (Coin *coin in arr) {
                
                if ([weakSelf.typeString isEqualToString:coin.name]) {
                    req.coinType = @"ETH";
                    req.tokenType = coin.name;
                    req.tokenAddress = coin.contact_address;
                    NSDecimalNumber *amountD = [NSDecimalNumber decimalNumberWithString:weakSelf.transAmountTextField.text];
                    for (int i = 0; i < [coin.decimals intValue]; i++) {
                        amountD  = [amountD decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"10"]];
                    }
                    req.amount = [NSString stringWithFormat:@"%@", amountD];
                }
            }
        }
    }
    dispatch_queue_t queue = dispatch_queue_create("com.uvtoken.transfer", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        
        NSError *error = nil;
        
        if ([type isEqualToString:@"Multi"]) {
            
            for (Coin *coin in arr) {
                
                if ([weakSelf.typeString isEqualToString:coin.name]) {
                    
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
                                
                                [weakSelf saveTransInfoToLocalDBWithTxID:hdRes.transferResponse.txId Nonce:hdRes.transferResponse.nonce GasPrice:req.feeRate];
                            }else{
                                [LSStatusBarHUD showMessageAndImage:Localized(@"提交失败")];
                                [SVProgressHUD dismiss];
                            }
                        }else{
                            [self showTransError:error];
                            [SVProgressHUD dismiss];
                        }
                    });
                }
            }
            return;
        }
        ApiTransferResponse *res = Uv1TransferFromKey(req, &error);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (res.txId) {
                if (res.txId.length > 0) {
                    [weakSelf saveTransInfoToLocalDBWithTxID:res.txId Nonce:res.nonce GasPrice:req.feeRate];
                }else{
                    [LSStatusBarHUD showMessageAndImage:Localized(@"提交失败")];
                    [SVProgressHUD dismiss];
                }
            }else{
                [self showTransError:error];
                [SVProgressHUD dismiss];
            }
        });
    });
}

//MARK:转账失败
- (void)showTransError:(NSError *)error{
    
    if ([error.localizedDescription isEqualToString:@"insufficient funds available to construct transaction"]) {
        
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:Localized(@"主币余额不足以支付矿工费") message:nil preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *alertA = [UIAlertAction actionWithTitle:Localized(@"确定") style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertC addAction:alertA];
        [self presentViewController:alertC animated:YES completion:nil];
    }else if ([error.localizedDescription containsString:@"maybe some parameter is missing"]){
        
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:Localized(@"矿工费获取失败，请检查网络") message:nil preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *alertA = [UIAlertAction actionWithTitle:Localized(@"确定") style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            
            [self getFee];
        }];
        
        [alertC addAction:alertA];
        [self presentViewController:alertC animated:YES completion:nil];
    }else{
        
        if ([SDKConfig isEqualToString:@"regtest"] || [SDKConfig isEqualToString:@"test"]) {
            
            [LSStatusBarHUD showMessageAndImage:[NSString stringWithFormat:@"%@:%@", Localized(@"提交失败"), error.localizedDescription]];
        }else{
            
            [LSStatusBarHUD showMessageAndImage:Localized(@"提交失败")];
        }
    }
}

//保存交易信息
- (void)saveTransInfoToLocalDBWithTxID:(NSString *)txid Nonce:(NSString *)nonce GasPrice:(NSString *)gasPrice{
    
    Record *record = [Record MR_createEntity];
    record.address = self.addressString;
    record.to_address = self.addrTextField.text;
    record.amount = self.transAmountTextField.text;
    record.type = @"转账";
    record.tx_id = txid;
    record.name = self.typeString;
    record.coin_tag = self.coinTagString;
    record.memo = self.memoTextField.text.length > 0 ? self.memoTextField.text:@"";
    record.start_time = [PTool getNowTimeTimestamp];
    
    //ETH以及其代币需要保存nonce值，以便进行交易加速或者取消交易
    if ([self.typeString isEqualToString:@"ETH"] || [self.coinTagString isEqualToString:@"ERC20"]) {
        
        record.nonce = nonce;
        record.gas_price = gasPrice;
    }
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    [SVProgressHUD showSuccessWithStatus:Localized(@"提交成功")];
    [SVProgressHUD dismissWithDelay:1];
    [self.navigationController popViewControllerAnimated:YES];
}

//MARK:判断输入的地址是否合法
- (void)validateAddress{
    
    //判断地址是否合法
    PWS(weakSelf);
    [[PWallet shareInstance] validAddress:self.addrTextField.text CoinType:[self.typeString isEqualToString:@"BTC"]||[self.coinTagString isEqualToString:@"OMNI"]?@"BTC":@"ETH" valid:^(bool valid) {
        
        if (!valid) {
            [PJToastView showInView:self.view text:Localized(@"您输入的地址不合法") duration:2 autoHide:YES];
        }else{
            
            if ([weakSelf isTransferAllowed]) {
                
                [weakSelf showTransDetailView];
            }
        }
    } failure:^(NSError * _Nonnull failure) {
        
    }];
}
//MARK:判断是否允许转账
- (BOOL)isTransferAllowed{
    
    NSDecimalNumber *inputD = [NSDecimalNumber decimalNumberWithString:self.transAmountTextField.text];
    NSDecimalNumber *balanceD = [NSDecimalNumber decimalNumberWithString:self.balanceString];
    //输入的转账金额大于当前资产金额
    if ([inputD compare:balanceD] == NSOrderedDescending) {
        
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:Localized(@"当前余额不足") message:nil preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *alertA = [UIAlertAction actionWithTitle:Localized(@"确定") style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertC addAction:alertA];
        [self presentViewController:alertC animated:YES completion:nil];
        return NO;
    }
    
    NSDecimalNumber *mainCoinBalanceD = [NSDecimalNumber decimalNumberWithString:[self getMainCoinBalance]];
    NSDecimalNumber *minerFeeD;
    if ([self.coinTagString isEqualToString:@"OMNI"] || [self.typeString isEqualToString:@"BTC"]) {
        minerFeeD = self.minnerFee;
    }else{
        minerFeeD = [NSDecimalNumber decimalNumberWithString:[self.minerFeeLabel.text stringByReplacingOccurrencesOfString:self.typeString withString:@""]];
    }
    DLog(@"当前矿工费:%@ 当前主币金额：%@", minerFeeD, mainCoinBalanceD);
    if ([minerFeeD compare:mainCoinBalanceD] == NSOrderedDescending) {
        
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:Localized(@"主币余额不足以支付矿工费") message:nil preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *alertA = [UIAlertAction actionWithTitle:Localized(@"确定") style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertC addAction:alertA];
        [self presentViewController:alertC animated:YES completion:nil];
        return NO;
    }
    
    //矿工费不能过低
    if ([self.gasPriceTextField.text floatValue] < 1) {
        
        if ([self.coinTagString isEqualToString:@"OMNI"] || [self.typeString isEqualToString:@"BTC"]) {
            
            if (self.customFeeBtn.selected) {
                
                [PJToastView showInView:self.view text:Localized(@"矿工费不能低于0.00000266BTC") duration:2 autoHide:YES];
                return NO;
            }
        }
    }
    
    //判断十分钟内有没有一笔未完成的订单
    NSArray *recordArr = [Record MR_findByAttribute:@"address" withValue:self.addressString];
    BOOL isHaveUnsuccessRecord = NO;
    for (Record *record in recordArr) {
        if (record.time.length < 7 || !record.time) {
            if ([PTool timestampSubtractionWithPastTime:record.start_time]) {
                
                isHaveUnsuccessRecord = YES;
            }
        }
    }
    
    //只有比特币以及代币转账的时候做转账10分钟限制
    if ([self.typeString isEqualToString:@"BTC"] || [self.coinTagString isEqualToString:@"OMNI"]) {
        
        if (isHaveUnsuccessRecord) {
            [PJToastView showInView:self.view text:Localized(@"您有一笔未确认的交易") duration:2 autoHide:YES];
            return NO;
        }
    }
    return YES;
}

//MARK:获取主币余额
- (NSString *)getMainCoinBalance{
    
    NSArray *coinArr = [Coin MR_findByAttribute:@"address" withValue:self.addressString];
    for (Coin *coin in coinArr) {
        if ([self.coinTagString isEqualToString:@"OMNI"] || [self.typeString isEqualToString:@"BTC"]) {
            if ([coin.name isEqualToString:@"BTC"]) {
                return coin.balance;
            }
        }else{
            if ([coin.name isEqualToString:@"ETH"]) {
                return coin.balance;
            }
        }
    }
    return @"unknow";
}

//MARK:获取转账费率
- (void)getFee{
    
    PWS(weakSelf);
    //获取BTC转账费率
    if ([self.coinTagString isEqualToString:@"OMNI"] || [self.typeString isEqualToString:@"BTC"]) {

        ApiTransactionFeeRateRequest *req = [[ApiTransactionFeeRateRequest alloc] init];
        req.coinType = @"BTC";
        
        dispatch_queue_t queue = dispatch_queue_create("com.vbhledger.tafwallet.getFee", DISPATCH_QUEUE_CONCURRENT);
        dispatch_async(queue, ^{
            
            NSError *error = nil;
            ApiTransactionFeeRateResponse *res = Uv1TransactionFeeRate(req, &error);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (res.hourFee) {
                    
                    self->slowRate = res.hourFee;
                    self->midRate  = res.halfHourFee;
                    self->fastRate = res.fastestFee;
                    
                    if ([weakSelf.selectedRate isEqualToString:@"0"]) {
                        
                        weakSelf.selectedRate = [NSString stringWithFormat:@"%lld", res.halfHourFee];
                    }
                    
                    self.slowRateLabel.text = [NSString stringWithFormat:@"%lu sat/b %@60%@", (unsigned long)self->slowRate, Localized(@"预计"), Localized(@"分钟")];
                    self.recommendRateLabel.text = [NSString stringWithFormat:@"%lu sat/b %@30%@", (unsigned long)self->midRate, Localized(@"预计"), Localized(@"分钟")];
                    self.fastRateLabel.text = [NSString stringWithFormat:@"%lu sat/b %@10%@", (unsigned long)self->fastRate, Localized(@"预计"), Localized(@"分钟")];
                    
                    [weakSelf getMinerFeeInfo];
                }
                if (error) {
                    if ([error.localizedDescription containsString:@"timeout"]) {
                        
                        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:Localized(@"checkNetworkStr") message:nil preferredStyle:(UIAlertControllerStyleAlert)];
                        UIAlertAction *alertA = [UIAlertAction actionWithTitle:Localized(@"确定") style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                            
                        }];
                        
                        [alertC addAction:alertA];
                        [weakSelf presentViewController:alertC animated:YES completion:nil];
                    }
                }
            });
        });
        return;
    }
    
    //获取以太坊转账费率
    NSString *url = @"https://www.gasnow.org/api/v3/gas/price";
    [PJNet requestAFURL:url parameters:@{} method:METHOD_GET succeed:^(id result) {
        
        NSInteger code = [[result objectForKey:@"code"] integerValue];
        if (code == 200) {
            
            NSDictionary *data = [result objectForKey:@"data"];
            if ([PTool isDictionary:data]) {
                
                NSString *fastFee = [NSString stringWithFormat:@"%@", [data objectForKey:@"rapid"]];
                NSString *standardFee = [NSString stringWithFormat:@"%@", [data objectForKey:@"standard"]];
                NSString *slowFee = [NSString stringWithFormat:@"%@", [data objectForKey:@"slow"]];
                self->fastRateD = [NSDecimalNumber decimalNumberWithString:fastFee];
                self->midRateD = [NSDecimalNumber decimalNumberWithString:standardFee];
                self->slowRateD = [NSDecimalNumber decimalNumberWithString:slowFee];
                NSString *fastFeeStr = [NSString stringWithFormat:@"%@", [self->fastRateD decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:GWEITOWEI]]];
                NSString *standardFeeStr = [NSString stringWithFormat:@"%@", [self->midRateD decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:GWEITOWEI]]];
                NSString *slowFeeStr = [NSString stringWithFormat:@"%@", [self->slowRateD decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:GWEITOWEI]]];
                
                weakSelf.slowRateLabel.text = [NSString stringWithFormat:@"%@ GWEI %@10%@", [PTool notRounding:slowFeeStr afterPoint:0], Localized(@"预计"), Localized(@"分钟")];
                weakSelf.recommendRateLabel.text = [NSString stringWithFormat:@"%@ GWEI %@3%@", [PTool notRounding:standardFeeStr afterPoint:0], Localized(@"预计"), Localized(@"分钟")];
                weakSelf.fastRateLabel.text = [NSString stringWithFormat:@"%@ GWEI %@0.25%@", [PTool notRounding:fastFeeStr afterPoint:0], Localized(@"预计"), Localized(@"分钟")];
                
                if ([weakSelf.selectedRate isEqualToString:@"0"]) {
                    
                    weakSelf.selectedRate = [NSString stringWithFormat:@"%@", self->midRateD];
                }
                
                [weakSelf getMinerFeeInfo];
            }else{
                [weakSelf SDKGetEthFee];
            }
        }else{
            [weakSelf SDKGetEthFee];
        }
    } failure:^(NSError *error) {
        
        [weakSelf SDKGetEthFee];
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

                self->slowRateD = [[NSDecimalNumber decimalNumberWithString:res.feeRate] decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"0.7"]];
                self->midRateD  = [[NSDecimalNumber decimalNumberWithString:res.feeRate] decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"0.85"]];
                self->fastRateD = [NSDecimalNumber decimalNumberWithString:res.feeRate];

                if ([weakSelf.selectedRate isEqualToString:@"0"]) {

                    weakSelf.selectedRate = [NSString stringWithFormat:@"%@", self->midRateD];
                }

                NSDecimalNumber *gweiToweiD = [NSDecimalNumber decimalNumberWithString:GWEITOWEI];

                weakSelf.slowRateLabel.text = [NSString stringWithFormat:@"%@ GWEI %@30%@", [self->slowRateD decimalNumberByDividingBy:gweiToweiD], Localized(@"预计"), Localized(@"分钟")];
                weakSelf.recommendRateLabel.text = [NSString stringWithFormat:@"%@ GWEI %@2%@", [self->midRateD decimalNumberByDividingBy:gweiToweiD], Localized(@"预计"), Localized(@"分钟")];
                weakSelf.fastRateLabel.text = [NSString stringWithFormat:@"%@ GWEI %@1%@", [self->fastRateD decimalNumberByDividingBy:gweiToweiD], Localized(@"预计"), Localized(@"分钟")];

                [weakSelf getMinerFeeInfo];
            }
        });
    });
}

//MARK:获取并计算矿工费
- (void)getMinerFeeInfo{
    
    PWS(weakSelf);
    
    if ([self.typeString isEqualToString:@"ETH"] || [self.coinTagString isEqualToString:@"ERC20"]) {
        
        if (isEthCustomPrice) {
            if ([self.gasPriceTextField.text isEqualToString:@"0"] || self.gasPriceTextField.text.length < 1) {
                return;
            }
            NSDecimalNumber *inputD = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@", self.gasPriceTextField.text]];
            NSDecimalNumber *transD = [[inputD decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"21000"]] decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:GWEITOWEI]];
            NSDecimalNumber *showFeeD = [transD decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:ETHTOWEI]];
            NSString *feeS = [NSString stringWithFormat:@"%@", showFeeD];
            self.minerFeeLabel.text = [NSString stringWithFormat:@"%@ ETH", [PTool notRounding:feeS afterPoint:8]];
            [self getBtcToCurrencyRate];
        }else{
            switch (pslider.index) {
                case 0:
                    self.selectedRate = [NSString stringWithFormat:@"%@", slowRateD];
                    break;
                case 1:
                    self.selectedRate = [NSString stringWithFormat:@"%@", midRateD];
                    break;
                case 2:
                    self.selectedRate = [NSString stringWithFormat:@"%@", fastRateD];
                    break;
                default:
                    break;
            }
            NSDecimalNumber *selectedD = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@", self.selectedRate]];
            self.minnerFee = [selectedD decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:ETHTOWEI]];
            NSDecimalNumber *showFeeD = [self.minnerFee decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"21000"]];
            NSString *feeS = [NSString stringWithFormat:@"%@", showFeeD];
            self.minerFeeLabel.text = [NSString stringWithFormat:@"%@ ETH", [PTool notRounding:feeS afterPoint:8]];
            [self getBtcToCurrencyRate];
        }
        return;
    }
    
    [[PWallet shareInstance] getFeeRateWithAddress:self.addressString size:^(NSString * _Nonnull size) {
        
        if (size.length > 0) {
            if (!weakSelf.selectedRate) {
                weakSelf.selectedRate = [NSString stringWithFormat:@"%@", self->midRateD];
            }
            NSDecimalNumber *sizeD = [NSDecimalNumber decimalNumberWithString:size];
            NSDecimalNumber *selectedRateD = [NSDecimalNumber decimalNumberWithString:weakSelf.selectedRate];
            NSDecimalNumber *multiplyD = [sizeD decimalNumberByMultiplyingBy:selectedRateD];
            weakSelf.minnerFee = [multiplyD decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"100000000"]];
            
            if ([self.typeString isEqualToString:@"BTC"]||[self.coinTagString isEqualToString:@"OMNI"]) {
//                weakSelf.minerFeeLabel.text = [NSString stringWithFormat:@"%@ BTC", weakSelf.minnerFee];
                NSString *feeS = [NSString stringWithFormat:@"%@", weakSelf.minnerFee];
                weakSelf.minerFeeLabel.text = [NSString stringWithFormat:@"%@ BTC", [PTool notRounding:feeS afterPoint:8]];
            }
            [weakSelf getBtcToCurrencyRate];
        }
    } failure:^(NSError * _Nonnull failure) {
        
        DLog(@"获取费率失败:%@", failure.localizedDescription);
    }];
}

- (void)getBtcToCurrencyRate{
    
    NSString *type = @"BTC";
    if ([self.typeString isEqualToString:@"ETH"] || [self.coinTagString isEqualToString:@"ERC20"]) {
        type = @"ETH";
    }
    //将币拼接成请求链接
    NSString *url = [NSString stringWithFormat:@"%@/wallet/market/tokenticker?&id=%@", [PTool getValueFromKey:walletHttpAPI], type];
    
    DLog(@"请求URL = %@", url);
    
    PWS(weakSelf);
    
    [[PHTTPClient shareInstance] requestMethod:METHOD_GET parameters:@{} url:url success:^(id  _Nonnull responseObject) {
        
        NSInteger code = [[responseObject objectForKey:@"code"] intValue];
        if (0 == code) {
            
            DLog(@"获取汇率成功");
            NSArray *list = [[responseObject objectForKey:@"data"] objectForKey:@"list"];
            if ([PTool isArray:list] && list.count > 0) {
                
                NSString *usdStr = [NSString stringWithFormat:@"%@", [list[0] objectForKey:@"price_usd"]];
                NSString *cnyStr = [NSString stringWithFormat:@"%@", [list[0] objectForKey:@"price_cny"]];
                NSString *eurStr = [NSString stringWithFormat:@"%@", [list[0] objectForKey:@"price_eur"]];
                NSDecimalNumber *priceUSD = [NSDecimalNumber decimalNumberWithString:usdStr];
                NSDecimalNumber *priceCNY = [NSDecimalNumber decimalNumberWithString:cnyStr];
                NSDecimalNumber *priceEUR = [NSDecimalNumber decimalNumberWithString:eurStr];
                
                NSDecimalNumber *showEthFeeD = [weakSelf.minnerFee decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"21000"]];
                if (self->isEthCustomPrice) {
                    if (self.gasPriceTextField.text.length < 1) {
                        return;
                    }
                    NSDecimalNumber *inputD = [[NSDecimalNumber decimalNumberWithString:weakSelf.gasPriceTextField.text] decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:GWEITOWEI]];
                    NSDecimalNumber *transD = [inputD decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"21000"]];
                    showEthFeeD = [transD decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:ETHTOWEI]];
                }
                
                NSString *selectedCurrencyUnit = (NSString *)[PTool getValueFromKey:@"selectedCurrencyUnit"];
                NSString *currency = @"￥";
                
                NSDecimalNumber *minnerFeeDecimal = weakSelf.minnerFee;
                
                if ([selectedCurrencyUnit isEqualToString:@"CNY"]) {
                    if ([weakSelf.typeString isEqualToString:@"ETH"]||[weakSelf.coinTagString isEqualToString:@"ERC20"]) {
                        
                        minnerFeeDecimal = [showEthFeeD decimalNumberByMultiplyingBy:priceCNY];
                    }else{
                        
                        minnerFeeDecimal = [minnerFeeDecimal decimalNumberByMultiplyingBy:priceCNY];
                    }
                }else if ([selectedCurrencyUnit isEqualToString:@"EUR"]){
                    
                    if ([weakSelf.typeString isEqualToString:@"ETH"]||[weakSelf.coinTagString isEqualToString:@"ERC20"]) {
                        
                        minnerFeeDecimal = [showEthFeeD decimalNumberByMultiplyingBy:priceEUR];
                    }else{
                        
                        minnerFeeDecimal = [minnerFeeDecimal decimalNumberByMultiplyingBy:priceEUR];
                    }
                    currency = @"€";
                }else if ([selectedCurrencyUnit isEqualToString:@"USD"]){
                    
                    if ([weakSelf.typeString isEqualToString:@"ETH"]||[weakSelf.coinTagString isEqualToString:@"ERC20"]) {
                        
                        minnerFeeDecimal = [showEthFeeD decimalNumberByMultiplyingBy:priceUSD];
                    }else{
                        
                        minnerFeeDecimal = [weakSelf.minnerFee decimalNumberByMultiplyingBy:priceUSD];
                    }
                    currency = @"$";
                }
                
                weakSelf.minerFeeTransCurrencyLabel.text = [NSString stringWithFormat:@"%@ %@", currency, [PTool notRounding:[NSString stringWithFormat:@"%@", minnerFeeDecimal] afterPoint:2]];
                
            }else{
                
                DLog(@"获取汇率列表为空");
            }
        }else{
            
            DLog(@"获取汇率失败");
        }
    } failure:^(NSError * _Nonnull error) {
        
        DLog(@"获取汇率失败%@", error.localizedDescription);
    }];
}

@end
