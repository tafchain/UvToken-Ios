//
//  ConfirmMnemonicVC.h
//  Blockchain Wallet
//
//  Created by Panerly on 2020/12/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^Animation)(void);

@interface ConfirmMnemonicVC : UIViewController

@property (weak, nonatomic) IBOutlet UIStackView *baseSelectView;
@property (weak, nonatomic) IBOutlet UIStackView *view1;
@property (weak, nonatomic) IBOutlet UIStackView *view2;
@property (weak, nonatomic) IBOutlet UIStackView *view3;
@property (weak, nonatomic) IBOutlet UIStackView *view4;
@property (weak, nonatomic) IBOutlet UIButton *finishBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;

@property (nonatomic, strong) NSString *backupConfig;
@property (nonatomic, strong) NSString *mnemonicString;
@property (nonatomic, strong) NSString *wallet_id;

@end

NS_ASSUME_NONNULL_END
