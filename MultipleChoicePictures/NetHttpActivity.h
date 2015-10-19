//
//  NetHttpActivity.h
//  frame
//
//  Created by 独孤剑道(张洋) on 15-6-22.
//  Copyright (c) 2015年 com. All rights reserved.
//

#import "MBProgressHUD.h"
#import <Foundation/Foundation.h>

@interface NetHttpActivity : NSObject

// singleton -activity
+ (MBProgressHUD *)shareActivity;
// get KeyWindow
+ (UIWindow *)getKeyWindow;

// singleton -alert
+ (void)showAlert:(NSString *)alert;
@end
