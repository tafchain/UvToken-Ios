//
//  PWallet.m
//  Blockchain Wallet
//
//  Created by Panerly on 2021/4/19.
//

#import "PWallet.h"
#import <walletsdk/Walletsdk.h>

@implementation PWallet

+ (instancetype)shareInstance
{
    static PWallet *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[PWallet alloc] init];
    });
    return singleton;
}
//MARK:钱包地址
- (NSString *)walletPath{
    
    //获取Documents路径
    NSArray *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsPath = [[document objectAtIndex:0] stringByAppendingPathComponent:@"keystore"];
    return documentsPath;
}

//MARK:创建钱包
- (void)createWalletWithCoinType:(NSString *)coinTypes Password:(NSString *)password WalletID:(void(^)(NSString *walletID))walletID AddCoinModel:(void(^)(AddCoinModel *coinModel))addCoinModel failure:(void (^)(NSError * failure))failure{
    
    ApiCreateWalletRequest *req = [[ApiCreateWalletRequest alloc] init];
    req.coinTypes = coinTypes;
    req.keystoreDir = [self walletPath];
    req.keystorePassword = password;
    
    PWS(weakSelf);
    dispatch_queue_t queue = dispatch_queue_create("com.uvtoken.createWallet", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        
        NSError *error = nil;
        ApiCreateWalletResponse *res = Uv1CreateWallet(req, &error);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (walletID) {
                walletID(res.walletId);
                NSArray *coinTypeArr = [coinTypes componentsSeparatedByString:@","];
                for (int i = 0; i < coinTypeArr.count; i++) {
                    [weakSelf createCoin:coinTypeArr[i] Password:password WalletID:res.walletId CoinModel:^(AddCoinModel *coinModel) {
                        if (addCoinModel) {
                            addCoinModel(coinModel);
                        }
                    } createCoinfailure:^(NSError *error) {
                        if (failure) {
                            failure(error);
                        }
                    }];
                }
            }
            if (error) {
                DLog(@"创建钱包失败---%@", error.localizedDescription);
                if (failure) {
                    failure(error);
                }
            }
            [self releaseMemory];
        });
    });
}

//MARK:创建币
- (void)createCoin:(NSString *)coinTpye Password:(NSString *)password WalletID:(NSString *)walletID  CoinModel:(void(^)(AddCoinModel *coinModel))coinModel  createCoinfailure:(void (^)(NSError * error))failure{
    
    ApiAddCoinTypeRequest *req = [[ApiAddCoinTypeRequest alloc] init];
    req.coinType = coinTpye;
    req.keystoreDir = [self walletPath];
    req.keystorePassword = password;
    req.walletId = walletID;
    
    dispatch_queue_t queue = dispatch_queue_create("com.uvtoken.createCoin", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        
        NSError *error = nil;
        ApiAddCoinTypeResponse *res = Uv1AddCoinType(req, &error);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (coinModel) {
                AddCoinModel *model = [[AddCoinModel alloc] init];
                model.account = res.account;
                model.address = res.address;
                model.change = res.change;
                model.coin = res.coin;
                model.index = res.index;
                model.walletID = walletID;
                model.coinType = coinTpye;
                model.keyId = walletID;
                coinModel(model);
            }
            if (error) {
                if (failure) {
                    failure(error);
                }
                DLog(@"创建%@币失败---%@", coinTpye, error.localizedDescription);
            }
        });
    });
}

//MARK:验证钱包密码
-(void)verifyWalletPwdWithWalletID:(NSString *)walletID Pwd:(NSString *)pwd valid:(void(^)(BOOL valid))valid{
    
    ApiVerifyWalletPasswordRequest *req = [[ApiVerifyWalletPasswordRequest alloc] init];
    req.keystoreDir = [self walletPath];
    req.password = pwd;
    req.walletId = walletID;
    
    dispatch_queue_t queue = dispatch_queue_create("com.uvtoken.verifyPwd", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        
        ApiVerifyWalletPasswordResponse *res = Uv1VerifyWalletPassword(req);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (valid) {
                valid(res.valid);
            }
            [self releaseMemory];
        });
    });
}

