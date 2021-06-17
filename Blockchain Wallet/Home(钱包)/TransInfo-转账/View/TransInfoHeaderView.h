//
//  TransInfoHeaderView.h
//  Blockchain Wallet
//
//  Created by Panerly on 2021/5/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TransInfoHeaderView : UIView

@property (strong, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UIImageView *currencyImgView;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *addrTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *addrLabel;
@property (nonatomic, copy) NSString *addrStr;

@end

NS_ASSUME_NONNULL_END
