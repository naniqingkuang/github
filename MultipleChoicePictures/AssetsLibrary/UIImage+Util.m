//
//  UIImage+Util.m
//  FlowWallet
//
//  Created by YangQin on 15-1-12.
//  Copyright (c) 2015年 YangQin. All rights reserved.
//

#import "UIImage+Util.h"

@implementation UIImage (Util)

- (UIImage *)scaleToSize:(CGSize)size
{

    //by haijian 等比例缩放到640*640以内
    float orignAspectRatio=self.size.width/self.size.height;
    float scaleAspectRatio=size.width/size.height;
    float w=self.size.width,h=self.size.height;
    
    if (orignAspectRatio>=scaleAspectRatio && w>size.width) {
        w=size.width;
        h=w*self.size.height/self.size.width;
    }
    if(orignAspectRatio<scaleAspectRatio && h>size.height)
    {
        h=size.height;
        w=h*self.size.width/self.size.height;
    }
    UIGraphicsBeginImageContext(CGSizeMake(w,h));
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [self drawInRect:CGRectMake(0,0,w,h)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    //返回新的改变大小后的图片
        CGSize newsize=newImage.size;
    return newImage;
}

@end
