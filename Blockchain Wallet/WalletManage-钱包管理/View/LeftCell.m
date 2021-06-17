//
//  LeftCell.m
//  Blockchain Wallet
//
//  Created by Panerly on 2020/12/30.
//

#import "LeftCell.h"

@implementation LeftCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setModel:(Wallet *)model{
    _model = model;
    [self.walletImgView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"icon_%@", [model.type lowercaseString]]]];
    if ([model.type isEqualToString:@"Multi"]) {
        self.walletTypeLabel.text = Localized(@"多链钱包");
    }else{
        
        self.walletTypeLabel.text = [NSString stringWithFormat:@"%@%@", model.type ,Localized(@"钱包")];
    }
    self.walletNameLabel.text = [NSString stringWithFormat:@"%@", model.name];
    [self.ManageBtn setTitle:[NSString stringWithFormat:@"%@>", Localized(@"管理")] forState:UIControlStateNormal];
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

- (void)setCoinModel:(Coin *)coinModel{
    _coinModel = coinModel;
    
    DLog(@"aeco address:%@", coinModel.address);
    self.walletNameLabel.text = [self hideMiddleString:coinModel.address];
    [self.walletImgView setImage:[UIImage imageNamed:@"icon_aeco"]];
    [self.ManageBtn setTitle:[NSString stringWithFormat:@"%@>", Localized(@"管理")] forState:UIControlStateNormal];
    [self.bgImgView setImage:[UIImage imageNamed:@"icon_white"]];
    self.walletTypeLabel.text = [NSString stringWithFormat:@"%@", coinModel.name];
    self.contentView.layer.shadowColor=[UIColor darkGrayColor].CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
