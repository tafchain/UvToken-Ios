//
//  SearchCell.h
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SearchCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *currencyImgView;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *tagImgView;
@property (weak, nonatomic) IBOutlet UILabel *addrLabel;
@property (weak, nonatomic) IBOutlet UIImageView *clickBtn;
@property (weak, nonatomic) IBOutlet UIImageView *coinTagImgView;

@property (nonatomic, strong) BaseModel *model;

@end

NS_ASSUME_NONNULL_END
