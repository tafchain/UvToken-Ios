//
//  SearchCell.m
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/13.
//

#import "SearchCell.h"

@implementation SearchCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setModel:(BaseModel *)model{
    _model = model;
    
    self.typeLabel.text = [model.symbol uppercaseString];
//    [self.currencyImgView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"icon_%@", [model.type lowercaseString]]]];
    if ([model.type isEqualToString:@"ERC20"]) {
        
        [self.coinTagImgView setImage:[UIImage imageNamed:@"icon_eth"]];
    }else if ([model.type isEqualToString:@"TRC20"]){
        
        [self.coinTagImgView setImage:[UIImage imageNamed:@"icon_trx"]];
    }else if ([model.type isEqualToString:@"OMNI"]){
        
        [self.coinTagImgView setImage:[UIImage imageNamed:@"icon_btc"]];
    }
    [self.currencyImgView sd_setImageWithURL:[NSURL URLWithString:model.logoURI] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"icon_%@", [model.symbol lowercaseString]]]];
    
    self.addrLabel.text = [self hideMiddleString:model.contactAddress];
    if ([[model.symbol uppercaseString] isEqualToString:@"USDT"]) {
        [self.tagImgView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"icon_%@", [model.type lowercaseString]]]];
        self.tagImgView.hidden = NO;
    }else{
        self.tagImgView.hidden = YES;
    }
    [self.clickBtn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"icon_%@", [model.selected isEqualToString:@"YES"]?@"reduce_gray":@"add_yellow"]]];
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

    // Configure the view for the selected state
}

@end
