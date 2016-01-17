//
//  SqlRequestUtil.m
//  MotionMeasurement
//
//  Created by 猪猪 on 15/10/14.
//  Copyright © 2015年 @猪猪. All rights reserved.
//

#import "SqlRequestUtil.h"
static SqlRequestUtil *static_sqlRequst;

@interface SqlRequestUtil ()
{
    FMDatabase *db;
}
@end
@implementation SqlRequestUtil
+(SqlRequestUtil *)shareInstance {
    if (static_sqlRequst == nil) {
        static_sqlRequst = [[SqlRequestUtil alloc]init];
    }
    return static_sqlRequst;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        db = nil;
        [self createDB];
        [self createTableDaylyData];
        [self createTableSingleData];
        [self createTableSingleDataTemp];
        //[self test];
    }
    return self;
}
- (void)test {
    [self clearSingleData];
    EveryDataUtil *data = [[EveryDataUtil alloc]init];
    data.date = @"11-10";
    data.startTime = @"12:23";
    data.singleTotalNum = 230.0;
    data.index = 1;
    data.alertCount = 23;
    data.endTime = @"23:34";
    data.maxNum = 20;
    [self insertEveryDataUtilData:data];
    data.date = @"11-10";
    data.startTime = @"12:23";
    data.singleTotalNum = 230.0;
    data.index = 2;
    data.alertCount = 23;
    data.endTime = @"23:34";
    data.maxNum = 20;
    [self insertEveryDataUtilData:data];
    data.date = @"11-10";
    data.startTime = @"12:23";
    data.singleTotalNum = 230.0;
    data.index = 3;
    data.alertCount = 23;
    data.endTime = @"23:34";
    data.maxNum = 20;
    [self insertEveryDataUtilData:data];
    data.date = @"11-10";
    data.startTime = @"12:23";
    data.singleTotalNum = 230.0;
    data.index = 4;
    data.alertCount = 23;
    data.endTime = @"23:34";
    data.maxNum = 20;
    [self insertEveryDataUtilData:data];
    data.date = @"11-10";
    data.startTime = @"12:23";
    data.singleTotalNum = 230.0;
    data.index = 5;
    data.alertCount = 23;
    data.endTime = @"23:34";
    data.maxNum = 20;
    [self insertEveryDataUtilData:data];
    data.date = @"11-10";
    data.startTime = @"12:23";
    data.singleTotalNum = 230.0;
    data.index = 6;
    data.alertCount = 23;
    data.endTime = @"23:34";
    data.maxNum = 20;
    [self insertEveryDataUtilData:data];
    data.date = @"11-11";
    data.startTime = @"12:23";
    data.singleTotalNum = 230.0;
    data.index = 1;
    data.alertCount = 23;
    data.endTime = @"23:34";
    data.maxNum = 20;
    [self insertEveryDataUtilData:data];
    data.date = @"11-11";
    data.startTime = @"12:23";
    data.singleTotalNum = 230.0;
    data.index = 2;
    data.alertCount = 23;
    data.endTime = @"23:34";
    data.maxNum = 20;
    [self insertEveryDataUtilData:data];
    data.date = @"11-11";
    data.startTime = @"12:23";
    data.singleTotalNum = 230.0;
    data.index = 3;
    data.alertCount = 23;
    data.endTime = @"23:34";
    data.maxNum = 20;
    [self insertEveryDataUtilData:data];
    data.date = @"11-11";
    data.startTime = @"12:23";
    data.singleTotalNum = 230.0;
    data.index = 4;
    data.alertCount = 23;
    data.endTime = @"23:34";
    data.maxNum = 20;
    [self insertEveryDataUtilData:data];
   
   

}
- (void)createDB{
    if(db == nil) {
        NSArray *arr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [arr objectAtIndex:0];
        //dbPath： 数据库路径，在Document中。
        NSString *dbPath = [documentDirectory stringByAppendingPathComponent:@"motion.db"];
        db = [[FMDatabase alloc]initWithPath:dbPath];
    }
}
- (void)close {
    if(db) {
        [db close];
    }
}
/**
 @interface EveryDataUtil : NSObject
 @property (nonatomic, copy) NSString *date;
 @property (nonatomic, copy) NSString *startTime; // 单次运动的时间
 @property (nonatomic, assign) int maxNum;  //超过上限的次数
 @property (nonatomic, assign) double singleTotalNum; //单次运动总量
 @property (nonatomic, assign) int index;
 @property (nonatomic, copy) NSString *endTime;
 @property (nonatomic, assign)BOOL isSave;
 @property (atomic, assign) int  alertCount;
 @end
 @interface DaylyMotion : NSObject
 @property (nonatomic, strong)NSString *thisDayDate;
 @property (assign, atomic) double  daylyTotal;  //一天的总和
 @property (assign, nonatomic) BOOL  daylyIsSave;   //当天的数据是否保存，也用于避免当天运动时间到达多次告警
 @end
 **/
