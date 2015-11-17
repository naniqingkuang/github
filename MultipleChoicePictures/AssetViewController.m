
//
//  AECAbstractViewController.m
//  AndEducationClient
//
//  Created by 独孤剑道(张洋) on 15/4/10.
//  Copyright (c) 2015年 zhyang. All rights reserved.
//

#import <objc/runtime.h>
#import "AssetViewController.h"

static char keyButtonActionBlock;

@interface AssetViewController ()

@end

@implementation AssetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - 导航栏－左边按钮
// 导航栏按钮－文字
- (UIBarButtonItem *)aecBarButtonItemLeftWithTitle:(NSString *)Title withColor:(UIColor *)color withActionBlock:(void(^)(void))actionBlock
{
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:Title
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(aecBarButtonItemAction:)];
    barButtonItem.tintColor = color;
    objc_setAssociatedObject(barButtonItem, &keyButtonActionBlock, actionBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    self.navigationItem.leftBarButtonItem = barButtonItem;
    
    return barButtonItem;
}

// 导航栏按钮－图片
- (UIBarButtonItem *)aecBarButtonItemLeftWithImage:(UIImage *)image withColor:(UIColor *)color withActionBlock:(void(^)(void))actionBlock
{
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithImage:image
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(aecBarButtonItemAction:)];
    barButtonItem.tintColor = color;
    objc_setAssociatedObject(barButtonItem, &keyButtonActionBlock, actionBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    self.navigationItem.leftBarButtonItem = barButtonItem;
    
    return barButtonItem;
}

#pragma mark - 导航栏－右边按钮
// 导航栏按钮－文字
- (UIBarButtonItem *)aecBarButtonItemRightWithTitle:(NSString *)Title withColor:(UIColor *)color withActionBlock:(void (^)(void))actionBlock
{
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:Title
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(aecBarButtonItemAction:)];
    barButtonItem.tintColor = color;
    objc_setAssociatedObject(barButtonItem, &keyButtonActionBlock, actionBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    self.navigationItem.rightBarButtonItem = barButtonItem;
    
    return barButtonItem;
}
- (UIBarButtonItem *)aecBarButtonItemReplaceRightWithTitle:(NSString *)Title withColor:(UIColor *)color withActionBlock:(void (^)(void))actionBlock
{
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:Title
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(aecBarButtonItemAction:)];
    barButtonItem.tintColor = color;
    objc_removeAssociatedObjects(barButtonItem);
    objc_setAssociatedObject(barButtonItem, &keyButtonActionBlock, actionBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    self.navigationItem.rightBarButtonItem = barButtonItem;
    
    return barButtonItem;
}

// 导航栏按钮－图片
- (UIBarButtonItem *)aecBarButtonItemRightWithImage:(UIImage *)image withColor:(UIColor *)color withActionBlock:(void (^)(void))actionBlock
{
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithImage:image
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(aecBarButtonItemAction:)];
    barButtonItem.tintColor = color;
    objc_setAssociatedObject(barButtonItem, &keyButtonActionBlock, actionBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    self.navigationItem.rightBarButtonItem = barButtonItem;
    
    return barButtonItem;
}

#pragma mark - 导航栏按钮－响应事件
- (void)aecBarButtonItemAction:(id)sender
{
    void(^actionBlock)(void) = objc_getAssociatedObject(sender, &keyButtonActionBlock);
    actionBlock();
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
