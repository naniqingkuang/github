//
//  LoginViewController.h
//  MotionMeasurement
//
//  Created by 猪猪 on 15/8/24.
//  Copyright (c) 2015年 @猪猪. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^Login_block) (void);
@interface LoginViewController : UIViewController
@property (copy , nonatomic)Login_block my_block;
@end
