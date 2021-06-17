//
//  SearchViewController.m
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/11.
//

#import "SearchViewController.h"
#import "View/SearchCell.h"
#import "SecurityUtil.h"
#import "AddCurrencyVC.h"

@interface SearchViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) NSMutableArray *dataArr;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, assign) BOOL isMulityWallet;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setUI];
    [self getHotData];
}

- (void)setUI{
    
    self.searchTextField.placeholder = Localized(@"请输入要添加的币种名称");
    [self.cancelBtn setTitle:Localized(@"取消") forState:UIControlStateNormal];
//    self.tipsLabel.text = Localized(@"当前仅支持添加 ERC20 代币");
//    [PTool YHLabelAttributedString:self.tipsLabel firstText:@"E" toEndText:@"0" textColor:baseColor textSize:17];
    self.sectionTitleLabel.text = Localized(@"热门币种");
    self.addMainChainLabel.text = Localized(@"添加主链");
    self.isMulityWallet = NO;
    
    NSString *currentWalletId = (NSString *)[PTool getValueFromKey:@"defaultWalletAddress"];
    if ([[PTool getWalletInfo:currentWalletId Type:@"type"] isEqualToString:@"Multi"]) {
        self.isMulityWallet = YES;
        self.addMainChainView.hidden = NO;
        self.addMainChainHeight.constant = 70;
    }else{
        self.addMainChainView.hidden = YES;
        self.addMainChainHeight.constant = 0;
    }
    
    [self.searchTypeArr addObject:@"ERC20"];
    [self.searchTypeArr addObject:@"TRC20"];
    
//    [self.searchTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.searchTextField.delegate = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SearchCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"SearchCellID"];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    
    if (textField.text.length > 0 && nil != textField.text) {
        self.headerView.hidden = YES;
        self.addMainChainView.hidden = YES;
        self.addMainChainHeight.constant = 0;
        self.headerHeight.constant = 0;
        [self getCoinListData];
    } else {
        self.addMainChainView.hidden = NO;
        self.headerHeight.constant = 44;
        self.addMainChainHeight.constant = 70;
        self.headerView.hidden = NO;
        [self getHotData];
    }
    return YES;
}

- (NSMutableArray *)getSearchTypeData{
    NSArray *arr = [Coin MR_findByAttribute:@"wallet_id" withValue:self.wallet_id];
    BOOL hasERC20 = NO;
    BOOL hasTRC20 = NO;
    for (Coin *coin in arr) {
        if ([coin.name isEqualToString:@"ETH"]) {
            hasERC20 = YES;
        }else if ([coin.name isEqualToString:@"TRX"]) {
            hasTRC20 = YES;
        }
    }
    NSMutableArray *arrs = [NSMutableArray array];
    if (hasERC20) {
        [arrs addObject:@"ERC20"];
    }
    if (hasTRC20) {
        [arrs addObject:@"TRC20"];
    }
    return arrs;
}

//获取热门币种详情
- (void)getHotData{
//    NSString *url = [NSString stringWithFormat:@"%@/wallet/erc20token/hot", (NSString *)[PTool getValueFromKey:walletHttpAPI]];
#warning 靖汉宇重写接口
    NSString *url = [NSString stringWithFormat:@"%@/v2/wallet/alltoken/hot", (NSString *)[PTool getValueFromKey:walletHttpAPI]];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:[self getSearchTypeData] forKey:@"type"];
    if ([SDKConfig containsString:@"test"]) {
        url = [NSString stringWithFormat:@"http://192.168.0.81:3000/v2/wallet/alltoken/hot"];
    }
    [dic setValue:[self getSearchTypeData] forKey:@"type"];
    [[PHTTPClient shareInstance] bodyRequestMethod:METHOD_POST parameters:dic url:url success:^(id _Nonnull responseObject) {
        
        [self.dataArr removeAllObjects];
        NSInteger code = [[responseObject objectForKey:@"code"] intValue];
        if (0 == code) {
            NSArray *dataArr = [responseObject objectForKey:@"data"];
            if ([PTool isArray:dataArr] && dataArr.count > 0) {
                NSMutableArray *ERC20Arr = [NSMutableArray array];
                NSMutableArray *TRC20Arr = [NSMutableArray array];
                for (NSDictionary *dic in dataArr) {
                    NSError *error = nil;
                    BaseModel *model = [[BaseModel alloc] initWithDictionary:dic error:&error];
                    NSArray *addedCoin = [Coin MR_findByAttribute:@"wallet_id" withValue:self.wallet_id];
                    model.contactAddress = [dic objectForKey:@"address"];
                    if ([[dic objectForKey:@"type"] isEqualToString:@"ERC20"]) {
                        model.address = [self getCoinInfoWithType:@"ETH"].address;
                        model.keyID = [self getCoinInfoWithType:@"ETH"].key_id;
                        for (Coin *coin in addedCoin) {
                            if ([coin.name isEqualToString:[[dic objectForKey:@"symbol"] uppercaseString]] && [coin.coin_tag isEqualToString:@"ERC20"]) {
                                model.selected = @"YES";
                            }
                        }
                        [ERC20Arr addObject:model];
                    }else if ([[dic objectForKey:@"type"] isEqualToString:@"TRC20"]) {
                        model.address = [self getCoinInfoWithType:@"TRX"].address;
                        model.keyID = [self getCoinInfoWithType:@"TRX"].key_id;
                        for (Coin *coin in addedCoin) {
                            if ([coin.name isEqualToString:[[dic objectForKey:@"symbol"] uppercaseString]] && [coin.coin_tag isEqualToString:@"TRC20"]) {
                                model.selected = @"YES";
                            }
                        }
                        [TRC20Arr addObject:model];
                    }
                }
                [self.dataArr addObject:@{@"ERC20":ERC20Arr}];
                [self.dataArr addObject:@{@"TRC20":TRC20Arr}];
            }
        }
        [self.tableView reloadData];
    } failure:^(NSError * _Nonnull error) {
        DLog(@"搜索币种列表接口请求失败");
    }];
}

