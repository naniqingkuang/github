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
@interface SingleMotion : NSObject
@property (nonatomic, copy) NSString *startTime; // 单次运动的时间
@property (nonatomic, assign) int maxNum;  //超过上限的次数
@property (nonatomic, assign) double singleTotalNum; //单次运动总量
@property (nonatomic, assign) int index;
@property (nonatomic, copy) NSString *endTime;
@property (nonatomic, assign)BOOL isSave;
@end
@interface HomeViewController : UIViewController
@end
