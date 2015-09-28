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
#define screenHeight  ([UIScreen mainScreen].bounds.size.height)
static BOOL logoFlag;
@interface LoginViewController ()
@property (strong, nonatomic) IBOutlet UITextField *nameText;
@property (strong, nonatomic) IBOutlet UITextField *passedText;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIImageView *logoImageView;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.logoImageView.layer.cornerRadius = 10;
    self.logoImageView.layer.masksToBounds = YES;
    self.loginButton.layer.cornerRadius = 8;
    self.loginButton.layer.masksToBounds = YES;
    logoFlag = NO;
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
   // [self dismissViewControllerAnimated:YES completion:nil];
    
    if(!self.nameText.text || self.passedText.text.length != 6) {
        [MBProgressHUD showError:@"用户名或者密码格式不正确，密码要去六位"];
        return;
    }
    [RequestUtil userLogin:self.nameText.text passwd:self.passedText.text block:^(bool flag) {
        if(flag){
            [RequestUtil setUserName:self.nameText.text];
            [RequestUtil getUserinfo:self.nameText.text block:^(NSDictionary *dict) {
                UserUtil *item = [[UserUtil alloc]initWithDict:dict];
                [RequestUtil setCurrentUser:item];
                logoFlag = YES;
                [self dismissViewControllerAnimated:YES completion:^{
                    [[SliderViewController sharedSliderController] showContentControllerWithModel:@"HomeViewController"];
                }];
            }];
        }
    }];
    
//        if([item.userName32 isEqualToString:self.nameText.text] && [item.password32 isEqualToString:self.passedText.text])
//        {
//            [self dismissViewControllerAnimated:YES completion:nil];
//        }
//        else
//        {
//            [MBProgressHUD showError:@"用户名或者密码不正确"];
//        }
}
- (IBAction)registerAcount:(UIButton *)sender {
    RegisterViewController *RegisterVC = [[RegisterViewController alloc]initWithNibName:@"RegisterViewController" bundle:nil];
    [self presentViewController:RegisterVC animated:YES completion:nil];
}
+ (BOOL)hasLogin {
    return logoFlag;
}
//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keboardShow:) name:UIKeyboardDidShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keboardShow:) name:UIKeyboardDidHideNotification object:nil];
//
//}
//- (void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
//    [[NSNotificationCenter defaultCenter]removeObserver:self forKeyPath:UIKeyboardDidHideNotification];
//    [[NSNotificationCenter defaultCenter]removeObserver:self forKeyPath:UIKeyboardDidShowNotification];
//
//}
//- (void)keboardShow:(NSNotification *)notification {
//    CGRect keyBRect = [[[notification userInfo]objectForKey:UIKeyboardBoundsUserInfoKey]CGRectValue];
//    NSTimeInterval animationDurat = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey]doubleValue];
//    CGRect frame = self.view.frame;
//    frame.size.height -= (frame.size.height - keyBRect.size.height);
//    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
//    [UIView setAnimationDuration:animationDurat];
//    self.view.frame = frame;
//    [UIView commitAnimations];
//}
//- (void)keboardHide:(NSNotification *)notification {
//    CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardBoundsUserInfoKey] CGRectValue];
//    NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
//    CGRect frame = self.view.frame;
//    frame.size.height +=  (frame.size.height - keyboardRect.size.height);
//    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
//    [UIView setAnimationDuration:animationDuration];
//    self.view.frame = frame;
//    [UIView commitAnimations];
//}
@end
