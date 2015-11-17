//
//  QSAssetLibraSelectPhotoViewController.h
//  AndEducationClient
//
//  Created by 独孤剑道(张洋) on 15/8/26.
//  Copyright (c) 2015年 zhyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QSAssetCommonRowCell.h"
#import "AssetViewController.h"

typedef void(^finishSelectPhotoPathsBlock)(NSMutableArray* selectArray);

@interface QSAssetLibraSelectPhotoViewController : AssetViewController

@property(nonatomic,strong) NSMutableArray *photoPaths;
@property(nonatomic,assign) NSInteger index;
@property(nonatomic,strong) NSArray * selectedAssetsArr;
@property(nonatomic,strong)QSAssetCommonRowCell *currentCell;
/// can edit - Default is no
@property(assign, nonatomic, getter = isCanEdit) BOOL canEdit;
@property (nonatomic, strong) finishSelectPhotoPathsBlock finishSelectBlock;
@property (nonatomic, assign) BOOL isOnlyOneSelectable;

@property (nonatomic, assign) NSUInteger numberOfSelectingAssets;
@property (nonatomic, assign) NSUInteger numberOfCouldSelectAssets;

@end