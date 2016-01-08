
//
//  HomePageViewController.m
//  testProject
//
//  Created by 猪猪 on 15/8/18.
//  Copyright (c) 2015年 @猪猪. All rights reserved.
//

#import "HomeViewController.h"
#import "mainView.h"
#import "SliderViewController.h"
#import "BlueToothSetViewController.h"
#import "BlueToothSetViewController.h"
#import "HomePageTableViewCell.h"
#import "LoginViewController.h"
#import "BlueToothUtil.h"
#import "RequestUtil.h"
#import "UserUtil.h"
#import "MBProgressHUD+Util.h"
#import "DaylyDataViewController.h"
#import "SqlRequestUtil.h"
#import "EveryDataUtil.h"
#import <AudioToolbox/AudioToolbox.h>
#define COLOR_TRANSLATE(x)  ((float)(x)/(255.0))

@implementation DaylyMotion
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.daylyTotal = 0.0;
        self.daylyIsSave = NO;
        NSDateFormatter *format = [[NSDateFormatter alloc]init];
        [format setDateFormat:@"MM-dd"];
        self.thisDayDate = [format stringFromDate:[NSDate date]];
        self.alertNum = 0;
    }
    return self;
}
@end
@interface HomeViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet mainView *TodayMeasurementView;  //园环
@property (strong, nonatomic) IBOutlet UINavigationItem *dateNavigationItem;
@property (strong, nonatomic) UIView *loginView;
@property (strong, nonatomic) IBOutlet UIProgressView *daylyTotalProgress;
@property (strong, nonatomic) IBOutlet UILabel *percentDaylyTotalParamLB;
@property (strong, nonatomic) IBOutlet UIImageView *chargeImageView;
@property (strong, nonatomic) BlueToothUtil *blueTooth;
@property (strong, nonatomic) UserUtil *curUser;
@property (strong, nonatomic) userParam *curUserParam;
@property (strong, nonatomic) NSTimer *heartBeatTimer;
@property (assign, atomic) double equivalent;
@property (assign, atomic) double inpulse;
@property (copy, atomic) NSString *softEdition;
@property (copy, atomic) NSString *hardWareEdition;
@property (strong, nonatomic) NSTimer *mainThreadTimer;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, atomic)  EveryDataUtil *curMotion;   //单次运动
@property (assign, atomic) int  typeSevVenConunt;  //
@property (strong, nonatomic) NSTimer *intervalTimer;
@property (strong,nonatomic)NSTimer *singleTimer;
@property (assign, nonatomic) int intervalTime;
@property (assign, nonatomic) BOOL firstGoFlag;
@property (copy, atomic) void (^notInParamTimeBlock)();
@property (copy, atomic) void (^overFloerBlock)();
@property (assign, nonatomic) double singleEndData;
@property (strong, nonatomic) NSMutableArray *todayData;  //今天的运动数据
@property (assign, atomic) int frequecyNum; //纪录今天运动的次数
@property (strong, atomic) DaylyMotion *daylyMotion;
@property (strong, atomic) SqlRequestUtil *sql;
@property (strong, nonatomic) NSMutableDictionary *historyListDict;
@property (strong, nonatomic) UIAlertView *alertView;
@property (assign, atomic) BOOL alertFlag;
@property (strong, nonatomic)NSTimer *alertTime;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [LoginViewController tryToLogin];
    [self setUp];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loginScucess) name:USER_LOGIN_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(logoutScucess) name:USER_LOGOUT_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(APNSNotification:) name:APNS_NOTIFICATION object:nil];

}

