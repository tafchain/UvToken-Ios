//
//  TRXTransTableViewCell.h
//  Blockchain Wallet
//
//  Created by 陈俭红 on 2021/6/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TRXTransTableViewCellDelegate <NSObject>

- (void)textFieldChangedWithTextField:(UITextField *)textField;

- (void)clickRightBtnWithBtn:(UIButton *)sender;
@end

@interface TRXTransTableViewCell : UITableViewCell
@property (nonatomic, copy)NSDictionary * dic;
/** 输入框 */
@property (nonatomic, strong)UITextField * textField;
/** */
@property (nonatomic, weak)id<TRXTransTableViewCellDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
