//
//  MnemonicCell.h
//  Blockchain Wallet
//
//  Created by Panerly on 2020/12/28.
//

#import <UIKit/UIKit.h>
#import "MnemonicModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MnemonicCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) MnemonicModel *model;

@end

NS_ASSUME_NONNULL_END
