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
#import "ModifyViewController.h"
#import "SliderViewController.h"
#import "SqlRequestUtil.h"
#import "Reachability.h"
#define screenHeight  ([UIScreen mainScreen].bounds.size.height)
static  BOOL logoFlag;
@interface LoginViewController ()<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *nameText;
@property (strong, nonatomic) IBOutlet UITextField *passedText;
@property (strong, nonatomic) IBOutlet UIImageView *rememberPWImageView;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIImageView *logoImageView;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.logoImageView.layer.cornerRadius = 10;
    self.logoImageView.layer.masksToBounds = YES;
    self.loginButton.layer.cornerRadius = 12;
    NSString *str = [RequestUtil getUserName];
    self.nameText.text = str;
    self.nameText.delegate = self;
    self.passedText.delegate = self;
    self.loginButton.layer.masksToBounds = YES;
    logoFlag = NO;
    BOOL flag = [[[NSUserDefaults standardUserDefaults]objectForKey:@"rememberPassWd"]boolValue];
    if(flag) {
        self.rememberPWImageView.image = [UIImage imageNamed:@"select.png"];
    } else {
        self.rememberPWImageView.image = [UIImage imageNamed:@"notSelect.png"];
    }
    // Do any additional setup after loading the view from its nib.
    NSLog(@"%s",__FUNCTION__);
}
- (IBAction)rememberPasswd:(id)sender {
    BOOL flag = [[[NSUserDefaults standardUserDefaults]objectForKey:@"rememberPassWd"]boolValue];
    if(flag) {
        self.rememberPWImageView.image = [UIImage imageNamed:@"notSelect.png"];
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:NO] forKey:@"rememberPassWd"];
    } else if(!flag){
        self.rememberPWImageView.image = [UIImage imageNamed:@"select.png"];
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:YES] forKey:@"rememberPassWd"];
    }
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
+ (void)tryToLogin {
    if(![self hasLogin]) {
        BOOL flag = [[[NSUserDefaults standardUserDefaults]objectForKey:@"rememberPassWd"]boolValue];
        NSString *userName = [RequestUtil getUserName];
        NSString *passwd = [[NSUserDefaults standardUserDefaults]objectForKey:@"passwd"];
        if(flag && userName.length >0 && passwd.length >0) {
            [RequestUtil userLogin:userName passwd:passwd block:^(bool flag) {
                if(flag){
                    [RequestUtil getUserinfo:userName block:^(NSDictionary *dict) {
                        UserUtil *item = [[UserUtil alloc]initWithDict:dict];
                        [RequestUtil setCurrentUser:item];
                        logoFlag = YES;
                        [[NSNotificationCenter defaultCenter]postNotification:[NSNotification notificationWithName:USER_LOGIN_SUCCESS object:nil]];
                    }];
                } else {
                    [MBProgressHUD showError:@"用户先登录，否则无法使用"];
                }
            }];
        }
    }
}
+ (void)tryHeartBeatLogin {
        BOOL flag = [[[NSUserDefaults standardUserDefaults]objectForKey:@"rememberPassWd"]boolValue];
        NSString *userName = [RequestUtil getUserName];
        NSString *passwd = [[NSUserDefaults standardUserDefaults]objectForKey:@"passwd"];
    if(![RequestUtil  checkNetState]) {
        logoFlag = NO;
        return ;
    }
        if(flag && userName.length >0 && passwd.length >0) {
            [RequestUtil userLogin:userName passwd:passwd block:^(bool flag) {
                if(flag){
                    [RequestUtil setUserName:userName];
                    [RequestUtil getUserinfo:userName block:^(NSDictionary *dict) {
                        UserUtil *item = [[UserUtil alloc]initWithDict:dict];
                        [RequestUtil setCurrentUser:item];
                        logoFlag = YES;
                    }];
                } else {
                    logoFlag = NO;
                }
            }];
        }
}

- (IBAction)loginButtonClicked:(id)sender {
   // [self dismissViewControllerAnimated:YES completion:nil];
    
//    if(!self.nameText.text || self.passedText.text.length != 6) {
//        [MBProgressHUD showError:@"用户名或者密码格式不正确，密码要求六位"];
//        return;
//    }
    [RequestUtil userLogin:self.nameText.text passwd:self.passedText.text block:^(bool flag) {
        if(flag){
            [RequestUtil getUserinfo:self.nameText.text block:^(NSDictionary *dict) {
                UserUtil *item = [[UserUtil alloc]initWithDict:dict];
                [RequestUtil setCurrentUser:item];
                logoFlag = YES;
                NSString *sr = [RequestUtil getUserName];
                NSString *st = self.nameText.text;
                if(![[RequestUtil getUserName] isEqualToString:self.nameText.text]) {
                    [[SqlRequestUtil shareInstance]deleteAllTableData];
                }
                [[NSNotificationCenter defaultCenter]postNotification:[NSNotification notificationWithName:USER_LOGIN_SUCCESS object:nil]];
                [self dismissViewControllerAnimated:YES completion:^{
                    [RequestUtil setUserName:self.nameText.text];
                    BOOL flag = [[[NSUserDefaults standardUserDefaults]objectForKey:@"rememberPassWd"]boolValue];
                    if(flag) {
                        [[NSUserDefaults standardUserDefaults]setObject:self.passedText.text forKey:@"passwd"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [[SliderViewController sharedSliderController] showContentControllerWithModel:@"HomeViewController"];
                }];
            }];
        } 
    }];
}
- (IBAction)registerAcount:(UIButton *)sender {
    RegisterViewController *RegisterVC = [[RegisterViewController alloc]initWithNibName:@"RegisterViewController" bundle:nil];
    [self presentViewController:RegisterVC animated:YES completion:nil];
}
+ (BOOL)hasLogin {
    return logoFlag;
}

- (void)keboardShow{
    CGRect frame = self.view.frame;
    frame.origin.y -=  100;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:0.2];
    self.view.frame = frame;
    [UIView commitAnimations];
}
- (IBAction)backToMain:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)keboardHide{
    CGRect frame = self.view.frame;
    frame.origin.y +=  100;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:0.2];
    self.view.frame = frame;
    [UIView commitAnimations];
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [self keboardHide];
    BOOL flag = [[[NSUserDefaults standardUserDefaults]objectForKey:@"rememberPassWd"]boolValue];
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self keboardShow];
    return YES;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.nameText resignFirstResponder];
    [self.passedText resignFirstResponder];
}
@end
