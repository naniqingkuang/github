//
//  UpdatePasswdViewController.m
//  MotionMeasurement
//
//  Created by 猪猪 on 15/9/18.
//  Copyright © 2015年 @猪猪. All rights reserved.
//

#import "UpdatePasswdViewController.h"
#import "MBProgressHUD+Util.h"
#import "RequestUtil.h"
#import "SliderViewController.h"
@interface UpdatePasswdViewController ()
@property (strong, nonatomic) IBOutlet UITextField *name;
@property (strong, nonatomic) IBOutlet UITextField *passed;
@property (strong, nonatomic) IBOutlet UITextField *aNewPassed;
@property (strong, nonatomic) IBOutlet UITextField *confirmPassed;

@end

@implementation UpdatePasswdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.passed.text = @"";
    self.aNewPassed.text = @"";
    self.confirmPassed.text = @"";
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backToSettingClicked:(id)sender {
    //[[SliderViewController sharedSliderController]leftItemClick];
    [[SliderViewController sharedSliderController] showContentControllerWithModel:@"HomeViewController"];

}
- (IBAction)updatePassedClicked:(id)sender {
    if(![self.aNewPassed.text isEqualToString:self.confirmPassed.text]){
        [MBProgressHUD showError:@"新密码不一致"];
    }
    [RequestUtil updatePasswd:self.name.text passed:self.passed.text newPassed:self.aNewPassed.text block:^{
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
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