//确认按钮随输入变化
- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField.text.length > 0 && nil != textField.text) {
        
        self.headerView.hidden = YES;
        self.addMainChainView.hidden = YES;
        self.addMainChainHeight.constant = 0;
        self.headerHeight.constant = 0;
        [self getCoinListData];
    }else{
        self.addMainChainView.hidden = NO;
        self.headerHeight.constant = 44;
        self.addMainChainHeight.constant = 70;
        self.headerView.hidden = NO;
        [self getHotData];
    }
}

//MARK:模糊查询获取ERC20代币列表数据
- (void)getCoinListData{
//    NSString *url = [NSString stringWithFormat:@"%@/wallet/erc20token/fuzzysearch?fuzzy=%@", (NSString *)[PTool getValueFromKey:walletHttpAPI], self.searchTextField.text];
    NSString *url = [NSString stringWithFormat:@"%@/v2/wallet/alltoken/fuzzysearch?fuzzy=%@", (NSString *)[PTool getValueFromKey:walletHttpAPI], self.searchTextField.text];
#warning 靖汉宇重写接口
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:self.searchTextField.text forKey:@"name"];
    [dic setValue:[self getSearchTypeData] forKey:@"type"];
    if ([SDKConfig containsString:@"test"]) {
        url = [NSString stringWithFormat:@"http://192.168.0.81:3000/v2/wallet/alltoken/fuzzysearch"];
    }
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
    [SVProgressHUD showWithStatus:Localized(@"loadingStr")];
    [[PHTTPClient shareInstance] requestMethod:METHOD_POST parameters:dic url:url success:^(id  _Nonnull responseObject) {
        [self.dataArr removeAllObjects];
        NSInteger code = [[responseObject objectForKey:@"code"] intValue];
        if (0 == code) {
            NSArray *dataArr = [responseObject objectForKey:@"data"];
            if ([PTool isArray:dataArr] && dataArr.count > 0) {
                NSMutableArray *ERC20Arr = [NSMutableArray array];
                NSMutableArray *TRC20Arr = [NSMutableArray array];
                NSArray *addedCoin = [Coin MR_findByAttribute:@"wallet_id" withValue:self.wallet_id];
                for (NSDictionary *dic in dataArr) {
                    NSError *error = nil;
                    BaseModel *model = [[BaseModel alloc] initWithDictionary:dic error:&error];
                    model.contactAddress = [dic objectForKey:@"address"];
                    if ([[dic objectForKey:@"type"] isEqualToString:@"ERC20"]) {
//                        model.address = [self getCoinInfoWithType:@"ETH"].address;
//                        model.keyID = [self getCoinInfoWithType:@"ETH"].key_id;
                        for (Coin *coin in addedCoin) {
                            if ([coin.name isEqualToString:[[dic objectForKey:@"symbol"] uppercaseString]] && [coin.coin_tag isEqualToString:@"ERC20"] && [coin.contact_address isEqualToString:[dic objectForKey:@"address"]]) {
                                model.selected = @"YES";
                            }
                        }
                        [ERC20Arr addObject:model];
                    }else if ([[dic objectForKey:@"type"] isEqualToString:@"TRC20"]) {
//                        model.address = [self getCoinInfoWithType:@"TRX"].address;
//                        model.keyID = [self getCoinInfoWithType:@"TRX"].key_id;
                        for (Coin *coin in addedCoin) {
                            if ([coin.name isEqualToString:[[dic objectForKey:@"symbol"] uppercaseString]] && [coin.coin_tag isEqualToString:@"TRC20"] && [coin.contact_address isEqualToString:[dic objectForKey:@"address"]]) {
                                model.selected = @"YES";
                            }
                        }
                        [TRC20Arr addObject:model];
                    }
                }
                [self.dataArr addObject:@{@"ERC20":ERC20Arr}];
                [self.dataArr addObject:@{@"TRC20":TRC20Arr}];
            }
        }
        [self.tableView reloadData];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
        [SVProgressHUD dismiss];
    } failure:^(NSError * _Nonnull error) {
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
        [SVProgressHUD dismiss];
        DLog(@"搜索币种列表接口请求失败");
    }];
}

