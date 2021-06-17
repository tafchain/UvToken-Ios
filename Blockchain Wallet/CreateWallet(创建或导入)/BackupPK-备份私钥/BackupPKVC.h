//
//  BackupPKVC.h
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BackupPKVC : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *resCopyBtn;
@property (weak, nonatomic) IBOutlet UIView *alertView;
@property (weak, nonatomic) IBOutlet UIView *alertContentView;
@property (weak, nonatomic) IBOutlet UILabel *alertLabel;
@property (weak, nonatomic) IBOutlet UIButton *knowBtn;

@property (nonatomic, copy) NSString *wallet_id;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *key_id;
@property (nonatomic, copy) NSString *passwordString;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alertHeight;

@end

NS_ASSUME_NONNULL_END
