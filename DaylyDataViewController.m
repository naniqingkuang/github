//
//  DaylyDataViewController.m
//  MotionMeasurement
//
//  Created by 猪猪 on 15/10/3.
//  Copyright © 2015年 @猪猪. All rights reserved.
//

#import "DaylyDataViewController.h"
#import "HomePageTableViewCell.h"
#import "HomeViewController.h"
@interface DaylyDataViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation DaylyDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.daylyData.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *myCellID = @"daylyDataCellID";
    HomePageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myCellID];
    if(!cell) {
        cell = (HomePageTableViewCell *)[[[NSBundle mainBundle]loadNibNamed:@"HomePageTableViewCell" owner:nil options:nil]lastObject];
    }
    SingleMotion *data = [self.daylyData objectAtIndex:indexPath.row];
    cell.progress.progress = data.singleTotalNum / self.maxsingleTotal;
    cell.mtextLabel.text = [NSString stringWithFormat:@"%d %@ - %@",data.index, data.startTime, data.endTime];
    return cell;
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
