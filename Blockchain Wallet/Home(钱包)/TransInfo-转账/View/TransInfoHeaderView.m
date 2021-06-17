//
//  TransInfoHeaderView.m
//  Blockchain Wallet
//
//  Created by Panerly on 2021/5/24.
//

#import "TransInfoHeaderView.h"

@implementation TransInfoHeaderView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"TransInfoHeaderView"owner:self options:nil];
        self.baseView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [self addSubview:self.baseView];
        [self setUI];
    }
    return self;
}

- (void)setUI{
    self.addrTitleLabel.text = Localized(@"地址");
}

- (IBAction)addrCopyAction:(UIButton *)sender {
    [UIPasteboard generalPasteboard].string = self.addrStr;
    [PJToastView showInView:[UIApplication sharedApplication].keyWindow text:Localized(@"复制成功") duration:2 autoHide:YES];
}

- (void)setBalanceLabel:(UILabel *)balanceLabel{
    _balanceLabel = balanceLabel;
}
@end
