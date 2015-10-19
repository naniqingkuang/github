//
//  XPhotoView.h
//  MotionMeasurement
//
//  Created by 猪猪 on 15/10/16.
//  Copyright © 2015年 @猪猪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface xPhotoView: UIScrollView <UIScrollViewDelegate>
@property (nonatomic, strong) UIImage                 *img;
@property (nonatomic, strong) UIImageView             *imgV;
@property (nonatomic, weak)   UINavigationController  *superView;
@property (nonatomic, strong) UIImageView *assetSingleImageView;
@property (nonatomic, strong) UILabel *indexNumLab;
@property (nonatomic, strong) UIButton *Indicator;
@property (nonatomic, copy)  void(^sigleTapReturn_block)(void);
@end