//MARK:导入私钥
- (void)importPkWithCoinType:(NSString *)coinType Password:(NSString *)password PrivateKey:(NSString *)privateKey response:(void(^)(AddCoinModel *response))response failure:(void (^)(NSError * failure))failure{
    
    [LSStatusBarHUD showLoading:Localized(@"正在导入...")];
    ApiImportPrivateKeyRequest *req = [[ApiImportPrivateKeyRequest alloc] init];
    req.coinType = coinType;
    req.keystoreDir = [self walletPath];
    req.passphrase = password;
    req.privateKey = privateKey;
    
    dispatch_queue_t queue = dispatch_queue_create("com.uvtoken.importPK", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        
        NSError *error = nil;
        ApiImportPrivateKeyResponse *res = Uv1ImportPrivateKey(req, &error);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (res.keyId) {
                if (response) {
                    
                    AddCoinModel *model = [[AddCoinModel alloc] init];
                    model.address = res.address;
                    model.keyId = res.keyId;
                    model.walletID = res.keyId;
                    response(model);
                }
            }
            if (error) {
                if (failure) {
                    failure(error);
                }
            }
            [self releaseMemory];
        });
    });
}
//MARK:导入助记词钱包
- (void)importMnemonicWithCoinTypes:(NSString *)coinTypes Password:(NSString *)password Mnemonics:(NSString *)mnemonics WalletID:(void(^)(NSString *walletID))walletID AddCoinModel:(void(^)(AddCoinModel *coinModel))addCoinModel failure:(void (^)(NSError * failure))failure{
    
    ApiImportWalletFromMnemonicRequest *req = [[ApiImportWalletFromMnemonicRequest alloc] init];
    req.coinTypes = coinTypes;
    req.keystoreDir = [self walletPath];
    req.keystorePassword = password;
    req.mnemonics = mnemonics;
    PWS(weakSelf);
    dispatch_queue_t queue = dispatch_queue_create("com.uvtoken.importMnemonic", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        
        NSError *error = nil;
        ApiImportWalletFromMnemonicResponse *res = Uv1ImportWalletFromMnemonic(req, &error);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (walletID) {
                walletID(res.walletId);
            }
            
            NSArray *coinTypeArr = [coinTypes componentsSeparatedByString:@","];
            for (int i = 0; i < coinTypeArr.count; i++) {
                [weakSelf createCoin:coinTypeArr[i] Password:password WalletID:res.walletId CoinModel:^(AddCoinModel *coinModel) {
                    if (addCoinModel) {
                        addCoinModel(coinModel);
                    }
                } createCoinfailure:^(NSError * _Nonnull error) {
                    if (error) {
                        failure(error);
                    }
                }];
            }
            
            if (error) {
                if (failure) {
                    failure(error);
                }
            }
            [weakSelf releaseMemory];
        });
    });
}
//MARK:备份单链钱包私钥--获取单链私钥
- (void)getPKDataFromSingleChainWithCoinType:(NSString *)coinType WalletID:(NSString *)walletID Password:(NSString *)password privateKey:(void(^)(NSString *privateKey))privateKey failure:(void (^)(NSError * failure))failure{
    
    ApiExportPrivateKeyRequest *req = [[ApiExportPrivateKeyRequest alloc] init];
    req.coinType = coinType;
    req.keystoreDir = [self walletPath];
    req.passphrase = password;
    req.keyId = walletID;
    
    dispatch_queue_t queue = dispatch_queue_create("com.uvtoken.getPKData", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        
        NSError *error = nil;
        ApiExportPrivateKeyResponse *res = Uv1ExportPrivateKey(req, &error);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (privateKey) {
                privateKey(res.privateKey);
            }
            if (error) {
                if (failure) {
                    failure(error);
                }
            }
            [self releaseMemory];
        });
    });
}

//MARK:备份多链钱包私钥--获取单链PK
- (void)getPKDataFromMasterWithParam:(NSDictionary *)param privateKey:(void(^)(NSString *privateKey))privateKey failure:(void (^)(NSError * failure))failure{
    
    ApiExportPrivateKeyFromMasterRequest *req = [[ApiExportPrivateKeyFromMasterRequest alloc] init];
    req.keystoreDir = [self walletPath];
    req.passphrase = param[@"password"];
    req.walletId = param[@"wallet_id"];
    req.account = [param[@"account"] longLongValue];
    req.change = [param[@"change"] longLongValue];
    req.index = [param[@"index"] longLongValue];
    req.coin = [param[@"coin"] longLongValue];
    
    dispatch_queue_t queue = dispatch_queue_create("com.uvtoken.getPKData", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        
        NSError *error = nil;
        ApiExportPrivateKeyFromMasterResponse *res = Uv1ExportPrivateKeyFromMaster(req, &error);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (privateKey) {
                privateKey(res.privateKey);
            }
            if (error) {
                if (failure) {
                    failure(error);
                }
            }
            [self releaseMemory];
        });
    });
}
//MARK:备份助记词
- (void)getMnemonicWithWalletID:(NSString *)walletID Password:(NSString *)password mnemonics:(void(^)(NSString *mnemonics))mnemonics failure:(void (^)(NSError * failure))failure{
    
    ApiBackupMnemonicRequest *req = [[ApiBackupMnemonicRequest alloc] init];
    req.keystoreDir = [self walletPath];
    req.keystorePassword = password;
    req.walletId = walletID;
    
    dispatch_queue_t queue = dispatch_queue_create("com.uvtoken.getPKData", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        
        NSError *error = nil;
        ApiBackupMnemonicResponse *res = Uv1BackupMnemonic(req, &error);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (mnemonics) {
                mnemonics(res.mnemonics);
            }
            if (error) {
                if (failure) {
                    failure(error);
                }
            }
            [self releaseMemory];
        });
    });
}

//MARK:修改钱包密码
- (void)changeWalletPwdWithKeyIDs:(NSString *)keyIDs PrevPassword:(NSString *)prevPassword NewPassword:(NSString *)newPassword WalletId:(NSString *)walletId success:(void(^)(bool success))success{
    ApiModifyPasswordRequest *req = [[ApiModifyPasswordRequest alloc] init];
    req.keystoreDir = [self walletPath];
    req.keyIds = keyIDs;
    req.prevPassword = prevPassword;
    req.newPassword = newPassword;
    req.walletId = walletId;
    
    dispatch_queue_t queue = dispatch_queue_create("com.uvtoken.changePwd", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        
        NSError *error = nil;
        ApiModifyPasswordResponse *res = Uv1ModifyPassword(req, &error);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (res.walletId) {
                if (success) {
                    success(YES);
                }
            }
            if (error) {
                if (success) {
                    success(NO);
                }
            }
            [self releaseMemory];
        });
    });
}

