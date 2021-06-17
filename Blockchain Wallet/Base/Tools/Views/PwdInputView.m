//
//  PwdInputView.m
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/12.
//

#import "PwdInputView.h"

@implementation PwdInputView


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"PwdInputView"owner:self options:nil];
        self.baseView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [self addSubview:self.baseView];
        
        [self exChangeOut:self.contentView dur:.4];
        [self setUI];
    }
    return self;
}

- (void)setUI{
    
    self.titleLabel.text = Localized(@"输入密码");
    self.pwdTextField.placeholder = Localized(@"请输入密码");
    [self.confirmBtn setTitle:Localized(@"确定") forState:UIControlStateNormal];
    
    [self.pwdTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)textFieldDidChange:(UITextField *)textField{
    if (textField.text.length > 0) {
        self.confirmBtn.userInteractionEnabled = YES;
        self.confirmBtn.alpha = 1;
    }else{
        self.confirmBtn.userInteractionEnabled = NO;
        self.confirmBtn.alpha = 0.3f;
    }
}
- (IBAction)secureEntryAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.pwdTextField.secureTextEntry = !sender.selected;
    [self.secureEntryBtn setImage:[UIImage imageNamed:sender.selected?@"icon_eye_on":@"icon_eye_off"] forState:UIControlStateNormal];
}


- (IBAction)confirmAction:(UIButton *)sender {
    
    [self.pwdTextField resignFirstResponder];
    if (self.inputString) {
        self.inputString(self.pwdTextField.text);
    }
    
    [self.contentView.layer removeAllAnimations];
    [UIView animateWithDuration:.3 animations:^{
        
        self.contentView.transform = CGAffineTransformMakeScale(.01, .01);
        self.contentView.alpha = 0;
        self.darkBgView.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

-(void)awakeFromNib {
    [super awakeFromNib];
    
    [[NSBundle mainBundle] loadNibNamed:@"PwdInputView"owner:self options:nil];
    self.baseView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self addSubview:self.baseView];
}

- (void)exChangeOut:(UIView *)changeOutView dur:(CFTimeInterval)dur{
    
    CAKeyframeAnimation * animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = dur;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
//    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 0.9)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animation.values = values;
    animation.timingFunction = [CAMediaTimingFunction functionWithName: @"easeInEaseOut"];
    [changeOutView.layer addAnimation:animation forKey:nil];
}

- (IBAction)closeAction:(UIButton *)sender {
    
    [self.contentView.layer removeAllAnimations];
    [UIView animateWithDuration:.3 animations:^{
        
        self.contentView.transform = CGAffineTransformMakeScale(.01, .01);
        self.contentView.alpha = 0;
        self.darkBgView.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self endEditing:YES];
}

@end
