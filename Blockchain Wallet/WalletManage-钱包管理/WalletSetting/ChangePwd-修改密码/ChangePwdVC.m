//
//  ChangePwdVC.m
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/19.
//

#import "ChangePwdVC.h"

@interface ChangePwdVC ()

@end

@implementation ChangePwdVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.prePwdTextField addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.pwdTextField addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.confirmTextField addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
    
    [self setUI];
}

- (void)setUI{
    
    self.prePwdLabel.text = Localized(@"原密码");
    self.pwdTitleLabel.text = Localized(@"密码");
    self.titleLabel.text = Localized(@"修改密码");
    self.confirmPwdTitleLabel.text = Localized(@"重复密码");
    self.pwdTextField.placeholder = Localized(@"请输入密码");
    self.prePwdTextField.placeholder = Localized(@"请输入原密码");
    self.confirmTextField.placeholder = Localized(@"请再次输入密码");
    self.pwdTipsLabel.text = Localized(@"至少8位字符，包含大小写字母和数字");
    self.prePwdTipsLabel.text = Localized(@"至少8位字符，包含大小写字母和数字");
    [self.changeBtn setTitle:Localized(@"确认修改") forState:UIControlStateNormal];
}

- (void)textFieldDidChanged:(UITextField *)textField {
    
    if (self.pwdTextField.text.length < 1 || self.confirmTextField.text.length < 1 || self.prePwdTextField.text.length < 1) {
        
        self.changeBtn.userInteractionEnabled = NO;
        self.changeBtn.alpha = 0.3f;
    }else{
        
        self.changeBtn.userInteractionEnabled = YES;
        self.changeBtn.alpha = 1.0f;
    }
    
    if (self.prePwdTextField == textField) {
        
        if ([PTool isAvailablePwd:self.prePwdTextField.text]) {
            self.lineView0.backgroundColor = [UIColor lightGrayColor];
            self.prePwdTipsLabel.textColor = [UIColor darkGrayColor];
        }else{
            self.lineView0.backgroundColor = [UIColor redColor];
            self.prePwdTipsLabel.textColor = [UIColor redColor];
            self.changeBtn.userInteractionEnabled = NO;
            self.changeBtn.alpha = 0.3f;
        }
    }
    if (self.pwdTextField == textField) {
        
        if ([PTool isAvailablePwd:self.pwdTextField.text]) {
            self.lineView1.backgroundColor = [UIColor lightGrayColor];
            self.pwdTipsLabel.textColor = [UIColor darkGrayColor];
        }else{
            self.lineView1.backgroundColor = [UIColor redColor];
            self.pwdTipsLabel.textColor = [UIColor redColor];
            self.changeBtn.userInteractionEnabled = NO;
            self.changeBtn.alpha = 0.3f;
        }
    }
}

- (IBAction)secureEntryAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    [sender setImage:[UIImage imageNamed:sender.selected?@"icon_eye_on":@"icon_eye_off"] forState:UIControlStateNormal];
    
    if (sender == self.secureEntryBtn1) {
        self.prePwdTextField.secureTextEntry = !sender.selected;
    }
    if (sender == self.secureEntryBtn2) {
        self.pwdTextField.secureTextEntry = !sender.selected;
    }
    if (sender == self.secureEntryBtn3) {
        self.confirmTextField.secureTextEntry = !sender.selected;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (IBAction)backAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//MARK:修改密码
- (IBAction)changePwdAction:(UIButton *)sender {
    if (![self.pwdTextField.text isEqualToString:self.confirmTextField.text]) {
        [LSStatusBarHUD showMessageAndImage:Localized(@"两次输入的密码不一致")];
        return;
    }
    [SVProgressHUD showWithStatus:Localized(@"修改中")];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    
    NSString *keyids = @"";
    PWS(weakSelf);
    [[PWallet shareInstance] changeWalletPwdWithKeyIDs:keyids PrevPassword:self.prePwdTextField.text NewPassword:self.pwdTextField.text WalletId:self.wallet_id success:^(bool success) {
        if (success) {
            [LSStatusBarHUD showMessage:@"修改成功"];
            [SVProgressHUD dismiss];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }else{
            [SVProgressHUD dismiss];
            [LSStatusBarHUD showMessageAndImage:Localized(@"修改失败")];
        }
    }];
}

- (void)onProgress:(NSString * _Nullable)keyId walletId:(NSString * _Nullable)walletId {
    dispatch_async(dispatch_get_main_queue(), ^{
        DLog(@"keyid%@---walletid:%@", keyId, walletId);
    });
}
@end
