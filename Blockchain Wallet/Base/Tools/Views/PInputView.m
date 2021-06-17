//
//  PInputView.m
//  Blockchain Wallet
//
//  Created by Panerly on 2020/12/30.
//

#import "PInputView.h"

@implementation PInputView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUI];
    }
    return self;
}

- (void)setUI{
    
    [[NSBundle mainBundle] loadNibNamed:@"PInputView"owner:self options:nil];
    self.baseView.frame = CGRectMake(0, 10, self.frame.size.width, self.frame.size.height);
    [self addSubview:self.baseView];
    
    [self.textField1 addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.textField2 addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.textField3 addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.textField4 addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.textField5 addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.textField6 addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.textField7 addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.textField8 addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.textField9 addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.textField10 addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.textField11 addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.textField12 addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.textField1.delegate = self;
    self.textField2.delegate = self;
    self.textField3.delegate = self;
    self.textField4.delegate = self;
    self.textField5.delegate = self;
    self.textField6.delegate = self;
    self.textField7.delegate = self;
    self.textField8.delegate = self;
    self.textField9.delegate = self;
    self.textField10.delegate = self;
    self.textField11.delegate = self;
    self.textField12.delegate = self;
    
    ((CusTextField *)self.textField1).pjTextFielddelegate = self;
    ((CusTextField *)self.textField2).pjTextFielddelegate = self;
    ((CusTextField *)self.textField3).pjTextFielddelegate = self;
    ((CusTextField *)self.textField4).pjTextFielddelegate = self;
    ((CusTextField *)self.textField5).pjTextFielddelegate = self;
    ((CusTextField *)self.textField6).pjTextFielddelegate = self;
    ((CusTextField *)self.textField7).pjTextFielddelegate = self;
    ((CusTextField *)self.textField8).pjTextFielddelegate = self;
    ((CusTextField *)self.textField9).pjTextFielddelegate = self;
    ((CusTextField *)self.textField10).pjTextFielddelegate = self;
    ((CusTextField *)self.textField11).pjTextFielddelegate = self;
    ((CusTextField *)self.textField12).pjTextFielddelegate = self;
    
    
//    self.textField1.hidden = YES;
//    self.textField2.hidden = YES;
//    self.textField3.hidden = YES;
//    self.textField4.hidden = YES;
//    self.textField5.hidden = YES;
//    self.textField6.hidden = YES;
//    self.textField7.hidden = YES;
//    self.textField8.hidden = YES;
//    self.textField9.hidden = YES;
//    self.textField10.hidden = YES;
//    self.textField11.hidden = YES;
//    self.textField12.hidden = YES;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    
    [[NSBundle mainBundle] loadNibNamed:@"PInputView"owner:self options:nil];
    self.baseView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self addSubview:self.baseView];
}