//MARK:查询BTC区块高度内的交易哈希
- (void)getTxHashsFromBlockHeight:(NSString *)blockHeight Address:(NSString *)address CoinType:(NSString *)coinType TokenType:(NSString *)tokenType txIDs:(void(^)(NSString *txIDs))txIDs failure:(void (^)(NSError * failure))failure{
    
    ApiGetAddressesTxIdsRequest *req = [[ApiGetAddressesTxIdsRequest alloc] init];
    req.startHeight = [blockHeight integerValue];
    req.addresses = address;
    req.coinType = coinType;
    req.tokenType = tokenType;
    
    dispatch_queue_t queue = dispatch_queue_create("com.uvtoken.getTxHashs", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        
        NSError *error = nil;
        ApiGetAddressesTxIdsResponse *res = Uv1GetAddressesTxIds(req, &error);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (txIDs) {
                txIDs(res.txIds);
            }
            if (error) {
                if (failure) {
                    failure(error);
                }
            }
            [self releaseMemory];
        });
    });
}
//MARK:根据交易ID查询交易
- (void)getFeeRateWithAddress:(NSString *)address size:(void(^)(NSString *size))size failure:(void (^)(NSError * failure))failure{
    
    ApiEstimateTransactionSizeRequest *req = [[ApiEstimateTransactionSizeRequest alloc] init];
    req.address = address;
    
    dispatch_queue_t queue = dispatch_queue_create("com.uvtoken.getSize", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        
        NSError *error = nil;
        ApiEstimateTransactionSizeResponse *res = Uv1EstimateTransactionSize(req, &error);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (size) {
                size([NSString stringWithFormat:@"%ld", res.size]);
            }
            if (error) {
                if (failure) {
                    failure(error);
                }
            }
            [self releaseMemory];
        });
    });
}
//MARK:获取BTC低中高费率
- (void)getBTCFeeRateWithCoinType:(NSString *)coinType rate:(void(^)(AddCoinModel *rate))rate failure:(void (^)(NSError * failure))failure{
    
    ApiTransactionFeeRateRequest *req = [[ApiTransactionFeeRateRequest alloc] init];
    req.coinType = coinType;
    
    dispatch_queue_t queue = dispatch_queue_create("com.uvtoken.getBTCFeeRate", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        
        NSError *error = nil;
        ApiTransactionFeeRateResponse *res = Uv1TransactionFeeRate(req, &error);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (rate) {
                AddCoinModel *model = [[AddCoinModel alloc] init];
                model.fastestFee = res.fastestFee;
                model.halfHourFee = res.halfHourFee;
                model.hourFee = res.hourFee;
                rate(model);
            }
            if (error) {
                if (failure) {
                    failure(error);
                }
            }
            [self releaseMemory];
        });
    });
}
//MARK:获取ETH费率
- (void)getETHFee:(void(^)(NSString *feeRate))feeRate failure:(void (^)(NSError * failure))failure{
    
    ApiEstimateEthGasPriceRequest *req = [[ApiEstimateEthGasPriceRequest alloc] init];
    
    dispatch_queue_t queue = dispatch_queue_create("com.uvtoken.getETHFee", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        
        NSError *error = nil;
        ApiEstimateEthGasPriceResponse *res = Uv1EstimateEthGasPrice(req, &error);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (feeRate) {
                feeRate(res.feeRate);
            }
            if (error) {
                if (failure) {
                    failure(error);
                }
            }
            [self releaseMemory];
        });
    });
}

//MARK:删除多链钱包钱包
- (void)deleteWalletWithWalletID:(NSString *)walletID Password:(NSString *)password success:(void(^)(bool success))success failure:(void (^)(NSError * failure))failure{
    
    ApiRemoveWalletRequest *req = [[ApiRemoveWalletRequest alloc] init];
    req.keystoreDir = [self walletPath];
    req.password = password;
    req.walletId = walletID;
    
    dispatch_queue_t queue = dispatch_queue_create("com.uvtoken.deleteWallet", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        
        NSError *error = nil;
        ApiRemoveWalletResponse *res = Uv1RemoveWallet(req, &error);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (res.walletId) {
                if (success) {
                    success(YES);
                }
            }
            if (error) {
                if (failure) {
                    failure(error);
                }
            }
            [self releaseMemory];
        });
    });
}

//MARK:删除单链钱包
- (void)deleteSingleChainWalletWithKeyIDs:(NSString *)keyIDs Password:(NSString *)password success:(void(^)(bool success))success failure:(void (^)(NSError * failure))failure{
    
    ApiRemoveKeyRequest *req = [[ApiRemoveKeyRequest alloc] init];
    req.keystoreDir = [self walletPath];
    req.keyIds = keyIDs;
    req.password = password;
    
    dispatch_queue_t queue = dispatch_queue_create("com.uvtoken.deleteSingleChainWallet", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        
        NSError *error = nil;
        ApiRemoveKeyResponse *res = Uv1RemoveKey(req, &error);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (res.keyIds) {
                if (success) {
                    success(YES);
                }
            }
            if (error) {
                if (failure) {
                    failure(error);
                }
            }
            [self releaseMemory];
        });
    });
}

//MARK:手动释放内存
- (void)releaseMemory{
    
    dispatch_queue_t queue = dispatch_queue_create("com.uvtoken.releaseMemonry", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        Uv1GarbageCollection();
    });
}

