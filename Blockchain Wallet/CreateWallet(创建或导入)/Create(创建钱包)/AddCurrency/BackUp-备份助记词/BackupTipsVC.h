//
//  BackupTipsVC.h
//  Blockchain Wallet
//
//  Created by Panerly on 2020/12/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BackupTipsVC : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *midLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipsDesLabel;
@property (weak, nonatomic) IBOutlet UIButton *backupBtn;
@property (weak, nonatomic) IBOutlet UIButton *laterBackUpBtn;

@property (nonatomic, strong) NSString *backupConfig;
@property (nonatomic, strong) NSString *wallet_id;
@property (nonatomic, strong) NSString *pwdStr;

@end

NS_ASSUME_NONNULL_END
