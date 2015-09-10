//
//  UserUtil.h
//  MotionMeasurement
//
//  Created by 猪猪 on 15/9/8.
//  Copyright © 2015年 @猪猪. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserUtil : NSObject
@property (nonatomic, copy)NSString *userName32;
@property (nonatomic, copy)NSString *userType1;
@property (nonatomic, copy)NSString *password32;
@property (nonatomic, copy)NSString *registerdate14;
@property (nonatomic, copy)NSString *deviceID18;
@property (nonatomic, copy)NSString *realName32;
@property (nonatomic, copy)NSString *gender1;  //1 男  2 女  3 未知
@property (nonatomic, copy)NSString *birthday8;
@property (nonatomic, copy)NSString *height;
@property (nonatomic, copy)NSString *weight;
@property (nonatomic, copy)NSString *address256;
@property (nonatomic, copy)NSString *phone32;
@property (nonatomic, copy)NSString *email32;
@property (nonatomic, copy)NSString *clientid1_32;
@property (nonatomic, copy)NSString *clientid2_32;
- (NSString *) checkType;
- (instancetype)initWithDict:(NSDictionary *)dict;
@end
