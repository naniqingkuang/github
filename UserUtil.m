//
//  UserUtil.m
//  MotionMeasurement
//
//  Created by 猪猪 on 15/9/8.
//  Copyright © 2015年 @猪猪. All rights reserved.
//

#import "UserUtil.h"
#import <objc/runtime.h>
@implementation UserUtil

- (NSString *) checkType
{
    NSString * res = @"";
    if(self.userName32.length >32)
    {
        res = @"姓名过长";
        return res;
    }
    if(self.password32.length >32)
    {
        res = @"密码过长";
        return res;
    }
    return res;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.userName32 = @"";
        self.password32 = @"";
        self.userType1 = @"";
        self.realName32 = @"";
        self.registerdate14 = @"";
        self.address256 = @"";
        self.gender1 = @"";
        self.deviceID18 = @"";
        self.height = @"";
        self.weight = @"";
        self.phone32 = @"";
        self.email32 = @"";
        self.birthday8 = @"";
    }
    return self;
}
- (instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.userName32 = [dict objectForKey:@"userName"];
        self.password32 = [dict objectForKey:@"password"];
        self.realName32 = [dict objectForKey:@"realName"];
        self.registerdate14 = [dict objectForKey:@"registerdate"];
        self.address256 = [dict objectForKey:@"address"];
        self.gender1 = [dict objectForKey:@"gender"];
        self.deviceID18 = [dict objectForKey:@"deviceID"];
        self.height = [dict objectForKey:@"height"];
        self.weight = [dict objectForKey:@"weight"];
        self.phone32 = [dict objectForKey:@"phone"];
        self.email32 = [dict objectForKey:@"email"];
        self.birthday8 = [dict objectForKey:@"brithday"];
        self.myId = [dict objectForKey:@"id"];
        self.insertTime = [dict objectForKey:@"isrtime"];
        self.clientid2_32 = [dict objectForKey:@"clientid2"];
        self.actflag1 = [dict objectForKey:@"actflag"];
        self.birthday8 = [dict objectForKey:@"birthday"];
    }
    return self;
}
- (void)checkAndAvoidNull
{
    unsigned int count = 0;
    NSString *str = nil;
    objc_property_t *ivar = class_copyPropertyList([self class], &count);
    for (int i = 0; i < count; i++) {
        str = [NSString stringWithUTF8String:property_getName(ivar[i])];
        if(nil == [self valueForKey:str]){
            [self setValue:@"" forKey:str];
        }
    }
}
@end
