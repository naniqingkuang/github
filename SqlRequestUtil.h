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
#import "EveryDataUtil.h"
@interface SqlRequestUtil : NSObject
+ (SqlRequestUtil *)shareInstance;
- (void)insertEveryDataUtilData:(EveryDataUtil *)data;
- (void)insertDaylyData:(DaylyMotion *)data;
- (NSArray *)readSingleData;
- (NSArray *)readSingleDataByDate:(NSString *)date;
- (NSArray *)readDaylyData;
- (void)updateDayData:(DaylyMotion *)data;
- (void)clearSingleData;
-(void)clearSingleDataByDate:(NSString *)date;
- (void)updateEveryDataUtilData:(EveryDataUtil *)data;
- (EveryDataUtil *)readSingleDataTemp;
- (void)updateEveryDataUtilTempData:(EveryDataUtil *)data date:(NSString *)date;
- (void)insertEveryDataUtilTempData:(EveryDataUtil *)data;
- (void)clearEveryDataUtilTempData;
- (void)deleteAllTableData;
- (void)clearDaylyData;
@end
