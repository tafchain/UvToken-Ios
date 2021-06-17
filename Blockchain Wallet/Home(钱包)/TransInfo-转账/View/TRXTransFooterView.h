//
//  TRXTransFooterView.h
//  Blockchain Wallet
//
//  Created by 陈俭红 on 2021/6/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TRXTransFooterViewDelegate <NSObject>

- (void)clickPlaintBtn;

@end

@interface TRXTransFooterView : UIView
@property (nonatomic, copy)NSString * balance;
@property (nonatomic, weak)id<TRXTransFooterViewDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