- (Coin *)getCoinInfoWithType:(NSString *)type{
    NSArray *arr = [Coin MR_findByAttribute:@"wallet_id" withValue:self.wallet_id];
    for (Coin *coin in arr) {
        if ([coin.name isEqualToString:type]) {
            DLog(@"address:%@", coin.address);
            return coin;
        }
    }
    return nil;
}

- (IBAction)backAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//MARK:UITableViewDelegate, UITableViewDataSource
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 44)];
    UILabel *sectionHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, KScreenWidth, 44)];
    sectionHeaderLabel.text = self.searchTypeArr[section];
    [view addSubview:sectionHeaderLabel];
    view.backgroundColor = [UIColor whiteColor];
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *arr = [self.dataArr[section] objectForKey:self.searchTypeArr[section]];
    return arr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (![[self getSearchTypeData] containsObject:self.searchTypeArr[section]]) {
        return 0;
    }
    if (![[self getSearchTypeData] containsObject:self.searchTypeArr[section]]) {
        return 0;
    }
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SearchCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"SearchCellID" forIndexPath:indexPath];
    cell.model = [self.dataArr[indexPath.section] objectForKey:self.searchTypeArr[indexPath.section]][indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    BaseModel *model = [self.dataArr[indexPath.section] objectForKey:self.searchTypeArr[indexPath.section]][indexPath.row];
    NSString *isSelected = model.selected;
    NSString *symbol = model.symbol;
    NSString *contactAddress = model.contactAddress;
    NSString *imageStr = model.logoURI;
    NSString *decimals = model.decimals;
    NSString *type = model.type;
    
    if ([isSelected isEqualToString:@"YES"]) {//已添加过此币种
        [LSStatusBarHUD showLoading:Localized(@"正在删除...")];
        NSArray *arr = [Coin MR_findByAttribute:@"wallet_id" withValue:self.wallet_id];
        for (Coin *coin in arr) {
            if ([coin.name isEqualToString:[symbol uppercaseString]] && [coin.coin_tag isEqualToString:type]) {
                [coin MR_deleteEntity];
            }
        }
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        [LSStatusBarHUD showMessage:Localized(@"删除成功")];
        ((BaseModel *)[self.dataArr[indexPath.section] objectForKey:self.searchTypeArr[indexPath.section]][indexPath.row]).selected = @"NO";
    }else{
        [LSStatusBarHUD showLoading:Localized(@"正在添加...")];
        Coin *coin = [Coin MR_createEntity];
        coin.wallet_id = self.wallet_id;
        coin.name = [symbol uppercaseString];
        coin.coin_tag = type;
        coin.contact_address = contactAddress;
        coin.image = imageStr;
        coin.balance = @"0";
        
        NSString *address = @"";
        NSString *key_id = @"";
        if ([type isEqualToString:@"ERC20"]) {
            address = [self getCoinInfoWithType:@"ETH"].address;
            key_id = [self getCoinInfoWithType:@"ETH"].key_id;
        }else if ([type isEqualToString:@"TRC20"]){
            address = [self getCoinInfoWithType:@"TRX"].address;
            key_id = [self getCoinInfoWithType:@"TRX"].key_id;
        }
        coin.key_id = key_id;
        coin.address = address;
        
        NSArray *coinArr = [Coin MR_findByAttribute:@"address" withValue:address];
        for (Coin *mainCoin in coinArr) {
            if ([type isEqualToString:@"TRC20"] && [mainCoin.name isEqualToString:@"TRX"]) {
                
                coin.account = mainCoin.account;
                coin.index = mainCoin.index;
                coin.change = mainCoin.change;
                coin.coin = mainCoin.coin;
                DLog(@"添加钱包信息：%lld%lld%lld", mainCoin.account, mainCoin.change, mainCoin.coin);
            }else if ([type isEqualToString:@"ERC20"] && [mainCoin.name isEqualToString:@"ETH"]) {
                
                coin.account = mainCoin.account;
                coin.index = mainCoin.index;
                coin.change = mainCoin.change;
                coin.coin = mainCoin.coin;
                DLog(@"添加钱包信息：%lld%lld%lld", mainCoin.account, mainCoin.change, mainCoin.coin);
            }
        }
        coin.decimals = decimals;
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        [LSStatusBarHUD showMessage:Localized(@"添加成功")];
        ((BaseModel *)[self.dataArr[indexPath.section] objectForKey:self.searchTypeArr[indexPath.section]][indexPath.row]).selected = @"YES";
    }
    [self.tableView reloadData];
    if (self.addCoinBlock) {
        self.addCoinBlock(YES);
    }
}

//MARK:添加主链币种
- (IBAction)addMainChainCoinAction:(UIButton *)sender {
    AddCurrencyVC *addVC = [[AddCurrencyVC alloc] init];
    addVC.comeFromeAddingMore = YES;
    [self.navigationController pushViewController:addVC animated:YES];
}

//MARK:LAZY
- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

- (NSMutableArray *)searchTypeArr{
    if (!_searchTypeArr) {
        _searchTypeArr = [NSMutableArray array];
    }
    return _searchTypeArr;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
@end
