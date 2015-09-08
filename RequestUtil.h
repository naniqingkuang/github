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

#define Server_url          @"http://msznyl.com:8088/MSZNYL/app/"
#define User_login          @"userLogin"
#define User_register       @"receiveAppUserInfo"
@interface RequestUtil : NSObject

+ (void)userLogin:(NSString *)name passwd:(NSString *)passwd block:(void (^)(bool)) aBlock;
+ (void)userRegister:(UserUtil *)item block:(void (^)(bool))aBlock;
@end
