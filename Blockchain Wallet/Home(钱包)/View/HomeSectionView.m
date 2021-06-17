//
//  HomeSectionView.m
//  Blockchain Wallet
//
//  Created by Panerly on 2021/4/14.
//

#import "HomeSectionView.h"

@implementation HomeSectionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUI];
    }
    return self;
}

- (void)setUI{
    if (!_titleLabel) {
        [self addSubview:self.titleLabel];
    }
    
    CGSize size = [PTool sizeWithText:Localized(@"资产") font:[UIFont systemFontOfSize:17] maxSize:CGSizeMake(self.frame.size.width, self.frame.size.height)];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(20, 5+(self.frame.size.height+20)/2, size.width, 2)];
    lineView.backgroundColor = baseColor;
    [self addSubview:lineView];
    
    if (!_addBtn) {
        [self addSubview:self.addBtn];
    }
    [self.addBtn addTarget:self action:@selector(btnClickAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        CGSize size = [PTool sizeWithText:Localized(@"资产") font:[UIFont systemFontOfSize:15] maxSize:CGSizeMake(self.frame.size.width, self.frame.size.height)];
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, (self.frame.size.height-20)/2, size.width, 20)];
        _titleLabel.text = Localized(@"资产");
        _titleLabel.font = [UIFont systemFontOfSize:15];
    }
    return _titleLabel;
}

- (UIButton *)addBtn{
    if (!_addBtn) {
        _addBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-35-10, self.frame.size.height/2-35/2, 35, 35)];
        [_addBtn setImage:[UIImage imageNamed:@"icon_home_add"] forState:UIControlStateNormal];
    }
    return _addBtn;
}

- (void)btnClickAction:(UIButton *)sender{
    if (self.addBlock) {
        self.addBlock();
    }
}

@end
