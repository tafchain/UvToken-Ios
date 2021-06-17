//
//  TRXTransTableViewCell.m
//  Blockchain Wallet
//
//  Created by 陈俭红 on 2021/6/3.
//

#import "TRXTransTableViewCell.h"

@interface TRXTransTableViewCell () <UITextFieldDelegate>
/** 主标题 */
@property (nonatomic, strong)UILabel * titleLabel;
/** 副标题 */
@property (nonatomic, strong)UIButton * rightBtn;
/** 分割线 */
@property (nonatomic, strong)UIView * segView;
@end

@implementation TRXTransTableViewCell

#pragma mark - Cycle Methods
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUI];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self.titleLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(20);
        make.top.equalTo(20);
        make.height.equalTo(20);
        make.right.equalTo(-20);
    }];
    [self.textField makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.top.equalTo(self.titleLabel.mas_bottom);
        make.bottom.equalTo(0);
        make.right.equalTo(-56);
    }];
    [self.rightBtn makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(-20);
        make.width.height.equalTo(36);
        make.centerY.equalTo(self.textField);
    }];
    [self.segView makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.titleLabel);
        make.bottom.equalTo(0);
        make.height.equalTo(0.5);
    }];
}

#pragma mark - Myself Methods
- (void)setUI{
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.textField];
    [self.contentView addSubview:self.rightBtn];
    [self.contentView addSubview:self.segView];
}

- (void)textFieldDidChange:(UITextField *)textField{
    if (self.delegate && [self.delegate respondsToSelector:@selector(textFieldChangedWithTextField:)]) {
        [self.delegate textFieldChangedWithTextField:textField];
    }
}

- (void)rightBtnAction:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickRightBtnWithBtn:)]) {
        [self.delegate clickRightBtnWithBtn:sender];
    }
}

#pragma mark - Setter Methods
- (void)setDic:(NSDictionary *)dic{
    _dic = dic;
    
    NSString * title = dic[@"title"];
    self.titleLabel.text = title;
    NSString * keyType = dic[@"keyType"];
    if ([keyType isEqualToString:@"1"]) {
        self.textField.keyboardType = UIKeyboardTypeDecimalPad;
    } else {
        self.textField.keyboardType = UIKeyboardTypeDefault;
    }
    self.textField.placeholder = dic[@"place"];
    NSString * content = dic[@"content"];
    if (content && content.length) {
        self.textField.text = content;
    } else {
        self.textField.text = nil;
    }
    NSString * img = dic[@"img"];
    NSString * btnStr = dic[@"btnStr"];
    if (img && img.length) {
        [self.rightBtn setImage:[UIImage imageNamed:img] forState:UIControlStateNormal];
    } else {
        [self.rightBtn setTitle:btnStr forState:UIControlStateNormal];
    }
}

#pragma mark - Getter Methods
- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textColor = COLORRGB(29, 34, 59);
        _titleLabel.font = [UIFont boldSystemFontOfSize:14];
    }
    return _titleLabel;
}

- (UITextField *)textField{
    if (!_textField) {
        _textField = [UITextField new];
        _textField.backgroundColor = [UIColor clearColor];
        _textField.font = [UIFont systemFontOfSize:14];
        _textField.textColor = COLORRGB(29, 34, 59);
        [_textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _textField;
}

- (UIButton *)rightBtn{
    if (!_rightBtn) {
        _rightBtn = [UIButton new];
        [_rightBtn setTitleColor:COLORRGB(29, 34, 59) forState:UIControlStateNormal];
        _rightBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_rightBtn addTarget:self action:@selector(rightBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightBtn;
}

- (UIView *)segView{
    if (!_segView) {
        _segView = [UIView new];
        _segView.backgroundColor = COLORRGB(232, 232, 235);
    }
    return _segView;
}
@end
