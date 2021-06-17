//
//  HomeHeaderView.h
//  Blockchain Wallet
//
//  Created by Panerly on 2021/4/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomeHeaderView : UIView

typedef void(^ShowBalanceBlock)(void);

@property (strong, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UIButton *showBlanceBtn;
@property (weak, nonatomic) IBOutlet UILabel *assetTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *currencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bgImgView;
@property (weak, nonatomic) IBOutlet UILabel *networkStatusLabel;
@property (nonatomic, copy) ShowBalanceBlock showBalanceBlock;

@end

NS_ASSUME_NONNULL_END
