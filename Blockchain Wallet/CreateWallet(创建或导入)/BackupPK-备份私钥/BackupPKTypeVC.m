//
//  BackupPKTypeVC.m
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/19.
//

#import "BackupPKTypeVC.h"
#import "AddCurrencyCell.h"
#import "BackupPKVC.h"

@interface BackupPKTypeVC ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) NSMutableArray *imgArr;

@end

@implementation BackupPKTypeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setUI];
    [self createData];
}

- (void)setUI{
    
    self.titleLabel.text = Localized(@"备份私钥");
    [self.tableView registerNib:[UINib nibWithNibName:@"AddCurrencyCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"AddCurrencyCellID"];
}

- (void)createData{
    
    if ([self.type isEqualToString:@"AECO"]) {
        
        NSArray *arr = [Coin MR_findByAttribute:@"address" withValue:self.wallet_id];
        for (Coin *coin in arr) {
            
            CurrencyModel *model = [[CurrencyModel alloc] init];
            model.name = coin.name;
            model.selectStatus = 3;
            model.icon = [NSString stringWithFormat:@"icon_%@", [coin.name lowercaseString]];
            [self.dataArr addObject:model];
        }
    }else{
        
        NSArray *arr = [Coin MR_findByAttribute:@"wallet_id" withValue:self.wallet_id];
        for (Coin *coin in arr) {
            
            if (coin.coin_tag.length < 1) {
                
                CurrencyModel *model = [[CurrencyModel alloc] init];
                model.name = coin.name;
                model.selectStatus = 3;
                model.icon = [NSString stringWithFormat:@"icon_%@", [coin.name lowercaseString]];
                [self.dataArr addObject:model];
            }
        }
    }
    [self.tableView reloadData];
}

- (IBAction)backAction:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

//MARK:UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 75;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AddCurrencyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddCurrencyCellID" forIndexPath:indexPath];
    cell.model = self.dataArr[indexPath.row];
    cell.titleLabel.transform = CGAffineTransformMakeTranslation(0, 35/2-10);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    BackupPKVC *pk = [BackupPKVC new];
    
    if ([self.type isEqualToString:@"AECO"]) {
        
        NSArray *arr = [Coin MR_findByAttribute:@"address" withValue:self.wallet_id];
        NSString *keyID = @"";
        for (Coin *coin in arr) {
            DLog(@"%@", coin.name);
            if ([coin.address isEqualToString:self.wallet_id]) {
                keyID = coin.key_id;
                DLog(@"key_id---%@", coin.key_id);
            }
        }
        pk.wallet_id = self.wallet_id;
        pk.type = self.type;
        pk.passwordString = self.passwordString;
        pk.key_id = keyID;
        [self.navigationController pushViewController:pk animated:YES];
        return;
    }
    NSString *type = ((CurrencyModel *)self.dataArr[indexPath.row]).name;
    
    NSArray *arr = [Coin MR_findByAttribute:@"wallet_id" withValue:self.wallet_id];
    NSString *keyID = @"";
    for (Coin *coin in arr) {
        DLog(@"%@", coin.name);
        if ([coin.name isEqualToString:type]) {
            keyID = coin.key_id;
            DLog(@"key_id---%@", coin.key_id);
        }
    }
    
    pk.wallet_id = self.wallet_id;
    pk.type = type;
    pk.passwordString = self.passwordString;
    pk.key_id = keyID;
    [self.navigationController pushViewController:pk animated:YES];
}


//MARK:LAZY
- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}
- (NSMutableArray *)imgArr{
    if (!_imgArr) {
        _imgArr = [NSMutableArray array];
    }
    return _imgArr;
}

@end
