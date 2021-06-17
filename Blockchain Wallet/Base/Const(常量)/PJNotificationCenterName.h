//
//  PJNotificationCenterName.h
//  Taft
//
//  Created by panerly on 2020/11/16.
//  Copyright © 2020 panerly. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PJNotificationCenterName : NSObject

/** 登录成功选择控制器通知 */
UIKIT_EXTERN NSString *const LOGINSELECTCENTERINDEX;
/** 退出登录成功选择控制器通知 */
UIKIT_EXTERN NSString *const LOGINOFFSELECTCENTERINDEX;
/** 需要调起登录控制器通知 */
UIKIT_EXTERN NSString *const PRENSENTLOGIN;
/** 需要调起预售控制器通知 */
UIKIT_EXTERN NSString *const PUSHTOPERSALE;
/** 切换语言通知 */
UIKIT_EXTERN NSString *const CHANGELANGUAGE;
/** 切换货币通知 */
UIKIT_EXTERN NSString *const CHANGECURRENCY;
/** 切换钱包通知 */
UIKIT_EXTERN NSString *const CHANGEWALLET;

/** taf登录通知 */
UIKIT_EXTERN NSString *const PRESENTTAFLOGIN;
/** taf登录成功通知 */
UIKIT_EXTERN NSString *const TAFSUCCESSLOGIN;
/** taf退出登录成功通知 */
UIKIT_EXTERN NSString *const TAFLOGOFF;

/** ETH转WEI单位 */
UIKIT_EXTERN NSString *const ETHTOWEI;
/** WEI转GWEI单位 */
UIKIT_EXTERN NSString *const GWEITOWEI;

/** TRX转SUN单位 */
UIKIT_EXTERN NSString *const TRXTOSUN;

@end

NS_ASSUME_NONNULL_END
