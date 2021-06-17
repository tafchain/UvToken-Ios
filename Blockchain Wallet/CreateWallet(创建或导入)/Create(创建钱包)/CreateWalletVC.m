//
//  CreateWalletVC.m
//  Blockchain Wallet
//
//  Created by Panerly on 2020/12/25.
//

#import "CreateWalletVC.h"
#import "AddCurrencyVC.h"
#import "CommonWebViewController.h"
#import "SecurityUtil.h"


@interface CreateWalletVC ()<UITextFieldDelegate>

@end

@implementation CreateWalletVC

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setUI];
}

- (void)setUI{
    
    self.titleLabel.text = Localized(@"创建钱包");
    self.walletNameLabel.text = Localized(@"钱包名称");
    self.walletNameTextField.placeholder = Localized(@"请输入名称");
    self.pwdLabel.text = Localized(@"密码");
    self.pwdTextField.placeholder = Localized(@"请输入密码");
    self.nameDesLabel.text = Localized(@"1-20位字符");
    self.pwdDesLabel.text = Localized(@"至少8位字符，包含大小写字母和数字");
    self.repeatLabel.text = Localized(@"重复密码");
    self.confirmPwdTextField.placeholder = Localized(@"请再次输入密码");
    self.agreeLabel.text = Localized(@"我已阅读并同意");
    [self.agreementBtn setTitle:Localized(@"《使用条款》") forState:UIControlStateNormal];
    [self.createBtn setTitle:Localized(@"创建") forState:UIControlStateNormal];

    [self.walletNameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.pwdTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.confirmPwdTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.walletNameTextField.delegate = self;
    
    NSString *str = @"";
    switch (self.type) {
        case ComeFromMnemonic:
            
            str = @"从导入助记词进入";
            self.titleLabel.text = Localized(@"导入钱包");
            [self.createBtn setTitle:Localized(@"完成") forState:UIControlStateNormal];
            break;
        case ComeFromPK:

            str = @"从导入私钥进入";
            self.titleLabel.text = [NSString stringWithFormat:@"%@ %@ %@",Localized(@"导入"), self.typeStr, Localized(@"钱包")];
            [self.createBtn setTitle:Localized(@"导入") forState:UIControlStateNormal];
            break;
        case ComeFromCreating:
            
            str = @"从创建钱包进入";
            break;
            
        default:
            break;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (range.length + range.location > textField.text.length) {
        return NO;
    }
    NSUInteger length = textField.text.length + string.length - range.length;
    return length <= 20;
}

- (IBAction)backAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
    
    [PTool saveValue:@" " forKey:@"creatingWalletAddress"];
}
- (IBAction)agreeAction:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        
        [sender setImage:[UIImage imageNamed:@"icon_agree_selected"] forState:UIControlStateNormal];
    }else{
        
        [sender setImage:[UIImage imageNamed:@"icon_agree_unselect"] forState:UIControlStateNormal];
    }
    [self.view endEditing:YES];
    [self textFieldDidChange:self.pwdTextField];
}

//确认按钮随输入变化
- (void)textFieldDidChange:(UITextField *)textField
{
    if (self.walletNameTextField.text.length < 1 || self.pwdTextField.text.length < 1 || self.confirmPwdTextField.text.length < 1 || !self.selectBtn.selected ) {
        
        self.createBtn.userInteractionEnabled = NO;
        self.createBtn.alpha = 0.3f;
    }else{
        
        self.createBtn.userInteractionEnabled = YES;
        self.createBtn.alpha = 1.0f;
    }
    
    if (self.walletNameTextField.text.length <1 || self.walletNameTextField.text.length >20) {
        
        self.lineView1.backgroundColor = [UIColor redColor];
        self.nameDesLabel.textColor = [UIColor redColor];
        self.createBtn.userInteractionEnabled = NO;
        self.createBtn.alpha = 0.3f;
    }else{
        
        self.lineView1.backgroundColor = [UIColor lightGrayColor];
        self.nameDesLabel.textColor = [UIColor darkGrayColor];
    }
    
    if (self.pwdTextField == textField) {
        
        if ([PTool isAvailablePwd:self.pwdTextField.text]) {
            self.lineView2.backgroundColor = [UIColor lightGrayColor];
            self.pwdDesLabel.textColor = [UIColor darkGrayColor];
        }else{
            self.lineView2.backgroundColor = [UIColor redColor];
            self.pwdDesLabel.textColor = [UIColor redColor];
            self.createBtn.userInteractionEnabled = NO;
            self.createBtn.alpha = 0.3f;
        }
    }
}

//是否显示密码
- (IBAction)showPwdAction:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        
        [sender setImage:[UIImage imageNamed:@"icon_eye_on"] forState:UIControlStateNormal];
        self.pwdTextField.secureTextEntry = NO;
    }else{
        
        [sender setImage:[UIImage imageNamed:@"icon_eye_off"] forState:UIControlStateNormal];
        self.pwdTextField.secureTextEntry = YES;
    }
}

- (IBAction)showRepeatPwdAction:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        
        [sender setImage:[UIImage imageNamed:@"icon_eye_on"] forState:UIControlStateNormal];
        self.confirmPwdTextField.secureTextEntry = NO;
    }else{
        
        [sender setImage:[UIImage imageNamed:@"icon_eye_off"] forState:UIControlStateNormal];
        self.confirmPwdTextField.secureTextEntry = YES;
    }
}


