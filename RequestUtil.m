//
//  RequestUtil.m
//  MotionMeasurement
//
//  Created by 猪猪 on 15/9/6.
//  Copyright (c) 2015年 @猪猪. All rights reserved.
//

#import "RequestUtil.h"
#import "Reachability.h"
#import "MBProgressHUD+Util.h"
#import "UserUtil.h"
#import <objc/runtime.h>
#import "EveryDataUtil.h"
static UserUtil *g_currentUser;
static NSString *userName;
@implementation RequestUtil

+ (int)checkNetState
{
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    return status;
}
+ (void)multiFormPost:(NSString *)url withPara:(NSDictionary *)param constructingBodyWithBlock:(void(^) (id<AFMultipartFormData> )) bodyBlock completionBlock:(void (^)(NSDictionary *)) completionBlock {
    if(![self checkNetState]){
        return;
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [[AFHTTPRequestSerializer alloc]init];
    manager.responseSerializer = [[AFHTTPResponseSerializer alloc]init];
    [manager POST:url parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        bodyBlock(formData);
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(responseObject != nil)
        {
            if(completionBlock)
            {
                NSError *err = nil;
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&err];
                if(!err)
                {
                    completionBlock(dict);
                }
            }
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}
+ (void)requestPost:(NSString *)url withPara:(NSDictionary *)para completionBlock:(void (^)(NSDictionary *)) completionBlock
{
    if(![self checkNetState]){
        return;
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [[AFHTTPRequestSerializer alloc]init];
    manager.responseSerializer = [[AFHTTPResponseSerializer alloc]init];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/plain", nil];
    [manager POST:url parameters:para success:^ void(AFHTTPRequestOperation * operation, id reponseObject) {
        if(reponseObject != nil)
        {
            if(completionBlock)
            {
                NSError *err = nil;
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:reponseObject options:kNilOptions error:&err];
                if(!err)
                {
                    completionBlock(dict);
                }
            }

        }
    } failure:^ void(AFHTTPRequestOperation * operation, NSError * err) {
        NSLog(@"%@",operation);
    }];
}
+ (NSString *)getFullPathUrl:(NSString *)url sub:(NSString *)subStr
{
    return [NSString stringWithFormat:@"%@%@",url,subStr];
}
#pragma mark 登录
+ (void)userLogin:(NSString *)name passwd:(NSString *)passwd block:(void (^)(bool)) aBlock
{
    NSString *fullUrl = [self getFullPathUrl:Server_url sub:User_login];
    NSDictionary *dict = @{@"userName":name,@"password":passwd,@"deviceID":@""};
    [self requestPost:fullUrl withPara:dict completionBlock:^(NSDictionary *dict) {
        NSInteger statusCode = [[dict objectForKey:@"statusCode"]integerValue];
        if(aBlock)
        {
            if(200 == statusCode)
            {
                aBlock(true);
            }
            else
            {
                [MBProgressHUD showError: [NSString stringWithFormat:@"登录失败，错误码:%@",[dict objectForKey:@"statusCode"]]];
            }
        }
    }];
}
#pragma mark 注册
+ (void)userRegister:(UserUtil *)item block:(void (^)(bool)) aBlock
{
    NSString *fullUrl = [self getFullPathUrl:Server_url sub:User_register];
    NSDictionary *dict =@{@"userName":item.userName32,@"userType":item.userType1,@"password":item.password32,@"registerdate":item.registerdate14,@"deviceID":item.deviceID18,@"realName":item.realName32,@"gender":item.gender1,@"birthday":item.birthday8,@"height":item.height,@"weight":item.weight,@"address":item.address256,@"phone":item.phone32,@"email":item.email32,@"clientid1":@"",@"clientid2":item.clientid2_32};
        [self requestPost:fullUrl withPara:dict completionBlock:^(NSDictionary *dict) {
        NSInteger statusCode = [[dict objectForKey:@"statusCode"]integerValue];
        if(aBlock)
        {
            if(200 == statusCode)
            {
                aBlock(true);
            }
            else
            {
                [MBProgressHUD showError: [NSString stringWithFormat:@"注册失败，错误码:%@",[dict objectForKey:@"statusCode"]]];
            }
        }
    }];
}
#pragma mark 修改数据
+ (void)userUpdateInfo:(UserUtil *)item block:(void (^)(bool)) aBlock
{
    NSString *fullUrl = [self getFullPathUrl:Server_url sub:USER_INFO_UPDATE];
    NSDictionary *dict =@{@"userName":item.userName32,@"userType":item.userType1,@"password":item.password32,@"deviceID":item.deviceID18,@"realName":item.realName32,@"gender":item.gender1,@"birthday":item.birthday8, @"height":item.height,@"weight":item.weight,@"address":item.address256,@"phone":item.phone32,@"email":item.email32,@"clientid1":@"",@"clientid2":item.clientid2_32};
    [self requestPost:fullUrl withPara:dict completionBlock:^(NSDictionary *dict) {
        NSInteger statusCode = [[dict objectForKey:@"statusCode"]integerValue];
        if(aBlock)
        {
            if(200 == statusCode)
            {
                aBlock(true);
            }
            else
            {
                [MBProgressHUD showError: [NSString stringWithFormat:@"修改信息失败，错误码:%@",[dict objectForKey:@"statusCode"]]];
            }
        }
    }];

}
#pragma mark 获取用户信息
+ (void)getUserinfo:(NSString *)userName block:(void(^)(NSDictionary *)) aBlock
{
    NSString *fullUrl = [self getFullPathUrl:Server_url sub:Get_UserInfo];
    NSDictionary *dict = @{@"userName":userName};
    [self requestPost:fullUrl withPara:dict completionBlock:^(NSDictionary *dict) {
        NSInteger statusCode = [[dict objectForKey:@"statusCode"]integerValue];
        if(200 == statusCode)
        {
            NSDictionary *data = [dict objectForKey:@"data"];
            if(aBlock) {
                aBlock(data);
            }
        }
        else
        {
            [MBProgressHUD showError: [NSString stringWithFormat:@"获取用户失败，错误码:%@",[dict objectForKey:@"statusCode"]]];
        }

    }];
}
#pragma mark 验证用户是否唯一
+ (void)checkUserName:(NSString *)userName withBlock:(void(^)()) aBlock
{
    NSString *fullUrl = [self getFullPathUrl:Server_url sub:USER_NAME_CHECK];
    NSDictionary *param = @{@"userName":userName};
    [self requestPost:fullUrl withPara:param completionBlock:^(NSDictionary *dict) {
        NSInteger statusCode = [[dict objectForKey:@"statusCode"]integerValue];
        if(aBlock)
        {
            if(200 == statusCode)
            {
                aBlock();
            }
            else
            {
                [MBProgressHUD showError: @"用户已存在"];
            }
        }
    }];
}
#pragma mark 更新密码
+ (void)updatePasswd:(NSString *)name passed:(NSString *)passwd newPassed:(NSString *)aNewPasswd block:(void (^)()) aBlock
{
    NSString *fullUrl = [self getFullPathUrl:Server_url sub:USER_RESET_PASSWD];
    NSDictionary *param = @{@"userName":name, @"password":passwd, @"newpwd":aNewPasswd};
    [self requestPost:fullUrl withPara:param completionBlock:^(NSDictionary *dict) {
        NSInteger statusCode = [[dict objectForKey:@"statusCode"]integerValue];
        if(aBlock)
        {
            if(200 == statusCode)
            {
                aBlock();
            }
            else
            {
                NSString *err = [dict objectForKey:@"reason"];
                
            }
        }
        
    }];
}
#pragma mark 上传实时数据
+ (void)uploadCurrentData:(NSString *)name
                 deviceID:(NSString *)deviceID
                 sportsDL:(NSString *)sportsDL
                 sportsCL:(NSString *)sportsCL
                    block:(void (^) ()) aBlock
{
    NSString *fullUrl = [self getFullPathUrl:Server_url sub:USER_UPLOAD_CURRENT_DATA];
    NSDictionary *param = @{@"userName":name,
                            @"deviceID":deviceID,
                            @"sportsDL":sportsDL,
                            @"sportsCL":sportsCL};
    [self requestPost:fullUrl withPara:param completionBlock:^(NSDictionary *dict) {
        NSInteger statusCode = [[dict objectForKey:@"statusCode"]integerValue];
        if(200 == statusCode)
        {
            if(aBlock){
                aBlock();
            }
        }
        else
        {
            NSString *err = [dict objectForKey:@"reason"];
            
        }

    }];

}
#pragma mark 获取配置参数
+ (void)doloadPatam:(NSString *)name
             device:(NSString *)deviceID
              block:(void (^)(NSDictionary *))aBlock{
    NSString *fullUrl = [self getFullPathUrl:Server_url sub:USER_DOWN_PARAM];
    NSDictionary *param = @{@"userName":name,
                            @"deviceID":deviceID};
    [self requestPost:fullUrl withPara:param completionBlock:^(NSDictionary *dict) {
        NSInteger statusCode = [[dict objectForKey:@"statusCode"]integerValue];
        if(200 == statusCode)
        {
            if(aBlock){
                aBlock([dict objectForKey:@"data"]);
            }
        }
        else
        {
            NSString *err = [dict objectForKey:@"reason"];
            
        }
        
    }];
}
#pragma mark 上传硬件数据
+ (void)uploadHardWareParam:(NSString *)name
                     device:(NSString *)deviceID
                        app:(NSString *)appID
                       soft:(NSString *)softID
                   hardWare:(NSString *)hardWareID
                      block:(void (^)()) aBlock{
    NSString *fullUrl = [self getFullPathUrl:Server_url sub:USER_UPLOAD_HARDWARE_PARAM];
    NSDictionary *param = @{@"userName":name,
                            @"deviceID":deviceID,
                            @"appVersion":appID,
                            @"devProgrmVersion":softID,
                            @"devHrdVersion":hardWareID};
    [self requestPost:fullUrl withPara:param completionBlock:^(NSDictionary *dict) {
        NSInteger statusCode = [[dict objectForKey:@"statusCode"]integerValue];
        if(200 == statusCode)
        {
            if(aBlock){
                aBlock();
            }
        }
        else
        {
            NSString *err = [dict objectForKey:@"reason"];
            
        }
    }];
}
+ (void)getFDList:(NSString *)name
           device:(NSString *)deviceID
             page:(int)pageNum
            block:(void (^)(NSDictionary *) )aBlock
{
    NSString *fullUrl = [self getFullPathUrl:Server_url sub:USER_GET_FEEDBACK_LIST];
    NSDictionary *param = @{@"userName":name,
                            @"deviceID":deviceID,
                            @"startTime":@"",
                            @"endTime":@"",
                            @"currentpage":[NSNumber numberWithInt:pageNum]};
    [self requestPost:fullUrl withPara:param completionBlock:^(NSDictionary *dict) {
        NSInteger statusCode = [[dict objectForKey:@"statusCode"]integerValue];
        if(200 == statusCode || 0 == statusCode)
        {
            if(aBlock){
                aBlock(dict);
            }
        }
        else
        {
            NSString *err = [dict objectForKey:@"reason"];
            
        }
    }];
}
+ (void)getFDAnswer:(NSString *)name
             device:(NSString *)deviceID
         feedBackID:(NSString *)feedBackID
              block:(void (^)(NSDictionary *))aBlock {
    NSString *fullUrl = [self getFullPathUrl:Server_url sub:USER_GET_FEEDBACK_ANSWER];
    NSDictionary *param = @{@"userName":name,
                            @"deviceID":deviceID,
                            @"msgID":feedBackID};
    [self requestPost:fullUrl withPara:param completionBlock:^(NSDictionary *dict) {
        NSInteger statusCode = [[dict objectForKey:@"statusCode"]integerValue];
        if(200 == statusCode)
        {
            if(aBlock){
                aBlock([dict objectForKey:@"data"]);
            }
        }
        else
        {
            NSString *err = [dict objectForKey:@"reason"];
            
        }
    }];
}
+ (void)uploadFeedBack:(NSString *)name
                device:(NSString *)deviceID
               content:(NSString *)content
                  type:(NSString *)type
                 image:(NSArray *)imgarr
                voice:(NSURL *)url
                 block:(void(^)()) aBlock {
    NSString *fullUrl = [self getFullPathUrl:Server_url sub:USER_UPLOAD_FDDATA];
    NSMutableArray *mulStr = [[NSMutableArray alloc]initWithCapacity:imgarr.count];
    int i = 1;
    for (i=1; i < imgarr.count+1; i++) {
        [mulStr addObject:[NSString stringWithFormat:@"file%d",i]];
    }
    [mulStr addObject:[NSString stringWithFormat:@"file%d",i++]];
    NSDictionary *param = @{@"userName":name,
                            @"deviceID":deviceID,
                            @"msgtype":type,
                            @"textmsg":content,
                            @"files":mulStr};
    [self multiFormPost:fullUrl withPara:param constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if(imgarr !=nil&&imgarr.count>0){
            for(int i=0;i<imgarr.count;i++){
                NSString *filePathStr = [imgarr objectAtIndex:i];
                NSURL *filePath = [NSURL fileURLWithPath:filePathStr];
                [formData appendPartWithFileURL:filePath name:[NSString stringWithFormat:@"file%d",i+1] error:nil];
            }
            [formData appendPartWithFileURL:url name:[NSString stringWithFormat:@"file%d",imgarr.count+1] error:nil];
        }

    } completionBlock:^(NSDictionary *dict) {
        NSInteger statusCode = [[dict objectForKey:@"statusCode"]integerValue];
        if(200 == statusCode)
        {
            if(aBlock){
                aBlock();
            }
        }
        else
        {
            NSString *err = [dict objectForKey:@"reason"];
            
        }

    }];
//    AFMultipartFormData *fordata =
//    [self multiFormPost:fullUrl withPara:param dataForm:^ completionBlock:^(NSDictionary *dict){
//        NSInteger statusCode = [[dict objectForKey:@"statusCode"]integerValue];
//        if(200 == statusCode)
//        {
//            if(aBlock){
//                aBlock();
//            }
//        }
//        else
//        {
//            NSString *err = [dict objectForKey:@"reason"];
//            
//        }
//    }];
}
+ (void)uploadAlertEvent:(NSString *)name
                  device:(NSString *)deviceID
                  reason:(NSString *)aReason
               startTime:(NSString *)startTime
             MotionStart:(NSString *)motionStartTime
             singleTotal:(double)singleTotal
              daylyTotal:(double )daylyTotal
             maxValueNum:(int)value
                   block:(void(^)()) aBlock {
    NSString *fullUrl = [self getFullPathUrl:Server_url sub:USER_UPLOAD_ALERT_EVENT];
    if(!name) name = @"";
    if(!deviceID) deviceID = @"";
    if(!aReason) aReason = @"";
    if(!startTime) startTime = @"";
    if(!motionStartTime) motionStartTime = @"";
    NSDictionary *param = @{@"userName":name,
                            @"deviceID":deviceID,
                            @"alarmReson":aReason,
                            @"alarmTime":startTime,
                            @"startTime":motionStartTime,
                            @"singleTotal":[NSNumber numberWithDouble:singleTotal],
                            @"dayTotal":[NSNumber numberWithDouble:daylyTotal],
                            @"maxValueNum":[NSNumber numberWithInt:value]};
    [self requestPost:fullUrl withPara:param completionBlock:^(NSDictionary *dict) {
        NSInteger statusCode = [[dict objectForKey:@"statusCode"]integerValue];
        if(200 == statusCode)
        {
            if(aBlock){
                aBlock();
            }
        }
        else
        {
            NSString *err = [dict objectForKey:@"reason"];
            
        }
        
    }];
}
+ (void)uploadDaylyData:(NSString *)name
                 device:(NSString *)deviceID
               dayTotal:(double)dayTotal
         dayMaxValueNum:(NSInteger)dayMaxValueNum
            dayAlarmNum:(NSInteger)dayAlarmNum
            daySportNum:(NSInteger)daySportNum
              everyData:(NSArray *)arr
                  block:(void(^)()) aBlock {
    int count = 0;
    int alertCount = 0;
    NSMutableArray *mulArr = [[NSMutableArray alloc]initWithCapacity:arr.count];
    for (EveryDataUtil *item in arr) {
        [item checkAndAvoidNull];
        NSDictionary *dict = @{ @"sportSerialNum":[NSNumber numberWithInt:item.index],
                                @"startTime":item.startTime,
                                @"endTime":item.endTime,
                                @"singleTotal":[NSNumber numberWithDouble:item.singleTotalNum],
                                @"maxValueNum":[NSNumber numberWithInt:item.maxNum]
                                };
        count += item.maxNum;
        alertCount += item.alertCount;
        [mulArr addObject:dict];
    }
    NSDictionary *dataDict = @{@"everyData":mulArr};
    NSString *fullUrl = [self getFullPathUrl:Server_url sub:USER_UPLOAD_DALYY_DATA];
    NSDictionary *param = @{@"userName":name,
                            @"deviceID":deviceID,
                            @"dayTotal":[NSNumber numberWithDouble:dayTotal],
                            @"dayMaxValueNum":[NSNumber numberWithInt:count],
                            @"dayAlarmNum":[NSNumber numberWithInt:alertCount],
                            @"daySportNum":[NSNumber numberWithInteger:daySportNum],
                            @"everyData":dataDict
                            };
    [self requestPost:fullUrl withPara:param completionBlock:^(NSDictionary *dict) {
        NSInteger statusCode = [[dict objectForKey:@"statusCode"]integerValue];
        if(200 == statusCode)
        {
            if(aBlock){
                aBlock();
            }
        }
        else
        {
            NSString *err = [dict objectForKey:@"reason"];
            
        }
    }];
}

+ (void)updateAPPClientID:(NSString *)name device:(NSString *)deviceID appClientID:(NSString *)appClientID block:(void(^)()) aBlock
{
    NSString *fullUrl = [self getFullPathUrl:Server_url sub:USER_UPDATE_APP_CLIENT_ID];
    NSDictionary *param = @{@"userName":name,
                            @"deviceID":deviceID,
                            @"clientID":appClientID,
                            @"type":@"2"};
    [self requestPost:fullUrl withPara:param completionBlock:^(NSDictionary *dict) {
        NSInteger statusCode = [[dict objectForKey:@"statusCode"]integerValue];
        if(200 == statusCode)
        {
            if(aBlock){
                aBlock();
            }
        }
        else
        {
            NSString *err = [dict objectForKey:@"reason"];
            
        }
    }];
}
+ (void)updatePercent:(NSString *)name device:(NSString *)deviceID percent:(double) progress block:(void (^)(void)) aBlock {
    NSString *fullUrl = [self getFullPathUrl:Server_url sub:USER_UPLOAD_PROGRESS];

    NSDictionary *param = @{@"userName":name,
                            @"deviceID":deviceID,
                            @"progress":[NSString stringWithFormat:@"%lf",progress*100]
                            };
    [self requestPost:fullUrl withPara:param completionBlock:^(NSDictionary *dict) {
        NSInteger statusCode = [[dict objectForKey:@"statusCode"]integerValue];
        if(200 == statusCode)
        {
            if(aBlock){
                aBlock();
            }
        }
        else
        {
            NSString *err = [dict objectForKey:@"reason"];
            
        }
    }];

}


+ (void)keepHeartBeat:(NSString *)name device:(NSString *)deviceID block:(void(^)(NSString *)) aBlock {
    NSString *fullUrl = [self getFullPathUrl:Server_url sub:USER_KEEP_HEART_BEAT];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"YYYYMMDDhhmmss"];
    NSString *currentTime = [dateFormatter stringFromDate:[NSDate date]];
    NSDictionary *param = @{@"userName":name,
                            @"deviceID":deviceID,
                            @"requestTime":currentTime
                            };
    [self requestPost:fullUrl withPara:param completionBlock:^(NSDictionary *dict) {
        NSArray *dataArr = [dict objectForKey:@"cmd"];
        if(dataArr)
        {
            if(aBlock){
                for (int i=0; i < dataArr.count; i++) {
                    aBlock([dataArr[i] objectForKey:@"c"]);
                }
            }
        }
        else
        {
            NSString *err = [dict objectForKey:@"reason"];
            
        }
    }];
}
+ (void)setCurrentUser:(UserUtil *)item
{
    g_currentUser = item;
}
+ (UserUtil *)getCurrentUser
{
    if(!g_currentUser)
    {
        g_currentUser = [[UserUtil alloc]init];
    }
    [g_currentUser checkAndAvoidNull];
   return g_currentUser;
}
+ (NSString *)getUserName {
    userName = [[NSUserDefaults standardUserDefaults]objectForKey:@"userName"];
    if(!userName)
    {
        return @"";
    }
    return userName;
}
+ (void)setUserName:(NSString *)name {
    userName = name;
    [[NSUserDefaults standardUserDefaults]setObject:userName forKey:@"userName"];
}

@end
