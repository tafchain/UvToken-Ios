//
//  PJTextField.m
//  Taft
//
//  Created by panerly on 2020/11/18.
//  Copyright © 2020 panerly. All rights reserved.
//

#import "PJTextField.h"
#define kAnimationOffSet 23
#define kSpaceToLine 2
#define kSpaceToPlaceHolder 22

@implementation PJTextField{
    CGRect frame;
    UIView *lineView;
    NSString *placeHolderString;
    UILabel *placeHolderLabel;
    UIColor *lineSelectedColor;
    UIColor *lineNormalColor;
    UIColor *lineDisabledColor;
    UIColor *inputTextColor;
    UIColor *placeHolderColor;
    double animationDuration;
    CGRect aFrame;
    CGRect framePlaceHolder;
    int offSetSizeTextField;
    UIFont *inputFont;
    UIFont *placeHolderFont;
    UIFont *placeHolderFontFloat;
    BOOL createdPlaceHolder;
}


- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        //frame = self.bounds;
        offSetSizeTextField = 14;
        self.lineSelectedColor = baseColor;
        self.lineNormalColor   = [UIColor colorWithRed:1 green:1 blue:1 alpha:.3];
        self.lineDisabledColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.3];
        self.textColor     = [UIColor blackColor];
        self.delegate = self;
//        self.textColor = inputTextColor;
        self.textColor = [UIColor whiteColor];
        [self addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
//        placeHolderString = self.placeholder;
//        self.placeholder = NULL;
        self.font = [UIFont systemFontOfSize:14];
        [self createLineInput];
//        [self createPlaceHolderInput];
        self.borderStyle = UITextBorderStyleNone;
        animationDuration = 0.1;
        aFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height + offSetSizeTextField);
    }
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    lineView.frame = CGRectMake(0,  self.frame.size.height - 10  , self.frame.size.width, 1);
    if (!createdPlaceHolder) {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height + offSetSizeTextField);
//        placeHolderLabel.frame = CGRectMake(0, (self.frame.size.height/2) - kSpaceToPlaceHolder, self.frame.size.width, self.frame.size.height);
        createdPlaceHolder = YES;
    }
}

-(void) createLineInput{
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height + kSpaceToLine , frame.size.width, .5f)];
    lineView.backgroundColor = lineNormalColor;
    [self addSubview:lineView];
}

-(void) createPlaceHolderInput{
    placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y + kSpaceToPlaceHolder, frame.size.width, frame.size.height)];
    placeHolderLabel.text = placeHolderString;
    placeHolderLabel.font = placeHolderFont;
    
    placeHolderLabel.textColor = [UIColor grayColor];
    placeHolderLabel.alpha = 1;
    self.tintColor = [UIColor grayColor];
    [self addSubview:placeHolderLabel];
}

#pragma mark UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [UIView animateWithDuration:animationDuration animations:^(void){
        self->lineView.backgroundColor = self->lineSelectedColor;
        if (textField.text.length == 0) {
            
            self->placeHolderLabel.frame = CGRectMake(self->placeHolderLabel.frame.origin.x, self->placeHolderLabel.frame.origin.y-kAnimationOffSet, self->placeHolderLabel.frame.size.width, self->placeHolderLabel.frame.size.height);
            self->placeHolderLabel.font = self->placeHolderFontFloat;
            
        }
    }completion:^(BOOL finished) {
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [UIView animateWithDuration:animationDuration animations:^(void){
        self->lineView.backgroundColor = self->lineNormalColor;
        if (textField.text.length == 0) {
            
            self->placeHolderLabel.frame = CGRectMake(self->placeHolderLabel.frame.origin.x, self->placeHolderLabel.frame.origin.y+kAnimationOffSet, self->placeHolderLabel.frame.size.width, self->placeHolderLabel.frame.size.height);
            self->placeHolderLabel.font = self->placeHolderFont;
        }
    }];
}

-(void) setEnabled:(BOOL)enabled{
    super.enabled = enabled;
    if (!enabled) {
        lineView.hidden = YES;
    }else{
        lineView.hidden = NO;
    }
}

- (void)textFieldDidChange:(id)sender
{
#warning 更改为固定字体
//    UITextField *textField = (UITextField *)sender;
    //Handle problem with font size when using secure text Entry
//    if (textField.text.length > 0) {
//        textField.font = inputFont;
//    }
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds, 0 ,0);
}

#pragma mark - Override default properties
-(void)setLineDisabledColor:(UIColor *)aLineDisabledColor{
    lineDisabledColor = aLineDisabledColor;
}

-(void) setLineNormalColor:(UIColor *)aLineNormalColor{
    lineNormalColor = aLineNormalColor;
}

-(void) setLineSelectedColor:(UIColor *)aLineSelectedColor{
    lineSelectedColor = aLineSelectedColor;
}

-(void) setInputTextColor:(UIColor *)anInputTextColor{
    inputTextColor = anInputTextColor;
    self.textColor = inputTextColor;
}

-(void) setInputPlaceHolderColor:(UIColor *)anInputPlaceHolderColor{
    placeHolderColor = anInputPlaceHolderColor;
    placeHolderLabel.textColor = placeHolderColor;
}

-(void) updateText:(NSString *) aText{
    if (aText.length > 0) {
    
        placeHolderLabel.frame = CGRectMake(placeHolderLabel.frame.origin.x, placeHolderLabel.frame.origin.y-kAnimationOffSet, placeHolderLabel.frame.size.width, placeHolderLabel.frame.size.height);
        placeHolderLabel.font = placeHolderFont;
    }
    
    self.text = aText;
}

-(void) setInputFont:(UIFont *)font NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR{
    inputFont = font;
    self.font = inputFont;
}

-(void) setPlaceHolderFont:(UIFont *)font NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR{
    placeHolderFont = font;
    placeHolderFontFloat = [UIFont fontWithName:placeHolderFont.fontName size:14];
    placeHolderLabel.font = placeHolderFont;
    
    if (self.text.length > 0 ){
        placeHolderLabel.font = placeHolderFontFloat;
    }
}


#pragma UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

@end
