//
//  ConfirmMnemonicVC.m
//  Blockchain Wallet
//
//  Created by Panerly on 2020/12/28.
//

#import "ConfirmMnemonicVC.h"
#import "MnemonicCell.h"
#import "CurrencyModel.h"
#import "ConfirmCell.h"
#import "PJTabVC.h"

@interface ConfirmMnemonicVC ()
<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong)NSMutableArray *dataArr;
@property (nonatomic, strong)NSMutableArray *selectedDataArr;
@property (nonatomic, strong)NSMutableArray *randomDataArr;

@end

@implementation ConfirmMnemonicVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setUI];
}

- (void)setUI{
    
    self.titleLabel.text = Localized(@"确认助记词");
    self.tipsLabel.text = Localized(@"请按顺序点击助记词，以确认您的备份正确性");
    [self.finishBtn setTitle:Localized(@"确定") forState:UIControlStateNormal];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 15.0f;
    layout.minimumInteritemSpacing = 0.0f;
    layout.sectionInset = UIEdgeInsetsMake(15, 0, 15, 0);
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"ConfirmCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"ConfirmCellID"];
    self.collectionView.collectionViewLayout = layout;
    
//    NSArray *mnemonicArr = @[@"aa", @"bbb", @"cccc", @"dddd", @"ee", @"ff", @"ggg", @"hhhhhhhh", @"iiiii", @"jjjjjjjjjj", @"kk", @"llllllll"];
    
    
    [self.dataArr removeAllObjects];
    NSArray *arr = [self.mnemonicString componentsSeparatedByString:@" "];
    if (arr.count > 0) {
        for (int i = 0; i < arr.count; i++) {
            [self.dataArr addObject:arr[i]];
        }
    }else{
        [LSStatusBarHUD showMessageAndImage:Localized(@"未知错误，请退出重试")];
    }
    
    if (self.dataArr.count > 0) {
        
        [self.randomDataArr addObjectsFromArray:[self randomArry:self.dataArr]];
    }
    
    for (UIButton *btn in self.view1.subviews) {
        for (int i = 0; i < self.randomDataArr.count; i++) {
            if (btn.tag-300 == i) {
                [btn setTitle:self.randomDataArr[i] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
        }
    }

    for (UIButton *btn in self.view2.subviews) {
        for (int i = 0; i < self.randomDataArr.count; i++) {
            if (btn.tag-300 == i) {
                [btn setTitle:self.randomDataArr[i] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
        }
    }

    for (UIButton *btn in self.view3.subviews) {
        for (int i = 0; i < self.randomDataArr.count; i++) {
            if (btn.tag-300 == i) {
                [btn setTitle:self.randomDataArr[i] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
        }
    }

    for (UIButton *btn in self.view4.subviews) {
        for (int i = 0; i < self.randomDataArr.count; i++) {
            if (btn.tag-300 == i) {
                [btn setTitle:self.randomDataArr[i] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
        }
    }
}

- (IBAction)backAction:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


//MARK:打乱数组
- (NSArray *)randomArry:(NSArray *)arry
{
    // 对数组乱序
    arry = [arry sortedArrayUsingComparator:^NSComparisonResult(NSString *str1, NSString *str2) {
        
        int seed = arc4random_uniform(2);
        
        if (seed) {
            return [str1 compare:str2];
        } else {
            return [str2 compare:str1];
        }
    }];
    return arry;
}

//MARK:LAZY
- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;;
}

- (NSMutableArray *)selectedDataArr{
    if (!_selectedDataArr) {
        _selectedDataArr = [NSMutableArray array];
    }
    return _selectedDataArr;
}
- (NSMutableArray *)randomDataArr{
    if (!_randomDataArr) {
        _randomDataArr = [NSMutableArray array];
    }
    return _randomDataArr;
}

//MARK:UICollectionViewDelegate, UICollectionViewDataSource

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ConfirmCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ConfirmCellID" forIndexPath:indexPath];
    cell.nameLabel.text = self.selectedDataArr[indexPath.row];
    NSString * currentMnemonic = [NSString stringWithFormat:@"%@", self.selectedDataArr[indexPath.row]];
    if (self.dataArr.count && ![currentMnemonic isEqualToString:self.dataArr[indexPath.row]]) {//顺序不对
        cell.flagImgView.hidden = NO;
        [LSStatusBarHUD showMessageAndImage:Localized(@"助记词顺序错误，请仔细检查")];
    } else {
        cell.flagImgView.hidden = YES;
    }
    self.finishBtn.alpha = [self refreshStatus]?1:0.3;
    self.finishBtn.userInteractionEnabled = [self refreshStatus]?YES:NO;
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.selectedDataArr.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((KScreenWidth-20*2)/3, 50);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (![self.selectedDataArr[indexPath.row] isEqualToString:self.dataArr[indexPath.row]]) {
        
        [self deleteBtnWithTitle:self.selectedDataArr[indexPath.row] Color:baseColor];
        [self.selectedDataArr removeObject:self.selectedDataArr[indexPath.row]];
        [self.collectionView reloadData];
    }
}

- (void)deleteBtnWithTitle:(NSString *)title Color:(UIColor *)color{
    
    for (UIButton *btn in self.view1.subviews) {
        if ([btn.titleLabel.text isEqualToString:title]) {
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setBackgroundColor:color];
        }
    }

    for (UIButton *btn in self.view2.subviews) {
        if ([btn.titleLabel.text isEqualToString:title]) {
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setBackgroundColor:color];
        }
    }

    for (UIButton *btn in self.view3.subviews) {
        if ([btn.titleLabel.text isEqualToString:title]) {
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setBackgroundColor:color];
        }
    }
    
    for (UIButton *btn in self.view4.subviews) {
        if ([btn.titleLabel.text isEqualToString:title]) {
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setBackgroundColor:color];
        }
    }
}

//MARK:点击添加助记词
- (IBAction)selectMenmonicAction:(UIButton *)sender {
    
    if (![self.selectedDataArr containsObject:sender.titleLabel.text]) {
        [self.selectedDataArr addObject:sender.titleLabel.text];
        [sender setTitleColor:baseColor forState:UIControlStateNormal];
        [sender setBackgroundColor:[UIColor whiteColor]];
    }else{
        if ([sender.titleLabel.text isEqualToString:self.selectedDataArr.lastObject]) {
            
            [self.selectedDataArr removeObject:sender.titleLabel.text];
            [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [sender setBackgroundColor:baseColor];
        }
    }
    [self.collectionView reloadData];
}

//MARK:刷新状态
- (BOOL)refreshStatus{
    
    if (self.selectedDataArr.count == self.dataArr.count && self.dataArr.count == 12) {//选择了全部助记词
        for (int i = 0; i < self.selectedDataArr.count; i++) {
            if (![self.selectedDataArr[i] isEqualToString:self.dataArr[i]]) {
                return NO;
            }
        }
        return YES;
    }
    return NO;
}

- (IBAction)finishAction:(UIButton *)sender {
    
    if (self.wallet_id.length > 0) {

        NSArray *selectedArr = [Wallet MR_findByAttribute:@"wallet_id" withValue:self.wallet_id];
        for (Wallet *wallet in selectedArr) {
            wallet.is_backup = YES;
        }
    }else{
        
        NSArray *selectedArr = [Wallet MR_findByAttribute:@"wallet_id" withValue:self.wallet_id];
        for (Wallet *wallet in selectedArr) {
            wallet.is_backup = YES;
        }
    }
    
    [PTool saveValue:self.wallet_id forKey:@"defaultWalletAddress"];
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:LOGINSELECTCENTERINDEX object:nil];
}

@end