-(void)createTableSingleData{
    if ([db open]) {
        if (![db tableExists:@"SingleData"]) {
            if ([db  executeUpdate:@"CREATE TABLE SingleData (date text,startTime text,maxNum INTEGER,singleTotalNum REAL,mIndex INTEGER,endTime text, isSave BLOB,alertCount INTEGER)"]) {
                [db close];
                NSLog(@"create table success");
            }else{
                NSLog(@"fail to create table");
            }
        }else {
            
             NSLog(@"table SingleData is already exist");
        }
        [db close];
    }else{
        NSLog(@"fail to open");
    }
}

-(void)createTableSingleDataTemp{
    if ([db open]) {
        if (![db tableExists:@"SingleDataTemp"]) {
            if ([db  executeUpdate:@"CREATE TABLE SingleDataTemp (date text,startTime text,maxNum INTEGER,singleTotalNum REAL,mIndex INTEGER,endTime text, isSave BLOB,alertCount INTEGER)"]) {
                [db close];
                NSLog(@"create table success");
            }else{
                NSLog(@"fail to create table");
            }
        }else {
            
            NSLog(@"table SingleData is already exist");
        }
        [db close];
    }else{
        NSLog(@"fail to open");
    }
}
- (void)createTableDaylyData {
    if ([db open]) {
        if (![db tableExists:@"DaylyData"]) {
            if ([db  executeUpdate:@"CREATE TABLE DaylyData (thisDayDate text,daylyTotal REAL,daylyIsSave BLOB,alertNum INT)"]) {
                NSLog(@"create table success");
                [db close];
            }else{
                NSLog(@"fail to create table");
            }
        }else {
            NSLog(@"table daylyData is already exist");
        }
        [db close];
    }else{
        NSLog(@"fail to open");
    }
}
- (void)deleteAllTableData{
    if ([db open]) {
        if ([db tableExists:@"DaylyData"]) {
            [db executeUpdate:@"delete from DaylyData"];
        }
        if ([db tableExists:@"SingleDataTemp"]) {
            [db executeUpdate:@"delete from SingleDataTemp"];
        }
        if ([db tableExists:@"SingleData"]) {
            [db executeUpdate:@"delete from SingleData"];
        }
        [db close];
    }else{
        NSLog(@"fail to open");
    }

}
- (void)insertEveryDataUtilData:(EveryDataUtil *)data {
    if([db open]) {
        [db executeUpdate:@"insert into SingleData (date,startTime,maxNum,singleTotalNum,mIndex,endTime, isSave,alertCount) values(?,?,?,?,?,?,?,?)",data.date,data.startTime,[NSNumber numberWithInt:data.maxNum],[NSNumber numberWithDouble:data.singleTotalNum],[NSNumber numberWithInt:data.index],data.endTime,[NSNumber numberWithBool:data.isSave],[NSNumber numberWithInt:data.alertCount],nil];
        [db close];
    }
}
- (void)updateEveryDataUtilData:(EveryDataUtil *)data {
    if ([db open]) {
        NSString *updateSql = [NSString stringWithFormat:
                               @"UPDATE SingleData SET date = '%@',startTime = '%@',maxNum = '%@',singleTotalNum = '%@',mIndex = '%@',endTime = '%@', isSave = '%@',alertCount = '%@' WHERE mIndex = '%@'",
                              data.date,data.startTime,[NSNumber numberWithInt:data.maxNum],[NSNumber numberWithDouble:data.singleTotalNum],[NSNumber numberWithInt:data.index],data.endTime,[NSNumber numberWithBool:data.isSave],[NSNumber numberWithInt:data.alertCount],[NSNumber numberWithInt:data.index]];
        BOOL res = [db executeUpdate:updateSql];
        if (!res) {
            NSLog(@"error when update db table");
        } else {
        }
        [db close];
        
    }
}
- (void)clearEveryDataUtilTempData {
    if ([db open]) {
        
        NSString *deleteSql = [NSString stringWithFormat:
                               @"delete from SingleDataTemp"];
        BOOL res = [db executeUpdate:deleteSql];
        
        if (!res) {
            NSLog(@"error when delete db table");
        } else {
            NSLog(@"success to delete db table");
        }
        [db close];
        
    }
}
- (void)insertEveryDataUtilTempData:(EveryDataUtil *)data {
    if([db open]) {
        BOOL res =[db executeUpdate:@"insert into SingleDataTemp (date,startTime,maxNum,singleTotalNum,mIndex,endTime, isSave,alertCount) values(?,?,?,?,?,?,?,?)",data.date,data.startTime,[NSNumber numberWithInt:data.maxNum],[NSNumber numberWithDouble:data.singleTotalNum],[NSNumber numberWithInt:data.index],data.endTime,[NSNumber numberWithBool:data.isSave],[NSNumber numberWithInt:data.alertCount],nil];
        if(!res){
            NSLog(@"insert table SingleDataTemp err");
        }
        [db close];
    }
}
- (void)updateEveryDataUtilTempData:(EveryDataUtil *)data date:(NSString *)date {
    if ([db open]) {
        NSString *updateSql = [NSString stringWithFormat:
                               @"UPDATE SingleDataTemp SET date = '%@',startTime = '%@',maxNum = '%@',singleTotalNum = '%@',mIndex = '%@',endTime = '%@', isSave = '%@',alertCount = '%@' WHERE date = '%@'",
                               data.date,data.startTime,[NSNumber numberWithInt:data.maxNum],[NSNumber numberWithDouble:data.singleTotalNum],[NSNumber numberWithInt:data.index],data.endTime,[NSNumber numberWithBool:data.isSave],[NSNumber numberWithInt:data.alertCount],date];
        BOOL res = [db executeUpdate:updateSql];
        if (!res) {
            NSLog(@"error when update db table");
        } else {
          // EveryDataUtil *data = [self readSingleDataTemp];
           // NSLog(@"%@",data);
        }
        [db close];
        
    }
}

