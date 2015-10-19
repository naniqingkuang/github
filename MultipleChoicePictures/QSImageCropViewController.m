//
//  QSImageCropViewController.m
//  QuicklyShop
//
//  Created by 独孤剑道(张洋) on 15-6-22.
//  Copyright (c) 2015年 com. All rights reserved.
//

#import <ImageIO/ImageIO.h>
#import "QSImageCropViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIImageView+WebCache.h"
#import "AECConfig.h"
@interface UIImage (ImageCrop_Addition)
- (UIImage *)fixOrientationOfCropImage;
- (UIImage *)cropImageForRect:(CGRect)cropedRect;
@end

@implementation UIImage (ImageCrop_Addition)

- (UIImage *)fixOrientationOfCropImage {
    
    if (self.imageOrientation == UIImageOrientationUp) {
        return self;
    }
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    UIImageOrientation io = self.imageOrientation;
    if ( io == UIImageOrientationDown || io == UIImageOrientationDownMirrored) {
        transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
        transform = CGAffineTransformRotate(transform, M_PI);
    } else if ( io == UIImageOrientationLeft || io == UIImageOrientationLeftMirrored) {
        transform = CGAffineTransformTranslate(transform, self.size.width, 0);
        transform = CGAffineTransformRotate(transform, M_PI_2);
    } else if ( io == UIImageOrientationRight || io == UIImageOrientationRightMirrored) {
        transform = CGAffineTransformTranslate(transform, 0, self.size.height);
        transform = CGAffineTransformRotate(transform, -M_PI_2);
    }
    
    if ( io == UIImageOrientationUpMirrored || io == UIImageOrientationDownMirrored) {
        transform = CGAffineTransformTranslate(transform, self.size.width, 0);
        transform = CGAffineTransformScale(transform, -1, 1);
    } else if ( io == UIImageOrientationLeftMirrored || io == UIImageOrientationRightMirrored) {
        transform = CGAffineTransformTranslate(transform, self.size.height, 0);
        transform = CGAffineTransformScale(transform, -1, 1);
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    if ( io == UIImageOrientationLeft || io == UIImageOrientationLeftMirrored
        || io == UIImageOrientationRight || io == UIImageOrientationRightMirrored) {
        CGContextDrawImage(ctx, (CGRect){CGPointZero,self.size.height,self.size.width}, self.CGImage);
    } else {
        CGContextDrawImage(ctx, (CGRect){CGPointZero,self.size.width,self.size.height}, self.CGImage);
    }
    
    CGImageRef cgImage = CGBitmapContextCreateImage(ctx);
    UIImage *imageOfFixedOrientation = [UIImage imageWithCGImage:cgImage];
    CGContextRelease(ctx);
    CGImageRelease(cgImage);
    
    return imageOfFixedOrientation;
}

- (UIImage *)cropImageForRect:(CGRect)cropedRect {
    cropedRect.origin.x *= self.scale;
    cropedRect.origin.y *= self.scale;
    cropedRect.size.width *= self.scale;
    cropedRect.size.height *= self.scale;
    
    if (cropedRect.origin.x < 0) {
        cropedRect.origin.x = 0;
    }
    if (cropedRect.origin.y < 0) {
        cropedRect.origin.y = 0;
    }
    
    CGFloat cgWidth = CGImageGetWidth(self.CGImage);
    CGFloat cgHeight = CGImageGetHeight(self.CGImage);
    if (CGRectGetMaxX(cropedRect) > cgWidth) {
        cropedRect.size.width = cgWidth-cropedRect.origin.x;
    }
    if (CGRectGetMaxY(cropedRect) > cgHeight) {
        cropedRect.size.height = cgHeight-cropedRect.origin.y;
    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, cropedRect);
    UIImage *imageOfCroped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    imageOfCroped = [UIImage imageWithCGImage:imageOfCroped.CGImage scale:self.scale
                                  orientation:self.imageOrientation];
    
    return imageOfCroped;
}
@end

#define kDefaultRatioOfWidthAndHeight 1.

@interface QSImageCropViewController ()
<
UIScrollViewDelegate
>
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIView *topBlackView;
@property (nonatomic, strong) UIBarButtonItem *cropedButton;
@property (nonatomic, strong) UIImageView *imageViewCrop;
@property (nonatomic, strong) UIWindow *actionWindow;
@property (nonatomic, strong) UIView *bottomBlackView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) CGFloat ratioOfWidthAndHeight;
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@end

