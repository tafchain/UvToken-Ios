//
//  CreateWalletVC.h
//  Blockchain Wallet
//
//  Created by Panerly on 2020/12/25.
//



#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef enum : NSUInteger {
    ComeFromPK,
    ComeFromMnemonic,
    ComeFromCreating,
    ComeFromHomeCreating,
} ComeFromType;


@interface CreateWalletVC : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *walletNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *pwdLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameDesLabel;
@property (weak, nonatomic) IBOutlet UILabel *pwdDesLabel;
@property (weak, nonatomic) IBOutlet UILabel *repeatLabel;
@property (weak, nonatomic) IBOutlet UILabel *agreeLabel;

@property (weak, nonatomic) IBOutlet UITextField *walletNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPwdTextField;
@property (weak, nonatomic) IBOutlet UIButton *createBtn;
@property (weak, nonatomic) IBOutlet UIButton *agreementBtn;
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;

@property (weak, nonatomic) IBOutlet UIView *lineView1;
@property (weak, nonatomic) IBOutlet UIView *lineView2;

@property (nonatomic, assign) ComeFromType type;//导入私钥 导入助记词 创建钱包 首页进入创建钱包
@property (nonatomic, copy) NSString *mnemonicString;
@property (nonatomic, copy) NSString *pkString;
@property (nonatomic, copy) NSString *typeStr;//ETH BTC TAF...

@end

NS_ASSUME_NONNULL_END
