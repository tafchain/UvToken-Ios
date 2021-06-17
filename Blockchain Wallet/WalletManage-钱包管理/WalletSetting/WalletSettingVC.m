//
//  WalletSettingVC.m
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/4.
//

#import "WalletSettingVC.h"
#import "View/WalletSettingCell.h"
#import "MnemonicVC.h"
#import "ChangePwdVC.h"
#import "BackupPKTypeVC.h"
#import "UIViewController+CWLateralSlide.h"
#import "RemoveKeyTool.h"
#import "ChagneWalletNameVC.h"

@interface WalletSettingVC ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;

@end

@implementation WalletSettingVC

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.edgesForExtendedLayout = UIRectEdgeAll;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUI];
}

- (void)setUI{
    
    self.titleLabel.text = Localized(@"钱包管理");
    [self.deleteBtn setTitle:Localized(Localized(@"删除钱包")) forState:UIControlStateNormal];
    [PTool addBorderWithView:self.deleteBtn Color:[UIColor systemRedColor] BorderWidth:1 CornerRadius:5];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"WalletSettingCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"WalletSettingID"];
    
    if ([self.type isEqualToString:@"Multi"]) {
        
        [self.dataArr addObjectsFromArray:@[Localized(@"钱包名称"), Localized(@"修改密码"), Localized(@"备份助记词"), Localized(@"备份私钥")]];
    }else if ([self.type isEqualToString:@"AECO"]){
        
        [self.dataArr addObjectsFromArray:@[Localized(@"钱包地址"), Localized(@"备份私钥")]];
        self.deleteBtn.hidden = YES;
    } else{
        
        [self.dataArr addObjectsFromArray:@[Localized(@"钱包名称"), Localized(@"修改密码"), Localized(@"备份私钥")]];
    }
}

- (IBAction)backAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [self cw_dismissViewController];
}

- (IBAction)deleteWalletAction:(UIButton *)sender {
    NSString *defaultWalletAddress = (NSString *)[PTool getValueFromKey:@"defaultWalletAddress"];
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    if ([self.wallet_id isEqualToString:defaultWalletAddress]) {//删除的钱包为当前正在使用的钱包
        PJAlert *alert = [[PJAlert alloc] initWithFrame:keyWindow.bounds Title:Localized(@"温馨提示") Content:Localized(@"你正在使用当前钱包，切换后再删除吧") Confirm:Localized(@"知道了")];
        alert.showTwoBtn = NO;
        [keyWindow addSubview:alert];
    }else{
        PWS(weakSelf);
        PwdInputView *inputView = [[PwdInputView alloc] initWithFrame:keyWindow.bounds];
        inputView.titleLabel.text = Localized(@"输入钱包密码");
        inputView.inputString = ^(NSString * _Nonnull str) {
            [[PWallet shareInstance] verifyWalletPwdWithWalletID:weakSelf.wallet_id Pwd:str valid:^(BOOL valid) {
                if (valid) {
                    [weakSelf deleteWallet:str];
                }else{
                    [LSStatusBarHUD showMessageAndImage:Localized(@"密码错误")];
                }
            }];
        };
        [keyWindow addSubview:inputView];
    }
}

- (void)deleteWallet:(NSString *)password{
    [SVProgressHUD showWithStatus:Localized(@"正在删除...")];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    NSArray *walletArr = [Wallet MR_findByAttribute:@"wallet_id" withValue:self.wallet_id];
    for (Wallet *wallet in walletArr) {
        if ([wallet.type isEqualToString:@"Multi"]) {
            [self deleteMultiWallet:password];
        }else{
            [self deleteSingleWallet:password];
        }
    }
}

//MARK:删除单链钱包
- (void)deleteSingleWallet:(NSString *)password{
    [[PWallet shareInstance] deleteSingleChainWalletWithKeyIDs:self.wallet_id Password:password success:^(bool success) {
        if (success) {
            [SVProgressHUD dismiss];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"wallet_id=%@", self.wallet_id];
            [Wallet MR_deleteAllMatchingPredicate:predicate];
            [Coin MR_deleteAllMatchingPredicate:predicate];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            [LSStatusBarHUD showMessage:Localized(@"删除成功")];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [LSStatusBarHUD showMessage:Localized(@"删除失败")];
            [SVProgressHUD dismiss];
        }
    } failure:^(NSError * _Nonnull failure) {
        [SVProgressHUD dismiss];
        [LSStatusBarHUD showMessage:Localized(@"删除失败")];
    }];
}

//MARK:删除多链钱包
- (void)deleteMultiWallet:(NSString *)password{
    PWS(weakSelf);
    [[PWallet shareInstance] deleteWalletWithWalletID:self.wallet_id Password:password success:^(bool success) {
        if (success) {
            NSArray *arr = [Coin MR_findByAttribute:@"wallet_id" withValue:self.wallet_id];
            for (Coin *coin in arr) {
                if ([coin.address isEqualToString:(NSString *)[PTool getValueFromKey:@"defaultAddress"]]) {
                    [PTool saveValue:@"0" forKey:defaultAddress];
                }
            }
            [SVProgressHUD dismiss];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"wallet_id=%@", weakSelf.wallet_id];
            [Wallet MR_deleteAllMatchingPredicate:predicate];
            [Coin MR_deleteAllMatchingPredicate:predicate];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            [LSStatusBarHUD showMessage:Localized(@"删除成功")];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }else{
            [LSStatusBarHUD showMessage:Localized(@"删除失败")];
            [SVProgressHUD dismiss];
        }
    } failure:^(NSError * _Nonnull failure) {
        
    }];
}

