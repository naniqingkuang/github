//
//  FeedBackListViewController.m
//  MotionMeasurement
//
//  Created by 猪猪 on 15/9/19.
//  Copyright © 2015年 @猪猪. All rights reserved.
//

#import "FeedBackListViewController.h"
#import "RequestUtil.h"
#import "UserUtil.h"
#import "FeedBackDetialViewController.h"
#import "FeedBackViewController.h"
#import "SliderViewController.h"
@interface FeedBackListViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic, strong) NSArray *dataList;
@end

@implementation FeedBackListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    // Do any additional setup after loading the view from its nib.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initData];
}
- (void)initData {
    UserUtil *item = [RequestUtil getCurrentUser];
    [RequestUtil getFDList:item.userName32 device:item.deviceID18 page:1 block:^(NSDictionary *dict) {
        self.dataList = [dict objectForKey:@"result"];
        [self.myTableView reloadData];
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *myCellID = @"feedBackTableViewCellID";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:myCellID];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]init];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    NSDictionary *dict = self.dataList[indexPath.row];
   // cell.textLabel.text = dict[@"fdTime"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYYMMddHHmmss"];
    NSDate *date = [formatter dateFromString:dict[@"fdTime"]];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
//    cell.textLabel.text = dict[@"msgID"];
    cell.textLabel.text = [formatter stringFromDate:date];
    return cell;
}
- (IBAction)addNewFDItem:(id)sender {
    FeedBackViewController *FDVC = [[FeedBackViewController alloc]init];
    [self presentViewController:FDVC animated:YES completion:nil];
}
- (IBAction)backButtonClicked:(id)sender {
    //[[SliderViewController sharedSliderController]leftItemClick];
    [[SliderViewController sharedSliderController] showContentControllerWithModel:@"HomeViewController"];

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FeedBackDetialViewController *FDDetailVC = [[FeedBackDetialViewController alloc]initWithNibName:@"FeedBackDetialViewController" bundle:nil];
    FDDetailVC.feedBackID = self.dataList[indexPath.row][@"msgID"];
    [self presentViewController:FDDetailVC animated:YES completion:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
