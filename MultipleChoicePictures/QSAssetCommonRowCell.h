//
//  QSAssetCommonRowCell.h
//  QuicklyShop
//
//  Created by 独孤剑道(张洋) on 15-6-22.
//  Copyright (c) 2015年 com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define ASSET_X_SPACE        10.
#define ASSET_Y_SPACE        5.
#define ASSET_WIDTH          95.
#define ASSET_HEIGT          ASSET_WIDTH
#define ASSET_X_OUTER_SPACE  7.5

@class QSAssetCommonRowCell;
typedef void (^takePhotoBlock) ();
typedef void (^selectionAssetBlock) (ALAsset *,BOOL , QSAssetCommonRowCell *,UIImageView *);

@interface QSAssetCommonRowCell : UITableViewCell

@property (nonatomic, copy) takePhotoBlock takePhotoBlock;
@property (nonatomic, copy) selectionAssetBlock selectionAssetBlock;
@property (nonatomic, strong) NSArray *assetsArr;                     //当前cell显示assets数组
@property (nonatomic, assign) BOOL isOnlyOneSelectable;               //是不是只能选择一张图片
@property (nonatomic, strong) NSMutableArray *hasSelectionArr;        //相册库选择的assets数组
@property (nonatomic, assign) NSUInteger numberOfCouldSelection;      //相册哭能选择的最大的相片数量
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer; //摄像头取景Layer

- (void)actionReloadTextValueWithIndex:(NSUInteger)index;
- (void)actionReloadSelectionStateWithIndex:(NSUInteger)index isSelection:(BOOL)isSelected;
@end
