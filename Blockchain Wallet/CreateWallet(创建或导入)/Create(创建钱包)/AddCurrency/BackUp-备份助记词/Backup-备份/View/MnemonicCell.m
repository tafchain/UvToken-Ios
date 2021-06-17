//
//  MnemonicCell.m
//  Blockchain Wallet
//
//  Created by Panerly on 2020/12/28.
//

#import "MnemonicCell.h"

@implementation MnemonicCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setModel:(MnemonicModel *)model{
    _model = model;
    
    self.numberLabel.text = model.number;
    self.nameLabel.text = model.name;
}

@end
