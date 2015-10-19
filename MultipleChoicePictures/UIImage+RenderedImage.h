//
//  UIImage+RenderedImage.h
//  QuicklyShop
//
//  Created by 独孤剑道(张洋) on 15-6-22.
//  Copyright (c) 2015年 com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, QSImageResizeOption){
    QSImageResizeOptionFill,
    QSImageResizeOptionFit,
};

@interface UIImage (RenderedImage)

+ (UIImage *)screenShoot:(UIView *)view;
+ (UIImage*)scaleDown:(UIImage*)image withSize:(CGSize)newSize;

+ (UIImage *)imageWithRenderColor:(UIColor *)color renderSize:(CGSize)size;
- (UIImage *)imageWithNewSize:(CGSize)size andResizeOption:(QSImageResizeOption)option;

@end
