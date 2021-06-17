//
//  HomeCell.h
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomeCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *currencyTypeImgView;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *transBalanceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *transCurrencyTypeImgView;
@property (weak, nonatomic) IBOutlet UIImageView *tagImgView;
@property (weak, nonatomic) IBOutlet UIImageView *typeImgView;//代币角标

@property (nonatomic, strong) BaseModel *model;

@end

NS_ASSUME_NONNULL_END