//MARK:获取余额币
- (void)getWalletBalanceWithAddress:(NSString *)address TokenAddress:(NSString *)tokenAddress CoinType:(NSString *)coinType TokenType:(NSString *)tokenType response:(void(^)(AddCoinModel *response))response failure:(void (^)(NSError * failure))failure{
    
    ApiGetAddressBalanceRequest *req = [[ApiGetAddressBalanceRequest alloc] init];
    req.address = address;
    req.coinType = coinType;
    req.tokenType = tokenType;
    req.tokenAddress = tokenAddress;
    
    dispatch_queue_t queue = dispatch_queue_create("com.uvtoken.getWalletBalance", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        
        NSError *error = nil;
        ApiGetAddressBalanceResponse *res = Uv1GetAddressBalance(req, &error);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (response) {
                
                AddCoinModel *model = [[AddCoinModel alloc] init];
                model.coinType = res.coinType;
                model.address = res.address;
                model.tokenType = res.tokenType;
                model.balanceAmount = res.balanceAmount;
                response(model);
            }
            if (error) {
                if (failure) {
                    failure(error);
                }
            }
            [self releaseMemory];
        });
    });
}
//MARK:验证地址是否合法
- (void)validAddress:(NSString *)address CoinType:(NSString *)coinType valid:(void(^)(bool valid))valid failure:(void (^)(NSError * failure))failure{
    
    ApiValidateAddressRequest *req = [[ApiValidateAddressRequest alloc] init];
    req.address = address;
    req.coinType = coinType;
    dispatch_queue_t queue = dispatch_queue_create("com.uvtoken.validAddress", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        
        NSError *error = nil;
        ApiValidateAddressResponse *res = Uv1ValidateAddress(req, &error);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (valid) {
                valid(res.valid);
            }
            if (error) {
                if (failure) {
                    failure(error);
                }
            }
            [self releaseMemory];
        });
    });
}

//MARK:配置钱包
- (void)configWithNet:(NSString *)net response:(void(^)(NSString *response))response{
    
    ApiParamRequest *req = [[ApiParamRequest alloc] init];
    req.net = net;
    NSError *error = nil;
    ApiParamResponse *res = Uv1ParamConfig(req, &error);
    if (res.net) {
        DLog(@"钱包SDK版本：%@", res.verSion);
        if (response) {
            response(res.net);
        }
    }
}

//MARK:兼容以前旧数据
- (void)compatibleOldData{
    
//    //暂时不开放
//    return;
    NSArray *coinArr = [Coin MR_findAll];
    for (Coin *coin in coinArr) {
        
        if ([coin.name isEqualToString:@"BTC"]) {
            if (!coin.coin) {
                coin.coin = 0x80000000;
                coin.account = 0x80000000;
                coin.index = 0;
                coin.change = 0;
            }
        }
        if ([coin.name isEqualToString:@"ETH"]) {
            if (!coin.coin) {
                coin.coin = 0x8000003c;
                coin.account = 0x80000000;
                coin.index = 0;
                coin.change = 0;
            }
        }
        if ([coin.name isEqualToString:@"AECO"]) {
            if (!coin.coin || !coin.account) {
                coin.coin = 0x80000001;
                coin.account = 0x80000000;
                coin.index = 0;
                coin.change = 0;
            }
        }
        if ([coin.name isEqualToString:@"USDT"]) {
            if ([coin.coin_tag isEqualToString:@"ERC20"]) {
                if (!coin.coin) {
                    coin.coin = 0x8000003c;
                    coin.account = 0x80000000;
                    coin.index = 0;
                    coin.change = 0;
                }
            }
            if ([coin.coin_tag isEqualToString:@"OMNI"]) {
                if (!coin.coin) {
                    coin.coin = 0x80000000;
                    coin.account = 0x80000000;
                    coin.index = 0;
                    coin.change = 0;
                }
            }
        }
        
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }
}

//MARK:ETH兑换其它代币
- (void)ethTransactionWithCoin:(Coin *)coin Password:(NSString *)password FromAddress:(NSString *)fromAddress ToAddress:(NSString *)toAddress Amount:(NSString *)amount GasLimit:(int64_t)gasLimit Data:(NSString *)data Success:(void(^)(NSString *txid, NSString *nonce))success failure:(void (^)(NSError * failure))failure{
    
    ApiETHTransactionRequest *req = [[ApiETHTransactionRequest alloc] init];
    req.keystoreDir = [self walletPath];
    req.coin = coin.coin;
    req.account = coin.account;
    req.change = coin.change;
    req.index = coin.index;
    req.passphrase = password;
    req.fromAddress = fromAddress;
    req.toAddress = toAddress;
    req.amount = amount;
    req.gasLimit = gasLimit;
    req.data = data;
    req.keyId = coin.wallet_id;
    dispatch_queue_t queue = dispatch_queue_create("com.uvtoken.ethTransaction", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        
        NSError *error = nil;
        ApiETHTransactionResponse *res = Uv1SendETHTransaction(req, NO, &error);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (res.txId) {
                if (success) {
                    success(res.txId, res.nonce);
                }
            }
            if (error) {
                if (failure) {
                    failure(error);
                }
            }
            [self releaseMemory];
        });
    });
}
//MARK:转换成标准EIP55地址
- (void)getEthStandardAddress:(NSString *)address Success:(void(^)(NSString *standardAddress))success failure:(void (^)(NSError * failure))failure{
    
    ApiETHEipAddressRequest *req = [[ApiETHEipAddressRequest alloc] init];
    req.address = address;
    dispatch_queue_t queue = dispatch_queue_create("com.uvtoken.getStandardAddress", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        
        NSError *error = nil;
        ApiETHEipAddressResponse *res = Uv1ToEip55Address(req, &error);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (res.address) {
                if (success) {
                    success(res.address);
                }
            }
            if (error) {
                if (failure) {
                    failure(error);
                }
            }
            [self releaseMemory];
        });
    });
}

//MARK:验证当前交易是否未完成
- (void)validTransactionWithTx_id:(NSString *)tx_id valid:(void(^)(bool valid))valid failure:(void (^)(NSError * failure))failure{
    
    ApiQueryETHTransactionRequest *req = [[ApiQueryETHTransactionRequest alloc] init];
    req.txId = tx_id;

    dispatch_queue_t queue = dispatch_queue_create("com.uvtoken.validTxid", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{

        NSError *error = nil;
        ApiQueryETHTransactionResponse *res = Uv1GetETHTransactionReceipt(req, &error);
        dispatch_async(dispatch_get_main_queue(), ^{

            if (valid) {
                valid(res.value);
            }
            if (error) {
                if (failure) {
                    failure(error);
                }
            }
            [self releaseMemory];
        });
    });
}

