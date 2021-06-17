//
//  UpdateView.h
//  schoolOnLine
//
//  Created by panerly on 2020/3/2.
//  Copyright © 2020 panerly. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UpdateView : UIView

@property (strong, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UIButton *updateNowBtn;
@property (weak, nonatomic) IBOutlet UIButton *forceUpdateBtn;
@property (weak, nonatomic) IBOutlet UIView *alertView;
@property (weak, nonatomic) IBOutlet UILabel *versionTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@property (nonatomic, assign) BOOL isForceUpdate;
@property (nonatomic, strong) NSString *upgradeUrl;

@end

NS_ASSUME_NONNULL_END
