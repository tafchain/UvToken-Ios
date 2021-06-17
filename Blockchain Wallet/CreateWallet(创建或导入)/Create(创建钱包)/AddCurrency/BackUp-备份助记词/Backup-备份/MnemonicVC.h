//
//  MnemonicVC.h
//  Blockchain Wallet
//
//  Created by Panerly on 2020/12/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MnemonicVC : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;
@property (weak, nonatomic) IBOutlet UIButton *finishBtn;
@property (weak, nonatomic) IBOutlet UIView *alertView;
@property (weak, nonatomic) IBOutlet UIView *alertContentView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *alertLabel;
@property (weak, nonatomic) IBOutlet UIButton *knowBtn;

@property (weak, nonatomic) IBOutlet UIButton *mnemonicCopyBtn;

@property (nonatomic, strong) NSString *backupConfig;
@property (nonatomic, strong) NSString *wallet_id;

@property (nonatomic, copy) NSString *pwdStr;

@end

NS_ASSUME_NONNULL_END
