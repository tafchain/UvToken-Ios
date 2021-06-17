//
//  AddCurrencyCell.m
//  Blockchain Wallet
//
//  Created by Panerly on 2020/12/28.
//

#import "AddCurrencyCell.h"

@implementation AddCurrencyCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setModel:(CurrencyModel *)model{
    _model = model;
    
    self.titleLabel.text = model.name;
    self.desLabel.text = model.des;
    
    //0:不可选择 1:未选中 2：已选中
    if (model.selectStatus == 2) {//选中状态
        
        [self.selectImgView setImage:[UIImage imageNamed:@"icon_cell_selected"]];
    }else if (model.selectStatus == 1) {//1:未选中
        
        [self.selectImgView setImage:[UIImage imageNamed:@"icon_unselect"]];
    }else if (model.selectStatus == 0) {//不可选择
        
        [self.selectImgView setImage:[UIImage imageNamed:@"icon_cell_unselect"]];
    }else{
        
        [self.selectImgView setImage:[UIImage imageNamed:@"icon_check"]];
    }
    [self.iconImgView setImage:[UIImage imageNamed:model.icon]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