- (void)viewDidAppear:(BOOL)animated {
    if(self.mainThreadTimer == nil){
        self.mainThreadTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(mainThread) userInfo:nil repeats:YES];
    }
    [super viewDidAppear:animated];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:USER_LOGIN_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:USER_LOGOUT_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:APNS_NOTIFICATION object:nil];
}
-(void)setUp
{
    __weak HomeViewController *weakSelf = self;
    self.view.backgroundColor = [UIColor whiteColor];
    self.alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    [self.TodayMeasurementView setLineWidth:22 AndOffset:10];
    [self.TodayMeasurementView setUp];
    [self.TodayMeasurementView setPersentMaskOfCircle:0 color:[UIColor redColor].CGColor];
    [self.TodayMeasurementView setTitle:@"本次未达标" andTarget:@"0"];
    self.percentDaylyTotalParamLB.text = [NSString stringWithFormat:@"今日未达标"];
    [self.daylyTotalProgress setProgress:0.0];
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"MM月dd日"];
    //self.dateNavigationItem.title= [NSString stringWithFormat:@"蓝牙未连接，已登录"];
    self.blueTooth = [BlueToothUtil getBlueToothInstance];
    if(![RequestUtil checkNetState]) {
        [MBProgressHUD showError:@"网络未连接，不能实现数据同步"];
    }

    //电量
       //实时数据
    [[BlueToothUtil getBlueToothInstance]readCurrentMotionMeasurement:^(float equivalent, float inpulse) {
        NSDateFormatter *datefomattersportsEndTimeParam =[[NSDateFormatter alloc]init];
        [datefomattersportsEndTimeParam setDateFormat:@"HH:mm"];
        NSString *curTime = [datefomattersportsEndTimeParam stringFromDate:[NSDate date]];
        self.equivalent = equivalent;  // 本次当量值
        self.inpulse = inpulse;  //
        if(![self.curUserParam.userName isEqualToString:@"7"]) {
            self.daylyMotion.daylyTotal += equivalent;    //今日总量
            if([curTime compare:self.curUserParam.sportsEndTimeParam]== NSOrderedAscending && [curTime compare:self.curUserParam.sportsBeginTimeParam]== NSOrderedDescending)
            { //若今天的数据已经超出
                if(self.daylyMotion.daylyTotal
                   < [self.curUserParam.dayValueMaxParam intValue]){
                    
                    if(self.intervalTimer) {
                        if([self.curUserParam.intervalTimeTypeParam isEqualToString:@"2"] && self.intervalTime > 0){  //当时间到了 还没有运动，即count 还是比较大
                            [RequestUtil uploadAlertEvent:self.curUser.userName32
                                                   device:self.curUser.deviceID18
                                                   reason:@"5"
                                                startTime:[self getCurrentDateOfDateAndTime]
                                              MotionStart:self.curMotion.startTime
                                              singleTotal:self.curMotion.singleTotalNum
                                               daylyTotal:self.daylyMotion.daylyTotal
                                              maxValueNum:self.curMotion.maxNum
                                                    block:^{
                                                        self.curMotion.alertCount ++;
                                                        self.daylyMotion.alertNum++;
                                                    }
                             ];
                            [self showAlertMeg:@"时间间隔内运动"];
                            if(self.intervalTime < 0) {
                                [self.intervalTimer invalidate];
                                self.intervalTimer = nil;
                            } else {
                                return;
                            }
                        }
                    }
                    
                    [format setDateFormat:@"HH:mm"];
                    NSString *curTime = [self.dateFormatter stringFromDate:[NSDate date]];
                    //单次数据清零，下一次开始了
                    if(self.curMotion.isSave) {
                        self.curMotion.isSave = NO;
                        NSString *startTime= [format stringFromDate:[NSDate date]];
                        self.curMotion.startTime = startTime;
                        self.curMotion.maxNum = 0;
                        self.curMotion.singleTotalNum = 0;
                        self.curMotion.endTime = @"";
                        self.curMotion.alertCount = 0;
                        self.curMotion.index = self.todayData.count+1;
                        [format setDateFormat:@"MM-dd"];
                        self.curMotion.date = [format stringFromDate:[NSDate date]];
                    }
                    //单次运动判断
                    if(self.singleTimer) {
                        [self.singleTimer invalidate];
                        self.singleTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(singleEndAction) userInfo:nil repeats:YES];
                        
                    } else {
                        self.singleTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(singleEndAction) userInfo:nil repeats:YES];
                    }
                    
                    //第二天数据清零
                    [self.dateFormatter setDateFormat:@"MM-dd"];
                    if(![self.daylyMotion.thisDayDate isEqualToString:[self.dateFormatter stringFromDate:[NSDate date]]] ) {
                        self.daylyMotion.daylyIsSave = NO;
                        self.daylyMotion.daylyTotal = 0;
                        self.daylyMotion.thisDayDate = [self.dateFormatter stringFromDate:[NSDate date]];
                    }
                    self.curMotion.singleTotalNum +=equivalent; //本次运动量
                    [self.TodayMeasurementView aninationStart];
                    if(self.curUserParam) {
                        [self showToUser];
                        [self.dateFormatter setDateFormat:@"HH:mm"];
                        if(inpulse > [self.curUserParam.maxValueParam doubleValue]) {
                            self.curMotion.maxNum ++;  //本次运动超过上限值
                        }
                        
                        //运动量过大
                        if(inpulse > [self.curUserParam.maxValueParam intValue]) {
                                [RequestUtil uploadAlertEvent:weakSelf.curUser.userName32
                                                       device:weakSelf.curUser.deviceID18
                                                       reason:@"7"
                                                    startTime:[self getCurrentDateOfDateAndTime]
                                                  MotionStart:weakSelf.curMotion.startTime
                                                  singleTotal:weakSelf.curMotion.singleTotalNum
                                                   daylyTotal:weakSelf.daylyMotion.daylyTotal
                                                  maxValueNum:weakSelf.curMotion.maxNum
                                                        block:^{
                                                            weakSelf.curMotion.alertCount ++;
                                                            weakSelf.daylyMotion.alertNum ++;

                                                        }
                                 ];
                            [self showAlertMeg:@"你的运动用力过大，可以轻点吗？"];
                            
                        }
                        
                        if(self.curMotion.singleTotalNum > [self.curUserParam.singleValueMaxParam intValue])
                        {
                            [RequestUtil uploadAlertEvent:self.curUser.userName32
                                                   device:self.curUser.deviceID18
                                                   reason:@"2"
                                                startTime:[self getCurrentDateOfDateAndTime]
                                              MotionStart:self.curMotion.startTime
                                              singleTotal:self.curMotion.singleTotalNum
                                               daylyTotal:self.daylyMotion.daylyTotal
                                              maxValueNum:self.curMotion.maxNum
                                                    block: ^{
                                                        self.curMotion.alertCount ++;
                                                        self.daylyMotion.alertNum++;
                                                    }
                             ];
                            [self showAlertMeg:@"本次已经过量，请停止运动"];
                        }
                    }            //用户单次已经过量没有停下来，也要警告
                    
                } else {
                    [RequestUtil uploadAlertEvent:self.curUser.userName32
                                           device:self.curUser.deviceID18
                                           reason:@"4"
                                        startTime:[self getCurrentDateOfDateAndTime]
                                      MotionStart:self.curMotion.startTime
                                      singleTotal:self.curMotion.singleTotalNum
                                       daylyTotal:self.daylyMotion.daylyTotal
                     
                                      maxValueNum:self.curMotion.maxNum
                                            block:^{
                                                self.curMotion.alertCount ++;
                                                self.daylyMotion.alertNum ++;
                                            }
                     ];
                    [self showAlertMeg:@"今天运动过量"];
                }
                               //运动间隔时间
                
            } else {
                [RequestUtil uploadAlertEvent:weakSelf.curUser.userName32
                                       device:weakSelf.curUser.deviceID18
                                       reason:@"8"
                                    startTime:[self getCurrentDateOfDateAndTime]
                                  MotionStart:self.curMotion.startTime
                                  singleTotal:self.curMotion.singleTotalNum
                                   daylyTotal:self.daylyMotion.daylyTotal
                                  maxValueNum:self.curMotion.maxNum
                                        block:^{
                                            weakSelf.curMotion.alertCount ++;
                                            weakSelf.daylyMotion.alertNum ++;
                                        }];
                [self showAlertMeg:@"你没有在规定时间内运动，请停止运动"];
                if (self.intervalTimer) {
                    [self.intervalTimer invalidate];
                    self.intervalTimer = nil;
                }
                if(self.singleTimer){
                    [self.singleTimer invalidate];
                    self.singleTimer = nil;
                }
            }
        } else {
            if(self.inpulse > [self.curUserParam.maxValueParam doubleValue]) {
                self.curMotion.maxNum ++;
            }
        }
   }];
    [self getHardInfo];
    self.mainThreadTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(mainThread) userInfo:nil repeats:YES];
    self.heartBeatTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(heartBeatAction) userInfo:nil repeats:YES];
}
- (void)loginScucess {
    [self initData];
    if(self.mainThreadTimer == nil){
        self.mainThreadTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(mainThread) userInfo:nil repeats:YES];
    }
    NSLog(@"login sucecced");
}
- (void)logoutScucess {
    if(self.mainThreadTimer){
        [self.mainThreadTimer invalidate];
        self.mainThreadTimer = nil;
    }
    self.curUserParam = nil;
    NSLog(@"logout sucecced");
}
- (void)todayDataSave:(EveryDataUtil *)data {
    if(data && self.todayData) {
        EveryDataUtil *item = [[EveryDataUtil alloc]init];
        item.startTime = data.startTime;
        item.endTime = data.endTime;
        item.maxNum = data.maxNum;
        item.index = data.index;
        item.singleTotalNum = data.singleTotalNum;
        item.alertCount = data.alertCount;
        item.date = data.date;
        item.isSave = data.isSave;
        [self.sql insertEveryDataUtilData:item];
        [self.todayData addObject:item];
    }
}

