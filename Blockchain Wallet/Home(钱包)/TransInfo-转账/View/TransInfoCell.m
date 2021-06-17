//
//  TransInfoCell.m
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/18.
//

#import "TransInfoCell.h"

@implementation TransInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [PTool addBorderWithView:self.cancelSpeedUpBtn Color:[UIColor blackColor] BorderWidth:0.5f CornerRadius:2];
    [self.cancelSpeedUpBtn setTitle:Localized(@"取消") forState:UIControlStateNormal];
    [self.speedUpBtn setTitle:Localized(@"加速") forState:UIControlStateNormal];
    self.pendingLabel.text = Localized(@"打包中");
}

- (void)setModel:(Record *)model{
    _model = model;
//    NSString *str = (NSString *)[PTool getValueFromKey:@"WalletSDKConfig"];
//    if ([str isEqualToString:@"regtest"]) {
//
//        self.typeLabel.text = [NSString stringWithFormat:@"%@:%@",Localized(model.type), [self hideMiddleString:model.tx_id]];
//    }else{
//
//        self.typeLabel.text = [NSString stringWithFormat:@"%@",Localized(model.type)];
//    }
    self.typeLabel.text = [NSString stringWithFormat:@"%@",Localized(model.type)];
    self.addressLabel.text = [self hideMiddleString:model.to_address];
    if ([model.type isEqualToString:@"收款"]) {
        self.amountLabel.text = [NSString stringWithFormat:@"%@%@", @"+", [PTool removeFloatAllZeroByString:model.amount]];
    }else if ([model.type isEqualToString:@"转账"]){
        self.amountLabel.text = [NSString stringWithFormat:@"%@%@", @"-", [PTool removeFloatAllZeroByString:model.amount]];
    }else{
        self.amountLabel.text = [NSString stringWithFormat:@"%@%@", [model.type isEqualToString:@"挖矿奖励"]||[model.type isEqualToString:@"矿工"]?@"+":@"-", [PTool removeFloatAllZeroByString:model.amount]];
    }
    self.timeLabel.text = model.time;
}

- (NSString *)hideMiddleString:(NSString *)string{
    if (string.length < 15) {
        return string;
    }
    NSString *newStr = @"";
    NSString *middleStr = [string substringWithRange:NSMakeRange(7, string.length-7)];
    NSString *lastStr = [string substringFromIndex:string.length-7];
    newStr = [string stringByReplacingOccurrencesOfString:middleStr withString:@"..."];
    newStr = [newStr stringByAppendingString:lastStr];
    return newStr;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
@end
