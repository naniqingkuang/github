//
//  EveryDataUtil.h
//  MotionMeasurement
//
//  Created by 猪猪 on 15/9/20.
//  Copyright © 2015年 @猪猪. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EveryDataUtil : NSObject
@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *startTime; // 单次运动的时间
@property (nonatomic, assign) int maxNum;  //超过上限的次数
@property (nonatomic, assign) double singleTotalNum; //单次运动总量
@property (nonatomic, assign) int index;
@property (nonatomic, copy) NSString *endTime;
@property (nonatomic, assign)BOOL isSave;
@property (atomic, assign) int  alertCount;
- (void)checkAndAvoidNull;
@end