//MARK:LAZY
- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

//MARK:UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WalletSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WalletSettingID" forIndexPath:indexPath];
    cell.nameLabel.text = self.dataArr[indexPath.row];
    if (indexPath.row == 0) {
        if ([self.type isEqualToString:@"AECO"]) {
            cell.desLabel.text = [self hideMiddleString:self.wallet_id];
            cell.checkImgView.hidden = YES;
        }else{
            cell.desLabel.text = [PTool getWalletInfo:self.wallet_id Type:@"name"];
            cell.checkImgView.hidden = NO;
        }
    }else{
        cell.checkImgView.hidden = NO;
    }
    return cell;
}

- (NSString *)hideMiddleString:(NSString *)string{
    if (string.length < 15) {
        return string;
    }
    NSString *newStr = @"";
    NSString *middleStr = [string substringWithRange:NSMakeRange(7, string.length-7)];
    NSString *lastStr = [string substringFromIndex:string.length-7];
    newStr = [string stringByReplacingOccurrencesOfString:middleStr withString:@"..."];
    newStr = [newStr stringByAppendingString:lastStr];
    return newStr;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ChagneWalletNameVC *changeWalletName = [ChagneWalletNameVC new];
    changeWalletName.wallet_id = self.wallet_id;
    changeWalletName.wallet_name = [PTool getWalletInfo:self.wallet_id Type:@"name"];
    BackupPKTypeVC *backup = [BackupPKTypeVC new];
    backup.wallet_id = self.wallet_id;
    
    if (indexPath.row == 0) {
        if ([self.type isEqualToString:@"AECO"]){
            [UIPasteboard generalPasteboard].string = self.wallet_id;
            [LSStatusBarHUD showMessage:@"复制成功"];
            return;
        }
        [self.navigationController pushViewController:changeWalletName animated:YES];
        return;
    }
    if ([self.type isEqualToString:@"AECO"]) {
        if (indexPath.row == 1) {
            UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
            PwdInputView *inputView = [[PwdInputView alloc] initWithFrame:keyWindow.bounds];
            inputView.titleLabel.text = Localized(@"输入账户密码");
            inputView.inputString = ^(NSString * _Nonnull str) {
                
                NSArray *arr = [Coin MR_findByAttribute:@"address" withValue:self.wallet_id];
                NSString *wallet_id = @"";
                for (Coin *coin in arr) {
                    wallet_id = coin.wallet_id;
                }
                
                [[PWallet shareInstance] verifyWalletPwdWithWalletID:wallet_id Pwd:str valid:^(BOOL valid) {
                    if (valid) {
                        backup.passwordString = str;
                        backup.type = self.type;
                        [self cw_pushViewController:backup];
                    }else{
                        [LSStatusBarHUD showMessageAndImage:Localized(@"密码错误")];
                    }
                }];
            };
            [keyWindow addSubview:inputView];
        }
        return;
    }
    if (indexPath.row == 1) {
        
        ChangePwdVC *changePwd = [ChangePwdVC new];
        changePwd.wallet_id = self.wallet_id;
        [self cw_pushViewController:changePwd];
        return;
    }
    
    NSString *selectStr = self.dataArr[indexPath.row];
    
    MnemonicVC *mnemonicVC = [MnemonicVC new];
    mnemonicVC.backupConfig = @"comeFromHome";
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    PwdInputView *inputView = [[PwdInputView alloc] initWithFrame:keyWindow.bounds];
    inputView.titleLabel.text = Localized(@"输入钱包密码");
    inputView.inputString = ^(NSString * _Nonnull str) {
        [[PWallet shareInstance] verifyWalletPwdWithWalletID:self.wallet_id Pwd:str valid:^(BOOL valid) {
            if (valid) {
                
                if ([selectStr isEqualToString:Localized(@"修改密码")]) {
                    
                }else if ([selectStr isEqualToString:Localized(@"备份助记词")]){
                    
                    [PTool saveValue:self.wallet_id forKey:@"backup_wallet_id"];//需要备份的wallet_id
                    mnemonicVC.wallet_id = self.wallet_id;
                    mnemonicVC.pwdStr = str;
                    [self cw_pushViewController:mnemonicVC];
                }else if ([selectStr isEqualToString:Localized(@"备份私钥")]){
                    
                    backup.passwordString = str;
                    backup.type = self.type;
                    [self cw_pushViewController:backup];
                }
            }else{
                [LSStatusBarHUD showMessageAndImage:Localized(@"密码错误")];
            }
        }];
    };
    [keyWindow addSubview:inputView];
}
@end
