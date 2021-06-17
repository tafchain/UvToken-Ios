//
//  SelectWalletVC.h
//  Blockchain Wallet
//
//  Created by Panerly on 2020/12/25.
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SelectWalletVC : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *desLabel;
@property (weak, nonatomic) IBOutlet UILabel *createWalletLabel;
@property (weak, nonatomic) IBOutlet UILabel *createDesLabel;
@property (weak, nonatomic) IBOutlet UILabel *importWalletLabel;
@property (weak, nonatomic) IBOutlet UILabel *importWalletDesLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *importBtnHeightConstraint;

@end

NS_ASSUME_NONNULL_END
