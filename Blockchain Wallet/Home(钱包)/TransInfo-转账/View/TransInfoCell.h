//
//  TransInfoCell.h
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TransInfoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *speedUpBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelSpeedUpBtn;
@property (weak, nonatomic) IBOutlet UILabel *pendingLabel;

@property (nonatomic, strong) Record *model;

@end

NS_ASSUME_NONNULL_END
