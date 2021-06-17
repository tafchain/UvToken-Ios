//
//  WalletViewController.h
//  Blockchain Wallet
//
//  Created by Panerly on 2020/12/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WalletViewController : UIViewController

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tipsViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *tipsView;
@property (weak, nonatomic) IBOutlet UIButton *walletNameBtn;

@property (weak, nonatomic) IBOutlet UILabel *zczzLabel;
@property (weak, nonatomic) IBOutlet UILabel *aqtxLabel;
@property (weak, nonatomic) IBOutlet UILabel *aqtxContentLabel;
@property (weak, nonatomic) IBOutlet UIButton *backupBtn;

@property (weak, nonatomic) IBOutlet UILabel *zcLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;

@property (weak, nonatomic) IBOutlet UIImageView *currencyImgView;
@property (weak, nonatomic) IBOutlet UILabel *equalLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *balanceToLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewHeight;
@property (weak, nonatomic) IBOutlet UIButton *addCurrencyBtn;
@property (weak, nonatomic) IBOutlet UIButton *scanBtn;

@property (weak, nonatomic) IBOutlet UIButton *showBalanceBtn;
@property (weak, nonatomic) IBOutlet UILabel *networkStatusLabel;

@end

NS_ASSUME_NONNULL_END
