//
//  MBProgressHUD+Util.h
//  AndEducationClient
//
//  Created by ray on 15/8/21.
//  Copyright (c) 2015年 zhyang. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (Util)
+ (void)showSuccess:(NSString *)success toView:(UIView *)view;
+ (void)showError:(NSString *)error toView:(UIView *)view;

+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view;


+ (void)showSuccess:(NSString *)success;
+ (void)showError:(NSString *)error;

+ (MBProgressHUD *)showMessage:(NSString *)message;

+ (void)hideHUDForView:(UIView *)view;
+ (void)hideHUD;
@end
