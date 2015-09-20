//
//  UserUtil.h
//  MotionMeasurement
//
//  Created by 猪猪 on 15/9/8.
//  Copyright © 2015年 @猪猪. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface userParam : NSObject
@property (nonatomic, copy) NSString *actflag;
@property (nonatomic, copy) NSString *dayValueMaxParam;
@property (nonatomic, copy) NSString *dayValueMinParam;
@property (nonatomic, copy) NSString *myID;
@property (nonatomic, copy) NSString *intervalTimeParam;
@property (nonatomic, copy) NSString *intervalTimeTypeParam;
@property (nonatomic, copy) NSString *isrtime;
@property (nonatomic, copy) NSString *maxValueNumParam;
@property (nonatomic, copy) NSString *maxValueParam;
@property (nonatomic, copy) NSString *singleValueMaxParam;
@property (nonatomic, copy) NSString *singleValueMinParam;
@property (nonatomic, copy) NSString *sportsBeginTimeParam;
@property (nonatomic, copy) NSString *sportsEndTimeParam;
@property (nonatomic, copy) NSString *userType;
- (NSString *) checkType;
- (instancetype)initWithDict:(NSDictionary *)dict;
- (void)checkAndAvoidNull;
@end

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
@property (nonatomic, copy)NSString *currentDate;
@property (nonatomic, copy)NSString *insertTime;
@property (nonatomic, copy)NSString *actflag1;
@property (nonatomic, copy)NSString *myId;

- (NSString *) checkType;
- (instancetype)initWithDict:(NSDictionary *)dict;
- (void)checkAndAvoidNull;
@end
