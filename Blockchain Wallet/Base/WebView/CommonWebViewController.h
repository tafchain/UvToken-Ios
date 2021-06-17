//
//  CommonWebViewController.h
//  Dow
//
//  Created by panerly on 2019/3/6.
//  Copyright © 2019 panerly. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CommonWebViewController : UIViewController

@property (nonatomic, strong) NSString *showShare;
@property (nonatomic, strong) NSString *webUrl;
@property (nonatomic, strong) NSString *cid;

@property (weak, nonatomic  ) IBOutlet UIView             *naviView;
@property (weak, nonatomic  ) IBOutlet UIButton           *closeBtn;
@property (weak, nonatomic  ) IBOutlet UILabel            *titleLabel;
@property (weak, nonatomic  ) IBOutlet UIButton           *shareBtn;
@property (weak, nonatomic  ) IBOutlet NSLayoutConstraint *maskWidth;

@end

NS_ASSUME_NONNULL_END