- (void)showToUser {
    [[BlueToothUtil getBlueToothInstance]readBatterySum:^(short batterySum) {
        NSString *str = [NSString stringWithFormat:@"%d.jpg",(int)(batterySum /20)];
        self.chargeImageView.image = [UIImage imageNamed:str];
        //self.rightBarButton.image = [UIImage imageNamed:str];
    }];

    //界面显示
    if(![self.curUserParam.userType isEqualToString:@"7"]){
        CGFloat percent = 0;
        double num = self.curMotion.singleTotalNum;
        percent = self.curMotion.singleTotalNum/[self.curUserParam.singleValueMaxParam doubleValue];
        if(percent > 1.0) {
            percent = 1.0;
        }
        if([self.curUserParam.singleValueMinParam doubleValue] - num >= 0.01) {
            [self.TodayMeasurementView setTitle:@"本次未达标" andTarget:nil];
            [self.TodayMeasurementView setPersentMaskOfCircle:(percent) color:[UIColor redColor].CGColor];
            
        } else if(num - [self.curUserParam.singleValueMinParam doubleValue] >= 0.01 && [self.curUserParam.singleValueMaxParam doubleValue] - num >= 0.01){
            [self.TodayMeasurementView setTitle:@"本次已达标" andTarget:nil];
            [self.TodayMeasurementView setPersentMaskOfCircle:(percent) color:[UIColor greenColor].CGColor];

        } else if(num - [self.curUserParam.singleValueMaxParam doubleValue] >= 0.01) {
            [self.TodayMeasurementView setTitle:@"本次超标" andTarget:nil];
            [self.TodayMeasurementView setPersentMaskOfCircle:(percent) color:[UIColor redColor].CGColor];
        }
        percent = self.daylyMotion.daylyTotal
        /[self.curUserParam.dayValueMaxParam doubleValue];
        if(percent > 1.0) {
            percent = 1.0;
        }
        [self.daylyTotalProgress setProgress:percent];
        num = self.daylyMotion.daylyTotal;
        if([self.curUserParam.dayValueMinParam doubleValue] - num >= 0.01) {
            self.percentDaylyTotalParamLB.text = [NSString stringWithFormat:@"今日未达标"];
            self.daylyTotalProgress.tintColor = [UIColor redColor];
        } else if (num - [self.curUserParam.dayValueMinParam doubleValue] >= 0.01 && [self.curUserParam.dayValueMaxParam doubleValue] - num >= 0.01 ){
            self.percentDaylyTotalParamLB.text = [NSString stringWithFormat:@"今日已达标"];
            self.daylyTotalProgress.tintColor = [UIColor greenColor];
        } else if(num - [self.curUserParam.dayValueMaxParam doubleValue] >= 0.01) {
            self.percentDaylyTotalParamLB.text = [NSString stringWithFormat:@"今日已超标"];
            self.daylyTotalProgress.tintColor = [UIColor redColor];
        }

    } else {
        CGFloat percent = 0.0;
        percent = self.curMotion.maxNum / self.curUserParam.maxValueNumParam;
        if(1.0 - percent >0.01){
            [self.TodayMeasurementView setPersentMaskOfCircle:(percent) color:[UIColor redColor].CGColor];
            [self.TodayMeasurementView setTitle:@"未达标" andTarget:nil];
        } else {
            percent = 1.0;
            [self.TodayMeasurementView setPersentMaskOfCircle:(percent) color:[UIColor greenColor].CGColor];
            [self.TodayMeasurementView setTitle:@"已达标" andTarget:nil];
        }
        self.percentDaylyTotalParamLB.text = @"";
    }
}
- (void)initData {
    _historyListDict = [[NSMutableDictionary alloc]initWithCapacity:20];
    self.alertFlag = NO;
    self.sql = [SqlRequestUtil shareInstance];
    [self.sql updateEveryDataUtilTempData:self.curMotion date:self.curMotion.date];
    EveryDataUtil *data = [self.sql readSingleDataTemp:self.curMotion.date];
    NSLog(@"%lf",data.singleTotalNum);

    self.typeSevVenConunt = 0;
    self.frequecyNum = 0;
    self.inpulse = 0.0;
    self.equivalent = 0.0;
    self.daylyMotion = [[DaylyMotion alloc]init];
    [self initSqlDaylyData];
    self.curMotion.maxNum = 0;
    self.firstGoFlag = NO;
    self.curMotion = [[EveryDataUtil alloc]init];
    self.curMotion.isSave = YES;
    self.dateFormatter = [[NSDateFormatter alloc]init];
    self.todayData = [[NSMutableArray alloc]initWithCapacity:20];
    [self.dateFormatter setDateFormat:@"MM-dd"];
    self.curMotion.date = [self.dateFormatter stringFromDate:[NSDate date]];
    
    [self initSqlTodayData];
    [self initSqlEveryDataUtilTemp:self.curMotion.date];
    if(self.curMotion.singleTotalNum > 0) {
        self.singleTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(singleEndAction) userInfo:nil repeats:YES];
    }
    self.curUserParam = nil;
    self.curUser = [RequestUtil getCurrentUser];
}
- (void)initSqlDaylyData {
    NSArray *arr = [self.sql readDaylyData];
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"MM-dd"];
    if(arr.count){
        DaylyMotion *motion = arr[0];  //有数据且是今天
        if([motion.thisDayDate isEqualToString:[format stringFromDate:[NSDate date]]]) {
            self.daylyMotion = motion;
            [format setDateFormat:@"HH:mm"];
            if([[format stringFromDate:[NSDate date]] compare:self.curUserParam.sportsEndTimeParam] == NSOrderedAscending){
                self.daylyMotion.daylyIsSave = NO;
                [self.sql updateDayData:self.daylyMotion];
            }
        } else { //更新为现在的数据
            [self.sql clearDaylyData];
            self.daylyMotion = [[DaylyMotion alloc]init];
            [self.sql insertDaylyData:self.daylyMotion];
        }
    } else {
        [self.sql clearDaylyData];
        self.daylyMotion = [[DaylyMotion alloc]init];
        [self.sql insertDaylyData:self.daylyMotion];
    }
}
- (void)initSqlTodayData {
    NSArray *arr = [self.sql readSingleData];
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"MM-dd"];
    if(arr.count){
        EveryDataUtil *motion = arr[0]; //是今天的数据
        for (EveryDataUtil *item in arr) {
            if([item.date isEqualToString:[format stringFromDate:[NSDate date]]]) {
                [self.todayData addObject:item];
            } else {
                NSArray *keys = [_historyListDict allKeys];
                for (NSString *str in keys) {
                    if([str isEqualToString:item.date]){
                        break;
                    }
                }
                NSArray *arr = [self.sql readSingleDataByDate:item.date];
                if(item.date) {
                    [self.historyListDict setObject:arr forKey:item.date];
                }
            }
        }
        
    }
}
- (void)initSqlEveryDataUtilTemp:(NSString *)date {
    EveryDataUtil *data = [self.sql readSingleDataTemp:date];
    if(data && data.date.length > 0) {
        [self.dateFormatter setDateFormat:@"MM-dd"];
        if(![data.date isEqualToString:[self.dateFormatter stringFromDate:[NSDate date]]]){
            [self.sql clearEveryDataUtilTempData];
            self.curMotion = [[EveryDataUtil alloc]init];
            [self.sql insertEveryDataUtilTempData:self.curMotion];
        } else {
            self.curMotion = data;
            self.frequecyNum = self.curMotion.index;
        }
    } else {
        [self.sql clearEveryDataUtilTempData];
        self.curMotion = [[EveryDataUtil alloc]init];
        [self.sql insertEveryDataUtilTempData:self.curMotion];
    }
}
- (void)uploadHistoryData:(NSDictionary *)dict {
    double total = 0.0;
    NSInteger maxVlue = 0;
    NSInteger alert = 0;
    NSArray *keys = [dict allKeys];
    if(keys.count){
        for (NSString *date in keys) {
            NSArray *data = [dict objectForKey:date];
            for (EveryDataUtil *item in data) {
                maxVlue +=item.maxNum;
                alert +=item.alertCount;
                total +=item.singleTotalNum;
            }
            [RequestUtil uploadDaylyData:self.curUser.userName32 device:self.curUser.deviceID18 dayTotal:total dayMaxValueNum:maxVlue dayAlarmNum:alert daySportNum:data.count everyData:data block:^{
            }];
            [self.sql clearSingleDataByDate:date];
            total = 0.0;
             maxVlue = 0;
             alert = 0;
        }
    }
}
- (void)statusCheck {
    [LoginViewController tryHeartBeatLogin];
    NSMutableString *statusStr = [[NSMutableString alloc]initWithString:@""];
    if(CBPeripheralStateConnected == [[BlueToothUtil getBlueToothInstance]getConnectFlag]){
        [statusStr appendFormat:@"蓝牙已连接"];
    } else if(CBPeripheralStateConnecting == [[BlueToothUtil getBlueToothInstance]getConnectFlag]){
        [statusStr appendFormat:@"蓝牙正在连接"];
    } else if(CBPeripheralStateDisconnected == [[BlueToothUtil getBlueToothInstance]getConnectFlag]) {
        [statusStr appendFormat:@"蓝牙未连接"];
    }else if(CBPeripheralStateDisconnecting == [[BlueToothUtil getBlueToothInstance]getConnectFlag]) {
        [statusStr appendFormat:@"蓝牙未连接"];
    }
    if([LoginViewController hasLogin]) {
        [statusStr appendFormat:@",用户已登录"];
    }else {
        [statusStr appendFormat:@",用户未登录"];
    }
    self.dateNavigationItem.title = statusStr;
}
#pragma mark  主线程
- (void)mainThread {
    [self getHardInfo];
    [self getParam];  //通过网络获取数据
    [self statusCheck];
    //数据库数据保存
    if(self.sql) {
        [self.sql updateDayData:self.daylyMotion];
        [self.sql updateEveryDataUtilTempData:self.curMotion date:self.curMotion.date];
        EveryDataUtil *data = [self.sql readSingleDataTemp:self.curMotion.date];
    }
    if(self.curUserParam)
    {
        [self showToUser];
        [self.dateFormatter setDateFormat:@"HH:mm"];
        NSString *curTime = [self.dateFormatter stringFromDate:[NSDate date]];
        NSString *curM = [curTime substringFromIndex:3];
        NSString *paramM = [self.curUserParam.sportsEndTimeParam substringFromIndex:3];
        
        if(![self.curUserParam.userType isEqualToString:@"7"]) { //用户不为7
            [RequestUtil updatePercent:self.curUser.userName32 device:self.curUser.deviceID18 percent:self.daylyMotion.daylyTotal / [self.curUserParam.dayValueMaxParam doubleValue] block:nil];
            [self todayEndTimeAction];
        } else { // 用户为7 天运动量没达到告警
            static int type7Flag = NO;
            [RequestUtil updatePercent:self.curUser.userName32 device:self.curUser.deviceID18 percent:self.curMotion.maxNum / self.curUserParam.maxValueNumParam block:nil];
            
            if([curTime compare:self.curUserParam.sportsEndTimeParam] == NSOrderedDescending && ([curM intValue] - [paramM intValue] < 1)) {
                if(self.curUserParam.maxValueNumParam > self.curMotion.maxNum) {
                    [RequestUtil uploadAlertEvent:self.curUser.userName32
                                           device:self.curUser.deviceID18
                                           reason:@"3"
                                        startTime:[self getCurrentDateOfDateAndTime]
                                      MotionStart:self.curMotion.startTime
                                      singleTotal:self.curMotion.singleTotalNum
                                       daylyTotal:self.daylyMotion.daylyTotal
                                      maxValueNum:self.curMotion.maxNum
                                            block:^{
                                                self.curMotion.alertCount ++;
                                                self.daylyMotion.alertNum ++;
                                            }
                     ];
                    type7Flag = YES;
                    [self showAlertMeg:@"今天运动量未达到"];
                }
            }
        }
    } else {
        
    }
}
- (void)singleEndAction {
    self.singleEndData = self.curMotion.singleTotalNum;
    [self.dateFormatter setDateFormat:@"HH:mm"];
    NSString *curTime = [self.dateFormatter stringFromDate:[NSDate date]];
    //单词运动判断
        if(self.curMotion.singleTotalNum > 0 && (self.curMotion.isSave == NO)) {
                        //单词完成过量
            if(self.curMotion.singleTotalNum > [self.curUserParam.singleValueMaxParam intValue])
            {
                [RequestUtil uploadAlertEvent:self.curUser.userName32
                                       device:self.curUser.deviceID18
                                       reason:@"2"
                                    startTime:[self getCurrentDateOfDateAndTime]
                                  MotionStart:self.curMotion.startTime
                                  singleTotal:self.curMotion.singleTotalNum
                                   daylyTotal:self.daylyMotion.daylyTotal
                                  maxValueNum:self.curMotion.maxNum
                                        block:^{
                                            self.curMotion.alertCount ++;
                                            self.daylyMotion.alertNum ++;

                                        }
                 ];
                [self showAlertMeg:@"本次运动过量"];
                
            }
                       //单词未完成
            if(self.curMotion.singleTotalNum >0 && self.curMotion.singleTotalNum < [self.curUserParam.singleValueMinParam intValue])
            {
                [RequestUtil uploadAlertEvent:self.curUser.userName32
                                       device:self.curUser.deviceID18
                                       reason:@"1"
                                    startTime:[self getCurrentDateOfDateAndTime]
                                  MotionStart:self.curMotion.startTime
                                  singleTotal:self.curMotion.singleTotalNum
                                   daylyTotal:self.daylyMotion.daylyTotal
                                  maxValueNum:self.curMotion.maxNum
                                        block:^{
                                            self.curMotion.alertCount ++;
                                            self.daylyMotion.alertNum ++;

                                        }
                 ];
                [self showAlertMeg:@"本次运动未完成"];
                
            }
            if(!self.curMotion.isSave) {
                //保存这次数据
                self.curMotion.isSave = YES;
                self.curMotion.endTime = curTime;
                [self todayDataSave:self.curMotion];
                //清除数据
                {
                    self.curMotion = [[EveryDataUtil alloc]init];
                    self.curMotion.maxNum = 0;
                    self.curMotion.singleTotalNum = 0;
                    self.curMotion.endTime = @"";
                    self.curMotion.alertCount = 0;
                    self.curMotion.isSave = YES;
                    NSDateFormatter *format = [[NSDateFormatter alloc]init];
                    [format setDateFormat:@"MM-dd"];
                    self.curMotion.date = [format stringFromDate:[NSDate date]];
                    [self.sql updateEveryDataUtilTempData:self.curMotion date:self.curMotion.date];
                }
            }

            [self.singleTimer invalidate];
            self.singleTimer = nil;
            self.intervalTime = self.curUserParam.intervalTimeParam * 60;
            self.intervalTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(intervalTimerAction) userInfo:nil repeats:YES];
            
        }
}
- (void)todayEndTimeAction {
    [self.dateFormatter setDateFormat:@"HH:mm"];
    NSString *curTime = [self.dateFormatter stringFromDate:[NSDate date]];
    NSString *curM = [curTime substringFromIndex:3];
    NSString *paramM = [self.curUserParam.sportsEndTimeParam substringFromIndex:3];
    //每天运动时间到达
    if([curTime compare:self.curUserParam.sportsEndTimeParam] == NSOrderedDescending && (self.daylyMotion.daylyIsSave == NO) && (self.singleTimer == nil))
    {
        self.daylyMotion.daylyIsSave = YES; //已经保存置位防止多次发警告
        //上传今天的运动数据
        [self.sql updateDayData:self.daylyMotion];
                //天运动量每到量
            if(self.daylyMotion.daylyTotal
               < [self.curUserParam.dayValueMinParam intValue]){
                [RequestUtil uploadAlertEvent:self.curUser.userName32
                                       device:self.curUser.deviceID18
                                       reason:@"3"
                                    startTime:[self getCurrentDateOfDateAndTime]
                                  MotionStart:self.curMotion.startTime
                                  singleTotal:self.curMotion.singleTotalNum
                                   daylyTotal:self.daylyMotion.daylyTotal
                 
                                  maxValueNum:self.curMotion.maxNum
                                        block:^{
                                            self.curMotion.alertCount ++;
                                            self.daylyMotion.alertNum ++;

                                        }
                 ];
                [self showAlertMeg:@"今天运动没到量"];
                
            }
        
        //若今天的数据已经超出则，不计运动时间直接提示今日运动过量即可
        if(self.daylyMotion.daylyTotal
           > [self.curUserParam.dayValueMaxParam intValue]){
            [RequestUtil uploadAlertEvent:self.curUser.userName32
                                   device:self.curUser.deviceID18
                                   reason:@"4"
                                startTime:[self getCurrentDateOfDateAndTime]
                              MotionStart:self.curMotion.startTime
                              singleTotal:self.curMotion.singleTotalNum
                               daylyTotal:self.daylyMotion.daylyTotal
             
                              maxValueNum:self.curMotion.maxNum
                                    block:^{
                                        self.curMotion.alertCount ++;
                                        self.daylyMotion.alertNum ++;

                                    }
             ];
            [self showAlertMeg:@"今天运动过量"];
        }
        [RequestUtil uploadDaylyData:self.curUser.userName32 device:self.curUser.deviceID18 dayTotal:self.daylyMotion.daylyTotal dayMaxValueNum:self.todayData.count dayAlarmNum:self.daylyMotion.alertNum daySportNum:self.todayData.count everyData:self.todayData block:^{
        }];

    }
}
- (void)getHardInfo {
    static int blueToothCount = 0;
    blueToothCount ++;
    int flag = [[BlueToothUtil getBlueToothInstance]getConnectFlag];
    if(blueToothCount == 10000) {
        blueToothCount = 0;
    }
    NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:@"blueToothName"];
    if(!(flag == CBPeripheralStateConnecting || CBPeripheralStateConnected == flag)) {
        if(name.length > 0){
            if((blueToothCount % 3) == 0) {
                [[BlueToothUtil getBlueToothInstance] reScan];
            }
        }
    } else if(CBPeripheralStateConnected == flag) {
        if(![[BlueToothUtil getBlueToothInstance]isBlueToothConnected]) {
            [[BlueToothUtil getBlueToothInstance] reScan];
        }
    }
    if(!self.curUser.deviceID18) {
        [[BlueToothUtil getBlueToothInstance]readDeviceID:^(NSString *name) {
            self.curUser.deviceID18 = name;
        }];
    }
    if(!self.softEdition) {
        [[BlueToothUtil getBlueToothInstance]readSoftEdition:^(NSString *softEdition) {
            self.softEdition = softEdition;
        }];
    }
    if(!self.hardWareEdition) {
        [[BlueToothUtil getBlueToothInstance]readHareEdition:^(NSString *hardWareEdition) {
            self.hardWareEdition = hardWareEdition;
        }];
    }
}
- (void)getParam {
    static BOOL flag = NO;
    if(!self.curUserParam){
        if([LoginViewController hasLogin]){
            if(!self.curUserParam && self.curUser.userName32.length >0 && self.curUser.deviceID18.length>0)
            {
                [RequestUtil doloadPatam:self.curUser.userName32 device:self.curUser.deviceID18 block:^(NSDictionary *dict) {
                    userParam *oldParam = [userParam readFromDefault];
                    self.curUserParam = [[userParam alloc]initWithDict:dict];
                    if(![oldParam checkTheSame:self.curUserParam]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [userParam writeToDefault:self.curUserParam];
                            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"经医生诊断，您的处方已更新，请按照新的处方运动" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                            [self alertTimeAction];
                            NSDateFormatter *format = [[NSDateFormatter alloc]init];
                            [format setDateFormat:@"HH:mm"];
                            if([[format stringFromDate:[NSDate date]] compare:self.curUserParam.sportsEndTimeParam] == NSOrderedAscending){
                                self.daylyMotion.daylyIsSave = NO;
                                [self.sql updateDayData:self.daylyMotion];
                            }

                            [alertView show];
                        });
                    } else {
                        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"经医生诊断，您的处方不许要更新，请按照原处方继续运动" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        [alertView show];
                    }
                }];
            }
            
            if(!(self.curUser.userName32.length >0) || !self.curUser.userName32) {
                if([RequestUtil getUserName].length >0){
                    [RequestUtil getUserinfo:[RequestUtil getUserName] block:^(NSDictionary *dict) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UserUtil *item = [[UserUtil alloc]initWithDict:dict];
                            [RequestUtil setCurrentUser:item];
                            self.curUser = item;
                        });
                    }];
                }
            }
            [self uploadHistoryData:self.historyListDict];
        } else {
            self.curUserParam = [userParam readFromDefault];
            if(self.curUserParam ==nil){
                if(!flag){
                    flag = YES;
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"没有配置参数，程序无法使用" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
                }
            } else {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"登陆失败，请按照原处方继续运动" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
            }
            self.curUser.userName32 = [RequestUtil getUserName];
        }
        NSDateFormatter *format = [[NSDateFormatter alloc]init];
        [format setDateFormat:@"HH:mm"];
        if([[format stringFromDate:[NSDate date]] compare:self.curUserParam.sportsEndTimeParam] == NSOrderedAscending){
            self.daylyMotion.daylyIsSave = NO;
            [self.sql updateDayData:self.daylyMotion];
        }
    }
}
- (void)intervalTimerAction {
    self.intervalTime --;
    [self.dateFormatter setDateFormat:@"HH:mm"];
    NSString *curTime = [self.dateFormatter stringFromDate:[NSDate date]];
    //第二次没有运动     （前提：count 已经大于30了）
    //没有运动  （前提：count 已经大于30了）
    if([self.curUserParam.intervalTimeTypeParam isEqualToString:@"1"] && self.intervalTime <0 && 0 == self.curMotion.singleTotalNum ) {  //当时间未到，运动时count 置0
        [RequestUtil uploadAlertEvent:self.curUser.userName32
                               device:self.curUser.deviceID18
                               reason:@"6"
                            startTime:[self getCurrentDateOfDateAndTime]
                          MotionStart:self.curMotion.startTime
                          singleTotal:self.curMotion.singleTotalNum
                           daylyTotal:self.daylyMotion.daylyTotal
                          maxValueNum:self.curMotion.maxNum
                                block:^{
                                    self.daylyMotion.alertNum ++;
                                    self.curMotion.alertCount ++;
                                }
];
        [self showAlertMeg:@"时间到了，马上运动吧"];
        [self.intervalTimer invalidate];
        _intervalTimer = nil;
    }
}

