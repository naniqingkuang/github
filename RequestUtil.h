//
//  RequestUtil.h
//  MotionMeasurement
//
//  Created by 猪猪 on 15/9/6.
//  Copyright (c) 2015年 @猪猪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "UserUtil.h"

//#define Server_url          @"http://msznyl.com:8088/MSZNYL/app/"
#define Server_url          @"http://www.msyzn.net:8088/MSZNYL/app/"
#define User_login          @"userLogin"
#define User_register       @"receiveAppUserInfo"
#define Get_UserInfo        @"getAppUserInfo"
#define USER_NAME_CHECK     @"isUniqueAccount"
#define USER_INFO_UPDATE    @"updateAppUserInfo"
@interface RequestUtil : NSObject

+ (void)setCurrentUser:(UserUtil *)item;
+ (UserUtil *)getCurrentUser;
+ (void)userLogin:(NSString *)name passwd:(NSString *)passwd block:(void (^)(bool)) aBlock;
+ (void)userRegister:(UserUtil *)item block:(void (^)(bool))aBlock;
+ (void)getUserinfo:(NSString *)userName block:(void(^)(NSDictionary* )) aBlock;
+ (void)checkUserName:(NSString *)userName withBlock:(void(^)()) aBlock;
+ (void)userUpdateInfo:(UserUtil *)item block:(void (^)(bool)) aBlock;
@end
