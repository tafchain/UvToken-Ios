//
//  PJAlert.m
//  Dow
//
//  Created by panerly on 2019/3/8.
//  Copyright © 2019 panerly. All rights reserved.
//

#import "PJAlert.h"

@implementation PJAlert

- (instancetype)initWithFrame:(CGRect)frame Title:(nonnull NSString *)title Content:(nonnull NSString *)content Confirm:(nonnull NSString *)confirmString
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"PJAlert"owner:self options:nil];
        self.baseView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        
        self.alertTitleLabel.text = title;
        self.alertContentLabel.text = content;
        [self.confirmBtn setTitle:confirmString forState:UIControlStateNormal];
        
        [self setUI];
    }
    return self;
}

- (void)setTitleHidden:(BOOL)titleHidden{
    _titleHidden = titleHidden;
    
    if (_titleHidden) {
        
        self.alertTitleLabel.hidden = YES;
        self.alertContentTopConstraint.constant = -26;
        self.alertViewHeightConstraint.constant = 156+[self measureMutilineStringHeight:self.alertContentLabel.text andFont:[UIFont systemFontOfSize:13] andWidthSetup:KScreenWidth - 26*2 - 48*2]-49;
    }else{
        
        self.alertViewHeightConstraint.constant = 94+68+[self measureMutilineStringHeight:self.alertContentLabel.text andFont:[UIFont systemFontOfSize:13] andWidthSetup:KScreenWidth - 26*2 - 48*2];
    }
}

- (void)setShowTwoBtn:(BOOL)showTwoBtn{
    _showTwoBtn = showTwoBtn;
    
    if (_showTwoBtn) {
        self.confirmBtn.hidden = YES;
        self.cancelBtn.hidden = NO;
        self.rightConfirmBtn.hidden = NO;
//        [PTool addBorderWithView:self.cancelBtn Color:COLORRGB(232, 188, 112) BorderWidth:1 CornerRadius:5];
//        [self.cancelBtn setTitleColor:COLORRGB(232, 188, 112) forState:UIControlStateNormal];
    }else{
        self.cancelBtn.hidden = YES;
        self.rightConfirmBtn.hidden = YES;
        self.confirmBtn.hidden = NO;
    }
}


- (void)setUI {
    
    [self.rightConfirmBtn setTitle:Localized(@"取消") forState:UIControlStateNormal];
    [self.cancelBtn setTitle:Localized(@"立即备份") forState:UIControlStateNormal];
    [PTool addBorderWithView:self.rightConfirmBtn Color:baseColor BorderWidth:1 CornerRadius:5];
    
    
    [self addSubview:self.baseView];
    [self exChangeOut:self.alertView dur:.4];
}


-(float)measureMutilineStringHeight:(NSString*)str andFont:(UIFont*)wordFont andWidthSetup:(float)width{
    
    if (str == nil || width <= 0){
        
        return 0;
    }
    
    CGSize measureSize = [str boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:wordFont, NSFontAttributeName, nil] context:nil].size;
    
    return ceil(measureSize.height);
}

- (IBAction)confirmAction:(id)sender {
//    if (self.confirm) {
//        self.confirm(YES);
//    }
    [self removeFromSuperview];
}

- (IBAction)cancelAction:(UIButton *)sender {
    
    if (self.confirm) {
        self.confirm(YES);
    }
    
    [self removeFromSuperview];
}

- (void)setConfirmString:(NSString *)confirmString{
    _confirmString = confirmString;
    [self.rightConfirmBtn setTitle:confirmString forState:UIControlStateNormal];
}

//缩放动画
- (void)animationWithView:(UIView *)view duration:(CFTimeInterval)duration{
    
    CABasicAnimation *animation=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.fromValue=[NSNumber numberWithFloat:1.1];
    animation.toValue=[NSNumber numberWithFloat:1.0];
    animation.duration = duration;
    animation.autoreverses=YES;
    animation.repeatCount=0;
    animation.removedOnCompletion=NO;
    animation.fillMode=kCAFillModeForwards;
    [view.layer addAnimation:animation forKey:@"zoom"];
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
- (void)dealloc{
    NSLog(@"delloc---PJAlertView");
}

@end
