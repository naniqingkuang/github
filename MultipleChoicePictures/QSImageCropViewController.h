//
//  QSImageCropViewController.h
//  QuicklyShop
//
//  Created by 独孤剑道(张洋) on 15-6-22.
//  Copyright (c) 2015年 com. All rights reserved.
//

#import "AECAbstractViewController.h"

typedef void (^ImageCropCompletedBlock) (NSString *imagePathOfCropped, UIImage *thumbnailImage,UIImage *cropedImage);

@interface QSImageCropViewController : AECAbstractViewController
@property (nonatomic, copy) NSString *imageURL;
@property (nonatomic, assign) BOOL shouldNotAnimation;
@property (nonatomic, copy) ImageCropCompletedBlock cropCompletedBlock;

@end
