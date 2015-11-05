//
//  LeftViewController.m
//  LeftRightSlider
//
//  Created by Zhao Yiqi on 13-11-27.
//  Copyright (c) 2013年 Zhao Yiqi. All rights reserved.
//

#import "LeftViewController.h"
#import "SliderViewController.h"
#import "BlueToothSetViewController.h"
#import "ModifyViewController.h"
#import "LoginViewController.h"
#import "UpdatePasswdViewController.h"
#import "DaylyDataViewController.h"
#import "LoginViewController.h"
@interface LeftViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *tableV;
}
@end

@implementation LeftViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *imgV=[[UIImageView alloc] initWithFrame:self.view.bounds];
    [imgV setImage:[UIImage imageNamed:@"left"]];
    [self.view addSubview:imgV];
    
     tableV=[[UITableView alloc] initWithFrame:CGRectMake(0, 200, self.view.frame.size.width, self.view.frame.size.height-200)];
    tableV.backgroundColor=[UIColor clearColor];
    tableV.delegate=self;
    tableV.dataSource=self;
    [self.view addSubview:tableV];
    
	// Do any additional setup after loading the view.
}
- (void)viewDidAppear:(BOOL)animated {
    [tableV reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:3 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID=@"cellID";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellID];
   
    if(cell==nil){
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.backgroundColor=[UIColor clearColor];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    switch(indexPath.row){
        case 0:
            cell.textLabel.text=@"主页";
            break;
        case 1:
            cell.textLabel.text=@"蓝牙设置";
            break;
        case 2:
            cell.textLabel.text=@"信息修改";
            break;
        case 3:
            if([LoginViewController hasLogin]){
                cell.textLabel.text = @"退出登录";
            } else {
                cell.textLabel.text = @"登录";
            }
            break;
        case 4:
            cell.textLabel.text = @"密码修改";
            break;
        case 5:
            cell.textLabel.text = @"反馈";
            break;
        case 6:
            cell.textLabel.text = @"今日详细数据";
            break;
        default:
            break;
    }
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 7;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    LoginViewController *loginVC = nil;
    switch (indexPath.row) {
        case 0:
            [[SliderViewController sharedSliderController] showContentControllerWithModel:@"HomeViewController"];
            break;
        case 1:
            [[SliderViewController sharedSliderController] showContentControllerWithModel:@"BlueToothSetViewController"];
            break;
        case 2:
            [[SliderViewController sharedSliderController] showContentControllerWithModel:@"ModifyViewController"];
//             modifyVC = [[ModifyViewController alloc]initWithNibName:@"ModifyViewController" bundle:nil];
//            [self presentViewController:modifyVC animated:YES completion:nil];
            break;
        case 3:
            loginVC = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
            [self presentViewController:loginVC animated:NO completion:nil];
            break;
        case 4:
            [[SliderViewController sharedSliderController] showContentControllerWithModel:@"UpdatePasswdViewController"];
            break;
        case 5:
            [[SliderViewController sharedSliderController]showContentControllerWithModel:@"FeedBackListViewController"];
            break;
        case 6:
            [[SliderViewController sharedSliderController]showContentControllerWithModel:@"DaylyDataViewController"];
            break;
        default:
            break;
    }
}
- (void)reloadTableView {
    [tableV reloadData];
}
@end
