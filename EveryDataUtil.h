//
//  EveryDataUtil.h
//  MotionMeasurement
//
//  Created by 猪猪 on 15/9/20.
//  Copyright © 2015年 @猪猪. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EveryDataUtil : NSObject
@property (nonatomic, assign) int sportSerialNum;
@property (nonatomic, copy) NSString *startTime;
@property (nonatomic, copy) NSString *endTime;
@property (nonatomic, assign) double singleTotal;
@property (nonatomic, assign) int  maxValueNum;
@end