#pragma  mark  心跳包
- (void)heartBeatAction {
        [RequestUtil keepHeartBeat:self.curUser.userName32 device:self.curUser.deviceID18 block:^(NSString *cmdStr) {
            [self remoteDataManager:cmdStr];
           }];
}
- (void)APNSNotification:(NSNotification *)msg {
    NSString *msgStr = msg.object;
    [self remoteDataManager:msgStr];
    NSLog(@"APNSNotification:%@",msg.object);
}
- (void)remoteDataManager:(NSString * )cmdstr {
    int cmd = [[cmdstr substringToIndex:1]intValue];
    switch (cmd) {
        case 0:
            NSLog(@"心跳消息：消息为空");
            break;
        case 1:  //VIP用户的反馈数据有最新回复
            _alertView.title = @"您提的问题有新的回复";
            [_alertView show];
            break;
        case 2: //上传实时数据
            if(self.curUser.userName32 && self.curUser.deviceID18 && self.equivalent && self.inpulse) {
                [RequestUtil uploadCurrentData:self.curUser.userName32
                                      deviceID:self.curUser.deviceID18
                                      sportsDL:[NSString stringWithFormat:@"%6.2f",self.equivalent]
                                      sportsCL:[NSString stringWithFormat:@"%6.2f",self.inpulse]
                                         block:nil];
            }
            break;
        case 3:
            
            break;
        case 4: //上传设备信息
            if(self.curUser.userName32.length >0 && self.curUser.deviceID18.length>0 && self.softEdition && self.hardWareEdition)
            {
                [RequestUtil uploadHardWareParam:self.curUser.userName32 device:self.curUser.deviceID18 app:@"1.0.0" soft:self.softEdition hardWare:self.hardWareEdition block:nil];
            }
            else
            {
                self.curUser = [RequestUtil getCurrentUser];
            }
            break;
        case 5:  //关闭心跳包
            [self.heartBeatTimer invalidate];
            self.heartBeatTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(heartBeatAction) userInfo:nil repeats:YES];
            break;
        case 7:
            [RequestUtil updatePercent:self.curUser.userName32 device:self.curUser.deviceID18 percent:self.daylyMotion.daylyTotal / [self.curUserParam.dayValueMaxParam doubleValue] block:nil];
            break;
        case 8:
            break;
        case 6:  //更改心跳间隔
            [self.heartBeatTimer invalidate];
            NSString *timeVal = [cmdstr substringFromIndex:[cmdstr rangeOfComposedCharacterSequenceAtIndex:3].location];
            int timeValInt = [timeVal intValue];
            if(timeValInt <1)
            {
                timeValInt = 1;
            }
            self.heartBeatTimer = [NSTimer scheduledTimerWithTimeInterval:timeValInt target:self selector:@selector(heartBeatAction) userInfo:nil repeats:YES];
            break;
    }
}
- (void)toLoginVC
{
    //弹出登录界面
    LoginViewController *loginVC=[[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
    
    [self presentViewController:loginVC animated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getHardInfo];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)leftNavigationClicked:(UIBarButtonItem *)sender {
    [[SliderViewController sharedSliderController]leftItemClick];
}
- (instancetype)init
{
    self = [self initWithNibName:@"HomeViewController" bundle:nil];
    if (self) {
    }
    return self;
}
- (IBAction)backDate:(UIButton *)sender {
}
- (IBAction)forwardDate:(UIButton *)sender {

}
#pragma mark tableviewDelegate and dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *homeCellID = @"HomeCellID";
    HomePageTableViewCell *cell = (HomePageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:homeCellID];
    if(!cell)
    {
        cell = (HomePageTableViewCell *) [[[NSBundle mainBundle]loadNibNamed:@"HomePageTableViewCell" owner:self options:nil]lastObject];
    }
    cell.textLabel.text = @"运动量1";
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 100, 30)];
    lab.textColor = [UIColor grayColor];
    lab.text = @"本次运动量";
    return lab;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if(buttonIndex == 1){
//        if(self.alertTime) {
//            [self.alertTime invalidate];
//        }
//        self.alertFlag = NO;
//    }
}
- (void)showAlertMeg:(NSString *)msg {
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    [alertView show];
    [self alertTimeAction];
}
- (void)alertTimeAction {
    [self playSound];
    [self vibrate];
}
- (void)playSound {
    AudioServicesPlaySystemSound(1007);
}
- (void)vibrate {
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
}
- (IBAction)detailButtonClicked:(id)sender {
    DaylyDataViewController *vc = [[DaylyDataViewController alloc]initWithNibName:@"DaylyDataViewController" bundle:nil];
    vc.daylyData = self.todayData;
    vc.maxsingleTotal = [self.curUserParam.singleValueMaxParam doubleValue];
    vc.maxDaylyTotal = [self.curUserParam.dayValueMaxParam doubleValue];
    vc.daylyTotal = self.daylyMotion.daylyTotal
;
    [self presentViewController:vc animated:YES completion:nil];
}
- (NSString *)getCurrentDateOfDateAndTime {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    return [dateFormatter stringFromDate:[NSDate date]];
}
//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    static CGFloat percent;
//    static CGFloat percent1;
//    static double num;
//    static double num1;
//    
//    //测试,猪猪
//    num += 100;
//    percent += 0.1;
//    if(percent > 1.0) {
//        percent = 1.0;
//    }
//    
//    if([self.curUserParam.singleValueMinParam doubleValue] - num >= 0.01) {
//        [self.TodayMeasurementView setTitle:@"本次未达标" andTarget:nil];
//        [self.TodayMeasurementView setPersentMaskOfCircle:(percent) color:[UIColor redColor].CGColor];
//        
//    } else if(num - [self.curUserParam.singleValueMinParam doubleValue] >= 0.01 && [self.curUserParam.singleValueMaxParam doubleValue] - num >= 0.01){
//        [self.TodayMeasurementView setTitle:@"本次已达标" andTarget:nil];
//        [self.TodayMeasurementView setPersentMaskOfCircle:(percent) color:[UIColor greenColor].CGColor];
//        
//    } else if(num - [self.curUserParam.singleValueMaxParam doubleValue] >= 0.01) {
//        [self.TodayMeasurementView setTitle:@"本次已超标" andTarget:nil];
//        [self.TodayMeasurementView setPersentMaskOfCircle:(percent) color:[UIColor redColor].CGColor];
//    }
//    percent1 += 0.05;
//    if(percent1 > 1.0) {
//        percent1 = 1.0;
//    }
//    num1 += 200;
//    [self.daylyTotalProgress setProgress:percent1];
//    if([self.curUserParam.dayValueMinParam doubleValue] - num1 >= 0.01) {
//        self.percentDaylyTotalParamLB.text = [NSString stringWithFormat:@"今日未达标"];
//        self.daylyTotalProgress.tintColor = [UIColor redColor];
//    } else if (num1 - [self.curUserParam.dayValueMinParam doubleValue] >= 0.01 && [self.curUserParam.dayValueMaxParam doubleValue] - num1 >= 0.01 ){
//        self.percentDaylyTotalParamLB.text = [NSString stringWithFormat:@"今日已达标"];
//        self.daylyTotalProgress.tintColor = [UIColor greenColor];
//    } else if(num1 - [self.curUserParam.dayValueMaxParam doubleValue] >= 0.01) {
//        self.percentDaylyTotalParamLB.text = [NSString stringWithFormat:@"今日已超标"];
//        self.daylyTotalProgress.tintColor = [UIColor redColor];
//    }
//}
@end
