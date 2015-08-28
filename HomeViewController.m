
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
#import "DPMeterView.h"
#define COLOR_TRANSLATE(x)  ((float)(x)/(255.0))
@interface HomeViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet mainView *TodayMeasurementView;
@property (strong, nonatomic) IBOutlet UILabel *chargeSumLB;
@property (strong, nonatomic) IBOutlet UINavigationItem *dateNavigationItem;
@property (strong, nonatomic) IBOutlet UIView *ChargeTopVIew;
@property (strong, nonatomic) IBOutlet DPMeterView *chargeView;
@property (strong, nonatomic)UIView *loginView;

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
    [self.TodayMeasurementView setTitle:@"今日运动" andTarget:@"20000"];
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"MM月dd日"];
    NSString *dateStr =[format stringFromDate:[NSDate date]];
    
    [self.chargeView setMeterType:DPMeterTypeLinearVertical];
    self.chargeView.progressTintColor = [UIColor colorWithRed:216/255.f green:147/255.f blue:48/255.f alpha:1.f];
    self.chargeView.trackTintColor = [UIColor colorWithRed:231/255.f green:190/255.f blue:132/255.f alpha:1.f];
    [self.chargeView setShape:[UIBezierPath bezierPathWithRoundedRect:self.chargeView.bounds cornerRadius:0.f].CGPath];
    [self.chargeView.layer setBorderWidth:3.f];
    self.ChargeTopVIew.layer.cornerRadius = 1.0;
    self.ChargeTopVIew.layer.masksToBounds = YES;
    self.chargeView.layer.masksToBounds = YES;
    self.chargeView.layer.cornerRadius = 2.0;
    
    [self.chargeView.layer setBorderColor:[UIColor colorWithRed:195/255.f green:129/255.f blue:35/255.f alpha:1.f].CGColor];
    self.dateNavigationItem.title= dateStr;
    [self performSelector:@selector(toLoginVC) withObject:nil afterDelay:0.0];
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
//    for (float i = 0.01; i < 1; i +=0.001 ) {
//        [self.TodayMeasurementView setPersentMaskOfCircle:i];
//        sleep(1);
//    }
   // [self.navigationController presentViewController:[[UIViewController alloc]init] animated:YES completion:nil];
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
//    UINavigationController *nav = [[UINavigationController alloc]init];
//    BlueToothSetViewController * vc = [[BlueToothSetViewController alloc]initWithNibName:@"BlueToothSetViewController" bundle:nil];
//    [nav pushViewController:vc animated:YES];
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
    lab.text = @"  今日运动量";
    return lab;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    static float i = 0;
    static BOOL Flags = YES;
    if(Flags)
    {
        i += 0.1;
    }
    else
    {
        i -= 0.1;
    }
    if(i > 1.0)
    {
        Flags = !Flags;
        i = 1.0;
    }
    if(i <0 )
    {
        i = 0.0;
        Flags = !Flags;
    }
    [self.TodayMeasurementView setPersentMaskOfCircle:i];
    int sum = i *2000;
    [self.chargeView setProgress:i animated:YES];
    self.chargeSumLB.text = [NSString stringWithFormat:@"%d%@",(int)(i *100),@"%"];
    [self.TodayMeasurementView setCurrentSum:[NSString stringWithFormat:@"%d",sum]];
}
@end
