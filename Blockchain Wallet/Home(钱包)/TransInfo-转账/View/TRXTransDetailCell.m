//
//  TRXTransDetailCell.m
//  Blockchain Wallet
//
//  Created by 陈俭红 on 2021/6/5.
//

#import "TRXTransDetailCell.h"

@interface TRXTransDetailCell ()
/** 主标题 */
@property (nonatomic, strong)UILabel * titleLabel;
/** des */
@property (nonatomic, strong)UILabel * desLabel;
@end

@implementation TRXTransDetailCell

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
        make.top.height.equalTo(self.contentView);
    }];
    [self.desLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel.mas_right).offset(20);
        make.right.equalTo(-20);
        make.top.height.equalTo(self.contentView);
    }];
}

#pragma mark - Myself Methods
- (void)setUI{
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.desLabel];
}

#pragma mark - Setter Methods
- (void)setDic:(NSDictionary *)dic{
    _dic = dic;
    
    self.titleLabel.text = dic[@"title"];
    self.desLabel.text = dic[@"content"];
}

#pragma mark - Getter Methods
- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textColor = COLORRGB(29, 34, 59);
        _titleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _titleLabel;
}

- (UILabel *)desLabel{
    if (!_desLabel) {
        _desLabel = [UILabel new];
        _desLabel.textColor = COLORRGB(187, 188, 196);
        _desLabel.font = [UIFont systemFontOfSize:14];
        _desLabel.textAlignment = NSTextAlignmentRight;
        _desLabel.numberOfLines = 0;
    }
    return _desLabel;
}
@end
