//
//  FeedBackDetialViewController.m
//  MotionMeasurement
//
//  Created by 猪猪 on 15/9/19.
//  Copyright © 2015年 @猪猪. All rights reserved.
//

#import "FeedBackDetialViewController.h"
#import "RequestUtil.h"
#import "UserUtil.h"

#define FD_TYPE_DICT @"1":@"疾病反馈",@"2":@"产品反馈",@"3":@"其它"
@interface FeedBackDetialViewController ()
@property (strong, nonatomic) IBOutlet UILabel *feedBackTypeLB;
@property (strong, nonatomic) IBOutlet UITextView *feedBackOontentTextView;
@property (strong, nonatomic) IBOutlet UITextView *answerTextView;
@end

@implementation FeedBackDetialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
       // Do any additional setup after loading the view from its nib.
    [self initData];
}
- (void)initData
{
    UserUtil *item = [RequestUtil getCurrentUser];
    [RequestUtil getFDAnswer:item.userName32 device:item.deviceID18 feedBackID:self.feedBackID block:^(NSDictionary * dict){
        NSString *type = dict[@"msgtype "];
        NSString *content = dict[@"textmsg"];
        NSString *answerContent = dict[@"rcontent"];
        NSDictionary *typeDict = @{FD_TYPE_DICT};
        dispatch_async(dispatch_get_main_queue(), ^{
            self.feedBackTypeLB.text = typeDict[type];
            self.feedBackOontentTextView.text = content;
            self.answerTextView.text = answerContent;

        });
    }];
}
- (IBAction)backButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
