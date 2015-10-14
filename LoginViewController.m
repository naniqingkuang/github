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
    self.loginButton.layer.cornerRadius = 12;
    NSString *str = [[NSUserDefaults standardUserDefaults]objectForKey:@"loginUser"];
    self.nameText.text = str;
    self.nameText.delegate = self;
    self.passedText.delegate = self;
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
                    [[NSUserDefaults standardUserDefaults] setObject:self.nameText.text forKey:@"loginUser"];
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
//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keboardShow:) name:UIKeyboardDidShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keboardHide:) name:UIKeyboardDidHideNotification object:nil];
//
//}
//- (void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
//    [[NSNotificationCenter defaultCenter]removeObserver:self forKeyPath:UIKeyboardDidHideNotification];
//    [[NSNotificationCenter defaultCenter]removeObserver:self forKeyPath:UIKeyboardDidShowNotification];
//
//}
//- (void)keboardShow:(NSNotification *)notification {
//    static double y = 0.0;
//    NSDictionary *userInfo = [notification userInfo];
//    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
//    CGRect keyboardRect = [aValue CGRectValue];
//    NSTimeInterval animationDurat = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey]doubleValue];
//    CGRect frame = self.view.frame;
//    if(y - keyboardRect.size.height > 0.1 || keyboardRect.size.height - y> 0.1){
//        frame.origin.y += y-100;
//        frame.origin.y -= keyboardRect.size.height -100;
//    }
//    y = keyboardRect.size.height;
//    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
//    [UIView setAnimationDuration:animationDurat];
//    self.view.frame = frame;
//    [UIView commitAnimations];
//}
//- (void)keboardHide:(NSNotification *)notification {
//    static double y = 0.0;
//    NSDictionary *userInfo = [notification userInfo];
//    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
//    CGRect keyboardRect = [aValue CGRectValue];
//    CGRect frame = self.view.frame;
//    if(y - keyboardRect.size.height > 0.1 || keyboardRect.size.height - y> 0.1){
//        frame.origin.y -= y -100;
//        frame.origin.y += keyboardRect.size.height -100;
//    }
//    y = keyboardRect.size.height;    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
//    NSTimeInterval animationDurat = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey]doubleValue];
//    [UIView setAnimationDuration:animationDurat];
//    self.view.frame = frame;
//    [UIView commitAnimations];
//}
- (void)keboardShow{
    CGRect frame = self.view.frame;
    frame.origin.y -=  100;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:0.2];
    self.view.frame = frame;
    [UIView commitAnimations];
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
