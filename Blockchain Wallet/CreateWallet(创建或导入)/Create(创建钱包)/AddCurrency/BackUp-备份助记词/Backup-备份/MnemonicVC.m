//
//  MnemonicVC.m
//  Blockchain Wallet
//
//  Created by Panerly on 2020/12/28.
//

#import "MnemonicVC.h"
#import "MnemonicModel.h"
#import "MnemonicCell.h"
#import "ConfirmMnemonicVC.h"
#import "SecurityUtil.h"

@interface MnemonicVC ()
<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong)NSMutableArray *dataArr;
@property (nonatomic, strong)NSString *mnemonicString;

@end

@implementation MnemonicVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setUI];
    [self getMnemonicsData];
}

- (void)setUI{
    
    NSString *str = (NSString *)[PTool getValueFromKey:@"WalletSDKConfig"];
    if ([str isEqualToString:@"regtest"] || [str isEqualToString:@"test"]) {
        self.mnemonicCopyBtn.hidden = NO;
    }else{
        self.mnemonicCopyBtn.hidden = YES;
    }
    self.titleLabel.text = Localized(@"备份助记词");
    self.alertLabel.text = Localized(@"截屏分享风险提醒");
    self.tipsLabel.text = Localized(@"请在安全的环境下按顺序抄些一下助记词，并妥善保存");
    [self.knowBtn setTitle:Localized(@"知道了") forState:UIControlStateNormal];
    [self.finishBtn setTitle:Localized(@"已完成备份") forState:UIControlStateNormal];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 15.0f;
    layout.minimumInteritemSpacing = 5.0f;
    layout.sectionInset = UIEdgeInsetsMake(15, 15, 15, 15);
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"MnemonicCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"MnemonicID"];
    self.collectionView.collectionViewLayout = layout;
    
}

//MARK:根据wallet_id获取助记词
- (void)getMnemonicsData{
    
    NSString *password = @"";
    NSArray *arr = [Wallet MR_findByAttribute:@"wallet_id" withValue:self.wallet_id];
    if (arr.count > 0) {
        
        for (Wallet *wallet in arr) {
            password = wallet.password;
        }
    }else{
        [LSStatusBarHUD showMessageAndImage:Localized(@"未知错误，请退出重试")];
        return;
    }
    
    PWS(weakSelf);
    [[PWallet shareInstance] getMnemonicWithWalletID:self.wallet_id Password:self.pwdStr mnemonics:^(NSString * _Nonnull mnemonics) {
        
        weakSelf.mnemonicString = mnemonics;
        NSArray *arr = [mnemonics componentsSeparatedByString:@" "];
        if (arr.count > 0) {
            
            for (int i = 0; i < arr.count; i++) {
                MnemonicModel *model = [[MnemonicModel alloc] init];
                model.name = arr[i];
                model.number = [NSString stringWithFormat:@"%d", i+1];
                [self.dataArr addObject:model];
            }
            [self.collectionView reloadData];
        }else{
            [LSStatusBarHUD showMessageAndImage:Localized(@"未知错误，请退出重试")];
        }
    } failure:^(NSError * _Nonnull failure) {
        
//        [LSStatusBarHUD showMessageAndImage:Localized(@"未知错误，请退出重试")];
    }];
}


- (IBAction)backAction:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)mnemonicCopyAction:(UIButton *)sender {
    
    [UIPasteboard generalPasteboard].string = self.mnemonicString;
    [LSStatusBarHUD showMessage:@"复制成功"];
}

//MARK:LAZY
- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;;
}

//MARK:UICollectionViewDelegate, UICollectionViewDataSource

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MnemonicCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MnemonicID" forIndexPath:indexPath];
    cell.model = self.dataArr[indexPath.row];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((KScreenWidth-20*2 - 5*4)/3, 50);
}

- (IBAction)dismissAlert:(UIButton *)sender {
    
    [UIView animateWithDuration:.5 animations:^{
        
        self.alertContentView.transform = CGAffineTransformMakeScale(.01f, .01f);
        self.alertContentView.alpha = .3f;
    } completion:^(BOOL finished) {
        [self.alertView removeFromSuperview];
    }];
}

- (IBAction)finishAction:(UIButton *)sender {
    
//    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"mnemonics.plist"];
//
//    [NSKeyedArchiver archiveRootObject:self.dataArr toFile:path];
    
    ConfirmMnemonicVC *confirmVC = [ConfirmMnemonicVC new];
    confirmVC.backupConfig = self.backupConfig;
    confirmVC.mnemonicString = self.mnemonicString;
    confirmVC.wallet_id = self.wallet_id;
    [self.navigationController pushViewController:confirmVC animated:YES];
}

@end
