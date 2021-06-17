//
//  ChangePwdVC.h
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChangePwdVC : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, copy) NSString *wallet_id;
@property (weak, nonatomic) IBOutlet UILabel *pwdTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *confirmPwdTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *pwdTipsLabel;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmTextField;
@property (weak, nonatomic) IBOutlet UIView *lineView1;
@property (weak, nonatomic) IBOutlet UIButton *changeBtn;
@property (weak, nonatomic) IBOutlet UILabel *prePwdLabel;
@property (weak, nonatomic) IBOutlet UITextField *prePwdTextField;
@property (weak, nonatomic) IBOutlet UILabel *prePwdTipsLabel;

@property (nonatomic, copy) NSString *pwdStr;
@property (weak, nonatomic) IBOutlet UIView *lineView0;

@property (weak, nonatomic) IBOutlet UIButton *secureEntryBtn1;
@property (weak, nonatomic) IBOutlet UIButton *secureEntryBtn2;
@property (weak, nonatomic) IBOutlet UIButton *secureEntryBtn3;


@end

NS_ASSUME_NONNULL_END
