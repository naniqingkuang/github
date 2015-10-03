//
//  MBProgressHUD+Util.m
//  AndEducationClient
//
//  Created by ray on 15/8/21.
//  Copyright (c) 2015年 zhyang. All rights reserved.
//

#import "MBProgressHUD+Util.h"

@implementation MBProgressHUD (Util)
#pragma mark 显示信息
+ (void)show:(NSString *)text view:(UIView *)view
{
    if(!text || [text isEqualToString:@""]) return;
    [MBProgressHUD hideHUD];
    if (view == nil) view = [self findShowWindow];
    // 快速显示一个提示信息
    __block MBProgressHUD *hud = nil;
    if([NSThread isMainThread]){
        hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    }else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        });
    }
    hud.detailsLabelText = text;
    hud.detailsLabelFont=[UIFont systemFontOfSize:14.];

    
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    // 1秒之后再消失
    [hud hide:YES afterDelay:1];
}

#pragma mark 显示错误信息
+ (void)showError:(NSString *)error toView:(UIView *)view{
    [self show:error  view:view];
}

+ (void)showSuccess:(NSString *)success toView:(UIView *)view
{
    [self show:success view:view];
}

#pragma mark 显示一些信息
+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view {
    [MBProgressHUD hideHUD];
    if (view == nil) view = [self findShowWindow];
    // 快速显示一个提示信息
    __block MBProgressHUD *hud = nil;
    if ([NSThread isMainThread]) {
        hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    }else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        });
    }
    hud.detailsLabelText = message;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // YES代表需要蒙版效果
    return hud;
}

+ (void)showSuccess:(NSString *)success
{
    [self showSuccess:success toView:nil];
}

+ (void)showError:(NSString *)error
{
    [self showError:error toView:nil];
}

+ (MBProgressHUD *)showMessage:(NSString *)message
{
    return [self showMessage:message toView:nil];
}

+ (void)hideHUDForView:(UIView *)view
{
    if (view == nil) view = [self findShowWindow];
    if ([NSThread isMainThread]) {
        [self hideHUDForView:view animated:YES];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideHUDForView:view animated:YES];
        });
    }
}

+ (void)hideHUD
{
    [self hideHUDForView:nil];
}
+(UIView *)findShowWindow
{
    UIView *view = nil;
    NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
    for (UIWindow *window in frontToBackWindows){
        BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
        BOOL windowIsVisible = !window.hidden && window.alpha > 0;
        BOOL windowLevelNormal = window.windowLevel == UIWindowLevelNormal;
        
        if (windowOnMainScreen && windowIsVisible && windowLevelNormal) {
            view = window;
            break;
        }
    }
    return view;
}
@end
