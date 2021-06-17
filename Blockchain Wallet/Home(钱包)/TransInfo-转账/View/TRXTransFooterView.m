//
//  TRXTransFooterView.m
//  Blockchain Wallet
//
//  Created by 陈俭红 on 2021/6/3.
//

#import "TRXTransFooterView.h"

@interface TRXTransFooterView ()
/**  */
@property (nonatomic, strong)UILabel * balanceLabel;
/** 主标题 */
@property (nonatomic, strong)UILabel * titleLabel;
/** 感叹号 */
@property (nonatomic, strong)UIButton * plaintBtn;
/**  */
@property (nonatomic, strong)UILabel * desLabel;

@end

@implementation TRXTransFooterView

#pragma mark - Cycle Methods
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUI];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self.balanceLabel makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(-20);
        make.top.equalTo(5);
        make.height.equalTo(15);
    }];
    [self.titleLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(20);
        make.top.equalTo(self.balanceLabel.mas_bottom).offset(10);
        make.height.equalTo(20);
    }];
    [self.plaintBtn makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel.mas_right).offset(5);
        make.width.height.equalTo(20);
        make.centerY.equalTo(self.titleLabel);
    }];
    [self.desLabel makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(-20);
        make.top.height.equalTo(self.titleLabel);
    }];
}

#pragma mark - Myself Methods
- (void)setUI{
    [self addSubview:self.balanceLabel];
    [self addSubview:self.titleLabel];
    [self addSubview:self.plaintBtn];
    [self addSubview:self.desLabel];
}

- (void)plaintBtnAction{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickPlaintBtn)]) {
        [self.delegate clickPlaintBtn];
    }
}

#pragma mark - Setter Methods
- (void)setBalance:(NSString *)balance{
    _balance = balance;
    
    self.balanceLabel.text = [NSString stringWithFormat:@"%@ %@ TRX", Localized(@"资产"), [PTool isString:balance] ? balance : @"0"];
}

#pragma mark - Getter Methods
- (UILabel *)balanceLabel{
    if (!_balanceLabel) {
        _balanceLabel = [UILabel new];
        _balanceLabel.textColor = COLORRGB(187, 188, 196);
        _balanceLabel.font = [UIFont systemFontOfSize:12];
        _balanceLabel.textAlignment = NSTextAlignmentRight;
    }
    return _balanceLabel;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textColor = COLORRGB(29, 34, 59);
        _titleLabel.font = [UIFont boldSystemFontOfSize:14];
        _titleLabel.text = Localized(@"矿工费");
    }
    return _titleLabel;
}

- (UIButton *)plaintBtn{
    if (!_plaintBtn) {
        _plaintBtn = [UIButton new];
        [_plaintBtn setImage:[UIImage imageNamed:@"icon_plaint"] forState:UIControlStateNormal];
        [_plaintBtn addTarget:self action:@selector(plaintBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _plaintBtn;
}

- (UILabel *)desLabel{
    if (!_desLabel) {
        _desLabel = [UILabel new];
        _desLabel.textColor = COLORRGB(50, 58, 67);
        _desLabel.font = [UIFont systemFontOfSize:14];
        _desLabel.textAlignment = NSTextAlignmentRight;
        _desLabel.text = @"0 TRX";
    }
    return _desLabel;
}
@end
