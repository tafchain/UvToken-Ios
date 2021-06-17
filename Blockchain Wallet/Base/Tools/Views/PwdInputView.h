//
//  PwdInputView.h
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^InputString)(NSString *str);

@interface PwdInputView : UIView

@property (strong, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *darkBgView;

@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UIButton *secureEntryBtn;

@property (nonatomic, copy) InputString inputString;

@end

NS_ASSUME_NONNULL_END
