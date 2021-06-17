//
//  TRXTransViewController.m
//  Blockchain Wallet
//
//  Created by 陈俭红 on 2021/6/3.
//

#import "TRXTransViewController.h"
#import "BWNavView.h"
#import "TRXTransTableViewCell.h"
#import "TRXTransFooterView.h"
#import "TRXTransDetailView.h"

#import "SDKTransTool.h"

#import "ScanViewController.h"
#import "AddressViewController.h"

@interface TRXTransViewController ()<UITableViewDataSource, UITableViewDelegate, TRXTransTableViewCellDelegate, TRXTransFooterViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong)BWNavView * navView;
@property (nonatomic, strong)UITableView * tableView;
@property (nonatomic, copy)NSArray * dataArray;
@property (nonatomic, copy)NSString * address;
@property (nonatomic, copy)NSString * amount;
/**  */
@property (nonatomic, strong)UIButton * submitBtn;
@end

@implementation TRXTransViewController

#pragma mark - Cycle Methods
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self setUI];
    
    [self setDefaultData];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

#pragma mark - Myself Methods
- (void)setUI{
    [self.view addSubview:self.navView];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.submitBtn];

    [self.navView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(0);
        make.left.right.equalTo(self.view);
        make.height.equalTo(STATUSBAR_HEIGHT + 44);
    }];
    [self.tableView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(STATUSBAR_HEIGHT + 44);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    [self.submitBtn makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(20);
        make.right.equalTo(-20);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-30);
        make.height.equalTo(44);
    }];
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setDefaultData{
    self.dataArray = @[
        @{@"title":Localized(@"收款地址"), @"place":Localized(@"请输入收款地址"), @"content":self.address ? : @"", @"img":@"icon_home_contact", @"btnStr":@"", @"keyType":@"0"},
        @{@"title":Localized(@"转账金额"), @"place":Localized(@"请输入转账金额"), @"content":self.amount ? : @"", @"img":@"", @"btnStr":Localized(@"全部"), @"keyType":@"1"},
    ];
    [self.tableView reloadData];
}