- (void)textFieldDidChange:(UITextField *)textField
{
    if ([textField.text containsString:@" "]) {
        
        [self nextResonseTextField:textField];
    }
    //过滤空格
    NSString *tem = [[textField.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsJoinedByString:@""];
    textField.text = tem;
}

//MARK:UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self nextResonseTextField:textField];
    if (textField.returnKeyType == UIReturnKeyDone) {
        [textField resignFirstResponder];
        
        NSString *allStr = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@ %@ %@ %@ %@ %@ %@", self.textField1.text, self.textField2.text, self.textField3.text, self.textField4.text, self.textField5.text, self.textField6.text, self.textField7.text, self.textField8.text, self.textField9.text, self.textField10.text, self.textField11.text, self.textField12.text];
        NSString *newStr =  [allStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (newStr.length > 0) {
            if (self.inputBlock) {
                self.inputBlock(allStr);
            }
        }
    }
    return YES;
}

//MARK:PJTextFieldDelegate
- (void)pjTextFieldDeleteBackward:(CusTextField *)textField{
    if (self.textField1 == textField) {
        
        return;
    }else if (self.textField2 == textField){
        if (textField.text.length < 1) {
            [self.textField1 becomeFirstResponder];
//            self.textField2.hidden = YES;
        }
    }else if (self.textField3 == textField){
        if (textField.text.length < 1) {
            [self.textField2 becomeFirstResponder];
//            self.textField3.hidden = YES;
        }
    }else if (self.textField4 == textField){
        if (textField.text.length < 1) {
            [self.textField3 becomeFirstResponder];
//            self.textField4.hidden = YES;
        }
    }else if (self.textField5 == textField){
        if (textField.text.length < 1) {
            [self.textField4 becomeFirstResponder];
//            self.textField5.hidden = YES;
        }
    }else if (self.textField6 == textField){
        if (textField.text.length < 1) {
            [self.textField5 becomeFirstResponder];
//            self.textField6.hidden = YES;
        }
    }else if (self.textField7 == textField){
        if (textField.text.length < 1) {
            [self.textField6 becomeFirstResponder];
//            self.textField7.hidden = YES;
        }
    }else if (self.textField8 == textField){
        if (textField.text.length < 1) {
            [self.textField7 becomeFirstResponder];
//            self.textField8.hidden = YES;
        }
    }else if (self.textField9 == textField){
        if (textField.text.length < 1) {
            [self.textField8 becomeFirstResponder];
//            self.textField9.hidden = YES;
        }
    }else if (self.textField10 == textField){
        if (textField.text.length < 1) {
            [self.textField9 becomeFirstResponder];
//            self.textField10.hidden = YES;
        }
    }else if (self.textField11 == textField){
        if (textField.text.length < 1) {
            [self.textField10 becomeFirstResponder];
//            self.textField11.hidden = YES;
        }
    }else if (self.textField12 == textField){
        if (textField.text.length < 1) {
            [self.textField11 becomeFirstResponder];
//            self.textField12.hidden = YES;
        }
    }
    if (textField.text.length < 1) {
        textField.backgroundColor = [UIColor whiteColor];
    }
}

- (void)nextResonseTextField:(UITextField *)textField{
    
    if (self.textField1 == textField) {
        
        [self.textField2 becomeFirstResponder];
//        self.textField2.hidden = NO;
    }else if (self.textField2 == textField) {
        
        [self.textField3 becomeFirstResponder];
//        self.textField3.hidden = NO;
    }else if (self.textField3 == textField) {
        
        [self.textField4 becomeFirstResponder];
//        self.textField4.hidden = NO;
    }else if (self.textField4 == textField) {
        
        [self.textField5 becomeFirstResponder];
//        self.textField5.hidden = NO;
    }else if (self.textField5 == textField) {
        
        [self.textField6 becomeFirstResponder];
//        self.textField6.hidden = NO;
    }else if (self.textField6 == textField) {
        
        [self.textField7 becomeFirstResponder];
//        self.textField7.hidden = NO;
    }else if (self.textField7 == textField) {
        
        [self.textField8 becomeFirstResponder];
//        self.textField8.hidden = NO;
    }else if (self.textField8 == textField) {
        
        [self.textField9 becomeFirstResponder];
//        self.textField9.hidden = NO;
    }else if (self.textField9 == textField) {
        
        [self.textField10 becomeFirstResponder];
//        self.textField10.hidden = NO;
    }else if (self.textField10 == textField) {
        
        [self.textField11 becomeFirstResponder];
//        self.textField11.hidden = NO;
    }else if (self.textField11 == textField) {
        
        [self.textField12 becomeFirstResponder];
//        self.textField12.hidden = NO;
    }
}

- (void)setWrongNum:(NSInteger)wrongNum{
    _wrongNum = wrongNum;

    for (UIStackView *stackView in self.baseStackView.subviews) {
        
        for (UIView *view in stackView.subviews) {
            
            for (UITextField *textField in view.subviews) {
                
                if (textField.tag == 500+wrongNum) {
                    
                    textField.backgroundColor = [UIColor redColor];
                }
            }
        }
    }
}

@end
