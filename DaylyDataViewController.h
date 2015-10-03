//
//  DaylyDataViewController.h
//  MotionMeasurement
//
//  Created by 猪猪 on 15/10/3.
//  Copyright © 2015年 @猪猪. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DaylyDataViewController : UIViewController
@property (nonatomic, strong) NSArray *daylyData;
@property (nonatomic, assign) double daylyTotal;
@property (nonatomic, assign) double maxDaylyTotal;
@property (nonatomic, assign) double maxsingleTotal;
@end
