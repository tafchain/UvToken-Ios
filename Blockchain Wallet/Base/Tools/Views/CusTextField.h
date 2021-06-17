//
//  CusTextField.h
//  Blockchain Wallet
//
//  Created by Panerly on 2020/12/31.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CusTextField;

@protocol PJTextFieldDelegate <NSObject>

- (void)pjTextFieldDeleteBackward:(CusTextField *)textField;

@end

@interface CusTextField : UITextField

@property (nonatomic, strong) id <PJTextFieldDelegate>pjTextFielddelegate;

@end

NS_ASSUME_NONNULL_END
