//
//  SqlRequestUtil.h
//  MotionMeasurement
//
//  Created by 猪猪 on 15/10/14.
//  Copyright © 2015年 @猪猪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "HomeViewController.h"

@interface SqlRequestUtil : NSObject
- (void)insertSingleMotionData:(SingleMotion *)data;
- (void)insertDaylyData:(DaylyMotion *)data;
- (NSArray *)readSingleData;
- (NSArray *)readDaylyData;
- (void)updateDayData:(DaylyMotion *)data;
- (void)clearSingleData;
- (void)updateSingleMotionData:(SingleMotion *)data;
@end