//MARK:保存ETH钱包交易记录
- (void)saveEthRecordToLocalDBWithArr:(NSArray *)txhashsArr CoinTagString:(NSString *)coinTagString ContactAddressStr:(NSString *)contactAddressStr AddressStr:(NSString *)addressStr CurrencyType:(NSString *)currencyType Decimals:(NSString *)decimals{
    
    for (int i = 0; i < txhashsArr.count; i++) {
        
        NSString *timestamp     = [txhashsArr[i] objectForKey:@"timestamp"];
        NSString *hash          = [txhashsArr[i] objectForKey:@"hash"];
        NSString *blockNumber   = [txhashsArr[i] objectForKey:@"blockNumber"];
        NSString *status        = [NSString stringWithFormat:@"%@", [txhashsArr[i] objectForKey:@"status"]];// 0:失败 1:成功 404:区块高度在一万以内的状态获取不到，统一为提交成功
        NSString *toAddress     = [NSString stringWithFormat:@"%@", [txhashsArr[i] objectForKey:@"to_"]];
        NSString *fromAddress   = [NSString stringWithFormat:@"%@", [txhashsArr[i] objectForKey:@"from_"]];
        NSString *amount        = [txhashsArr[i] objectForKey:@"value_"];
        NSString *gasUsedStr    = [txhashsArr[i] objectForKey:@"gasUsed"];
        NSString *gasPriceStr   = [txhashsArr[i] objectForKey:@"gasPrice"];
        NSDecimalNumber *gasUsedD   = [NSDecimalNumber decimalNumberWithString:gasUsedStr];
        NSDecimalNumber *gasPriceD  = [NSDecimalNumber decimalNumberWithString:gasPriceStr];
        NSDecimalNumber *minerFeeD  = [[gasUsedD decimalNumberByMultiplyingBy:gasPriceD] decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:ETHTOWEI]];
        
        if (![coinTagString containsString:@"null"]) {//代币
            
#warning v2更改：inputDecode改为logs数组，取值的时候按照地址作为key进行取值
//                toAddress = [[txhashsArr[i] objectForKey:@"inputDecode"] objectForKey:@"_to"];
//                fromAddress = [[txhashsArr[i] objectForKey:@"inputDecode"]objectForKey:@"_from"];
//                amount = [[txhashsArr[i] objectForKey:@"inputDecode"]objectForKey:@"_value"];
            NSArray * arr = [txhashsArr[i] objectForKey:@"logs"];
            if ([PTool isArray:arr]) {
                for (NSDictionary *dic in arr) {
                    if ([dic[@"_address"] isEqualToString:contactAddressStr]) {
                        toAddress = [dic objectForKey:@"_to"];
                        fromAddress = [dic objectForKey:@"_from"];
                        amount = [dic objectForKey:@"_value"];
                    }
                }
            }
        }
        
        NSArray *arr = [Record MR_findByAttribute:@"tx_id" withValue:hash];
        for (Record *record in arr) {
            if ([record.address isEqualToString:addressStr] && [record.name isEqualToString:currencyType]) {//代币与主币地址相同，所以需要币名称做区分
                record.time = [PTool ConvertStrToTime:[NSString stringWithFormat:@"%@", timestamp]];
                if ([coinTagString isEqualToString:@"ERC20"]) {
                    
                    NSDecimalNumber *amountD = [NSDecimalNumber decimalNumberWithString:amount];
                    for (int i = 0; i < [decimals integerValue]; i++) {
                        amountD = [amountD decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"10"]];
                    }
                    record.amount = [NSString stringWithFormat:@"%@", amountD];
                }else{
                    
                    NSDecimalNumber *amountD = [[NSDecimalNumber decimalNumberWithString:amount] decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:ETHTOWEI]];
                    record.amount = [NSString stringWithFormat:@"%@", amountD];
                }
                record.type = [toAddress isEqualToString:addressStr]?@"收款":@"转账";
                
                if (![addressStr isEqualToString:fromAddress]) {//自己是收款方
                    
                    record.to_address = fromAddress;
                }else{
                    
                    record.to_address = toAddress;
                }
                record.block_height = [NSString stringWithFormat:@"%@", blockNumber];
                record.result = status;
                record.miner_fee = [NSString stringWithFormat:@"%@", minerFeeD];
                record.gas_price = [NSString stringWithFormat:@"%@", gasPriceStr];
                [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            }
        }
    }
}


