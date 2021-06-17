//
//  LeftViewController.m
//  Blockchain Wallet
//
//  Created by Panerly on 2020/12/30.
//

#import "LeftViewController.h"
#import "LeftCell.h"
#import "CreateWalletVC.h"
#import "UIViewController+CWLateralSlide.h"
#import "WalletSettingVC.h"
#import "PJNav.h"

@interface LeftViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) NSMutableArray *aecoDataArr;

@end

@implementation LeftViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
//    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUI];
    [self getWalletData];
}

- (void)setUI{
    
    self.qbglLabel.text = Localized(@"钱包管理");
    [self.cancelBtn setTitle:Localized(@"取消") forState:UIControlStateNormal];
    [self.createWalletBtn setTitle:Localized(@"创建钱包") forState:UIControlStateNormal];
    [self.importWalletBtn setTitle:Localized(@"导入钱包") forState:UIControlStateNormal];
    [PTool addBorderWithView:self.createWalletBtn Color:baseColor BorderWidth:1 CornerRadius:5];
    [PTool addBorderWithView:self.importWalletBtn Color:baseColor BorderWidth:1 CornerRadius:5];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"LeftCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"LeftCellID"];
}

//MARK:获取钱包数据
- (void)getWalletData{
    
    [self.dataArr removeAllObjects];
    
    [self.dataArr addObjectsFromArray:[Wallet MR_findAll]];
    
    [self.aecoDataArr removeAllObjects];
    
    [self.aecoDataArr addObjectsFromArray:[Coin MR_findByAttribute:@"name" withValue:@"AECO"]];
    
    if (self.dataArr.count > 0) {
        [self.tableView reloadData];
    }
}

//MARK:UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if ([AECOConfig isEqualToString:@"show"]) {
        return 2;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return self.dataArr.count;
    }
    return self.aecoDataArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    }
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 50)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, KScreenWidth-40, 50)];
    label.text = Localized(@"账户管理");
    [view addSubview:label];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LeftCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LeftCellID" forIndexPath:indexPath];
    [cell.ManageBtn addTarget:self action:@selector(manageWallet:) forControlEvents:UIControlEventTouchUpInside];
    cell.contentView.layer.shadowOffset = CGSizeMake(0,0);
    cell.contentView.layer.shadowOpacity = 0.3;//阴影透明度，默认0
    cell.contentView.layer.shadowRadius = 3;//阴影半径，默认3
    cell.model = self.dataArr[indexPath.row];
    if (indexPath.section == 1) {//AECO
        cell.ManageBtn.tag = 400+indexPath.row;
        cell.coinModel = self.aecoDataArr[indexPath.row];
        return cell;
    }
    cell.ManageBtn.tag = 200+indexPath.row;
    NSString *defaultWallet = (NSString *)[PTool getValueFromKey:@"defaultWalletAddress"];
    NSString *currentWallet = ((Wallet *)self.dataArr[indexPath.row]).wallet_id;
    if ([defaultWallet isEqualToString:currentWallet]) {//选中的钱包
        cell.contentView.layer.shadowColor=baseColor.CGColor;
        [cell.bgImgView setImage:[UIImage imageNamed:@"icon_yellow_right_left"]];
        cell.walletNameLabel.textColor = [UIColor whiteColor];
        cell.walletTypeLabel.textColor = [UIColor whiteColor];
        [cell.ManageBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else{
        [cell.bgImgView setImage:[UIImage imageNamed:@"icon_white"]];
        cell.walletNameLabel.textColor = [UIColor blackColor];
        cell.contentView.layer.shadowColor=[UIColor darkGrayColor].CGColor;
        cell.walletTypeLabel.textColor = [UIColor blackColor];
        [cell.ManageBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        return;
    }
    NSString *selectedWallet = ((Wallet *)self.dataArr[indexPath.row]).name;
    NSString *walletID = ((Wallet *)self.dataArr[indexPath.row]).wallet_id;
    [PTool saveValue:walletID forKey:@"defaultWalletAddress"];
    if (self.selectedWallet) {
        self.selectedWallet([NSString stringWithFormat:@"%@", selectedWallet], @"changeWallet");
    }
    [self dismissViewControllerAnimated:YES completion:^{
            
    }];
}

- (void)manageWallet:(UIButton *)sender{
    NSString *wallet_id;
    NSString *type;
    if (sender.tag >= 400) {
        wallet_id = ((Coin *)self.aecoDataArr[sender.tag-400]).address;
        type = @"管理AECO";
    }else{
        wallet_id = ((Wallet *)self.dataArr[sender.tag-200]).wallet_id;
        type = ((Wallet *)self.dataArr[sender.tag-200]).type;
    }
//    WalletSettingVC *setting = [[WalletSettingVC alloc] init];
//    setting.wallet_id = wallet_id;
//    setting.type = type;
//    PJNav *nav = [[PJNav alloc] initWithRootViewController:setting];
//    nav.modalPresentationStyle = 0;
//    nav.navigationBar.hidden = YES;
//    [self cw_presentViewController:setting drewerHidden:NO];
//    [self cw_pushViewController:setting];
//    [self.navigationController pushViewController:setting animated:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.selectedWallet) {
            self.selectedWallet(wallet_id, type);
        }
    }];
}

//创建钱包
- (IBAction)createWalletAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.selectedWallet) {
            self.selectedWallet(@"", @"createWallet");
        }
    }];
    
//    CreateWalletVC *createVC = [CreateWalletVC new];
//    createVC.type = ComeFromCreating;
//    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:createVC];
////    navi.modalPresentationStyle = 0;
//    [self presentViewController:navi animated:YES completion:^{
//
//    }];
    
//    [self cw_pushViewController:createVC];
//    [self cw_presentViewController:navi drewerHidden:YES];
}

//MARK:lazy
- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

- (NSMutableArray *)aecoDataArr{
    if (!_aecoDataArr) {
        _aecoDataArr = [NSMutableArray array];
    }
    return _aecoDataArr;
}

//导入钱包
- (IBAction)importWalletAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.selectedWallet) {
            self.selectedWallet(@"", @"importWallet");
        }
    }];
}

- (IBAction)dismissAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
            
    }];
}
@end