//MARK:创建钱包
- (IBAction)createWalletAction:(UIButton *)sender {
    
    if (![self.pwdTextField.text isEqualToString:self.confirmPwdTextField.text]) {
        [LSStatusBarHUD showMessageAndImage:Localized(@"两次输入的密码不一致")];
        return;
    }
    
    AddCurrencyVC *add = [AddCurrencyVC new];
    add.passwordString = self.pwdTextField.text;
    add.nameString = self.walletNameTextField.text;
    
    switch (self.type) {
        case ComeFromMnemonic:
            
            [PTool saveValue:@"ComeFromMnemonic" forKey:@"ComeFromType"];
            add.mnemonicString = self.mnemonicString;
            [self.navigationController pushViewController:add animated:YES];
            break;
        case ComeFromPK:
            
            [self validatePK];
            break;
        case ComeFromCreating:
            
            [PTool saveValue:@"ComeFromCreating" forKey:@"ComeFromType"];
            [self.navigationController pushViewController:add animated:YES];
            break;
            
        default:
            break;
    }
}


//使用条款
- (IBAction)agreementAction:(UIButton *)sender {
    
    CommonWebViewController *web = [[CommonWebViewController alloc] init];
//    web.webUrl = [NSString stringWithFormat:@"%@/purchase?language=%@", TaftDetailApi, [PTool getValueFromKey:@"appLanguage"]];
//    [PTool saveValue:@"YES" forKey:@"canLoadWebViewPage"];
    NSString *language = (NSString *)[PTool getValueFromKey:@"appLanguage"];
    if ([language isEqualToString:@"zh-Hans"]) {
        
        web.webUrl = @"https://wallet.uvtoken.com/wallet/clause/agreement/agreement.html";
    }else{
        
        web.webUrl = @"https://wallet.uvtoken.com/wallet/clause/agreement/agreement-en.html";
    }
    [self.navigationController pushViewController:web animated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

//MARK:导入指定私钥钱包
- (void)validatePK{
    
    [LSStatusBarHUD showLoading:Localized(@"正在导入...")];
    
    PWS(weakSelf);
    [[PWallet shareInstance] importPkWithCoinType:self.typeStr Password:self.pwdTextField.text PrivateKey:self.pkString response:^(AddCoinModel * _Nonnull response) {
        
        if (response && response.address) {
            
            NSArray *coinArr = [Coin MR_findAll];
            BOOL existPk = NO;
            for (Coin *coin in coinArr) {
                if ([coin.address isEqualToString:response.address]) {
                    existPk = YES;
                }
            }
            if (existPk) {
                
                [weakSelf deleteWalletWithWalletID:response.walletID Password:weakSelf.pwdTextField.text];
                return;
            }
            Wallet *wallet = [Wallet MR_createEntity];
            wallet.name = weakSelf.walletNameTextField.text;
            wallet.password = [SecurityUtil encryptAESData:weakSelf.pwdTextField.text];
            wallet.type = weakSelf.typeStr;
            wallet.wallet_id = response.keyId?response.keyId:response.walletID;
            wallet.is_backup = NO;
            
            Coin *coin = [Coin MR_createEntity];
            coin.wallet_id = response.keyId?response.keyId:response.walletID;
            coin.name = weakSelf.typeStr;
            coin.key_id = response.keyId?response.keyId:response.walletID;
            coin.address = response.address;
            coin.account = response.account;
            coin.change = response.change;
            coin.index = response.index;
            coin.coin = response.coin;
            
            if ([weakSelf.typeStr isEqualToString:@"BTC"]) {
                
                Coin *coin_usdt = [Coin MR_createEntity];
                coin_usdt.wallet_id = response.keyId?response.keyId:response.walletID;
                coin_usdt.name = @"USDT";
                coin_usdt.key_id = response.keyId?response.keyId:response.walletID;
                coin_usdt.address = response.address;
                coin_usdt.coin_tag = @"OMNI";
                coin_usdt.account = response.account;
                coin_usdt.change = response.change;
                coin_usdt.index = response.index;
                coin_usdt.coin = response.coin;
            }
            
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            
            [LSStatusBarHUD showMessage:Localized(@"导入成功")];
            [PTool saveValue:response.keyId?response.keyId:response.walletID forKey:@"defaultWalletAddress"];
            [self performSelector:@selector(enterHome) withObject:nil afterDelay:1];
        }
    } failure:^(NSError * _Nonnull failure) {
        
        if ([failure.localizedDescription isEqualToString:@"address already exists"]) {
            
            [LSStatusBarHUD showMessageAndImage:Localized(@"已存在，请勿重复导入")];
            Class repeatImportVC = NSClassFromString(@"RepeatImportVC");
            [self.navigationController pushViewController:[repeatImportVC new] animated:YES];
        }else{
            
            [LSStatusBarHUD showMessageAndImage:Localized(@"请输入正确的私钥地址")];
        }
    }];
}

//删除重复导入的keytore文件
- (void)deleteWalletWithWalletID:(NSString *)wallet_id Password:(NSString *)password{
    
    [[PWallet shareInstance] deleteSingleChainWalletWithKeyIDs:wallet_id Password:password success:^(bool success) {
        if (success) {
            [SVProgressHUD dismiss];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"wallet_id=%@", wallet_id];
            [Wallet MR_deleteAllMatchingPredicate:predicate];
            [Coin MR_deleteAllMatchingPredicate:predicate];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        }else{
            [SVProgressHUD dismiss];
        }
    } failure:^(NSError * _Nonnull failure) {
        [SVProgressHUD dismiss];
    }];
    
    [LSStatusBarHUD showMessageAndImage:Localized(@"已存在，请勿重复导入")];
    Class repeatImportVC = NSClassFromString(@"RepeatImportVC");
    [self.navigationController pushViewController:[repeatImportVC new] animated:YES];
}
- (void)enterHome{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:LOGINSELECTCENTERINDEX object:nil];
}

@end