@implementation QSImageCropViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.ratioOfWidthAndHeight = kDefaultRatioOfWidthAndHeight;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    self.title = @"裁剪图片";
    
    __weak typeof(self) weakSelf = self;
    
    [self aecBarButtonItemLeftWithTitle:@"返回" withColor:COLOR_0 withActionBlock:^{
        
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    
    self.cropedButton = [self aecBarButtonItemRightWithTitle:@"选取" withColor:COLOR_0 withActionBlock:^{
        
        [weakSelf actionCropImage];
    }];
    
    [self.view addSubview:self.topBlackView = [self acquireBlackTransparentOverlayView]];
    [self.view addSubview:self.bottomBlackView = [self acquireBlackTransparentOverlayView]];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self adjustFrameSets];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -getter or setter
- (void)setImageURL:(NSString *)imageURL {
    _imageURL = imageURL;
    
    if ([_imageURL rangeOfString:@"http"].location != NSNotFound) {
        __weak typeof(self) weakSelf = self;
        _cropedButton.enabled = NO;
        
        [self.imageViewCrop sd_setImageWithURL:[NSURL URLWithString:[weakSelf operationImgURL:_imageURL withImgSize:self.imageViewCrop.bounds.size]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            if (!weakSelf)
            {
                return;
            }
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (image)
            {
                strongSelf.imageViewCrop.image = image;
                strongSelf.cropedButton.enabled = YES;
                [strongSelf adjustFrameSets];
            }
        }];
        
    } else {
        if ([self.imageURL  rangeOfString:@"asset"].location != NSNotFound) {
            [self.assetsLibrary assetForURL:[NSURL URLWithString:self.imageURL] resultBlock:^(ALAsset *asset) {
                if (asset) {
                    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                             (id)kCFBooleanTrue, kCGImageSourceCreateThumbnailWithTransform,
                                             (id)kCFBooleanTrue, kCGImageSourceCreateThumbnailFromImageAlways,
                                             (id)[NSNumber numberWithFloat:320.], kCGImageSourceThumbnailMaxPixelSize,
                                             nil];
                    self.imageViewCrop.image = [UIImage imageWithCGImage:[[asset defaultRepresentation] CGImageWithOptions:options]];
                    [self adjustFrameSets];
                }
            } failureBlock:NULL];
        } else {
            NSString *pathOfImage = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",self.imageURL]];
            self.imageViewCrop.image = [UIImage imageWithContentsOfFile:pathOfImage];
            [self adjustFrameSets];
        }
    }
}

- (UIView *)overlayView {
    if (!_overlayView) {
        _overlayView = [[UIView alloc] init];
        _overlayView.userInteractionEnabled = NO;
        _overlayView.layer.borderWidth = 1.;
        _overlayView.layer.borderColor = [UIColor whiteColor].CGColor;
        [self.view addSubview:_overlayView];
    }
    return _overlayView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.exclusiveTouch = YES;
        _scrollView.delegate = self;
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}

- (UIImageView *)imageViewCrop {
    if (!_imageViewCrop) {
        _imageViewCrop = [[UIImageView alloc] init];
        _imageViewCrop.contentMode = UIViewContentModeScaleAspectFit;
        _imageViewCrop.backgroundColor = [UIColor clearColor];
        [self.scrollView addSubview:_imageViewCrop];
    }
    return _imageViewCrop;
}

- (ALAssetsLibrary *)assetsLibrary {
    if (!_assetsLibrary) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
}

