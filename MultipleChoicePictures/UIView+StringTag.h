//
//  UIView+StringTag.h
//  AppAustriaX
//
//  Created by 独孤剑道(张洋) on 15-6-22.
//  Copyright (c) 2015年 Austria. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (StringTag)

@property (nonatomic, strong) NSString *stringTag;

- (UIView *)viewWithStringTag:(NSString *)tag;

- (UIView *)findFirstResponder;

@end