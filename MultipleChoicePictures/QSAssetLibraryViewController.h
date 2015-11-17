//
//  QSAssetLibraryViewController.h
//  QuicklyShop
//
//  Created by 独孤剑道(张洋) on 15-6-22.
//  Copyright (c) 2015年 com. All rights reserved.
//

#import "AssetViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>

typedef void (^completeSelectAssetsBlock) (NSArray *);
typedef void (^singleSelectImageBlock) (UIImage *imageOfCropped);
@interface QSAssetLibraryViewController : AssetViewController

@property (nonatomic, assign) NSUInteger numberOfSelectingAssets;
@property (nonatomic, assign) NSUInteger numberOfCouldSelectAssets;
@property (nonatomic, assign) BOOL isOnlyOneSelectable;
@property (nonatomic, copy) completeSelectAssetsBlock selectAssetsBlock;
@property (nonatomic, copy) singleSelectImageBlock singleSelectImageBlock;
@end
