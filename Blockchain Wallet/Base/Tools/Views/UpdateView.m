//
//  UpdateView.m
//  schoolOnLine
//
//  Created by panerly on 2020/3/2.
//  Copyright © 2020 panerly. All rights reserved.
//

#import "UpdateView.h"

@implementation UpdateView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"UpdateView"owner:self options:nil];
        self.baseView.frame = CGRectMake(0, 10, self.frame.size.width, self.frame.size.height);
        [self addSubview:self.baseView];
        self.nextBtn.layer.cornerRadius = 20.0;
        self.nextBtn.layer.borderColor = baseColor.CGColor;
        self.nextBtn.layer.borderWidth = 1.0f;
        self.versionTitleLabel.text = Localized(@"版本更新");
        [self.forceUpdateBtn setTitle:Localized(@"立即更新") forState:UIControlStateNormal];
        [self.nextBtn setTitle:Localized(@"取消") forState:UIControlStateNormal];
        [self.updateNowBtn setTitle:Localized(@"立即更新") forState:UIControlStateNormal];
        
        [self exChangeOut:self.alertView dur:.4];
    }
    return self;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    
    [[NSBundle mainBundle] loadNibNamed:@"UpdateView"owner:self options:nil];
    self.baseView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self addSubview:self.baseView];
}

- (void)setIsForceUpdate:(BOOL)isForceUpdate{
    _isForceUpdate = isForceUpdate;
    if (_isForceUpdate) {
        self.forceUpdateBtn.hidden = NO;
        self.updateNowBtn.hidden = YES;
        self.nextBtn.hidden = YES;
    }else{
        self.forceUpdateBtn.hidden = YES;
        self.updateNowBtn.hidden = NO;
        self.nextBtn.hidden = NO;
    }
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
- (IBAction)ignoreAction:(id)sender {
    
    [self removeFromSuperview];
}
- (IBAction)updateAction:(id)sender {
    
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.upgradeUrl.length>0?self.upgradeUrl:@"https://apps.apple.com/cn/app/UvToken/id1552556395"] options:@{} completionHandler:^(BOOL success) {
            
        }];
    } else {
        // Fallback on earlier versions
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.upgradeUrl.length>0?self.upgradeUrl:@"https://apps.apple.com/cn/app/UvToken/id1552556395"]];
    }
    if (!self.isForceUpdate) {
        
        [self removeFromSuperview];
    }
}


@end
