//
//  PJAlert.h
//  Dow
//
//  Created by panerly on 2019/3/8.
//  Copyright © 2019 panerly. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ConfirmBlock)(BOOL confirm);

@interface PJAlert : UIView

@property (strong, nonatomic) IBOutlet PJAlert *baseView;
@property (weak, nonatomic) IBOutlet UIView *alertView;
@property (weak, nonatomic) IBOutlet UILabel *alertTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *alertContentLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alertViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alertContentTopConstraint;

@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;//一个按钮时确认btn
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;//左边取消btn
@property (weak, nonatomic) IBOutlet UIButton *rightConfirmBtn;//邮编确认btn

@property (nonatomic, copy) ConfirmBlock confirm;
@property (nonatomic, assign) BOOL titleHidden;
@property (nonatomic, assign) BOOL showTwoBtn;
@property (nonatomic, strong) NSString *confirmString;


- (instancetype)initWithFrame:(CGRect)frame Title:(NSString *)title Content:(NSString *)content Confirm:(NSString *)confirmString;

@end

NS_ASSUME_NONNULL_END
