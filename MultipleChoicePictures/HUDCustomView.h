//
//  HUDCustomView.h
//  EGOTestSerialsOne
//
//  Created by 独孤剑道(张洋) on 15-6-22.
//  Copyright (c) 2015年 com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    NSSpinningCircleSizeDefault,
    NSSpinningCircleSizeLarge,
    NSSpinningCircleSizeSmall
}NSSpinningCircleSize;

@interface HUDCustomView : UIView


@property (nonatomic, assign) BOOL                 isAnimating;
@property (nonatomic, assign) BOOL                 hasGlow;
@property (nonatomic, strong) UIColor              *color;
@property (nonatomic, assign) float                speed;
@property (nonatomic, assign) NSSpinningCircleSize circleSize;

+ (HUDCustomView *)circleWithSize:(NSSpinningCircleSize)size color:(UIColor *)color;
@end
