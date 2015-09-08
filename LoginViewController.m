//
//  LoginViewController.m
//  MotionMeasurement
//
//  Created by 猪猪 on 15/8/24.
//  Copyright (c) 2015年 @猪猪. All rights reserved.
//

#import "LoginViewController.h"
#import "RequestUtil.h"
#import "MBProgressHUD+Util.h"
#import "RegisterViewController.h"
@interface LoginViewController ()
@property (strong, nonatomic) IBOutlet UITextField *nameText;
@property (strong, nonatomic) IBOutlet UITextField *passedText;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSLog(@"%s",__FUNCTION__);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)loginButtonClicked:(id)sender {
    if(!self.nameText.text || self.passedText.text.length != 6)
    {
        [MBProgressHUD showError:@"用户名或者密码不对，密码要去六位"];
        return;
    }
    [RequestUtil userLogin:self.nameText.text passwd:self.passedText.text block:^(bool flag)
     {
         if(flag)
         {
             [self dismissViewControllerAnimated:YES completion:nil];
         }
         else
         {
             [MBProgressHUD showError:@"登录失败"];
         }
     }];
}
- (IBAction)registerAcount:(UIButton *)sender {
    RegisterViewController *RegisterVC = [[RegisterViewController alloc]initWithNibName:@"RegisterViewController" bundle:nil];
    [self presentViewController:RegisterVC animated:YES completion:nil];
}

@end
