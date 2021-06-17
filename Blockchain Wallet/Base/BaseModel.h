//
//  BaseModel.h
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/12.
//

#import <JSONModel/JSONModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseModel : JSONModel

//首页
@property (nonatomic) NSString<Optional> *hidden;//是否隐藏金额
@property (nonatomic) NSString<Optional> *imgName;//币种图片
@property (nonatomic) NSString<Optional> *type;//币种：ETH BTC TAF...
@property (nonatomic) NSString<Optional> *balance;//余额
@property (nonatomic) NSString<Optional> *transBalance;//转换成指定币种后的余额
@property (nonatomic) NSString<Optional> *coinTag;//OMNI ERC20...
@property (nonatomic) NSString<Optional> *unsupportCoin;//不支持转化金额的币种

//地址簿
@property (nonatomic) NSString<Optional> *addrName;
@property (nonatomic) NSString<Optional> *address;
@property (nonatomic) NSString<Optional> *descript;
@property (nonatomic) NSString<Optional> *selected;

//转账记录
//@property (nonatomic) NSString<Optional> *type//收款、转账
@property (nonatomic) NSString<Optional> *contactAddress;//合约地址

//添加币种
@property (nonatomic) NSString<Optional> *keyID;
//@property (nonatomic) NSString<Optional> *address;//代币的合约地址
@property (nonatomic) NSString<Optional> *image;//代币的http图片地址
@property (nonatomic) NSString<Optional> *decimals;//代币精度

//获取汇率
@property (nonatomic) NSString<Optional> *price_usd;//当前币对换usd汇率 例如 1btc = 31223 usd
@property (nonatomic) NSString<Optional> *price_cny;//当前币对换cny汇率 例如 1btc = 202471 usd
@property (nonatomic) NSString<Optional> *price_eur;
@property (nonatomic) NSString<Optional> *symbol;//币种

//行情
@property (nonatomic) NSString<Optional> *name;
//@property (nonatomic) NSString<Optional> *symbol;
@property (nonatomic) NSString<Optional> *rank;
@property (nonatomic) NSString<Optional> *logo;
@property (nonatomic) NSString<Optional> *logo_png;
//@property (nonatomic) NSString<Optional> *price_usd;
//@property (nonatomic) NSString<Optional> *price_cny;
//@property (nonatomic) NSString<Optional> *price_eur;
@property (nonatomic) NSString<Optional> *price_btc;
@property (nonatomic) NSString<Optional> *volume_24h_usd;
@property (nonatomic) NSString<Optional> *market_cap_usd;
@property (nonatomic) NSString<Optional> *market_cap_cny;
@property (nonatomic) NSString<Optional> *available_supply;
@property (nonatomic) NSString<Optional> *total_supply;
@property (nonatomic) NSString<Optional> *max_supply;
@property (nonatomic) NSString<Optional> *percent_change_1h;
@property (nonatomic) NSString<Optional> *percent_change_24h;
@property (nonatomic) NSString<Optional> *percent_change_7d;
@property (nonatomic) NSString<Optional> *last_updated;
@property (nonatomic) NSString<Optional> *isWatchList;


//法币汇率
@property (nonatomic) NSString<Optional> *USD;
//@property (nonatomic) NSString<Optional> *AED;
//@property (nonatomic) NSString<Optional> *ARS;
//@property (nonatomic) NSString<Optional> *AUD;
//@property (nonatomic) NSString<Optional> *BGN;
//@property (nonatomic) NSString<Optional> *BRL;
//@property (nonatomic) NSString<Optional> *BSD;
//@property (nonatomic) NSString<Optional> *CAD;
//@property (nonatomic) NSString<Optional> *CHF;
//@property (nonatomic) NSString<Optional> *CLP;
@property (nonatomic) NSString<Optional> *CNY;
//@property (nonatomic) NSString<Optional> *COP;
//@property (nonatomic) NSString<Optional> *CZK;
//@property (nonatomic) NSString<Optional> *DKK;
//@property (nonatomic) NSString<Optional> *DOP;
//@property (nonatomic) NSString<Optional> *EGP;
@property (nonatomic) NSString<Optional> *EUR;
//@property (nonatomic) NSString<Optional> *FJD;
//@property (nonatomic) NSString<Optional> *GBP;
//@property (nonatomic) NSString<Optional> *GTQ;
//@property (nonatomic) NSString<Optional> *HKD;
//@property (nonatomic) NSString<Optional> *HRK;
//@property (nonatomic) NSString<Optional> *HUF;
//@property (nonatomic) NSString<Optional> *IDR;
//@property (nonatomic) NSString<Optional> *ILS;
//@property (nonatomic) NSString<Optional> *ISK;


//交易-选择货币
//@property (nonatomic) NSString<Optional> *address;
//@property (nonatomic) NSString<Optional> *decimals;
@property (nonatomic) NSString<Optional> *logoURI;
//@property (nonatomic) NSString<Optional> *name;
//@property (nonatomic) NSString<Optional> *symbol;

//交易-获取余额
@property (nonatomic) NSDictionary<Optional> *wallets;

@end

NS_ASSUME_NONNULL_END
