
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
#define COLOR_TRANSLATE(x)  ((float)(x)/(255.0))
@interface HomeViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet mainView *TodayMeasurementView;
@property (strong, nonatomic) IBOutlet UINavigationItem *dateNavigationItem;
@property (strong, nonatomic) UIView *loginView;
@property (strong, nonatomic) IBOutlet UIImageView *chargeImageView;
@property (strong, nonatomic) BlueToothUtil *blueTooth;
@property (strong, nonatomic) UserUtil *curUser;
@property (strong, nonatomic) userParam *curUserParam;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
}
-(void)setUp
{
    self.view.backgroundColor = [UIColor whiteColor];
    [self.TodayMeasurementView setPersentMaskOfCircle:0];
    [self.TodayMeasurementView setLineWidth:22 AndOffset:10];
    [self.TodayMeasurementView setUp];
    [self.TodayMeasurementView setTitle:@"本次运动" andTarget:@"20000"];
    self.curUser = [RequestUtil getCurrentUser];
    [RequestUtil doloadPatam:self.curUser.userName32 device:self.curUser.deviceID18 block:^(NSDictionary *dict) {
        self.curUserParam = [[userParam alloc]initWithDict:dict];
    }];
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"MM月dd日"];
    NSString *dateStr =[format stringFromDate:[NSDate date]];
    self.dateNavigationItem.title= dateStr;
    [self performSelector:@selector(toLoginVC) withObject:nil afterDelay:0.0];
    self.blueTooth = [BlueToothUtil getBlueToothInstance];
    [[BlueToothUtil getBlueToothInstance]readCurrentMotionMeasurement:^(float equivalent, float inpulse) {
        [self.TodayMeasurementView setPersentMaskOfCircle:(equivalent/200.0)];
        [self.TodayMeasurementView setCurrentSum:[NSString stringWithFormat:@"%0.1f",equivalent]];
        [RequestUtil uploadCurrentData:self.curUser.userName32
                              deviceID:self.curUser.deviceID18
                              sportsDL:[NSString stringWithFormat:@"%6.2f",equivalent]
                              sportsCL:[NSString stringWithFormat:@"%6.2f",inpulse]
                                 block:nil];
    }];
    [[BlueToothUtil getBlueToothInstance]readDeviceID:^(NSString *name) {
        self.curUser.deviceID18 = name;
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
    if(self.curUser.deviceID18.length >1)
    {
        __block NSString *hardWareID = nil;
        __block NSString *softWareID = nil;
        [[BlueToothUtil getBlueToothInstance]readHareEdition:^(NSString *hardWareEdition) {
            hardWareID = hardWareEdition;
        }];
        [[BlueToothUtil getBlueToothInstance]readSoftEdition:^(NSString *softEdition) {
            softWareID = softEdition;
        }];
        [RequestUtil uploadHardWareParam:self.curUser.userName32
                                  device:self.curUser.deviceID18
                                     app:@""
                                    soft:softWareID
                                hardWare:hardWareID
                                   block:nil];
    }
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
    static float i = 0;
    i +=0.1;
    [self.TodayMeasurementView setPersentMaskOfCircle:(i)];
}
@end
