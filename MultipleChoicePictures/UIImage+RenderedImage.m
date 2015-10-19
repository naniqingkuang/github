//
//  UIImage+RenderedImage.m
//  QuicklyShop
//
//  Created by 独孤剑道(张洋) on 15-6-22.
//  Copyright (c) 2015年 com. All rights reserved.
//

#import "UIImage+RenderedImage.h"
#import <Accelerate/Accelerate.h>
@implementation UIImage (RenderedImage)
+ (UIImage *)screenShoot:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions([view bounds].size, YES, 1.);
    [[view layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *cropImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return cropImage;
}

+ (UIImage*)scaleDown:(UIImage*)image withSize:(CGSize)newSize
{
    
    //We prepare a bitmap with the new size
    UIGraphicsBeginImageContextWithOptions(newSize, YES, 0.0);
    
    //Draws a rect for the image
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    
    //We set the scaled image from the context
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}


+ (UIImage *)imageWithRenderColor:(UIColor *)color renderSize:(CGSize)size{
    
    UIImage *image = nil;
    UIGraphicsBeginImageContext(size);
    [color setFill];
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0., 0., size.width, size.height));
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)imageWithNewSize:(CGSize)size andResizeOption:(QSImageResizeOption)option{
    
    UIImage *image = nil;
    CGSize originSize = self.size;
    
    CGFloat minOriginSize = MIN(originSize.width, originSize.height);
    CGFloat maxOriginSize = MAX(originSize.width, originSize.height);
    CGFloat minNewSize = MIN(size.width, size.height);
    CGFloat maxNewSize = MAX(size.width, size.height);
    if (maxOriginSize < minNewSize) {
        
        image = self;
    }else{
        
        CGFloat scaleRate = 1.;
        if (option ==  QSImageResizeOptionFit) {
            scaleRate = minNewSize / maxOriginSize;
        }else{
            scaleRate = maxNewSize / minOriginSize;
        }
        CGSize drawSize = CGSizeMake(originSize.width * scaleRate, originSize.height * scaleRate);
        CGFloat startX = (option == QSImageResizeOptionFit) ? (size.width * 0.5 - drawSize.width * 0.5) : 0.;
        CGPoint drawPoint = drawPoint = CGPointMake(startX, size.height * 0.5 - drawSize.height * 0.5);

        UIGraphicsBeginImageContextWithOptions(size, NO, 0.);
        [self drawInRect:CGRectMake(drawPoint.x, drawPoint.y, drawSize.width, drawSize.height)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return image;
}

@end
