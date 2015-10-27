//
//  HomeViewController.h
//  MotionMeasurement
//
//  Created by 猪猪 on 15/8/20.
//  Copyright (c) 2015年 @猪猪. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserUtil.h"

static UserUtil *g_CurrentUser;

@interface DaylyMotion : NSObject
@property (nonatomic, strong)NSString *thisDayDate;
@property (assign, atomic) double  daylyTotal;  //一天的总和
@property (assign, nonatomic) BOOL  daylyIsSave;   //当天的数据是否保存，也用于避免当天运动时间到达多次告警
@end
@interface HomeViewController : UIViewController
@end