//MARK:保存BTC以及代币交易记录
- (void)saveBtcRecordWithTxhashsArr:(NSArray *)txhashsArr AddressStr:(NSString *)addressStr CurrencyType:(NSString *)currencyType CoinTagString:(NSString *)coinTagString{
    
    for (int i = 0; i < txhashsArr.count; i++) {
        
        NSString *timestamp = [txhashsArr[i] objectForKey:@"blocktime"];
        
        NSString *hash = [txhashsArr[i] objectForKey:@"txid"];
        
        NSString *blockNumber = [txhashsArr[i] objectForKey:@"blockheight"];
        
        //USDT 判断valid是否为false 如果为false则此笔交易为失败状态
//        NSString *valid = [NSString stringWithFormat:@"%@", [txhashsArr[i] objectForKey:@"valid"]];
        
        NSArray *toAddressArr = [txhashsArr[i] objectForKey:@"to_addresses"];
        NSArray *fromAddressArr = [txhashsArr[i] objectForKey:@"from_addresses"];
        
        NSString *fromAddress = @"";
        NSString *toAddress = @"";
        NSString *fromAmount = @"";
        NSString *toAmount = @"";
        NSString *targetAddress = @"";
        
        //from为空，to里有数据
        if (![PTool isArray:fromAddressArr]&&[PTool isArray:toAddressArr]) {
            
            //如果to里有自己，那么取自己的那条数据为有效数据
            if ([PTool isArray:toAddressArr]) {
                BOOL isSelfAddress = NO;
                NSString *maxAmount = @"0";
                NSInteger avalibleIndex = 0;
                for (int i = 0; i < toAddressArr.count; i++) {
                    NSString *currentFromAddress = [NSString stringWithFormat:@"%@", [toAddressArr[i] objectForKey:@"address"]];
                    NSString *currentAmount = [NSString stringWithFormat:@"%@", [toAddressArr[i] objectForKey:@"amount"]];
                    if ([addressStr isEqualToString:currentFromAddress]) {
                        isSelfAddress = YES;
                        toAddress = addressStr;
                        toAmount = currentAmount;
                    }
                    NSDecimalNumber *maxAmountD = [NSDecimalNumber decimalNumberWithString:maxAmount];
                    NSDecimalNumber *currentAmountD = [NSDecimalNumber decimalNumberWithString:currentAmount];
                    if ([maxAmountD compare:currentAmountD] == NSOrderedAscending) {
                        avalibleIndex = i;
                    }
                }
                //计算出对方的地址
                targetAddress = [toAddressArr[avalibleIndex] objectForKey:@"address"];
                
                //如果没有自己的地址那么取最大金额的那条数据为有效数据
                if (!isSelfAddress) {
                    DLog(@"from为空，to里面没有自己.toAddressArr:%@", toAddressArr);
                }else{
                    //保存到数据库里
                    NSArray *arrAll = [Record MR_findByAttribute:@"tx_id" withValue:hash];
                    NSMutableArray *arr = [NSMutableArray array];
                    for (Record *record in arrAll) {
                        if ([record.name isEqualToString:currencyType] && [record.address isEqualToString:addressStr]) {
                            [arr addObject:record];
                        }
                    }
                    for (Record *record in arr) {
                        record.time = [PTool ConvertStrToTime:[NSString stringWithFormat:@"%@", timestamp]];
                        record.to_address = targetAddress;
                        record.amount = toAmount.length > 0?toAmount:fromAmount;
                        record.type = @"挖矿奖励";
//                            record.type = @"收款";
                        record.block_height = [NSString stringWithFormat:@"%@", blockNumber];
                        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                    }
                }
            }
        }
        //from有数据，to里无数据（这种情况不应该出现）
        if ([PTool isArray:fromAddressArr]&&![PTool isArray:toAddressArr]) {
            
            DLog(@"from数组有数据：%@,to数组无数据", fromAddressArr);
        }
        
        //from和to里都有数据
        if ([PTool isArray:fromAddressArr] && [PTool isArray:toAddressArr]) {
            
            BOOL bothSelf = NO;
            NSDecimalNumber *fromValueSumD = [NSDecimalNumber decimalNumberWithString:@"0"];
            NSDecimalNumber *toValueSumD = [NSDecimalNumber decimalNumberWithString:@"0"];
            
            for (int i = 0; i < fromAddressArr.count; i++) {
                NSString *currentFromAddress = [NSString stringWithFormat:@"%@", [fromAddressArr[i] objectForKey:@"address"]];
                NSString *currentAmount = [NSString stringWithFormat:@"%@", [fromAddressArr[i] objectForKey:@"amount"]];
                NSDecimalNumber *currentAmountD = [NSDecimalNumber decimalNumberWithString:currentAmount];
                fromValueSumD = [fromValueSumD decimalNumberByAdding:currentAmountD];
                for (int j = 0; j < toAddressArr.count; j++) {
                    NSString *currentToAddress = [NSString stringWithFormat:@"%@", [toAddressArr[j] objectForKey:@"address"]];
                    if ([currentFromAddress isEqualToString:currentToAddress] && [currentToAddress isEqualToString:addressStr]) {
                        bothSelf = YES;
                    }
                }
            }
            
            for (int i = 0; i < toAddressArr.count; i++) {
                NSString *currentAmount = [NSString stringWithFormat:@"%@", [toAddressArr[i] objectForKey:@"amount"]];
                NSDecimalNumber *currentAmountD = [NSDecimalNumber decimalNumberWithString:currentAmount];
                toValueSumD = [toValueSumD decimalNumberByAdding:currentAmountD];
            }
            
            //如果转账方和收款方里都有自己的数据，那么在收款方里查找到除了自己那条数据外最大的值作为有效数据
            if (bothSelf) {
                NSString *maxAmount = @"0";
                NSInteger maxAmountIndex = 0;
                for (int j = 0; j < toAddressArr.count; j++) {
                    NSString *currentToAddress = [NSString stringWithFormat:@"%@", [toAddressArr[j] objectForKey:@"address"]];
                    NSString *currentAmount = [NSString stringWithFormat:@"%@", [toAddressArr[j] objectForKey:@"amount"]];
                    //移除自己的数据，查找最大的金额，作为实际收款人信息
                    if (![addressStr isEqualToString:currentToAddress]) {
                        NSDecimalNumber *maxAmountD = [NSDecimalNumber decimalNumberWithString:maxAmount];
                        NSDecimalNumber *currentAmountD = [NSDecimalNumber decimalNumberWithString:currentAmount];
                        if ([maxAmountD compare:currentAmountD] == NSOrderedAscending) {
                            maxAmount = currentAmount;
                            maxAmountIndex = j;
                        }
                    }
                }
                fromAddress = addressStr;
                targetAddress = [toAddressArr[maxAmountIndex] objectForKey:@"address"];
                toAmount = [toAddressArr[maxAmountIndex] objectForKey:@"amount"];
                
                //保存到数据库里
                NSArray *arrAll = [Record MR_findByAttribute:@"tx_id" withValue:hash];
                NSMutableArray *arr = [NSMutableArray array];
                for (Record *record in arrAll) {
                    if ([record.name isEqualToString:currencyType] && [record.address isEqualToString:addressStr]) {
                        [arr addObject:record];
                    }
                }
                for (Record *record in arr) {
                    record.time = [PTool ConvertStrToTime:[NSString stringWithFormat:@"%@", timestamp]];
                    record.to_address = targetAddress;
                    record.amount = toAmount;
                    record.type = @"转账";
                    record.block_height = [NSString stringWithFormat:@"%@", blockNumber];
                    if ([coinTagString isEqualToString:@"OMNI"]) {
                        
                        record.miner_fee = [NSString stringWithFormat:@"%@", [txhashsArr[i] objectForKey:@"fee"]];
                        record.valid = [NSString stringWithFormat:@"%@", [txhashsArr[i] objectForKey:@"valid"]];
                    }else{
                        
                        record.miner_fee = [NSString stringWithFormat:@"%@", [fromValueSumD decimalNumberBySubtracting:toValueSumD]];
                    }
                    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                }
            }else{//转账方和收款方不同时有自己，那么取出来from或者to里的自己那条数据
                
                NSInteger fromMaxAmountIndex = 0;
                NSInteger toMaxAmountIndex = 0;
                NSInteger toSelfAmountIndex = 0;
                NSDecimalNumber *fromMaxAmountD = [NSDecimalNumber decimalNumberWithString:@"0"];
                NSDecimalNumber *toMaxAmountD = [NSDecimalNumber decimalNumberWithString:@"0"];
                BOOL isFromSelf = NO;
                
                //在from里筛选出自己的那一条数据
                for (int i = 0; i < fromAddressArr.count; i++) {
                    NSString *currentFromAddress = [NSString stringWithFormat:@"%@", [fromAddressArr[i] objectForKey:@"address"]];
                    NSString *currentAmount = [NSString stringWithFormat:@"%@", [fromAddressArr[i] objectForKey:@"amount"]];
                    NSDecimalNumber *currentAmountD = [NSDecimalNumber decimalNumberWithString:currentAmount];
                    if ([addressStr isEqualToString:currentFromAddress]) {
                        fromAddress = addressStr;
                        fromAmount = currentAmount;
                        isFromSelf = YES;
                    }
                    if ([fromMaxAmountD compare:currentAmountD] == NSOrderedAscending) {
                        fromMaxAmountD = currentAmountD;
                        fromMaxAmountIndex = i;
                    }
                }
                //在to里筛选出来自己的那一条数据
                for (int i = 0; i < toAddressArr.count; i++) {
                    NSString *currentToAddress = [NSString stringWithFormat:@"%@", [toAddressArr[i] objectForKey:@"address"]];
                    NSString *currentAmount = [NSString stringWithFormat:@"%@", [toAddressArr[i] objectForKey:@"amount"]];
                    NSDecimalNumber *currentAmountD = [NSDecimalNumber decimalNumberWithString:currentAmount];
                    if ([addressStr isEqualToString:currentToAddress]) {
                        toAddress = currentToAddress;
                        toAmount = currentAmount;
                        isFromSelf = NO;
                        toSelfAmountIndex = i;
                    }
                    if ([toMaxAmountD compare:currentAmountD] == NSOrderedAscending) {
                        toMaxAmountD = currentAmountD;
                        toMaxAmountIndex = i;
                    }
                }
                NSString *targetAmount = @"";
                if (isFromSelf) {
                    
                    targetAddress = [toAddressArr[toMaxAmountIndex] objectForKey:@"address"];
                    targetAmount = [toAddressArr[toMaxAmountIndex] objectForKey:@"amount"];
                }else{
                    
                    targetAddress = [fromAddressArr[fromMaxAmountIndex] objectForKey:@"address"];
                    targetAmount = [toAddressArr[toSelfAmountIndex] objectForKey:@"amount"];
                }
                
                //保存到数据库里
                NSArray *arrAll = [Record MR_findByAttribute:@"tx_id" withValue:hash];
                NSMutableArray *arr = [NSMutableArray array];
                for (Record *record in arrAll) {
                    if ([record.name isEqualToString:currencyType] && [record.address isEqualToString:addressStr]) {
                        [arr addObject:record];
                    }
                }
                for (Record *record in arr) {
                    record.time = [PTool ConvertStrToTime:[NSString stringWithFormat:@"%@", timestamp]];
                    if (![addressStr isEqualToString:fromAddress]) {//转账方不是自己
                        
                        record.to_address = targetAddress;
                        record.amount = targetAmount;
                        record.type = @"收款";
                    }else{
                        
                        record.to_address = targetAddress;
                        record.amount = targetAmount;
                        record.type = @"转账";
                    }
                    record.block_height = [NSString stringWithFormat:@"%@", blockNumber];
                    if ([coinTagString isEqualToString:@"OMNI"]) {
                        
                        record.miner_fee = [NSString stringWithFormat:@"%@", [txhashsArr[i] objectForKey:@"fee"]];
                        record.valid = [NSString stringWithFormat:@"%@", [txhashsArr[i] objectForKey:@"valid"]];
                    }else{
                        
                        record.miner_fee = [NSString stringWithFormat:@"%@", [fromValueSumD decimalNumberBySubtracting:toValueSumD]];
                    }
                    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                }
            }
        }
    }
}

