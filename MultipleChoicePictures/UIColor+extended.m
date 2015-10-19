//
//  UIColor+extended.m
//  shareCar
//
//  Created by 独孤剑道(张洋) on 15-6-22.
//  Copyright (c) 2015年 duonuo. All rights reserved.
//

#import "UIColor+extended.h"

@implementation UIColor (extended)
+ (UIColor *)hexChangeFloat:(NSString *)hexColor
{
    if ([hexColor length]<6)
        return nil;
    
    unsigned int red_, green_, blue_;
    NSRange exceptionRange;
    exceptionRange.length = 2;
    
    //red
    exceptionRange.location = 0;
    [[NSScanner scannerWithString:[hexColor substringWithRange:exceptionRange]]scanHexInt:&red_];
    
    //green
    exceptionRange.location = 2;
    [[NSScanner scannerWithString:[hexColor substringWithRange:exceptionRange]]scanHexInt:&green_];
    
    //blue
    exceptionRange.location = 4;
    [[NSScanner scannerWithString:[hexColor substringWithRange:exceptionRange]]scanHexInt:&blue_];
    
    UIColor *resultColor = [UIColor colorWithRed:(CGFloat)red_/255. green:(CGFloat)green_/255. blue:(CGFloat)blue_/255. alpha:1.0];
    return resultColor;
}
@end
