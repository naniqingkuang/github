
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
#define COLOR_TRANSLATE(x)  ((float)(x)/(255.0))
@implementation SingleMotion
@end
@interface HomeViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet mainView *TodayMeasurementView;  //园环
@property (strong, nonatomic) IBOutlet UINavigationItem *dateNavigationItem;
@property (strong, nonatomic) UIView *loginView;
@property (strong, nonatomic) IBOutlet UIProgressView *daylyTotalProgress;
@property (strong, nonatomic) IBOutlet UILabel *daylyTotalParamLB;
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
@property (strong, atomic) SingleMotion *curMotion;   //单次运动
@property (assign, atomic) double  daylyTotal;  //一天的总和
@property (assign, atomic) int count;   //计数器，用于判断每次运动
@property (assign, atomic) int  typeSevVenConunt;  //
@property (strong, nonatomic) NSTimer *intervalTimer;
@property (assign, nonatomic) int intervalTime;
@property (assign, nonatomic) BOOL firstGoFlag;
@property (copy, atomic) void (^notInParamTimeBlock)();
@property (copy, atomic) void (^overFloerBlock)();
@property (strong, nonatomic) NSMutableArray *todayData;  //今天的运动数据
@property (assign, atomic) int frequecyNum; //纪录今天运动的次数
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self setUp];
}
-(void)setUp
{
    self.view.backgroundColor = [UIColor whiteColor];
    [self.TodayMeasurementView setPersentMaskOfCircle:0];
    [self.TodayMeasurementView setLineWidth:22 AndOffset:10];
    [self.TodayMeasurementView setUp];
    self.curUser = [RequestUtil getCurrentUser];
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"MM月dd日"];
    NSString *dateStr =[format stringFromDate:[NSDate date]];
    self.dateNavigationItem.title= dateStr;
    [self performSelector:@selector(toLoginVC) withObject:nil afterDelay:0.0];
    self.blueTooth = [BlueToothUtil getBlueToothInstance];
    [[BlueToothUtil getBlueToothInstance]readCurrentMotionMeasurement:^(float equivalent, float inpulse) {
        
        self.equivalent = equivalent;  // 本次当量值
        self.inpulse = inpulse;  //
        self.daylyTotal +=equivalent;    //今日总量
        NSString *curTime = [self.dateFormatter stringFromDate:[NSDate date]];
        if(self.curMotion.isSave) {
            self.curMotion.isSave = NO;
            self.curMotion.startTime = curTime;
            self.curMotion.maxNum = 0;
            self.curMotion.singleTotalNum = 0;
            self.curMotion.endTime = @"";
            self.curMotion.index = ++self.frequecyNum;
        }
        self.curMotion.singleTotalNum +=equivalent; //本次运动量
        __weak HomeViewController *weakSelf = self;
        [self.TodayMeasurementView aninationStart];
        if(self.curUserParam) {
            // 用户不为7
            if(![self.curUserParam.userName isEqualToString:@"7"]) {
                self.count = 0;
                self.firstGoFlag = YES;
                [self.dateFormatter setDateFormat:@"HH:ss"];
                if(equivalent > [self.curUserParam.maxValueParam doubleValue]) {
                    self.curMotion.maxNum ++;  //本次运动超过上限值
                }
                
                //界面显示
                [self.TodayMeasurementView setPersentMaskOfCircle:(self.curMotion.singleTotalNum/[self.curUserParam.singleValueMaxParam doubleValue])];
                [self.TodayMeasurementView setCurrentSum:[NSString stringWithFormat:@"%2.0f%@",self.curMotion.singleTotalNum/[self.curUserParam.singleValueMaxParam doubleValue]*100,@"%"]];
                self.percentDaylyTotalParamLB.text = [NSString stringWithFormat:@"%2.0lf%@",(self.daylyTotal/[self.curUserParam.dayValueMaxParam doubleValue]*100),@"%"];
                [self.daylyTotalProgress setProgress:self.daylyTotal/[self.curUserParam.dayValueMaxParam doubleValue]];
                
                //告警不在时间内运动
                if([curTime compare:self.curUserParam.sportsBeginTimeParam] == NSOrderedAscending || [curTime compare:self.curUserParam.sportsEndTimeParam] == NSOrderedDescending) {
                    
                    self.notInParamTimeBlock = ^{
                        [RequestUtil uploadAlertEvent:weakSelf.curUser.userName32
                                               device:weakSelf.curUser.deviceID18
                                               reason:@"8"
                                            startTime:curTime
                                          MotionStart:weakSelf.curMotion.startTime
                                          singleTotal:weakSelf.curMotion.singleTotalNum
                                           daylyTotal:weakSelf.daylyTotal
                                          maxValueNum:weakSelf.curMotion.maxNum
                                                block:nil];
                        
                    };
                } else {  //在规定运动时间内
                        //病人运动量过大
                        if(equivalent > [self.curUserParam.maxValueParam intValue]) {
                            self.overFloerBlock = ^{
                                [RequestUtil uploadAlertEvent:weakSelf.curUser.userName32
                                                       device:weakSelf.curUser.deviceID18
                                                       reason:@"7"
                                                    startTime:curTime
                                                  MotionStart:weakSelf.curMotion.startTime
                                                  singleTotal:0.0
                                                   daylyTotal:0.0
                                                  maxValueNum:0
                                                        block:nil];
                                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"运动幅度过大，请停止运动" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                                [alertView show];
                                
                            };
                        } else {  //达到最低要求,将结果显示出来
                            
                        }
                        
                    }
            }  else  {//为用户为7的
                [self.TodayMeasurementView setPersentMaskOfCircle:((double)self.curMotion.maxNum/(double)self.curUserParam.maxValueNumParam )];
                [self.TodayMeasurementView setCurrentSum:[NSString stringWithFormat:@"%2.0lf%@",((double)self.curMotion.maxNum/(double)self.curUserParam.maxValueNumParam) * 100,@"%"]];
                self.percentDaylyTotalParamLB.text = [NSString stringWithFormat:@"%2.0lf%@",((double)self.curMotion.maxNum/(double)self.curUserParam.maxValueNumParam *100),@"%"];
                [self.daylyTotalProgress setProgress:(double)self.curMotion.maxNum/(double)self.curUserParam.maxValueNumParam];
            }
        }
    }];
    [self getHardInfo];
    self.heartBeatTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(heartBeatAction) userInfo:nil repeats:YES];
    self.mainThreadTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(mainThread) userInfo:nil repeats:YES];
}
- (void)todayDataSave:(SingleMotion *)data {
    if(data && self.todayData) {
        SingleMotion *item = [[SingleMotion alloc]init];
        item.startTime = data.startTime;
        item.endTime = data.endTime;
        item.maxNum = data.maxNum;
        item.index = data.index;
        item.singleTotalNum = data.singleTotalNum;
        [self.todayData addObject:item];
    }
}
- (void)initData {
    self.typeSevVenConunt = 0;
    self.frequecyNum = 0;
    self.inpulse = 0.0;
    self.equivalent = 0.0;
    self.daylyTotal = 0.0;
    self.count = 0;
    self.curMotion.maxNum = 0;
    self.firstGoFlag = NO;
    self.curMotion = [[SingleMotion alloc]init];
    self.curMotion.isSave = NO;
    self.dateFormatter = [[NSDateFormatter alloc]init];
    [self.TodayMeasurementView setTitle:@"本次运动" andTarget:@"0"];
    [self.TodayMeasurementView setCurrentSum:@"0%"];
    self.percentDaylyTotalParamLB.text = [NSString stringWithFormat:@"%d%@",0,@"%"];
    [self.daylyTotalProgress setProgress:0.0];
    self.todayData = [[NSMutableArray alloc]initWithCapacity:20];
}
- (void)mainThread {
    if([LoginViewController hasLogin])
    {
        static int blueToothCount = 0;
        blueToothCount ++;
        if(![[BlueToothUtil getBlueToothInstance]isBlueToothConnected]) {
            if((blueToothCount % 8) == 0) {
                blueToothCount = 0;
                [MBProgressHUD showError:@"蓝牙未连接"];
            }
        }
        if(!self.curUser.deviceID18) {
            [[BlueToothUtil getBlueToothInstance]readDeviceID:^(NSString *name) {
                self.curUser.deviceID18 = name;
            }];
        }
        if(!(self.curUser.userName32.length >0) || !self.curUser.userName32) {
            [RequestUtil getUserinfo:[RequestUtil getUserName] block:^(NSDictionary *dict) {
                dispatch_async(dispatch_get_main_queue(), ^{
                UserUtil *item = [[UserUtil alloc]initWithDict:dict];
                [RequestUtil setCurrentUser:item];
                self.curUser = item;
                });
            }];
            
        }
        if(!self.curUserParam && self.curUser.userName32.length >0 && self.curUser.deviceID18.length>0)
        {
            [RequestUtil doloadPatam:self.curUser.userName32 device:self.curUser.deviceID18 block:^(NSDictionary *dict) {
                self.curUserParam = [[userParam alloc]initWithDict:dict];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.TodayMeasurementView setTitle:@"本次运动" andTarget:self.curUserParam.singleValueMaxParam];
                    self.daylyTotalParamLB.text = self.curUserParam.dayValueMaxParam;
                });
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
        if(self.curUserParam)
        {
            [self.dateFormatter setDateFormat:@"HH:mm:ss"];
            NSString *curTime = [self.dateFormatter stringFromDate:[NSDate date]];
            NSString *curM = [curTime substringFromIndex:3];
            NSString *paramM = [self.curUserParam.sportsEndTimeParam substringFromIndex:3];
            if(![self.curUserParam.userType isEqualToString:@"7"]) { //用户不为7
                if(self.overFloerBlock) {  //超过了最大值告警
                    self.overFloerBlock();
                    self.overFloerBlock = nil;
                }
                if(self.notInParamTimeBlock) {  //不在规定时间内告警
                    self.notInParamTimeBlock();
                    self.notInParamTimeBlock = nil;
                }
                //－－－－－－－－－－－－－－－－运动时间到检测
               
                //每天运动时间到达
                if([curTime compare:self.curUserParam.sportsEndTimeParam] == NSOrderedDescending && ([curM intValue] - [paramM intValue] < 1) && self.count >58)
                {
                    if([self.curUserParam.userType isEqualToString:@"7"]) {
                    } else {
                        //天运动量过量
                        if(self.daylyTotal > [self.curUserParam.dayValueMaxParam intValue]){
                            [RequestUtil uploadAlertEvent:self.curUser.userName32
                                                   device:self.curUser.deviceID18
                                                   reason:@"4"
                                                startTime:curTime
                                              MotionStart:@""
                                              singleTotal:0.0
                                               daylyTotal:self.daylyTotal
                                              maxValueNum:0.0
                                                    block:nil];
                        }
                        //天运动量每到量
                        if(self.daylyTotal < [self.curUserParam.dayValueMinParam intValue]){
                            [RequestUtil uploadAlertEvent:self.curUser.userName32
                                                   device:self.curUser.deviceID18
                                                   reason:@"3"
                                                startTime:curTime
                                              MotionStart:@""
                                              singleTotal:0.0
                                               daylyTotal:self.daylyTotal
                                              maxValueNum:0.0
                                                    block:nil];
                        }
                    }
                }
                if(self.firstGoFlag)
                {
                    self.count ++;
                }
                //单词运动判断
                if(self.count >60 && self.curMotion.singleTotalNum > 0) {
                    if(!self.curMotion.isSave) {
                        self.curMotion.isSave = YES;
                        self.curMotion.endTime = curTime;
                        [self todayDataSave:self.curMotion];
                    }
                    //单词未完成
                    if(self.curMotion.singleTotalNum < [self.curUserParam.singleValueMinParam intValue])
                    {
                        [RequestUtil uploadAlertEvent:self.curUser.userName32
                                               device:self.curUser.deviceID18
                                               reason:@"1"
                                            startTime:curTime
                                          MotionStart:self.curMotion.startTime
                                          singleTotal:self.curMotion.singleTotalNum
                                           daylyTotal:0.0
                                          maxValueNum:self.curMotion.maxNum
                                                block:nil];
                    }
                    //单词完成过量
                    if(self.curMotion.singleTotalNum > [self.curUserParam.singleValueMaxParam intValue])
                    {
                        [RequestUtil uploadAlertEvent:self.curUser.userName32
                                               device:self.curUser.deviceID18
                                               reason:@"2"
                                            startTime:curTime
                                          MotionStart:self.curMotion.startTime
                                          singleTotal:self.curMotion.singleTotalNum
                                           daylyTotal:0.0
                                          maxValueNum:self.curMotion.maxNum
                                                block:nil];
                    }
                    self.intervalTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(intervalTimerAction) userInfo:nil repeats:YES];
                    self.intervalTime = self.curUserParam.intervalTimeParam * 60;
                    
                }

            } else { // 用户为7 天运动量没达到告警
                if([curTime compare:self.curUserParam.sportsEndTimeParam] == NSOrderedDescending && ([curM intValue] - [paramM intValue] < 1)) {
                    if(self.curUserParam.maxValueNumParam > self.curMotion.maxNum) {
                        [RequestUtil uploadAlertEvent:self.curUser.userName32
                                               device:self.curUser.deviceID18
                                               reason:@"3"
                                            startTime:curTime
                                          MotionStart:self.curMotion.startTime
                                          singleTotal:0.0
                                           daylyTotal:self.curMotion.maxNum
                                          maxValueNum:0.0
                                                block:nil];
                    }
                }
            }
        }
    }
}
- (void)intervalTimerAction {
    self.intervalTime --;
    [self.dateFormatter setDateFormat:@"HH:ss"];
    NSString *curTime = [self.dateFormatter stringFromDate:[NSDate date]];
    //第二次没有运动     （前提：count 已经大于30了）
    if([self.curUserParam.intervalTimeTypeParam isEqualToString:@"2"] && self.intervalTime < 0 && (self.curUserParam.intervalTimeParam *60 < self.count && self.count >30)){
        [RequestUtil uploadAlertEvent:self.curUser.userName32
                               device:self.curUser.deviceID18
                               reason:@"6"
                            startTime:curTime
                          MotionStart:@""
                          singleTotal:0.0
                           daylyTotal:0.0
                          maxValueNum:0
                                block:nil];
        [self.intervalTimer invalidate];
    }
    //还没到时间就运动  （前提：count 已经大于30了）
    if([self.curUserParam.intervalTimeTypeParam isEqualToString:@"1"] && self.intervalTime >0 && (self.count < 30 )) {
        [RequestUtil uploadAlertEvent:self.curUser.userName32
                               device:self.curUser.deviceID18
                               reason:@"5"
                            startTime:curTime
                          MotionStart:@""
                          singleTotal:0.0
                           daylyTotal:0.0
                          maxValueNum:0
                                block:nil];
        [self.intervalTimer invalidate];
    }
}
- (void)getHardInfo
{
    [[BlueToothUtil getBlueToothInstance]readDeviceID:^(NSString *name) {
        self.curUser.deviceID18 = name;
    }];
    [[BlueToothUtil getBlueToothInstance]readSoftEdition:^(NSString *softEdition) {
        self.softEdition = softEdition;
    }];
    [[BlueToothUtil getBlueToothInstance]readHareEdition:^(NSString *hardWareEdition) {
        self.hardWareEdition = hardWareEdition;
    }];
    
}
#pragma  mark  心跳包
- (void)heartBeatAction {
        [RequestUtil keepHeartBeat:self.curUser.userName32 device:self.curUser.deviceID18 block:^(NSString *cmdStr) {
        int cmd = [[cmdStr substringToIndex:1]intValue];
        switch (cmd) {
            case 0:
                NSLog(@"心跳消息：消息为空");
            break;
            case 1:  //VIP用户的反馈数据有最新回复
                
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
                break;
            case 6:  //更改心跳间隔
                [self.heartBeatTimer invalidate];
                NSString *timeVal = [cmdStr substringFromIndex:[cmdStr rangeOfComposedCharacterSequenceAtIndex:3].location];
                int timeValInt = [timeVal intValue];
                if(timeValInt <1)
                {
                    timeValInt = 1;
                }
                self.heartBeatTimer = [NSTimer scheduledTimerWithTimeInterval:timeValInt target:self selector:@selector(heartBeatAction) userInfo:nil repeats:YES];
                break;
        }
    }];
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
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"MM月dd日"];
    NSString *dateStr =[format stringFromDate:[NSDate date]];
    self.dateNavigationItem.title = dateStr;
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
    cell.progress.progress = 1.0;
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
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSString *str = [NSString stringWithFormat:@"2.jpg"];
    self.chargeImageView.image = [UIImage imageNamed:str];
}
- (IBAction)detailButtonClicked:(id)sender {
    DaylyDataViewController *vc = [[DaylyDataViewController alloc]initWithNibName:@"DaylyDataViewController" bundle:nil];
    vc.daylyData = self.todayData;
    vc.maxsingleTotal = [self.curUserParam.singleValueMaxParam doubleValue];
    vc.maxDaylyTotal = [self.curUserParam.dayValueMaxParam doubleValue];
    vc.daylyTotal = self.daylyTotal;
    [self presentViewController:vc animated:YES completion:nil];
}

@end
