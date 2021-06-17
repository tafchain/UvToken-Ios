//
//  HomeHeaderView.m
//  Blockchain Wallet
//
//  Created by Panerly on 2021/4/13.
//

#import "HomeHeaderView.h"

@implementation HomeHeaderView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"HomeHeaderView"owner:self options:nil];
        self.baseView.frame = CGRectMake(0, 10, self.frame.size.width, self.frame.size.height);
        [self addSubview:self.baseView];
        
    }
    return self;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    
    [[NSBundle mainBundle] loadNibNamed:@"HomeHeaderView"owner:self options:nil];
    self.baseView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self addSubview:self.baseView];
}
- (IBAction)showBalanceAction:(UIButton *)sender {
    NSString *showBalance = (NSString *)[PTool getValueFromKey:@"showBalance"];
    if ([showBalance isEqualToString:@"NO"]) {
        [PTool saveValue:@"YES" forKey:@"showBalance"];
    }else{
        [PTool saveValue:@"NO" forKey:@"showBalance"];
    }
    if (self.showBalanceBlock) {
        self.showBalanceBlock();
    }
}

@end
