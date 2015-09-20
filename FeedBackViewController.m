//
//  FeedBackViewController.m
//  MotionMeasurement
//
//  Created by 猪猪 on 15/9/10.
//  Copyright © 2015年 @猪猪. All rights reserved.
//

#import "FeedBackViewController.h"
#import "RequestUtil.h"
#import "UserUtil.h"
@interface FeedBackViewController ()
@property (strong, nonatomic) IBOutlet UITextView *contentTExtView;
@property (strong, nonatomic) IBOutlet UIButton *button1;
@property (strong, nonatomic) IBOutlet UIButton *button2;
@property (strong, nonatomic) IBOutlet UIButton *button3;
@property (strong, nonatomic) NSString *fdType;
@end

@implementation FeedBackViewController
- (IBAction)feedBackComit:(id)sender {
    UserUtil *item = [RequestUtil getCurrentUser];
    [RequestUtil uploadFeedBack:item.userName32 device:item.deviceID18 content:self.contentTExtView.text type:self.fdType block:^{
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fdType = @"1";
    self.button1.backgroundColor = [UIColor grayColor];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)backButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)selectType:(id)sender {
    self.button1.backgroundColor = [UIColor clearColor];
    self.button2.backgroundColor = [UIColor clearColor];
    self.button3.backgroundColor = [UIColor clearColor];
    UIButton *button = sender;
    button.backgroundColor = [UIColor grayColor];
    if(button == self.button1) {
        self.fdType = @"1";
    } else if(button == self.button2) {
        self.fdType = @"2";
    } else if(button == self.button3) {
        self.fdType = @"3";
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

@end
