//
//  PJNotificationCenterName.m
//  Taft
//
//  Created by panerly on 2020/11/16.
//  Copyright © 2020 panerly. All rights reserved.
//

#import "PJNotificationCenterName.h"

@implementation PJNotificationCenterName

/** 登录成功选择控制器通知 */
NSString *const LOGINSELECTCENTERINDEX = @"LOGINSELECTCENTERINDEX";
/** 退出登录成功选择控制器通知 */
NSString *const LOGINOFFSELECTCENTERINDEX = @"LOGINOFFSELECTCENTERINDEX";

/** 需要调起登录控制器通知 */
NSString *const PRENSENTLOGIN = @"PRENSENTLOGIN";
/** 需要调起预售控制器通知 */
NSString *const PUSHTOPERSALE = @"PUSHTOPERSALE";
/** 切换语言通知 */
NSString *const CHANGELANGUAGE = @"CHANGELANGUAGE";
/** 切换货币通知 */
NSString *const CHANGECURRENCY = @"CHANGECURRENCY";
/** 切换钱包通知 */
NSString *const CHANGEWALLET = @"CHANGEWALLET";


/** taf登录通知 */
NSString *const PRESENTTAFLOGIN = @"PRESENTTAFLOGIN";
/** taf登录成功通知 */
NSString *const TAFSUCCESSLOGIN = @"TAFSUCCESSLOGIN";
/** taf退出登录成功通知 */
NSString *const TAFLOGOFF = @"TAFLOGOFF";


/** ETH转WEI单位 */
NSString *const ETHTOWEI = @"1000000000000000000";
/** GWEI转WEI单位 */
NSString *const GWEITOWEI = @"1000000000";

/** TRX转SUN单位 */
NSString *const TRXTOSUN = @"1000000";

@end
