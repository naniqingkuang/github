//
//  UserUtil.m
//  MotionMeasurement
//
//  Created by 猪猪 on 15/9/8.
//  Copyright © 2015年 @猪猪. All rights reserved.
//

#import "UserUtil.h"
#import <objc/runtime.h>

@implementation userParam
- (NSString *)checkType{
    NSString *res = @"";
    return res;
}
- (instancetype)initWithDict:(NSDictionary *)dict{
        self = [super init];
        if (self) {
            self.myID = [dict objectForKey:@"id"];
            self.actflag = [dict objectForKey:@"actflag"];
            self.acttime = [dict objectForKey:@"acttime"];
            self.dayValueMaxParam = [dict objectForKey:@"dayValueMaxParam"];
            self.dayValueMinParam = [dict objectForKey:@"dayValueMinParam"];
            self.intervalTimeParam = [[dict objectForKey:@"intervalTimeParam"]intValue];
            self.intervalTimeTypeParam = [dict objectForKey:@"intervalTimeTypeParam"];
            self.isrtime = [dict objectForKey:@"isrtime"];
            self.maxValueNumParam = [[dict objectForKey:@"maxValueNumParam"]intValue];
            self.maxValueParam = [dict objectForKey:@"maxValueParam"];
            self.sportsBeginTimeParam = [dict objectForKey:@"sportsBeginTimeParam"];
            self.singleValueMaxParam = [dict objectForKey:@"singleValueMaxParam"];
            self.singleValueMinParam = [dict objectForKey:@"singleValueMinParam"];
            self.sportsEndTimeParam = [dict objectForKey:@"sportsEndTimeParam"];
            self.userType = [dict objectForKey:@"userType"];
            self.weightValueParam = [dict objectForKey:@"weightValueParam"];
            self.status = [dict objectForKey:@"status"];
            self.userName = [dict objectForKey:@"userName"];
        }
        return self;
    return self;
}
- (void)checkAndAvoidNull{
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
        self.height = [NSString stringWithFormat:@"%ld",[[dict objectForKey:@"height"]integerValue]];
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
