//
//  PWallet.h
//  Blockchain Wallet
//
//  Created by Panerly on 2021/4/19.
//

#import <Foundation/Foundation.h>
#import "AddCoinModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PWallet : NSObject

+ (instancetype)shareInstance;
//钱包地址
- (NSString *)walletPath;
//创建钱包
- (void)createWalletWithCoinType:(NSString *)coinTypes Password:(NSString *)password WalletID:(void(^)(NSString *walletID))walletID AddCoinModel:(void(^)(AddCoinModel *coinModel))addCoinModel failure:(void (^)(NSError * failure))failure;
//创建币
- (void)createCoin:(NSString *)coinTpye Password:(NSString *)password WalletID:(NSString *)walletID  CoinModel:(void(^)(AddCoinModel *coinModel))coinModel  createCoinfailure:(void (^)(NSError * error))failure;
//验证钱包密码是否正确
-(void)verifyWalletPwdWithWalletID:(NSString *)walletID Pwd:(NSString *)pwd valid:(void(^)(BOOL valid))valid;

//导入私钥
- (void)importPkWithCoinType:(NSString *)coinType Password:(NSString *)password PrivateKey:(NSString *)privateKey response:(void(^)(AddCoinModel *response))response failure:(void (^)(NSError * failure))failure;

//导入助记词钱包
- (void)importMnemonicWithCoinTypes:(NSString *)coinTypes Password:(NSString *)password Mnemonics:(NSString *)mnemonics WalletID:(void(^)(NSString *walletID))walletID AddCoinModel:(void(^)(AddCoinModel *coinModel))addCoinModel failure:(void (^)(NSError * failure))failure;

//备份多链钱包私钥获取PK
- (void)getPKDataFromMasterWithParam:(NSDictionary *)param privateKey:(void(^)(NSString *privateKey))privateKey failure:(void (^)(NSError * failure))failure;

//备份单链钱包私钥--获取单链私钥
- (void)getPKDataFromSingleChainWithCoinType:(NSString *)coinType WalletID:(NSString *)walletID Password:(NSString *)password privateKey:(void(^)(NSString *privateKey))privateKey failure:(void (^)(NSError * failure))failure;

//备份助记词
- (void)getMnemonicWithWalletID:(NSString *)walletID Password:(NSString *)password mnemonics:(void(^)(NSString *mnemonics))mnemonics failure:(void (^)(NSError * failure))failure;

//修改钱包密码
- (void)changeWalletPwdWithKeyIDs:(NSString *)keyIDs PrevPassword:(NSString *)prevPassword NewPassword:(NSString *)newPassword WalletId:(NSString *)walletId success:(void(^)(bool success))success;

//查询BTC区块高度内的交易哈希
- (void)getTxHashsFromBlockHeight:(NSString *)blockHeight Address:(NSString *)address CoinType:(NSString *)coinType TokenType:(NSString *)tokenType txIDs:(void(^)(NSString *txIDs))txIDs failure:(void (^)(NSError * failure))failure;

//根据交易ID查询交易
- (void)getFeeRateWithAddress:(NSString *)address size:(void(^)(NSString *size))size failure:(void (^)(NSError * failure))failure;

//获取BTC低中高费率
- (void)getBTCFeeRateWithCoinType:(NSString *)coinType rate:(void(^)(AddCoinModel *rate))rate failure:(void (^)(NSError * failure))failure;

//获取ETH费率
- (void)getETHFee:(void(^)(NSString *feeRate))feeRate failure:(void (^)(NSError * failure))failure;

//删除多链钱包钱包
- (void)deleteWalletWithWalletID:(NSString *)walletID Password:(NSString *)password success:(void(^)(bool success))success failure:(void (^)(NSError * failure))failure;

//删除单链钱包
- (void)deleteSingleChainWalletWithKeyIDs:(NSString *)keyIDs Password:(NSString *)password success:(void(^)(bool success))success failure:(void (^)(NSError * failure))failure;

//获取余额币
- (void)getWalletBalanceWithAddress:(NSString *)address TokenAddress:(NSString *)tokenAddress CoinType:(NSString *)coinType TokenType:(NSString *)tokenType response:(void(^)(AddCoinModel *response))response failure:(void (^)(NSError * failure))failure;

//验证地址是否合法
- (void)validAddress:(NSString *)address CoinType:(NSString *)coinType valid:(void(^)(bool valid))valid failure:(void (^)(NSError * failure))failure;

//配置钱包
- (void)configWithNet:(NSString *)net response:(void(^)(NSString *response))response;

//MARK:兼容以前旧数据
- (void)compatibleOldData;

//ETH兑换其它代币
- (void)ethTransactionWithCoin:(Coin *)coin Password:(NSString *)password FromAddress:(NSString *)fromAddress ToAddress:(NSString *)toAddress Amount:(NSString *)amount GasLimit:(int64_t)gasLimit Data:(NSString *)data Success:(void(^)(NSString *txid, NSString *nonce))success failure:(void (^)(NSError * failure))failure;
//转换成标准EIP55地址
- (void)getEthStandardAddress:(NSString *)address Success:(void(^)(NSString *standardAddress))success failure:(void (^)(NSError * failure))failure;
//验证当前交易是否未完成
- (void)validTransactionWithTx_id:(NSString *)tx_id valid:(void(^)(bool valid))valid failure:(void (^)(NSError * failure))failure;
//保存ETH交易记录
- (void)saveEthRecordToLocalDBWithArr:(NSArray *)txhashsArr CoinTagString:(NSString *)coinTagString ContactAddressStr:(NSString *)contactAddressStr AddressStr:(NSString *)addressStr CurrencyType:(NSString *)currencyType Decimals:(NSString *)decimals;
//保存BTC以及代币交易记录
- (void)saveBtcRecordWithTxhashsArr:(NSArray *)txhashsArr AddressStr:(NSString *)addressStr CurrencyType:(NSString *)currencyType CoinTagString:(NSString *)coinTagString;
//获取RTX交易hash
- (void)getTRXHashWithTXIDs:(NSString *)txids Param:(NSDictionary *)param success:(void(^)(BOOL success))success failure:(void (^)(NSError * failure))failure;
//转化TRX base58 地址
+ (NSString *)convertTrxAddress:(NSString *)address;
//判断本地钱包是否包含以太坊地址 0:当前钱包包含eth 1:本地钱包包含eth 2:本地钱包不包含eth
+ (NSInteger)containsETH;
@end

NS_ASSUME_NONNULL_END
