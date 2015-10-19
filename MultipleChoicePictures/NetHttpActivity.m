//
//  NetHttpActivity.m
//  frame
//
//  Created by 独孤剑道(张洋) on 15-6-22.
//  Copyright (c) 2015年 com. All rights reserved.
//

#import "HUDCustomView.h"
#import "NetHttpActivity.h"

#define kMinShowTime  0.5
#define kBaseViewTag  100

static  MBProgressHUD *mbProgressHud = nil;
@implementation NetHttpActivity

#pragma mark - singleton -activity
+ (MBProgressHUD *)shareActivity
{
    // apply a onceToken
    static dispatch_once_t onceToken;
    // start dispatch_onect_t
    dispatch_once(&onceToken, ^{
      UIWindow *window = [NetHttpActivity getKeyWindow];
      mbProgressHud = [[MBProgressHUD alloc] initWithView:window];
      [mbProgressHud setUserInteractionEnabled:NO];
      [mbProgressHud setRemoveFromSuperViewOnHide:YES];
      [mbProgressHud setSquare:YES];
      [mbProgressHud setMinShowTime:kMinShowTime];
      [window addSubview:mbProgressHud];
    });
    [mbProgressHud setLabelText:@""];
    // set  mode MBProgressHUDModeCustomView
    [mbProgressHud setMode:MBProgressHUDModeCustomView];
    // get out window
    UIWindow *window = [NetHttpActivity getKeyWindow];
    [window addSubview:mbProgressHud];
    [window bringSubviewToFront:mbProgressHud];
    // clear UIComponents
    UIView *clearBaseView = (UIView *)[mbProgressHud viewWithTag:kBaseViewTag];
    if (clearBaseView)
        [clearBaseView removeFromSuperview];
    
    // init and set baseView
    UIView *baseView = [[UIView alloc] init];
    // set tag
    [baseView setTag:kBaseViewTag];
    // set background
    [baseView setBackgroundColor:[UIColor clearColor]];
    
    // init and set progressLab
    UILabel *progressLab = [[UILabel alloc] init];
    // set  property
    [progressLab setTextColor:[UIColor whiteColor]];
    [progressLab setBackgroundColor:[UIColor clearColor]];
    // set  fontSize
    [progressLab setFont:[UIFont systemFontOfSize:14.]];
    // set  text
    [progressLab setText:@"加载中..."];
    // set  sizeToFit
    [progressLab sizeToFit];
    // init and set progressHUD
    HUDCustomView *hudCustomView = [HUDCustomView circleWithSize:NSSpinningCircleSizeLarge color:[UIColor colorWithRed:50.0/255.0 green:155.0/255.0 blue:255.0/255.0 alpha:1.0]];
    // set is Animating YES
    [hudCustomView setIsAnimating:YES];
    // set Glow No
    [hudCustomView setHasGlow:NO];
    // set animation Speed
    [hudCustomView setSpeed:0.55];
    
    // set fix baseView
    [baseView setBounds:CGRectMake(0, 0, [hudCustomView frame].size.width, [hudCustomView frame].size.height + [progressLab frame].size.height - 5)];
    // set fix progressLab
    CGRect fixFrame = [progressLab frame];
    fixFrame.origin = CGPointMake(([hudCustomView frame].size.width - [progressLab frame].size.width)/2., [hudCustomView frame].size.height + 5);
    [progressLab setFrame:fixFrame];
    
    // add subView to superView
    [baseView addSubview:hudCustomView];
    [baseView addSubview:progressLab];
    
    // set CustomView
    [mbProgressHud setCustomView:baseView];
    
    return mbProgressHud;
}

#pragma mark -getKeyWindow
+ (UIWindow *)getKeyWindow
{
    return [[[UIApplication sharedApplication] delegate] window];
}

#pragma mark -
+ (void)showAlert:(NSString *)alert
{
    if (!mbProgressHud) {
        [NetHttpActivity shareActivity];
    }
    mbProgressHud.layer.zPosition = MAXFLOAT;
    
    // clear UIComponents
    UIView *clearBaseView = (UIView *)[mbProgressHud viewWithTag:kBaseViewTag];
    if (clearBaseView) {
        [clearBaseView removeFromSuperview];
    }
    
    // reset Mode
    [mbProgressHud setMode:MBProgressHUDModeText];
    // set   text
    // set property
    [mbProgressHud setSquare:YES];
    // add to window
    [[NetHttpActivity getKeyWindow] addSubview:mbProgressHud];
    // set alertString
    [mbProgressHud setLabelText:alert];
    // bring to Font
    [[NetHttpActivity getKeyWindow] bringSubviewToFront:mbProgressHud];
    // set Hide YES when removeFromSuperView
    [mbProgressHud setRemoveFromSuperViewOnHide:YES];
    // set HUDAnimationFade
    [mbProgressHud setAnimationType:MBProgressHUDAnimationFade];
    
    // show
    [mbProgressHud show:YES];
    // hide
    [mbProgressHud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:kMinShowTime];
}

@end
