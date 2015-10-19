//
//  AECAbstractViewController.h
//  AndEducationClient
//
//  Created by 独孤剑道(张洋) on 15/4/10.
//  Copyright (c) 2015年 zhyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AECAbstractViewController : UIViewController

#pragma mark - 导航栏－左边按钮
// 导航栏按钮－文字
- (UIBarButtonItem *)aecBarButtonItemLeftWithTitle:(NSString *)Title withColor:(UIColor *)color withActionBlock:(void(^)(void))actionBlock;
// 导航栏按钮－图片
- (UIBarButtonItem *)aecBarButtonItemLeftWithImage:(UIImage *)image withColor:(UIColor *)color withActionBlock:(void(^)(void))actionBlock;
- (UIBarButtonItem *)aecBarButtonItemReplaceRightWithTitle:(NSString *)Title withColor:(UIColor *)color withActionBlock:(void (^)(void))actionBlock;

#pragma mark - 导航栏－右边按钮
// 导航栏按钮－文字
- (UIBarButtonItem *)aecBarButtonItemRightWithTitle:(NSString *)Title withColor:(UIColor *)color withActionBlock:(void (^)(void))actionBlock;
// 导航栏按钮－图片
- (UIBarButtonItem *)aecBarButtonItemRightWithImage:(UIImage *)image withColor:(UIColor *)color withActionBlock:(void (^)(void))actionBlock;

@end
