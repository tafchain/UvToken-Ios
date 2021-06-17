//
//  ChagneWalletNameVC.h
//  Blockchain Wallet
//
//  Created by Panerly on 2021/2/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChagneWalletNameVC : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *walletNameLabel;

@property (weak, nonatomic) IBOutlet UITextField *walletNameTextField;

@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;

@property (nonatomic, copy) NSString *wallet_id;

@property (nonatomic, copy) NSString *wallet_name;

@end

NS_ASSUME_NONNULL_END