/** 扫描 */
- (void)scan{
    [PTool isCamCanOpenWithBlock:^(BOOL canOpen) {
        if (canOpen) {
            ScanViewController * vc = [ScanViewController new];
            vc.returnRes = @"YES";
            PWS(weakSelf);
            vc.scanBlock = ^(NSString * _Nonnull scanResultStr) {
                weakSelf.address = scanResultStr;
                [weakSelf setDefaultData];
            };
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
}

/** 选择地址 */
- (void)chooseAddress{
    AddressViewController * vc = [AddressViewController new];
    vc.type = @"comeFromTrans";
    vc.filterStr = self.typeString;
    vc.coinTagStr = self.coinTagString;
    
    PWS(weakSelf);
    vc.selectAddress = ^(NSString * _Nonnull address) {
        if (address.length > 0) {
            weakSelf.address = address;
            [weakSelf setDefaultData];
        }
    };
    [self.navigationController pushViewController:vc animated:YES];
}

/** 选择全部金额 */
- (void)chooseAmount{
    if ([PTool isString:self.balanceString]) {
        self.amount = self.balanceString;
        [self setDefaultData];
    }
}

#pragma mark - Getter Methods
- (BWNavView *)navView{
    if (!_navView) {
        _navView = [BWNavView new];
        NSString * title = [NSString stringWithFormat:@"%@ %@", self.typeString, Localized(@"转账")];
        if ([self.coinTagString isEqualToString:@"TRC20"]) {
            //代币
            title = [NSString stringWithFormat:@"%@(%@) %@", self.typeString, self.coinTagString, Localized(@"转账")];
        }
        _navView.title = title;
        _navView.rightImgStr = @"icon_scan";
        
        PWS(weakSelf);
        _navView.backBlock = ^{
            [weakSelf back];
        };
        _navView.rightBlock = ^{
            [weakSelf scan];
        };
    }
    return _navView;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        [_tableView registerClass:[TRXTransTableViewCell class] forCellReuseIdentifier:@"TRXTransTableViewCell"];
    }
    return _tableView;
}

- (UIButton *)submitBtn{
    if (!_submitBtn) {
        _submitBtn = [UIButton new];
        _submitBtn.backgroundColor = baseColor;
        [_submitBtn setTitle:Localized(@"提交") forState:UIControlStateNormal];
        [_submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _submitBtn.layer.cornerRadius = 4;
        _submitBtn.layer.masksToBounds = YES;
        _submitBtn.alpha = 0.3f;
        _submitBtn.userInteractionEnabled = NO;
        [_submitBtn addTarget:self action:@selector(clickSubmitBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _submitBtn;
}

#pragma mark - UITextFieldDelegate Methods
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    [self setDefaultData];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField.keyboardType == UIKeyboardTypeDecimalPad) {
        //限制只能输入数字
        BOOL isHaveDian = YES;
        if ([textField.text rangeOfString:@"."].location == NSNotFound) {
            isHaveDian = NO;
        }
        //存在小数点
        if (isHaveDian) {
            NSRange ran = [textField.text rangeOfString:@"."];
            NSArray * arr = [Coin MR_findByAttribute:@"address" withValue:self.addressString];
            NSString * decimals = @"6";
            for (Coin * coin in arr) {
                if ([self.typeString isEqualToString:coin.name] && [self.coinTagString isEqualToString:@"TRC20"] && coin.decimals && coin.decimals.length) {
                    decimals = coin.decimals;
                }
            }
            if (range.location - ran.location <= [decimals integerValue]) {
                return YES;
            } else {
                return NO;
            }
        }
    }
    return YES;
}

#pragma mark - TRXTransTableViewCellDelegate Methods
- (void)textFieldChangedWithTextField:(UITextField *)textField{
    TRXTransTableViewCell * cell = (TRXTransTableViewCell *)textField.superview.superview;
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath.row == 0) {
        self.address = textField.text;
    }
    if (indexPath.row == 1) {
        self.amount = textField.text;
    }
    [self changeBtnStatus];
}

- (void)changeBtnStatus{
    if (self.address.length > 0 && self.amount.length > 0) {
        self.submitBtn.alpha = 1;
        self.submitBtn.userInteractionEnabled = YES;
    } else {
        self.submitBtn.alpha = 0.3f;
        self.submitBtn.userInteractionEnabled = NO;
    }
}

- (void)clickRightBtnWithBtn:(UIButton *)sender{
    TRXTransTableViewCell * cell = (TRXTransTableViewCell *)sender.superview.superview;
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath.row == 0) {
        [self chooseAddress];
    }
    if (indexPath.row == 1) {
        [self chooseAmount];
        [self changeBtnStatus];
    }
}

#pragma mark - TRXTransFooterViewDelegate Methods
/** 感叹号说明 */
- (void)clickPlaintBtn{
    [self.view endEditing:YES];

    PJAlert * alert = [[PJAlert alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds Title:Localized(@"矿工费说明") Content:Localized(@"当用户发起一笔转账交易时，矿工费计算方法如下：\n-优先尝试消耗交易发起者的剩余带宽（Bandwidth Points）\n-如果账户中带宽不足，则消耗交易发起者余额中的TRX，交易的字节数*10 sun（1TRX = 1000000 sun）此处矿工费根据一般交易预估得出，最终实际消耗矿工费由波场网络决定，请知悉。") Confirm:Localized(@"确认")];
    alert.showTwoBtn = NO;
    alert.titleHidden = NO;
    [alert.confirmBtn setTitle:Localized(@"确认") forState:UIControlStateNormal];
    alert.confirm = ^(BOOL confirm) {
        
    };
    [[UIApplication sharedApplication].keyWindow addSubview:alert];
}

/** 提交 */
- (void)clickSubmitBtn{
    [self.view endEditing:YES];
    self.submitBtn.userInteractionEnabled = NO;

    [self validateAddress];
}

//MARK:判断输入的地址是否合法
- (void)validateAddress{
    [LSStatusBarHUD showLoading:Localized(@"loadingStr")];
    [[PWallet shareInstance] validAddress:self.address CoinType:@"TRX" valid:^(bool valid) {
        [LSStatusBarHUD hideLoading];
        self.submitBtn.userInteractionEnabled = YES;
        if (!valid) {
            [LSStatusBarHUD showMessageAndImage:Localized(@"您输入的地址不合法")];
        }else{
            if ([self isTransferAllowed]) {
                [self showTransDetailView];
            }
        }
    } failure:^(NSError * _Nonnull failure) {
        [LSStatusBarHUD hideLoading];
        self.submitBtn.userInteractionEnabled = YES;
    }];
}

//MARK:判断是否允许转账
- (BOOL)isTransferAllowed{
    if ([self.addressString isEqualToString:self.address]) {
        [PJToastView showInView:self.view text:Localized(@"不能给自己转账") duration:2 autoHide:YES];
        return NO;
    }
    if (![self.coinTagString isEqualToString:@"TRC20"]) {
        //主币
        if ([self.amount floatValue] <= 0) {
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:Localized(@"金额不能为0") message:nil preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *alertA = [UIAlertAction actionWithTitle:Localized(@"确定") style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alertC addAction:alertA];
            [self presentViewController:alertC animated:YES completion:nil];
            return NO;
        }
    }
    NSDecimalNumber * inputD = [NSDecimalNumber decimalNumberWithString:self.amount];
    NSDecimalNumber * balanceD = [NSDecimalNumber decimalNumberWithString:self.balanceString];
    //输入的转账金额大于当前资产金额
    if ([inputD compare:balanceD] == NSOrderedDescending) {
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:Localized(@"当前余额不足") message:nil preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *alertA = [UIAlertAction actionWithTitle:Localized(@"确定") style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertC addAction:alertA];
        [self presentViewController:alertC animated:YES completion:nil];
        return NO;
    }
    return YES;
}

- (void)showTransDetailView{
    NSDictionary * dic = @{@"trx":self.amount ? : @"", @"address":self.address ? : @"", @"fee":@"0"};
    [TRXTransDetailView showTransDetailViewWithDic:dic block:^{
        PwdInputView *inputView = [[PwdInputView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
        PWS(weakSelf);
        inputView.inputString = ^(NSString * _Nonnull str) {
            NSArray * arr = [Coin MR_findByAttribute:@"address" withValue:self.addressString];
            NSString * wallet_id = @"";
            for (Coin * coin in arr) {
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
    }];
}

/** SDK进行转账 */
- (void)transferAction:(NSString *)password{
    //获取Documents路径
    NSArray *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsPath = [[document objectAtIndex:0] stringByAppendingPathComponent:@"keystore"];
    [SVProgressHUD showWithStatus:Localized(@"提交中...")];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    NSArray * arr = [Coin MR_findByAttribute:@"address" withValue:self.addressString];
    NSString * type = [PTool getWalletInfo:((Coin *)arr[0]).wallet_id Type:@"type"];
    
    PWS(weakSelf);
    ApiTransferRequest *req = [[ApiTransferRequest alloc] init];
    NSDecimalNumber *amountD = [[NSDecimalNumber decimalNumberWithString:self.amount] decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:TRXTOSUN]];
    NSString * amout = [NSString stringWithFormat:@"%@", amountD];
    if ([self.coinTagString isEqualToString:@"TRC20"]) {
        //代币
        amout = self.amount;
    }
    req.amount = amout;
    req.coinType = @"TRX";
    req.feeRate = @"0";
    req.keyId = ((Coin *)arr[0]).wallet_id;
    req.keystoreDir = documentsPath;
    req.toAddress = weakSelf.address;
    req.passphrase = password;
    if ([weakSelf.coinTagString isEqualToString:@"TRC20"]) {//TRC20
        req.tokenType = self.typeString;
    }
    dispatch_queue_t queue = dispatch_queue_create("com.uvtoken.transfer", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        NSError *error = nil;
        if ([type isEqualToString:@"Multi"]) {
            for (Coin * coin in arr) {
                if ([weakSelf.typeString isEqualToString:coin.name]) {
                    DLog(@"多链钱包转账信息：%lld%lld%lld", coin.account, coin.change, coin.coin);
                    ApiTransferFromHdWalletRequest *hdReq = [[ApiTransferFromHdWalletRequest alloc] init];
                    if ([self.coinTagString isEqualToString:@"TRC20"]) {
                        req.tokenAddress = coin.contact_address;
                    }
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

/** 保存交易信息 */
- (void)saveTransInfoToLocalDBWithTxID:(NSString *)txid Nonce:(NSString *)nonce GasPrice:(NSString *)gasPrice{
    Record *record = [Record MR_createEntity];
    record.address = self.addressString;
    record.to_address = self.address;
    record.amount = self.amount;
    record.type = @"转账";
    record.tx_id = txid;
    record.name = self.typeString;
    record.coin_tag = self.coinTagString;
    record.memo = @"";
    record.start_time = [PTool getNowTimeTimestamp];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    [SVProgressHUD showSuccessWithStatus:Localized(@"提交成功")];
    [SVProgressHUD dismissWithDelay:1];
    [self.navigationController popViewControllerAnimated:YES];
}

/** 转账失败 */
- (void)showTransError:(NSError *)error{
    if ([SDKConfig isEqualToString:@"regtest"] || [SDKConfig isEqualToString:@"test"]) {
        [LSStatusBarHUD showMessageAndImage:[NSString stringWithFormat:@"%@:%@", Localized(@"提交失败"), error.localizedDescription]];
    } else {
        [LSStatusBarHUD showMessageAndImage:Localized(@"提交失败")];
    }
}

#pragma mark - UITableViewDataSource | UITableViewDelegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    return 76;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TRXTransTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"TRXTransTableViewCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    cell.textField.delegate = self;
    cell.dic = self.dataArray[indexPath.row];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    TRXTransFooterView * view = [[TRXTransFooterView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 300)];
    view.balance = self.balanceString;
    view.delegate = self;
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 300;
}
@end
