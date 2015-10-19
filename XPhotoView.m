//
//  XPhotoView.m
//  MotionMeasurement
//
//  Created by 猪猪 on 15/10/16.
//  Copyright © 2015年 @猪猪. All rights reserved.
//

#import "XPhotoView.h"
#import "AECConfig.h"
#import "UIImage+Util.h"
#import "UIView+StringTag.h"
#pragma mark class xPhotoView
@implementation xPhotoView
#pragma mark 初始化
- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        self.minimumZoomScale = 1.;
        self.maximumZoomScale = 2.;
        self.multipleTouchEnabled = YES;
        self.delegate = self;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.bounces = YES;
        
        self.backgroundColor = COLOR_4;
        
        self.imgV = [[UIImageView alloc] init];
        self.imgV.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_imgV];
        
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        singleTap.numberOfTapsRequired = 1;
        
        [self addGestureRecognizer:singleTap];
        
        [singleTap requireGestureRecognizerToFail:doubleTap];
        
        self.assetSingleImageView= [[UIImageView alloc] initWithFrame:CGRectMake(9, 9, 26, 26)];
        self.assetSingleImageView.stringTag = kSelectionImageKey;
        self.indexNumLab = [[UILabel alloc] init];
        self.indexNumLab.frame = CGRectMake(10, 10, 24, 24);
        self.indexNumLab.stringTag = kSelectionLabKey;
        self.indexNumLab.textAlignment = NSTextAlignmentCenter;
        self.indexNumLab.textColor = [UIColor whiteColor];
        self.Indicator= [UIButton buttonWithType:UIButtonTypeCustom];
        self.Indicator.frame = CGRectMake((2*self.frame.size.width)-50, 20, 44, 44);
        self.Indicator.imageEdgeInsets = UIEdgeInsetsMake(9, 9, 9, 9);
        [self.Indicator addSubview:self.assetSingleImageView];
        [self.Indicator addSubview:self.indexNumLab];
    }
    return self;
}

#pragma mark datasource and delegate
#pragma mark UIScrollViewDelegate
- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _imgV.frame;
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
    }
    else{
        frameToCenter.origin.x = 0;
    }
    if(frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
    }
    else{
        frameToCenter.origin.y = 0;
    }
    if (!CGRectEqualToRect(_imgV.frame, frameToCenter)){
        _imgV.frame = frameToCenter;
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _imgV;
}
#pragma mark event response
- (void)doubleTap:(UITapGestureRecognizer *)tap{
    if(2. == self.zoomScale ){
        [self setZoomScale:1. animated:YES];
    }
    else{
        CGPoint point = [tap locationInView:self];
        [self zoomToRect:CGRectMake(point.x, point.y, 1, 1) animated:YES];
    }
}

- (void)singleTap:(id)sender
{
    [_superView setNavigationBarHidden:!_superView.navigationBar.hidden animated:NO];
    if(self.sigleTapReturn_block){
        self.sigleTapReturn_block();
    }
}

#pragma mark private methodes
- (CGRect)getImgVFrame:(UIImage *)img{
    CGRect rect;
    CGFloat width,height;
    if(img.size.width/img.size.height==MAX(img.size.width/img.size.height, self.frame.size.width/self.frame.size.height)){
        width = self.frame.size.width;
        height = width/img.size.width*img.size.height;
        rect = CGRectMake(0, (self.frame.size.height-height)*.5, width, height);
    } else{
        height = self.frame.size.height;
        width = img.size.width*height/img.size.height;
        rect = CGRectMake((self.frame.size.width-width)*.5, 0, width, height);
    }
    return rect;
}

- (void)setImg:(UIImage *)img{
    _img = img;
    if(img){
        _imgV.frame = [self getImgVFrame:img];
    }
    _imgV.image = _img;
    _imgV.contentMode = UIViewContentModeScaleToFill;
}

@end

