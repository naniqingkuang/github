//
//  mainView.h
//  testProject
//
//  Created by 猪猪 on 15/8/18.
//  Copyright (c) 2015年 @猪猪. All rights reserved.
//
//需求改了  .........   .....
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
@interface mainView : UIView
- (void)setPersentMaskOfCircle:(CGFloat)value;
- (void)setLineWidth:(float)bigCircleLineWidth AndOffset:(float)smallCircleLineWidth;
- (void)setUp;
- (void)setTitle:(NSString *)title andTarget:(NSString *)targetSum;
- (void)setCurrentSum:(NSString *)curSum;
- (void)aninationStart;
@end