- (void)insertDaylyData:(DaylyMotion *)data {
    if([db open]) {
        [db executeUpdate:@"insert into DaylyData (thisDayDate,daylyTotal,daylyIsSave,alertNum) values(?,?,?,?)",data.thisDayDate,[NSNumber numberWithDouble:data.daylyTotal],[NSNumber numberWithBool:data.daylyIsSave],[NSNumber numberWithInt:data.alertNum],nil];
        [db close];
    }
}
- (NSArray *)readSingleData {
    if ([db open]) {
        NSString * sql = [NSString stringWithFormat:
                          @"SELECT * FROM %@",@"SingleData"];
        NSMutableArray *arr = [[NSMutableArray alloc]initWithCapacity:10];
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next]) {
            EveryDataUtil *data = [[EveryDataUtil alloc]init];
            data.date = [rs stringForColumn:@"date"];
            data.startTime = [rs stringForColumn:@"startTime"];
            data.maxNum =[rs intForColumn:@"maxNum"];
            data.singleTotalNum = [rs doubleForColumn:@"singleTotalNum"];
            data.index = [rs intForColumn:@"mIndex"];
            data.endTime = [rs stringForColumn:@"endTime"];
            data.isSave = [rs boolForColumn:@"isSave"];
            data.alertCount = [rs intForColumn:@"alertCount"];
            [arr addObject:data];
        }
        [db close];
        return arr;
    }
    return nil;
}
- (NSArray *)readSingleDataByDate:(NSString *)date {
    if ([db open]) {
        NSString * sql = [NSString stringWithFormat:
                          @"SELECT * FROM %@ WHERE date = '%@' ",@"SingleData",date];
        NSMutableArray *arr = [[NSMutableArray alloc]initWithCapacity:10];
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next]) {
            EveryDataUtil *data = [[EveryDataUtil alloc]init];
            data.date = [rs stringForColumn:@"date"];
            data.startTime = [rs stringForColumn:@"startTime"];
            data.maxNum =[rs intForColumn:@"maxNum"];
            data.singleTotalNum = [rs doubleForColumn:@"singleTotalNum"];
            data.index = [rs intForColumn:@"mIndex"];
            data.endTime = [rs stringForColumn:@"endTime"];
            data.isSave = [rs boolForColumn:@"isSave"];
            data.alertCount = [rs intForColumn:@"alertCount"];
            [arr addObject:data];
        }
        [db close];
        return arr;
    }
    return nil;
}