#pragma mark -adjustImageViewFramAndScrollViewContent
- (void)adjustImageViewFramAndScrollViewContent {
    CGRect frame = self.scrollView.frame;
    if (self.imageViewCrop.image) {
        CGSize imageSize = self.imageViewCrop.image.size;
        CGRect imageFrame = (CGRect){CGPointZero,imageSize};
        
        CGFloat ratio = 0.;
        if (frame.size.width <= frame.size.height) {
            ratio = frame.size.width/imageFrame.size.width;
            imageFrame.size.height = imageFrame.size.height*ratio;
            imageFrame.size.width = frame.size.width;
        } else {
            ratio = frame.size.height/imageFrame.size.height;
            imageFrame.size.width = imageFrame.size.width*ratio;
            imageFrame.size.height = frame.size.height;
        }
        self.scrollView.contentSize = frame.size;
        
        BOOL isBaseOnWidth = [self isBaseOnWidthOfOverlayView];
        self.imageViewCrop.frame = imageFrame;
        CGFloat ratioOfWidth = CGRectGetWidth(self.overlayView.frame)/CGRectGetWidth(imageFrame);
        CGFloat ratioOfHeight = CGRectGetHeight(self.overlayView.frame)/CGRectGetHeight(imageFrame);
        CGFloat maxRatio = ratioOfHeight < ratioOfWidth ? ratioOfWidth:ratioOfHeight;
        self.scrollView.minimumZoomScale = maxRatio;
        self.scrollView.maximumZoomScale = self.scrollView.minimumZoomScale*3 < 2. ? 2. : self.scrollView.minimumZoomScale*3;
        self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
        
        if (isBaseOnWidth) {
            self.scrollView.contentInset = UIEdgeInsetsMake(CGRectGetMinY(self.overlayView.frame), 0,
                                                            CGRectGetHeight(self.view.bounds)-CGRectGetMaxY(self.overlayView.frame), 0);
            
            CGFloat offsetY = CGRectGetHeight(self.scrollView.bounds) > self.scrollView.contentSize.height ?
            (CGRectGetHeight(self.scrollView.bounds) - self.scrollView.contentSize.height)*.5:0.;
            self.scrollView.contentOffset = CGPointMake(0., -offsetY);
            self.scrollView.zoomScale = CGRectGetHeight(self.view.bounds)/CGRectGetHeight(imageFrame);
        } else {
            self.scrollView.contentInset = UIEdgeInsetsMake(0, CGRectGetMinX(self.overlayView.frame),
                                                            0, CGRectGetWidth(self.view.bounds)-CGRectGetMaxX(self.overlayView.frame));
            CGFloat offsetX = CGRectGetWidth(self.scrollView.bounds) > self.scrollView.contentSize.width ?
            (CGRectGetWidth(self.scrollView.bounds) - self.scrollView.contentSize.width)*.5:0.;
            self.scrollView.contentOffset = CGPointMake(-offsetX, 0.);
            self.scrollView.zoomScale = CGRectGetWidth(self.view.bounds)/CGRectGetWidth(imageFrame);
        }
    } else {
        frame.origin = CGPointZero;
        self.imageViewCrop.frame = frame;
        self.scrollView.contentSize = self.imageViewCrop.frame.size;
        self.scrollView.minimumZoomScale = 1.;
        self.scrollView.maximumZoomScale = self.scrollView.minimumZoomScale;
        self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
    }
}

#pragma mark -adjustFrameSets
- (void)adjustFrameSets {
    [self adjustLayoutViewFrame];
    [self adjustImageViewFramAndScrollViewContent];
}

#pragma mark -adjustLayoutViewFrame
- (void)adjustLayoutViewFrame {
    [self.view sendSubviewToBack:self.scrollView];
    self.scrollView.minimumZoomScale = 1.;
    self.scrollView.maximumZoomScale = self.scrollView.minimumZoomScale;
    self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
    self.scrollView.frame = self.view.bounds;
    
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = width/self.ratioOfWidthAndHeight;
    BOOL isBaseOnWidth = YES;
    if (height > CGRectGetHeight(self.view.bounds)) {
        height = CGRectGetHeight(self.view.bounds);
        width = height*self.ratioOfWidthAndHeight;
        isBaseOnWidth = NO;
    }
    self.overlayView.frame = CGRectMake(0, 0, width, height);
    self.overlayView.center = CGPointMake(CGRectGetWidth(self.view.bounds)/2., CGRectGetHeight(self.view.bounds)/2.);
    if (isBaseOnWidth) {
        self.topBlackView.frame = CGRectMake(0, 0, width, CGRectGetMinY(self.overlayView.frame));
        self.bottomBlackView.frame = CGRectMake(0, CGRectGetMaxY(self.overlayView.frame), width,
                                                CGRectGetHeight(self.view.bounds)-CGRectGetMaxY(self.overlayView.frame));
    } else {
        self.topBlackView.frame = CGRectMake(0, 0, CGRectGetMinX(self.overlayView.frame), height);
        self.bottomBlackView.frame = CGRectMake(CGRectGetMaxX(self.overlayView.frame), 0,
                                                CGRectGetWidth(self.view.bounds)-CGRectGetMaxX(self.overlayView.frame), height);
    }
}

