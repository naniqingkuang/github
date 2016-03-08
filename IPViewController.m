//
//  IPViewController.m
//  MotionMeasurement
//
//  Created by zhuzhu on 16/3/3.
//  Copyright © 2016年 @猪猪. All rights reserved.
//

#import "IPViewController.h"
#import "SliderViewController.h"
#import "Reachability.h"
#import "MBProgressHUD+Util.h"
@interface IPViewController ()
@property (weak, nonatomic) IBOutlet UITextField *portText;
@property (weak, nonatomic) IBOutlet UITextField *IPText;

@end

@implementation IPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)confirmButtonAction:(id)sender {
    if(!(self.IPText.text && self.IPText.text.length >0)){
        [MBProgressHUD showError:@"请输入正确的IP地址"];
    }
    if(self.portText.text.length >0){
        NSString *Url = [NSString stringWithFormat:@"http://%@:%@",self.IPText.text,self.portText.text];
        [[NSUserDefaults standardUserDefaults]setObject:Url forKey:@"IPText"];

    } else {
        [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"http://%@",self.IPText.text] forKey:@"IPText"];
    }
    //    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reachNotificationAction:) name:kReachabilityChangedNotification object:nil];
    //    [reach startNotifier];
    [[SliderViewController sharedSliderController] showContentControllerWithModel:@"HomeViewController"];
}
- (IBAction)backwordAction:(id)sender {
    [[SliderViewController sharedSliderController] showContentControllerWithModel:@"HomeViewController"];
}
- (IBAction)clearUp:(id)sender {
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"IPText"];

}
//- (void)reachNotificationAction:(NSNotification *)note {
//    Reachability *reach = note.object;
//    if(reach.reachabilityForLocalWiFi)
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
