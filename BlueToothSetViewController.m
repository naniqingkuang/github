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
    self.bluetoothNameList = [[BlueToothUtil getBlueToothInstance]getNameOfBlueToothList];
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
    if(self.m_block){
        self.m_block();
    }else {
        [[SliderViewController sharedSliderController]leftItemClick];
    }
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
        int i = indexPath.row;
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
    if([self.isSelectedName isEqual:self.bluetoothNameList[indexPath.row]])
    {
        [[BlueToothUtil getBlueToothInstance]stopConnect:self.bluetoothNameList[indexPath.row]];
        self.isSelectedName = @"";
        [self.tableView reloadData];
    }
    else
    {
        NSString *nameStr = [NSString stringWithFormat:@"正在连接:%@",self.bluetoothNameList[indexPath.row]];
        self.m_MBprogressHUB = [MBProgressHUD showMessage:nameStr toView:self.view];
        [[BlueToothUtil getBlueToothInstance]blueToothConnectTo:self.bluetoothNameList[indexPath.row] block:^{
            if (self.m_MBprogressHUB) {
                [self.m_MBprogressHUB hide:YES];
            }
            self.isSelectedName = self.bluetoothNameList[indexPath.row];
            [self.tableView reloadData];
        }];
 
    }
}
- (IBAction)refreshBlueToothList:(id)sender {
   // [self resScanBlutTooth];
    [[BlueToothUtil getBlueToothInstance]reScan];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(resScanBlutTooth) userInfo:nil repeats:YES];
    self.bluetoothNameList = [[BlueToothUtil getBlueToothInstance]getNameOfBlueToothList];
    [self.tableView reloadData];
}
- (void)resScanBlutTooth
{
    static int i = 0;
    i ++;
    if(5 == i)
    {
        if (self.timer) {
            [self.timer invalidate];
            [[BlueToothUtil getBlueToothInstance]stopScan];
        }
    }
    self.bluetoothNameList = [[BlueToothUtil getBlueToothInstance]getNameOfBlueToothList];
    [self.tableView reloadData];
}
@end
