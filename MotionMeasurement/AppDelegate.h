//
//  AppDelegate.h
//  MotionMeasurement
//
//  Created by 猪猪 on 15/8/20.
//  Copyright (c) 2015年 @猪猪. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "GeTuiSdk.h"
#define KGtAppId  @"y0mvudjG98AKTGAnpFKLKA"
#define kGtAppKey @"JwxHKrNpRd7P9TzojKIxS9"
#define KGtAppSecret @"JlKrqxIRGt630QBXS5dDM6"
@interface AppDelegate : UIResponder <UIApplicationDelegate, GeTuiSdkDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

