//
//  PJTextField.h
//  Taft
//
//  Created by panerly on 2020/11/18.
//  Copyright © 2020 panerly. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PJTextField : UITextField<UITextFieldDelegate>{
    
}
-(void) setLineDisabledColor:(UIColor *)aLineDisabledColor NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;
-(void) setLineNormalColor:(UIColor *)aLineNormalColor NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;
-(void) setLineSelectedColor:(UIColor *)aLineSelectedColor NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;
-(void) setInputTextColor:(UIColor *)anInputTextColor NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;
-(void) setInputPlaceHolderColor:(UIColor *)anInputPlaceHolderColor NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;
-(void) setPlaceHolderFont:(UIFont *)font NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;
-(void) setInputFont:(UIFont *)font NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;
-(void) updateText:(NSString *) aText;

@end


NS_ASSUME_NONNULL_END
