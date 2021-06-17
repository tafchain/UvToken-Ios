//
//  ChagneWalletNameVC.m
//  Blockchain Wallet
//
//  Created by Panerly on 2021/2/20.
//

#import "ChagneWalletNameVC.h"

@interface ChagneWalletNameVC ()<UITextFieldDelegate>

@end

@implementation ChagneWalletNameVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUI];
}

- (void)setUI{
    self.titleLabel.text = Localized(@"修改钱包名称");
    self.walletNameLabel.text = Localized(@"新名称");
    self.walletNameTextField.placeholder = Localized(@"请输入新名称");
    [self.confirmBtn setTitle:Localized(@"确认修改") forState:UIControlStateNormal];
    [self.walletNameTextField addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
    self.walletNameTextField.delegate = self;
    self.walletNameTextField.text = self.wallet_name;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (range.length + range.location > textField.text.length) {
        return NO;
    }
    NSUInteger length = textField.text.length + string.length - range.length;
    return length <= 20;
}

- (void)textFieldDidChanged:(UITextField *)textField {
    if (self.walletNameTextField.text.length < 1) {
        self.confirmBtn.userInteractionEnabled = NO;
        self.confirmBtn.alpha = 0.3f;
    }else{
        self.confirmBtn.userInteractionEnabled = YES;
        self.confirmBtn.alpha = 1.0f;
    }
}

- (IBAction)backAction:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

//修改钱包名称
- (IBAction)changeAction:(UIButton *)sender {
    if (self.walletNameTextField.text.length > 20) {
        [PJToastView showInView:self.view text:Localized(@"请输入1-20位字符") duration:2 autoHide:YES];
        return;
    }
    NSArray *arr = [Wallet MR_findByAttribute:@"wallet_id" withValue:self.wallet_id];
    for (Wallet *wallet in arr) {
        wallet.name = self.walletNameTextField.text;
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        [SVProgressHUD showSuccessWithStatus:Localized(@"修改成功")];
        [SVProgressHUD dismissWithDelay:1.5f];
        NSString *defaultWallet = (NSString *)[PTool getValueFromKey:@"defaultWalletAddress"];
        //当前所修改的钱包是首页的钱包，需要刷新首页钱包名称
        if ([defaultWallet isEqualToString:self.wallet_id]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:CHANGECURRENCY object:nil];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
@end