//MARK:获取RTX交易详情
- (void)getTRXHashWithTXIDs:(NSString *)txids Param:(NSDictionary *)param success:(void(^)(BOOL success))success failure:(void (^)(NSError * failure))failure{
    
    ApiQueryTrxTransactionRequest *req = [[ApiQueryTrxTransactionRequest alloc] init];
    req.txIds = txids;
    
    dispatch_queue_t queue = dispatch_queue_create("com.uvtoken.getRTXTxhashData", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        
        NSError *error = nil;
        ApiQueryTrxTransactionResponse *res = Uv1GetTrxTransaction(req, &error);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (res.trxTransaction) {
                NSArray *arr = (NSArray *)[PTool dictionaryWithJsonString:res.trxTransaction];
                if (arr.count > 0) {
                    [self saveRtxRecordToLocalDBWithArr:arr Param:param saveSuccess:^(BOOL saveSuccess) {
                        if (success) {
                            success(saveSuccess);
                        }
                    }];
                }
            }
            if (error) {
                if (failure) {
                    failure(error);
                }
            }
            [self releaseMemory];
        });
    });
}

- (void)saveRtxRecordToLocalDBWithArr:(NSArray *)txhashsArr Param:(NSDictionary *)param saveSuccess:(void(^)(BOOL saveSuccess))saveSuccess{
    /*amount = 2000000000;
     blocktime = "1.622601696e+12";
     "contract_address" = "";
     data = "";
     fee = 100000;
     from = 4141f0a2b01c950b4d38c9abfe9b96579dea065168;
     to = 41e9a3903902f1f584e63a78e3171631504be8e521;
     txid = d668774194e5674740b80f8b6469c02be1da4af6821015addeea784ac7be9b5c;*/
    
    NSString *addressStr = param[@"address"];
    NSString *currencyType = param[@"currencyType"];
    NSString *coinTagString = param[@"coinTagString"];
//    NSString *contractAddress = [NSString stringWithFormat:@"%@", param[@"contractAddress"]];
    
    for (int i = 0; i < txhashsArr.count; i++) {

        NSString *timestamp     = [txhashsArr[i] objectForKey:@"blocktime"];
        NSString *hash          = [txhashsArr[i] objectForKey:@"txid"];
        NSString *toAddress     = [NSString stringWithFormat:@"%@", [txhashsArr[i] objectForKey:@"to"]];
        NSString *fromAddress   = [NSString stringWithFormat:@"%@", [txhashsArr[i] objectForKey:@"from"]];
        NSString *amount        = [NSString stringWithFormat:@"%@", [txhashsArr[i] objectForKey:@"amount"]];
        NSString *result        = [NSString stringWithFormat:@"%@", [txhashsArr[i] objectForKey:@"result"]];
        NSString *fee    = [[txhashsArr[i] objectForKey:@"fee"] containsString:@"nil"]?@"0":[txhashsArr[i] objectForKey:@"fee"];
        NSDecimalNumber *feeD   = [[NSDecimalNumber decimalNumberWithString:fee] decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:TRXTOSUN]];

        NSArray *arr = [Record MR_findByAttribute:@"tx_id" withValue:hash];
        for (Record *record in arr) {
            //代币与主币地址相同，所以需要币名称做区分
            if ([record.address isEqualToString:addressStr] && [record.name isEqualToString:currencyType]) {
                record.time = [PTool ConvertStrToTime:[NSString stringWithFormat:@"%@", timestamp]];
                if([coinTagString isEqualToString:@"TRC20"]){
                    record.amount = [NSString stringWithFormat:@"%@", amount];
                }else if ([currencyType isEqualToString:@"TRX"]) {
                    NSDecimalNumber *amountD = [[NSDecimalNumber decimalNumberWithString:amount] decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:TRXTOSUN]];
                    record.amount = [NSString stringWithFormat:@"%@", amountD];
                }
                record.type = [toAddress isEqualToString:addressStr]?@"收款":@"转账";
                if (![addressStr isEqualToString:fromAddress]) {//自己是收款方
                    
                    record.to_address = fromAddress;
                }else{
                    
                    record.to_address = toAddress;
                }
                record.result = [[result uppercaseString] isEqualToString:@"FAILED"]?@"0":@"1";
                record.miner_fee = [NSString stringWithFormat:@"%@", feeD];
                //from to里面都没有自己 那么这条数据是无效数据
                BOOL containSelf = NO;
                [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                if ([addressStr isEqualToString:fromAddress] || [addressStr isEqualToString:toAddress]) {
                    containSelf = YES;
                }
                //from和to里面都不包含自己，那么删除掉此条脏数据
                if (!containSelf) {
                    [record MR_deleteEntity];
                }
            }
        }
    }
    if (saveSuccess) {
        saveSuccess(YES);
    }
}

//MARK:转化TRX base58 地址
+ (NSString *)convertTrxAddress:(NSString *)address{
    ApiToTrxAddressRequest *req = [[ApiToTrxAddressRequest alloc] init];
    req.address = address;
    NSError *error = nil;
    ApiToTrxAddressResponse *res = Uv1ToTrxAddress(req, &error);
    return res.address;
}

//MARK:判断本地钱包是否包含以太坊地址 0:当前钱包包含eth 1:本地钱包包含eth 2:本地钱包不包含eth
+ (NSInteger)containsETH{
    
    NSString *defaultWallet = (NSString *)[PTool getValueFromKey:@"defaultWalletAddress"];
    NSArray *arr = [Coin MR_findByAttribute:@"wallet_id" withValue:defaultWallet];
    NSArray *allCoins = [Coin MR_findAll];
    for (Coin *coin in arr) {
        if ([coin.name isEqualToString:@"ETH"]) {
            return 0;
        }
    }
    for (Coin *coin in allCoins) {
        if ([coin.name isEqualToString:@"ETH"]) {
            return 1;
        }
    }
    return 2;
}
@end
