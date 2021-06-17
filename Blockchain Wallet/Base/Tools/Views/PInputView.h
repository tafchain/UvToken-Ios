//
//  PInputView.h
//  Blockchain Wallet
//
//  Created by Panerly on 2020/12/30.
//

#import <UIKit/UIKit.h>
#import "CusTextField.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^InputBlock)(NSString *inputText);

@interface PInputView : UIView
<UITextFieldDelegate, PJTextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIView *baseView;

@property (weak, nonatomic) IBOutlet UIStackView *baseStackView;

@property (weak, nonatomic) IBOutlet UITextField *textField1;
@property (weak, nonatomic) IBOutlet UITextField *textField2;
@property (weak, nonatomic) IBOutlet UITextField *textField3;
@property (weak, nonatomic) IBOutlet UITextField *textField4;
@property (weak, nonatomic) IBOutlet UITextField *textField5;
@property (weak, nonatomic) IBOutlet UITextField *textField6;
@property (weak, nonatomic) IBOutlet UITextField *textField7;
@property (weak, nonatomic) IBOutlet UITextField *textField8;
@property (weak, nonatomic) IBOutlet UITextField *textField9;
@property (weak, nonatomic) IBOutlet UITextField *textField10;
@property (weak, nonatomic) IBOutlet UITextField *textField11;
@property (weak, nonatomic) IBOutlet UITextField *textField12;


@property (nonatomic, copy) InputBlock inputBlock;

@property (nonatomic, assign) NSInteger wrongNum;

@end

NS_ASSUME_NONNULL_END
