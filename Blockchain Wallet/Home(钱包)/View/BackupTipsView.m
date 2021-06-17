//
//  BackupTipsView.m
//  Blockchain Wallet
//
//  Created by Panerly on 2021/4/14.
//

#import "BackupTipsView.h"

@implementation BackupTipsView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"BackupTipsView"owner:self options:nil];
        self.baseView.frame = CGRectMake(0, 10, self.frame.size.width, self.frame.size.height);
        [self addSubview:self.baseView];
        [self setUI];
    }
    return self;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    
    [[NSBundle mainBundle] loadNibNamed:@"BackupTipsView"owner:self options:nil];
    self.baseView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self addSubview:self.baseView];
}

- (void)setUI{
    
    self.tipsLabel.text = Localized(@"安全提醒内容");
    self.tipsTitleLabel.text = Localized(@"安全提醒");
    [self.backupBtn setTitle:Localized(@"立即备份") forState:UIControlStateNormal];
}

- (IBAction)closeAction:(UIButton *)sender {
    if (self.closeBlock) {
        self.closeBlock();
    }
}

- (IBAction)backupAction:(UIButton *)sender {
    if (self.backupBlock) {
        self.backupBlock();
    }
}

@end
