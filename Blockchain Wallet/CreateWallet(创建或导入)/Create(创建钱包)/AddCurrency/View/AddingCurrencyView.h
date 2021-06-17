//
//  AddingCurrencyView.h
//  Blockchain Wallet
//
//  Created by Panerly on 2020/12/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AddingCurrencyView : UIView

@property (strong, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewConstraint;
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;
@property (nonatomic, assign) NSInteger creatingIndex;


- (instancetype)initWithFrame:(CGRect)frame ImgArr:(NSArray<UIImage *>*)imgArr;

@end

NS_ASSUME_NONNULL_END
