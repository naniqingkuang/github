//
//  EveryDataUtil.m
//  MotionMeasurement
//
//  Created by 猪猪 on 15/9/20.
//  Copyright © 2015年 @猪猪. All rights reserved.
//

#import "EveryDataUtil.h"
#import <objc/runtime.h>
@implementation EveryDataUtil
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
