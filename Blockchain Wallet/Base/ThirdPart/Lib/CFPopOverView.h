//
//  CFPopOverView.h
//  CFLive
//
//  Created by 陈峰 on 2017/3/14.
//  Copyright © 2017年 Peak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CFPopOverView : UIView

@property (nonatomic, copy) UIColor *borderColor;
@property (nonatomic, copy) void (^selectRowAtIndex)(NSInteger index);

@property (nonatomic,assign ) BOOL isShowIcon;

@property (nonatomic, assign) CGFloat cellHeight;

// 默认选择的 title
@property (nonatomic, copy) NSString *selectedTitle;

- (void)excuteBlockWithTarget:(id)target CompletedBlock:(void(^)(id target, NSInteger index))completedBlock;

- (instancetype)initWithOrigin:(CGPoint)origin titles:(NSArray *)titles images:(NSArray *)images;
- (void)showInView:(UIView *)view;
- (void)dismiss;
- (void)dismiss:(BOOL)animated;


@end
