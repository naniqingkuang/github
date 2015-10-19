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
#define Server_url                              @"http://www.msyzn.net:8088/MSZNYL/app/"
#define User_login                              @"userLogin"
#define User_register                           @"receiveAppUserInfo"
#define Get_UserInfo                            @"getAppUserInfo"
#define USER_NAME_CHECK                         @"isUniqueAccount"
#define USER_INFO_UPDATE                        @"updateAppUserInfo"
#define USER_RESET_PASSWD                       @"resetPwd"
#define USER_UPLOAD_CURRENT_DATA                @"receiveLiveSportData"
#define USER_DOWN_PARAM                         @"getSportsCfgParam"
#define USER_UPLOAD_HARDWARE_PARAM              @"receiveDeviceInfo"
#define USER_GET_FEEDBACK_LIST                  @"getHistoryFDList"
#define USER_GET_FEEDBACK_ANSWER                @"getFeedBackInfo"
#define USER_UPLOAD_FDDATA                      @"receiveFeedBackInfo"
#define USER_UPLOAD_ALERT_EVENT                 @"receiveAlarmEvents"
#define USER_UPLOAD_DALYY_DATA                  @"receiveDaySportData"
#define USER_UPDATE_APP_CLIENT_ID               @"updateAppClientID"
#define USER_KEEP_HEART_BEAT                    @"receiveHeartbeatInfo"
#define USER_UPLOAD_PROGRESS                    @"receiveProgress"
#define USER_UPLOAD_OTHER_DATA                  @"receiveOtherData"

@interface RequestUtil : NSObject

+ (void)setCurrentUser:(UserUtil *)item;
+ (UserUtil *)getCurrentUser;
+ (void)userLogin:(NSString *)name
           passwd:(NSString *)passwd
            block:(void (^)(bool)) aBlock;

+ (void)userRegister:(UserUtil *)item
               block:(void (^)(bool))aBlock;

+ (void)getUserinfo:(NSString *)userName
              block:(void(^)(NSDictionary* )) aBlock;

+ (void)checkUserName:(NSString *)userName
            withBlock:(void(^)()) aBlock;

+ (void)userUpdateInfo:(UserUtil *)item
                 block:(void (^)(bool)) aBlock;

+ (void)updatePasswd:(NSString *)name
              passed:(NSString *)passwd
           newPassed:(NSString *)aNewPasswd
               block:(void (^)()) aBlock;

+ (void)uploadCurrentData:(NSString *)name
                 deviceID:(NSString *)deviceID
                 sportsDL:(NSString *)sportsDL
                 sportsCL:(NSString *)sportsCL
                    block:(void (^) ()) aBlock;

+ (void)doloadPatam:(NSString *)name
             device:(NSString *)deviceID
              block:(void (^)(NSDictionary *))aBlock;

+ (void)uploadHardWareParam:(NSString *)name
                     device:(NSString *)deviceID
                        app:(NSString *)appID
                       soft:(NSString *)softID
                   hardWare:(NSString *)hardWareID
                      block:(void (^)()) aBlock;

+ (void)getFDList:(NSString *)name
           device:(NSString *)deviceID
             page:(int)pageNum
            block:(void (^)(NSDictionary *) )aBlock;

+ (void)getFDAnswer:(NSString *)name
             device:(NSString *)deviceID
         feedBackID:(NSString *)feedBackID
              block:(void (^)(NSDictionary *))aBlock;

+ (void)uploadFeedBack:(NSString *)name
                device:(NSString *)deviceID
               content:(NSString *)content
                  type:(NSString *)type
                 image:(NSArray *)imgarr
                 voice:(NSURL *)url
                 block:(void(^)()) aBlock;

+ (void)uploadDaylyData:(NSString *)name
                 device:(NSString *)deviceID
               dayTotal:(double)dayTotal
         dayMaxValueNum:(NSInteger)dayMaxValueNum
            dayAlarmNum:(NSInteger)dayAlarmNum
            daySportNum:(NSInteger)daySportNum
              everyData:(NSArray *)arr
                  block:(void(^)()) aBlock;

+ (void)uploadAlertEvent:(NSString *)name
                  device:(NSString *)deviceID
                  reason:(NSString *)aReason
               startTime:(NSString *)startTime
             MotionStart:(NSString *)motionStartTime
             singleTotal:(double)singleTotal
              daylyTotal:(double )daylyTotal
             maxValueNum:(int)value
                   block:(void(^)()) aBlock;

+ (void)updateAPPClientID:(NSString *)name
             device:(NSString *)deviceID
        appClientID:(NSString *)appClientID
              block:(void(^)()) aBlock;

+ (void)keepHeartBeat:(NSString *)name
               device:(NSString *)deviceID
                block:(void(^)(NSString *)) aBlock;
+ (void)updatePercent:(NSString *)name
               device:(NSString *)deviceID
              percent:(double) progress
                block:(void (^)(void)) aBlock;
+ (NSString *)getUserName;
+ (void)setUserName:(NSString *)name;
@end
