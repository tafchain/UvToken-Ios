//
//  LeftCell.h
//  Blockchain Wallet
//
//  Created by Panerly on 2020/12/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LeftCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *ManageBtn;
@property (weak, nonatomic) IBOutlet UIImageView *bgImgView;
@property (weak, nonatomic) IBOutlet UILabel *walletTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *walletNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *walletImgView;

@property (nonatomic, strong) Wallet *model;
@property (nonatomic, strong) Coin *coinModel;

@end

NS_ASSUME_NONNULL_END
