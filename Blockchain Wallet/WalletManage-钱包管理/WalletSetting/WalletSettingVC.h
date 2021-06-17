//
//  WalletSettingVC.h
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WalletSettingVC : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

@property (nonatomic, copy) NSString *wallet_id;
@property (nonatomic, copy) NSString *type;//是否是多链钱包 Mulity BTC ETH TAF

@end

NS_ASSUME_NONNULL_END
