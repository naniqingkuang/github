//
//  BlueToothSetViewController.m
//  testProject
//
//  Created by 猪猪 on 15/8/13.
//  Copyright (c) 2015年 @猪猪. All rights reserved.
//

#import "BlueToothSetViewController.h"
#import "SliderViewController.h"
#import "BlueToothUtil.h"
#import "MBProgressHUD+Util.h"
#import "BlueToothTableViewCell.h"
@interface BlueToothSetViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *bluetoothNameList;
@property (nonatomic, strong) MBProgressHUD *m_MBprogressHUB;
@property (nonatomic, copy) NSString *isSelectedName;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation BlueToothSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.bluetoothNameList = [[BlueToothUtil getBlueToothInstance]getNameOfBlueToothList];
    [self refreshBlueToothList:nil];
    self.isSelectedName = [[NSUserDefaults standardUserDefaults]objectForKey:@"blueToothName"];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
#pragma mark CBCentralManager的代理方法
////CBCentralManagerStateUnknown = 0,
//CBCentralManagerStateResetting,
//CBCentralManagerStateUnsupported,
//CBCentralManagerStateUnauthorized,
//CBCentralManagerStatePoweredOff,
//CBCentralManagerStatePoweredOn,


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)viewWillAppear:(BOOL)animated
{
//    [[BlueToothUtil getBlueToothInstance] reScan];
//    
//    [self.tableView reloadData];
   // [self.connectBlueTooth  readValueForCharacteristic:self.connectCharacristic];
}
- (IBAction)backToSetting:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
    [[SliderViewController sharedSliderController]leftItemClickToMain];
}


#pragma mark tableview deledate an datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  self.bluetoothNameList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *myCellid = @"blueToothtableviewcell";
    BlueToothTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myCellid];
    if(!cell)
    {
        cell = (BlueToothTableViewCell*)[[[NSBundle mainBundle]loadNibNamed:@"BlueToothTableViewCell" owner:self options:nil]lastObject];
    }
    if(self.bluetoothNameList.count)
    {
        NSString *str = self.bluetoothNameList[indexPath.row];
        cell.contextLabel.text = str;
        cell.titleLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row +1];
        if([self.isSelectedName isEqualToString:self.bluetoothNameList[indexPath.row]])
        {
            cell.m_imageView.hidden = NO;
        }
        else
        {
            cell.m_imageView.hidden = YES;
        }
        
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if([self.isSelectedName isEqual:self.bluetoothNameList[indexPath.row]])
    {
        [[BlueToothUtil getBlueToothInstance]stopConnect:self.bluetoothNameList[indexPath.row]];
        self.isSelectedName = @"";
        [userDefault setObject:@"" forKey:@"blueToothName"];
        [userDefault synchronize];

        [self.tableView reloadData];
    }
    else
    {
        [userDefault setObject:self.bluetoothNameList[indexPath.row] forKey:@"blueToothName"];
        [userDefault synchronize];
        self.isSelectedName = self.bluetoothNameList[indexPath.row];
        [self.tableView reloadData];
    }
}
- (IBAction)refreshBlueToothList:(id)sender {
   // [self resScanBlutTooth];
  //  NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:@"blueToothName"];
    [[BlueToothUtil getBlueToothInstance]reScan];
    if(!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(resScanBlutTooth) userInfo:nil repeats:YES];
    }else {
        [self.timer invalidate];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(resScanBlutTooth) userInfo:nil repeats:YES];
    }
    self.bluetoothNameList = [[BlueToothUtil getBlueToothInstance]getNameOfBlueToothList];
    [self.tableView reloadData];
}
- (void)resScanBlutTooth
{
    static int i = 0;
    i ++;
    if(120 == i || [[BlueToothUtil getBlueToothInstance]isBlueToothConnected])
    {
        i = 0;
        if (self.timer) {
            [self.timer invalidate];
            self.timer = nil;
            [[BlueToothUtil getBlueToothInstance]stopScan];
        }
    }
    self.bluetoothNameList = [[BlueToothUtil getBlueToothInstance]getNameOfBlueToothList];
    [self.tableView reloadData];
}
@end
