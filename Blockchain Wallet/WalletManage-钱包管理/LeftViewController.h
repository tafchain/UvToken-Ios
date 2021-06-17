//
//  LeftViewController.h
//  Blockchain Wallet
//
//  Created by Panerly on 2020/12/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^SelectedWallet)(NSString *walletName ,NSString *type);

@interface LeftViewController : UIViewController

@property (nonatomic, copy) SelectedWallet selectedWallet;
@property (weak, nonatomic) IBOutlet UILabel *qbglLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *createWalletBtn;
@property (weak, nonatomic) IBOutlet UIButton *importWalletBtn;

@end

NS_ASSUME_NONNULL_END
