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
static UserUtil *g_currentUser;
@implementation RequestUtil

- (int)checkNetState
{
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    return status;
}

+ (void)requestPost:(NSString *)url withPara:(NSDictionary *)para completionBlock:(void (^)(NSDictionary *)) completionBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [[AFHTTPRequestSerializer alloc]init];
    manager.responseSerializer = [[AFHTTPResponseSerializer alloc]init];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/plain", nil];
//    NSDictionary *dict = @{@"userName":@"qq"};
//    
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
+ (void)userRegister:(UserUtil *)item block:(void (^)(bool)) aBlock
{
    NSString *fullUrl = [self getFullPathUrl:Server_url sub:User_register];
    NSDictionary *dict =@{@"userName":item.userName32,@"userType":item.userType1,@"password":item.password32,@"registerdate":item.registerdate14,@"deviceID":item.deviceID18,@"realName":item.realName32,@"gender":item.gender1,@"birthday":item.birthday8,@"weight":item.weight,@"address":item.address256,@"phone":item.phone32,@"email":item.email32,@"clientid1":@"",@"clientid2":item.clientid2_32};
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
+ (void)userUpdateInfo:(UserUtil *)item block:(void (^)(bool)) aBlock
{
    NSString *fullUrl = [self getFullPathUrl:Server_url sub:USER_INFO_UPDATE];
    NSDictionary *dict =@{@"userName":item.userName32,@"userType":item.userType1,@"password":item.password32,@"deviceID":item.deviceID18,@"realName":item.realName32,@"gender":item.gender1,@"birthday":item.birthday8,@"weight":item.weight,@"address":item.address256,@"phone":item.phone32,@"email":item.email32,@"clientid1":@"",@"clientid2":item.clientid2_32};
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
+ (void)getUserinfo:(NSString *)userName block:(void(^)(NSDictionary *)) aBlock
{
    NSString *fullUrl = [self getFullPathUrl:Server_url sub:Get_UserInfo];
    NSDictionary *dict = @{@"userName":userName};
    [self requestPost:fullUrl withPara:dict completionBlock:^(NSDictionary *dict) {
        NSInteger statusCode = [[dict objectForKey:@"statusCode"]integerValue];
        if(aBlock)
        {
            if(200 == statusCode)
            {
                NSDictionary *data = [dict objectForKey:@"data"];
                aBlock(data);
            }
            else
            {
                [MBProgressHUD showError: [NSString stringWithFormat:@"获取用户失败，错误码:%@",[dict objectForKey:@"statusCode"]]];
            }
        }
        
    }];
}
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
@end
