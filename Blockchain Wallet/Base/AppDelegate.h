//
//  AppDelegate.h
//  Blockchain Wallet
//
//  Created by Panerly on 2020/12/24.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

typedef void (^Animation)(void);

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

