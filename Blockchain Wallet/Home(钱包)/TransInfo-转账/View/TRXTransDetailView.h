//
//  TRXTransDetailView.h
//  Blockchain Wallet
//
//  Created by 陈俭红 on 2021/6/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TRXTransDetailView : UIView
/** 展示货币选择 */
+ (instancetype)showTransDetailViewWithDic:(NSDictionary *)dic block:(void(^)(void))block;
@end

NS_ASSUME_NONNULL_END
