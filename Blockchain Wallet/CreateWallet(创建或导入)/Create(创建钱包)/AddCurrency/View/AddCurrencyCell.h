//
//  AddCurrencyCell.h
//  Blockchain Wallet
//
//  Created by Panerly on 2020/12/28.
//

#import <UIKit/UIKit.h>
#import "CurrencyModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AddCurrencyCell : UITableViewCell

@property (nonatomic, strong) CurrencyModel *model;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *desLabel;

@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;
@property (weak, nonatomic) IBOutlet UIImageView *selectImgView;

@end

NS_ASSUME_NONNULL_END
