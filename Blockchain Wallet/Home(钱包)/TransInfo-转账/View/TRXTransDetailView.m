//
//  TRXTransDetailView.m
//  Blockchain Wallet
//
//  Created by 陈俭红 on 2021/6/5.
//

#import "TRXTransDetailView.h"
#import "TRXTransDetailCell.h"

typedef void(^SearchBlock)(void);

static CGFloat defaultHeight = 298;

@interface TRXTransDetailView ()<UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>
/** 白色背景 */
@property (nonatomic, strong)UIView * bgView;
/** 取消按钮 */
@property (nonatomic, strong)UIButton * cancelBtn;
/** 标题 */
@property (nonatomic, strong)UILabel * titleLabel;
/** 标题 */
@property (nonatomic, strong)UIView * segView;
/** 金额 */
@property (nonatomic, strong)UILabel * amountLabel;
/** tableView */
@property (nonatomic, strong)UITableView * tableView;
/** 确认按钮 */
@property (nonatomic, strong)UIButton * sureBtn;
/** 数据源 */
@property (nonatomic, copy)NSArray * dataArray;
/** 回调block */
@property (nonatomic, copy)SearchBlock searchBlock;
/** 回调block */
@property (nonatomic, copy)NSDictionary * dic;
@end

@implementation TRXTransDetailView

#pragma mark - Cycle Methods
+ (instancetype)showTransDetailViewWithDic:(NSDictionary *)dic block:(void(^)(void))block{
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    TRXTransDetailView * view = [[TRXTransDetailView alloc] initWithFrame:window.bounds];
    [window addSubview:view];
    view.searchBlock = block;
    view.dic = dic;
    [view showChooseCoinView];
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
        [self addAllViews];
        [self setDefaultLayout];
        [self addGes];
        
        [self loadNewData];
    }
    return self;
}

- (void)setDefaultLayout{
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(0);
        make.top.equalTo(KScreenHeight);
        make.height.equalTo(defaultHeight + BOTTOM_SAFEAREA_HEIGHT);
    }];
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(0);
        make.width.height.equalTo(44);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.cancelBtn.mas_right);
        make.right.equalTo(-44);
        make.top.height.equalTo(self.cancelBtn);
    }];
    [self.segView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.bgView);
        make.height.equalTo(0.5);
        make.top.equalTo(self.titleLabel.mas_bottom);
    }];
    [self.amountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.bgView);
        make.height.equalTo(50);
        make.top.equalTo(self.segView.mas_bottom);
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.bgView);
        make.height.equalTo(100);
        make.top.equalTo(self.amountLabel.mas_bottom);
    }];
    [self.sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(20);
        make.right.equalTo(-20);
        make.height.equalTo(44);
        make.bottom.equalTo(-(30 + BOTTOM_SAFEAREA_HEIGHT));
    }];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isDescendantOfView:self.bgView]) {
        return NO;
    }
    return YES;
}

#pragma mark - Myself Methods
- (void)addAllViews{
    [self addSubview:self.bgView];
    [self.bgView addSubview:self.cancelBtn];
    [self.bgView addSubview:self.titleLabel];
    [self.bgView addSubview:self.segView];
    [self.bgView addSubview:self.amountLabel];
    [self.bgView addSubview:self.tableView];
    [self.bgView addSubview:self.sureBtn];
}

- (void)addGes{
    UITapGestureRecognizer * ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gesAction)];
    ges.delegate = self;
    [self addGestureRecognizer:ges];
}

- (void)gesAction{
    [self hiddenChooseCoinView];
}

- (void)loadNewData{
    
}

- (void)cancelBtnAction{
    [self hiddenChooseCoinView];
}

- (void)showChooseCoinView{
    [self.bgView setNeedsUpdateConstraints];
    [self.bgView.superview layoutIfNeeded];
    [UIView animateWithDuration:0.5 animations:^{
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        [self.bgView setNeedsUpdateConstraints];
        CGFloat y = KScreenHeight - defaultHeight;
        [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(y);
        }];
        [self.bgView.superview layoutIfNeeded];
    }];
}

- (void)hiddenChooseCoinView{
    [UIView animateWithDuration:0.5 animations:^{
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
        [self.bgView setNeedsUpdateConstraints];
        [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(KScreenHeight);
        }];
        [self.bgView.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

- (void)sureBtnAction{
    if (self.searchBlock) {
        self.searchBlock();
    }
    [self hiddenChooseCoinView];
}

#pragma mark - Setter Methods
- (void)setDic:(NSDictionary *)dic{
    _dic = dic;
    
    self.amountLabel.text = [NSString stringWithFormat:@"%@ TRX", dic[@"trx"]];
    self.dataArray = @[@{@"title":Localized(@"收款地址"), @"content":dic[@"address"]}, @{@"title":Localized(@"矿工费"), @"content":[NSString stringWithFormat:@"%@ TRX", dic[@"fee"]]}];
    [self.tableView reloadData];
}

#pragma mark - Getter Methods
- (UIView *)bgView{
    if (!_bgView) {
        _bgView = [UIView new];
        _bgView.backgroundColor = [UIColor whiteColor];
    }
    return _bgView;
}

- (UIButton *)cancelBtn{
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelBtn setImage:[UIImage imageNamed:@"icon_close"] forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textColor = COLORRGB(29, 34, 59);
        _titleLabel.font = [UIFont boldSystemFontOfSize:14];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = Localized(@"转账详情");
    }
    return _titleLabel;
}

- (UIView *)segView{
    if (!_segView) {
        _segView = [UIView new];
        _segView.backgroundColor = COLORRGB(244, 245, 249);
    }
    return _segView;
}

- (UILabel *)amountLabel{
    if (!_amountLabel) {
        _amountLabel = [UILabel new];
        _amountLabel.textColor = COLORRGB(29, 34, 59);
        _amountLabel.font = [UIFont boldSystemFontOfSize:14];
        _amountLabel.textAlignment = NSTextAlignmentCenter;
        _amountLabel.text = @"0 TRX";
    }
    return _amountLabel;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (UIButton *)sureBtn{
    if (!_sureBtn) {
        _sureBtn = [UIButton new];
        _sureBtn.backgroundColor = baseColor;
        [_sureBtn setTitle:Localized(@"确定") forState:UIControlStateNormal];
        [_sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _sureBtn.layer.cornerRadius = 4;
        _sureBtn.layer.masksToBounds = YES;
        [_sureBtn addTarget:self action:@selector(sureBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureBtn;
}

#pragma mark - UITableViewDelegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * cellString = @"TRXTransDetailCell";
    TRXTransDetailCell * cell = [tableView dequeueReusableCellWithIdentifier:cellString];
    if (!cell) {
        cell = [[TRXTransDetailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellString];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.dic = self.dataArray[indexPath.row];
    return cell;
}
@end
