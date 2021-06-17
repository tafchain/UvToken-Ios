//
//  BackupPKTypeVC.h
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BackupPKTypeVC : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, copy) NSString *wallet_id;
@property (nonatomic, copy) NSString *passwordString;
@property (nonatomic, copy) NSString *type;

@end

NS_ASSUME_NONNULL_END