- (EveryDataUtil *)readSingleDataTemp:(NSString *)date {
    if ([db open]) {
        NSString * sql = [NSString stringWithFormat:
                          @"SELECT * FROM %@ WHERE date = '%@'",@"SingleDataTemp",date];
        FMResultSet * rs = [db executeQuery:sql];
        EveryDataUtil *data = [[EveryDataUtil alloc]init];
        int flag = 0;
        while ([rs next]) {
            data.date = [rs stringForColumn:@"date"];
            data.startTime = [rs stringForColumn:@"startTime"];
            data.maxNum =[rs intForColumn:@"maxNum"];
            data.singleTotalNum = [rs doubleForColumn:@"singleTotalNum"];
            data.index = [rs intForColumn:@"mIndex"];
            data.endTime = [rs stringForColumn:@"endTime"];
            data.isSave = [rs boolForColumn:@"isSave"];
            data.alertCount = [rs intForColumn:@"alertCount"];
            flag ++;
        }
        [db close];
        if(flag) {
            return data;
        }
    }
    return nil;
}

- (void)clearSingleData {
    if ([db open]) {
        
        NSString *deleteSql = [NSString stringWithFormat:
                               @"delete from SingleData"];
        BOOL res = [db executeUpdate:deleteSql];
        
        if (!res) {
            NSLog(@"error when delete db table");
        } else {
            NSLog(@"success to delete db table");
        }
        [db close];
        
    }
}
//清除本日数据
- (void)clearDaylyData {
    if ([db open]) {
        
        NSString *deleteSql = [NSString stringWithFormat:
                               @"delete from DaylyData"];
        BOOL res = [db executeUpdate:deleteSql];
        
        if (!res) {
            NSLog(@"error when delete db table");
        } else {
            NSLog(@"success to delete db table");
        }
        [db close];
        
    }
}

-(void)clearSingleDataByDate:(NSString *)date {
    if ([db open]) {
        
        NSString *deleteSql = [NSString stringWithFormat:
                               @"delete from SingleData WHERE date = '%@'",date];
        BOOL res = [db executeUpdate:deleteSql];
        
        if (!res) {
            NSLog(@"error when delete db table");
        } else {
            NSLog(@"success to delete db table");
        }
        [db close];
        
    }
}

- (NSArray *)readDaylyData {
    if ([db open]) {
        NSString * sql = [NSString stringWithFormat:
                          @"SELECT * FROM %@",@"DaylyData"];
        NSMutableArray *arr = [[NSMutableArray alloc]initWithCapacity:10];
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next]) {
            DaylyMotion *data = [[DaylyMotion alloc]init];
            data.thisDayDate = [rs stringForColumn:@"thisDayDate"];
            data.daylyTotal = [rs doubleForColumn:@"daylyTotal"];
            data.daylyIsSave =[rs boolForColumn:@"daylyIsSave"];
            data.alertNum = [rs intForColumn:@"alertNum"];
            [arr addObject:data];
        }
        [db close];
        return arr;
    }
    return nil;

}
- (void)updateDayData:(DaylyMotion *)data {
    if ([db open]) {
        NSString *updateSql = [NSString stringWithFormat:
                               @"UPDATE DaylyData SET thisDayDate = '%@',daylyTotal = '%@',daylyIsSave = '%@',alertNum = '%d' WHERE thisDayDate = '%@' ",
                               data.thisDayDate,[NSNumber numberWithDouble:data.daylyTotal],[NSNumber numberWithBool:data.daylyIsSave],data.alertNum ,data.thisDayDate];
        BOOL res = [db executeUpdate:updateSql];
        if (!res) {
            NSLog(@"error when update db table");
        } else {
        }
        [db close];
        
    }
}
@end
