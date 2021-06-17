//
//  HomeCell.m
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/5.
//

#import "HomeCell.h"

@implementation HomeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setModel:(BaseModel *)model{
    _model = model;
    [self.currencyTypeImgView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:[UIImage imageNamed:model.imgName]];
    self.typeLabel.text = model.type;
    
    NSString *showBalance = (NSString *)[PTool getValueFromKey:@"showBalance"];
    if ([showBalance isEqualToString:@"NO"]) {
        
        self.transCurrencyTypeImgView.hidden = YES;
        self.balanceLabel.text = @"*****";
        self.transBalanceLabel.text = @"*****";
    }else{
        
        self.transCurrencyTypeImgView.hidden = NO;
        self.balanceLabel.text = [model.balance containsString:@"null"]?@"0":[PTool notRounding:model.balance afterPoint:8];
        
        if ([model.unsupportCoin isEqualToString:@"YES"]) {
            
            self.transBalanceLabel.text = @"~";
            self.transCurrencyTypeImgView.hidden = YES;
        }else{
            
            self.transBalanceLabel.text = [NSString stringWithFormat:@"≈%@", model.transBalance];
        }
    }
    
    if ([model.type isEqualToString:@"USDT"]) {
        
        [self.tagImgView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"icon_%@", [model.coinTag lowercaseString]]]];
        self.tagImgView.hidden = NO;
    }else{
        self.tagImgView.hidden = YES;
    }
    if ([model.coinTag isEqualToString:@"ERC20"]) {
        
        [self.typeImgView setImage:[UIImage imageNamed:@"icon_eth"]];
    }else if ([model.coinTag isEqualToString:@"TRC20"]){
        
        [self.typeImgView setImage:[UIImage imageNamed:@"icon_trx"]];
    }else if ([model.coinTag isEqualToString:@"OMNI"]){
        
        [self.typeImgView setImage:[UIImage imageNamed:@"icon_btc"]];
    }else{
        [self.typeImgView setImage:[UIImage imageNamed:@"icon_null"]];
    }
    
    NSString *currency = (NSString *)[PTool getValueFromKey:@"selectedCurrencyUnit"];
    [self.transCurrencyTypeImgView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"icon_home_dark_%@", [currency lowercaseString]]]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
