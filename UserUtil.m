//
//  UserUtil.m
//  MotionMeasurement
//
//  Created by 猪猪 on 15/9/8.
//  Copyright © 2015年 @猪猪. All rights reserved.
//

#import "UserUtil.h"

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
@end