#pragma mark -isBaseOnWidthOfOverlayView
- (BOOL)isBaseOnWidthOfOverlayView {
    if (CGRectGetWidth(self.overlayView.frame) < CGRectGetWidth(self.view.bounds)) {
        return NO;
    }
    return YES;
}

#pragma mark -acquireBlackTransparentOverlayView
- (UIView *)acquireBlackTransparentOverlayView {
    UIView *overlayView = [[UIView alloc] init];
    overlayView.userInteractionEnabled = NO;
    overlayView.backgroundColor = [UIColor blackColor];
    overlayView.layer.opacity = 0.25;
    return overlayView;
}

#pragma mark -actionCropImage
- (void)actionCropImage {
    if (!self.imageViewCrop.image) {
        return;
    }
    if (self.scrollView.tracking || self.scrollView.dragging || self.scrollView.decelerating || self.scrollView.zoomBouncing || self.scrollView.zooming) {
        return;
    }
    
    CGPoint startPoint = [self.overlayView convertPoint:CGPointZero toView:self.imageViewCrop];
    CGPoint endPoint = [self.overlayView convertPoint:CGPointMake(CGRectGetMaxX(self.overlayView.bounds), CGRectGetMaxY(self.overlayView.bounds)) toView:self.imageViewCrop];
    
    CGFloat wRatio = self.imageViewCrop.image.size.width/(CGRectGetWidth(self.imageViewCrop.frame)/self.scrollView.zoomScale);
    CGFloat hRatio = self.imageViewCrop.image.size.height/(CGRectGetHeight(self.imageViewCrop.frame)/self.scrollView.zoomScale);
    CGRect cropRect = CGRectMake(startPoint.x*wRatio, startPoint.y*hRatio, (endPoint.x-startPoint.x)*wRatio, (endPoint.y-startPoint.y)*hRatio);
    UIImage *cropImage = [self.imageViewCrop.image cropImageForRect:cropRect];
    
    NSString *imageNameOfCroped;
    NSString *imagePathOfCroped;
    if ([self.imageURL rangeOfString:@"http"].location != NSNotFound) {
        imageNameOfCroped = [NSString stringWithFormat:@"%d",(int)[[NSDate date] timeIntervalSince1970]];
    } else {
        imageNameOfCroped = [NSString stringWithFormat:@"%@cropped",self.imageURL];
    }
    imagePathOfCroped = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",imageNameOfCroped]];
    [UIImagePNGRepresentation(cropImage) writeToFile:imagePathOfCroped atomically:YES];
    if (self.cropCompletedBlock) {
        UIImage *thumbnailImage = cropImage;
        if (cropImage.size.width > 95. && cropImage.size.height > 95.) {
            thumbnailImage = [self scaleDown:cropImage withSize:CGSizeMake(95, 95)];
        }
        self.cropCompletedBlock(imageNameOfCroped,thumbnailImage,cropImage);
    }
    [self.navigationController popViewControllerAnimated:!self.shouldNotAnimation];
}

#pragma mark -UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageViewCrop;
}

#pragma mark -operationImgURL
- (NSString *)operationImgURL:(NSString *)imageURL withImgSize:(CGSize)imageSize {
    imageURL = [imageURL stringByReplacingOccurrencesOfString:@"$w$" withString:[NSString stringWithFormat:@"%0.f",imageSize.width*2]];
    imageURL = [imageURL stringByReplacingOccurrencesOfString:@"$h$" withString:[NSString stringWithFormat:@"%0.f",imageSize.height*2]];
    imageURL = [imageURL stringByReplacingOccurrencesOfString:@"@" withString:@""];
    return imageURL;
}

- (UIImage*)scaleDown:(UIImage*)image withSize:(CGSize)newSize
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

@end
