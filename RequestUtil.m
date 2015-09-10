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

static UserUtil *g_currentUser;
@implementation RequestUtil

- (int)checkNetState
{
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    return status;
}

+ (void)requestPost:(NSString *)url withPara:(NSString *)para completionBlock:(void (^)(NSDictionary *)) completionBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
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
    }];
}
+ (NSString *)getFullPathUrl:(NSString *)url sub:(NSString *)subStr
{
    return [NSString stringWithFormat:@"%@%@",url,subStr];
}
+ (void)userLogin:(NSString *)name passwd:(NSString *)passwd block:(void (^)(bool)) aBlock
{
    NSString *fullUrl = [self getFullPathUrl:Server_url sub:User_login];
    NSString *param = [NSString stringWithFormat:@"{\"userName\":\"%@\",\"password\":\"%@\",\"deviceID\":\"%@\"}",name,passwd,@""];
    [self requestPost:fullUrl withPara:param completionBlock:^(NSDictionary *dict) {
        NSString *resStr = [dict objectForKey:@"reason"];
        if(aBlock)
        {
            if([resStr isEqual:@"ok"])
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
+ (void)userRegister:(UserUtil *)item block:(void (^)(bool)) aBlock
{
    NSString *fullUrl = [self getFullPathUrl:Server_url sub:User_register];
    NSString *param = [NSString stringWithFormat:@"{\"userName\":%@,\"userType\":%@,\"password\":%@,\"registerdate\":%@,\"deviceID\":%@,\"realName\":%@,\"gender\":%@,\"birthday\":%@,\"height\":%@,\"weight\":%@,\"address\":%@,\"phone\":%@,\"email\":%@,\"clientid1\":%@,\"clientid2\":%@}",item.userName32,item.userType1,item.password32,item.registerdate14,item.deviceID18,item.realName32,item.gender1,item.birthday8,item.height,item.weight,item.address256,item.phone32,item.email32,@"",item.clientid2_32];
    [self requestPost:fullUrl withPara:param completionBlock:^(NSDictionary *dict) {
        NSString *resStr = [dict objectForKey:@"reason"];
        if(aBlock)
        {
            if([resStr isEqual:@"ok"])
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
+ (void)getUserinfo:(NSString *)userName block:(void(^)(NSDictionary* )) aBlock
{
    NSString *fullUrl = [self getFullPathUrl:Server_url sub:Get_UserInfo];
    NSString *param = [NSString stringWithFormat:@"\"userName\":%@",userName];
    [self requestPost:fullUrl withPara:param completionBlock:^(NSDictionary *dict) {
        NSDictionary *data = [dict objectForKey:@"data"];
        aBlock(data);
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
    return g_currentUser;
}
@end
