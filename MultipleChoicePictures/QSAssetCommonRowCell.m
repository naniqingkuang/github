//
//  QSAssetCommonRowCell.m
//  QuicklyShop
//
//  Created by 独孤剑道(张洋) on 15-6-22.
//  Copyright (c) 2015年 com. All rights reserved.
//

#import <objc/runtime.h>
#import "QSAssetCommonRowCell.h"
#import "NetHttpActivity.h"
#import "UIColor+extended.h"
#import "AssetConfig.h"
@interface QSAssetCommonRowCell () {
    UIImageView *assetOneImageView;
    UIImageView *assetTwoImageView;
    UIImageView *assetThrImageView;
    UIImageView *assetMaskOneImageView;
    UIImageView *assetMaskTwoImageView;
    UIImageView *assetMaskThrImageView;
    UIImageView *assetSingleOneImageView;
    UIImageView *assetSingleTwoImageView;
    UIImageView *assetSingleThrImageView;
    UILabel *assetMultiOneLab;
    UILabel *assetMultiTwoLab;
    UILabel *assetMultiThrLab;
    //BOOL hasLoadedThumbnail;
}
@end

static char * assetHasLoaded;
@implementation QSAssetCommonRowCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        assetOneImageView = [[UIImageView alloc] init];
        assetOneImageView.frame = CGRectMake(ASSET_X_OUTER_SPACE, ASSET_Y_SPACE, ASSET_WIDTH, ASSET_HEIGT);
        [self addSubview:assetOneImageView];
        assetMaskOneImageView = [[UIImageView alloc] initWithFrame:assetOneImageView.bounds];
        assetMaskOneImageView.image = [UIImage imageNamed:@"photoMaskNormal"];
        [assetOneImageView addSubview:assetMaskOneImageView];
        assetSingleOneImageView = [[UIImageView alloc] initWithFrame:CGRectMake(59.5, 9.5, 26, 26)];
        [assetMaskOneImageView addSubview:assetSingleOneImageView];
        assetMultiOneLab = [[UILabel alloc] initWithFrame:CGRectMake(60.5, 10.5, 24, 24)];
        [self setLabelProperty:assetMultiOneLab font:16 titleColor:@"FFFFFF"];
        assetMultiOneLab.textAlignment = NSTextAlignmentCenter;
        [assetMaskOneImageView addSubview:assetMultiOneLab];
        
        assetTwoImageView = [[UIImageView alloc] init];
        assetTwoImageView.frame = CGRectMake(ASSET_X_OUTER_SPACE+ASSET_X_SPACE+ASSET_WIDTH, ASSET_Y_SPACE, ASSET_WIDTH, ASSET_HEIGT);
        [self addSubview:assetTwoImageView];
        assetMaskTwoImageView = [[UIImageView alloc] initWithFrame:assetTwoImageView.bounds];
        assetMaskTwoImageView.image = [UIImage imageNamed:@"photoMaskNormal"];
        [assetTwoImageView addSubview:assetMaskTwoImageView];
        assetSingleTwoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(59.5, 9.5, 26, 26)];
        [assetMaskTwoImageView addSubview:assetSingleTwoImageView];
        assetMultiTwoLab = [[UILabel alloc] initWithFrame:CGRectMake(60.5, 10.5, 24, 24)];
        [self setLabelProperty:assetMultiTwoLab font:16 titleColor:@"FFFFFF"];
        assetMultiTwoLab.textAlignment = NSTextAlignmentCenter;
        [assetMaskTwoImageView addSubview:assetMultiTwoLab];
        
        
        assetThrImageView = [[UIImageView alloc] init];
        assetThrImageView.frame = CGRectMake(ASSET_X_OUTER_SPACE+(ASSET_X_SPACE+ASSET_WIDTH)*2, ASSET_Y_SPACE, ASSET_WIDTH, ASSET_HEIGT);
        [self addSubview:assetThrImageView];
        assetMaskThrImageView = [[UIImageView alloc] initWithFrame:assetThrImageView.bounds];
        assetMaskThrImageView.image = [UIImage imageNamed:@"photoMaskNormal"];
        [assetThrImageView addSubview:assetMaskThrImageView];
        assetSingleThrImageView = [[UIImageView alloc] initWithFrame:CGRectMake(59.5, 9.5, 26, 26)];
        [assetMaskThrImageView addSubview:assetSingleThrImageView];
        assetMultiThrLab = [[UILabel alloc] initWithFrame:CGRectMake(60.5, 10.5, 24, 24)];
        [self setLabelProperty:assetMultiThrLab font:16 titleColor:@"FFFFFF"];
        assetMultiThrLab.textAlignment = NSTextAlignmentCenter;
        [assetMaskThrImageView addSubview:assetMultiThrLab];
        
        assetOneImageView.layer.zPosition = MAXFLOAT;
        assetTwoImageView.layer.zPosition = MAXFLOAT;
        assetThrImageView.layer.zPosition = MAXFLOAT;
        
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)layoutSubviews{
    // animation code
    /*
    UITableView *superView;
    if (IS_IOS7_LATER) {
        superView = (UITableView *)self.superview.superview;
    } else {
        superView = (UITableView *)self.superview;
    }
    if (!superView.decelerating && !superView.dragging) {
        CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
        rotationAnimation.fromValue = [NSNumber numberWithFloat:0.];
        rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI_2];
        rotationAnimation.autoreverses = YES;
        rotationAnimation.removedOnCompletion = YES;
        
        [assetOneImageView.layer addAnimation:rotationAnimation forKey:@"assetOne"];
        [assetTwoImageView.layer addAnimation:rotationAnimation forKey:@"assetTwo"];
        [assetThrImageView.layer addAnimation:rotationAnimation forKey:@"assetThr"];
    }
    */
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark -override
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    UITableView *superView;
    if (IS_IOS7_LATER) {
        superView = (UITableView *)self.superview.superview;
    } else {
        superView = (UITableView *)self.superview;
    }
    if (superView.decelerating || superView.isDragging) {
        return ;
    }
    
    CGPoint locationPoint = [touches.anyObject locationInView:self];
    CGPoint original;
    CGSize size;
    ALAsset *operationAsset;
    UIImageView *maskImageView;
    UILabel *assetMultiLab;
    UIImageView *assetSingleImageView;
    BOOL showOriginalPicture;
    if (CGRectContainsPoint(assetOneImageView.frame, locationPoint)) {
        if (_assetsArr.count < 1) {
            [self actionShouldTakingPhoto:assetOneImageView];
            return ;
        }
        original = assetOneImageView.frame.origin;
        size = assetOneImageView.frame.size;
        operationAsset = [_assetsArr objectAtIndex:0];
        maskImageView = assetMaskOneImageView;
        assetMultiLab = assetMultiOneLab;
        assetSingleImageView = assetSingleOneImageView;
    } else if (CGRectContainsPoint(assetTwoImageView.frame, locationPoint)) {
        if (_assetsArr.count < 2) {
            [self actionShouldTakingPhoto:assetTwoImageView];
            return ;
        }
        original = assetTwoImageView.frame.origin;
        size = assetTwoImageView.frame.size;
        operationAsset = [_assetsArr objectAtIndex:1];
        maskImageView = assetMaskTwoImageView;
        assetMultiLab = assetMultiTwoLab;
        assetSingleImageView = assetSingleTwoImageView;
    } else if (CGRectContainsPoint(assetThrImageView.frame, locationPoint)) {
        if (_assetsArr.count < 3) {
            [self actionShouldTakingPhoto:assetThrImageView];
            return ;
        }
        original = assetThrImageView.frame.origin;
        size = assetThrImageView.frame.size;
        operationAsset = [_assetsArr objectAtIndex:2];
        maskImageView = assetMaskThrImageView;
        assetMultiLab = assetMultiThrLab;
        assetSingleImageView = assetSingleThrImageView;
    }

    if (_selectionAssetBlock&&operationAsset) {
        if (CGRectContainsPoint((CGRect){original,size.width,size.height/2},locationPoint)) {
            showOriginalPicture = NO;
            BOOL hasFoundSelectedAsset = NO;
            
            for (ALAsset * asset in _hasSelectionArr) {
                if ([[[asset valueForProperty:ALAssetPropertyAssetURL] description] isEqualToString:[[operationAsset valueForProperty:ALAssetPropertyAssetURL] description]]) {
                    hasFoundSelectedAsset = YES;
                    maskImageView.image = [UIImage imageNamed:@"photoMaskNormal"];
                    if (_isOnlyOneSelectable) {
                        assetSingleImageView.image = nil;
                    } else {
                        assetMultiLab.text = @"";
                    }
                    break;
                }
            }
            if (!hasFoundSelectedAsset) {
                if (!_isOnlyOneSelectable) {
                    if (_hasSelectionArr.count >= _numberOfCouldSelection) {
                        [NetHttpActivity showAlert:[NSString stringWithFormat:@"只能选择%lu张图片",(unsigned long)_numberOfCouldSelection]];
                        
                        return ;
                    }
                } else {
                    if (_hasSelectionArr.count == 1) {
                        return ;
                    }
                }
            }
            _selectionAssetBlock(operationAsset, showOriginalPicture,self,maskImageView);
            if (!hasFoundSelectedAsset) {
                if (!_isOnlyOneSelectable) {
                    maskImageView.image = [UIImage imageNamed:@"photoMaskHigh"];
                    assetMultiLab.text = [NSString stringWithFormat:@"%lu",(unsigned long)_hasSelectionArr.count];
                } else {
                    assetSingleImageView.image = [UIImage imageNamed:@"singleSelect"];
                }
            }
        } else {
            showOriginalPicture = YES;
            _selectionAssetBlock(operationAsset, showOriginalPicture,self,maskImageView);
        }
    }
}

#pragma mark -actionShouldTakingPhoto
- (void)actionShouldTakingPhoto:(UIImageView *)imageView{
    for (CALayer *subLayer in imageView.layer.sublayers) {
        if (subLayer == _captureVideoPreviewLayer) {
            if (_takePhotoBlock) {
                _takePhotoBlock();
            }
            break;
        }
    }
}

#pragma mark -getter or setter
- (void)setIsOnlyOneSelectable:(BOOL)isOnlyOneSelectable{
    _isOnlyOneSelectable = isOnlyOneSelectable;
}

- (void)setAssetsArr:(NSArray *)assetsArr{
    _assetsArr = assetsArr;
    assetOneImageView.image = nil;
    assetTwoImageView.image = nil;
    assetThrImageView.image = nil;
    
    for (CALayer *subLayer in assetOneImageView.layer.sublayers) {
        if ([subLayer isKindOfClass:[AVCaptureVideoPreviewLayer class]]) {
            [subLayer removeFromSuperlayer];
            break;
        }
    }
    for (CALayer *subLayer in assetTwoImageView.layer.sublayers) {
        if ([subLayer isKindOfClass:[AVCaptureVideoPreviewLayer class]]) {
            [subLayer removeFromSuperlayer];
            break;
        }
    }
    for (CALayer *subLayer in assetThrImageView.layer.sublayers) {
        if ([subLayer isKindOfClass:[AVCaptureVideoPreviewLayer class]]) {
            [subLayer removeFromSuperlayer];
            break;
        }
    }

    if (_assetsArr.count >= 1) {
        ALAsset *assetOne = (ALAsset *)[_assetsArr objectAtIndex:0];
        assetMaskOneImageView.image = [UIImage imageNamed:@"photoMaskNormal"];
        [self actionSetImageWithImageView:assetOneImageView asset:assetOne];
    } else {
        assetMaskOneImageView.image = nil;
    }
    if (_assetsArr.count >= 2) {
        ALAsset *assetTwo = (ALAsset *)[_assetsArr objectAtIndex:1];
        assetMaskTwoImageView.image = [UIImage imageNamed:@"photoMaskNormal"];
        [self actionSetImageWithImageView:assetTwoImageView asset:assetTwo];
    } else {
        assetMaskTwoImageView.image = nil;
    }
    
    if (_assetsArr.count == 3) {
        ALAsset *assetThr = (ALAsset *)[_assetsArr objectAtIndex:2];
        assetMaskThrImageView.image = [UIImage imageNamed:@"photoMaskNormal"];
        [self actionSetImageWithImageView:assetThrImageView asset:assetThr];
    } else {
        assetMaskThrImageView.image = nil;
    }
}

- (void)setHasSelectionArr:(NSMutableArray *)hasSelectionArr {
    _hasSelectionArr = hasSelectionArr;
    assetMultiOneLab.text = @"";
    assetMultiTwoLab.text = @"";
    assetMultiThrLab.text = @"";
    assetSingleOneImageView.image = nil;
    assetSingleTwoImageView.image = nil;
    assetSingleThrImageView.image = nil;
    
    for (ALAsset *selectedAsset in _hasSelectionArr) {
        for (ALAsset *asset in _assetsArr) {
            if ([[[selectedAsset valueForProperty:ALAssetPropertyAssetURL] description] isEqualToString:[[asset valueForProperty:ALAssetPropertyAssetURL] description]]) {
                NSUInteger indexOfAsset = [_assetsArr indexOfObject:asset];
                if (_isOnlyOneSelectable) {
                    if (indexOfAsset == 0) {
                        assetSingleOneImageView.image = [UIImage imageNamed:@"singleSelect"];
                    } else if (indexOfAsset == 1) {
                        assetSingleTwoImageView.image = [UIImage imageNamed:@"singleSelect"];
                    } else if (indexOfAsset == 2) {
                        assetSingleThrImageView.image = [UIImage imageNamed:@"singleSelect"];
                    }
                    return;
                    break;
                } else {
                    NSUInteger indexOfSelectedAsset = [_hasSelectionArr indexOfObject:selectedAsset]+1;
                    if (indexOfAsset == 0) {
                        assetMaskOneImageView.image = [UIImage imageNamed:@"photoMaskHigh"];
                        assetMultiOneLab.text = [NSString stringWithFormat:@"%lu",(unsigned long)indexOfSelectedAsset];
                    } else if (indexOfAsset == 1){
                        assetMaskTwoImageView.image = [UIImage imageNamed:@"photoMaskHigh"];
                        assetMultiTwoLab.text = [NSString stringWithFormat:@"%lu",(unsigned long)indexOfSelectedAsset];
                    } else if (indexOfAsset == 2) {
                        assetMaskThrImageView.image = [UIImage imageNamed:@"photoMaskHigh"];
                        assetMultiThrLab.text = [NSString stringWithFormat:@"%lu",(unsigned long)indexOfSelectedAsset];
                    }
                }
            }
        }
    }
}

- (void)setCaptureVideoPreviewLayer:(AVCaptureVideoPreviewLayer *)captureVideoPreviewLayer{
    _captureVideoPreviewLayer = captureVideoPreviewLayer;
    _captureVideoPreviewLayer.frame = assetOneImageView.bounds;
    
    if (_assetsArr.count == 0) {
        [assetOneImageView.layer addSublayer: _captureVideoPreviewLayer];
        assetMaskOneImageView.image = [UIImage imageNamed:@"takePhotoNormal"];
    } else if (_assetsArr.count == 1) {
        [assetTwoImageView.layer addSublayer:_captureVideoPreviewLayer];
        assetMaskTwoImageView.image = [UIImage imageNamed:@"takePhotoNormal"];
    } else if (_assetsArr.count == 2) {
        [assetThrImageView.layer addSublayer:_captureVideoPreviewLayer];
        assetMaskThrImageView.image = [UIImage imageNamed:@"takePhotoNormal"];
    }
}

#pragma mark -actionSetImageWithImageView
- (void)actionSetImageWithImageView:(UIImageView *)imageView asset:(ALAsset *)asset {
    if (asset != nil) {
        imageView.image = [UIImage imageWithCGImage:asset.thumbnail];
        BOOL assetOfHasLoaded =  [objc_getAssociatedObject(asset, assetHasLoaded) boolValue];
        if (!assetOfHasLoaded) {
            imageView.alpha = 0.;
            [UIView animateWithDuration:.5 animations:^{
                imageView.alpha = 1.;
                imageView.image = [UIImage imageWithCGImage:asset.thumbnail];
            } completion:^(BOOL finished) {
                if (finished) {
                    objc_setAssociatedObject(asset, assetHasLoaded, [NSNumber numberWithBool:YES], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                }
            }];
        }
    }
    //imageView.image = [UIImage imageWithCGImage:asset.thumbnail];
    /*
    if (!hasLoadedThumbnail) {
        imageView.alpha = 0.;
        [UIView transitionWithView:imageView duration:.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            imageView.alpha = 1.;
            imageView.image = [UIImage imageWithCGImage:asset.thumbnail];
        } completion:^(BOOL finished) {
            if (finished) {
                hasLoadedThumbnail = YES;
            }
        }];
    } else {
        imageView.image = [UIImage imageWithCGImage:[asset thumbnail]];
    }
    */
}

#pragma mark -actionReloadTextValueWithIndex
- (void)actionReloadTextValueWithIndex:(NSUInteger)index{
    ALAsset *asset = [_assetsArr objectAtIndex:index];
    for (ALAsset *selectionAsset in _hasSelectionArr) {
        if ([[[selectionAsset valueForProperty:ALAssetPropertyAssetURL] description] isEqualToString:[[asset valueForProperty:ALAssetPropertyAssetURL] description]]) {
            NSUInteger indexOfSelectionArr = [_hasSelectionArr indexOfObject:selectionAsset];
            if (index == 0) {
                assetMultiOneLab.text = [NSString stringWithFormat:@"%lu",indexOfSelectionArr+1];
            } else if (index == 1) {
                assetMultiTwoLab.text = [NSString stringWithFormat:@"%lu",indexOfSelectionArr+1];
            } else if (index == 2){
                assetMultiThrLab.text = [NSString stringWithFormat:@"%lu",indexOfSelectionArr+1];
            }
            break;
        }
    }
}

#pragma mark -actionReloadSelectionStateWithIndex
- (void)actionReloadSelectionStateWithIndex:(NSUInteger)index isSelection:(BOOL)isSelected{
    if (isSelected) {
        [self actionReloadTextValueWithIndex:index];
        if (index == 0) {
            if (_isOnlyOneSelectable) {
                assetMultiOneLab.text = @"";
                assetSingleOneImageView.image = [UIImage imageNamed:@"singleSelect"];
            } else {
                assetMaskOneImageView.image = [UIImage imageNamed:@"photoMaskHigh"];
            }
        } else if (index == 1) {
            if (_isOnlyOneSelectable) {
                assetMultiTwoLab.text = @"";
                assetSingleTwoImageView.image = [UIImage imageNamed:@"singleSelect"];
            } else {
                assetMaskTwoImageView.image = [UIImage imageNamed:@"photoMaskHigh"];
            }
        } else if (index == 2){
            if (_isOnlyOneSelectable) {
                assetMultiThrLab.text = @"";
                assetSingleTwoImageView.image = [UIImage imageNamed:@"singleSelect"];
            } else {
                assetMaskThrImageView.image = [UIImage imageNamed:@"photoMaskHigh"];
            }
        }
    } else {
        if (index == 0) {
            assetMultiOneLab.text = @"";
            assetSingleOneImageView.image = nil;
            assetMaskOneImageView.image = [UIImage imageNamed:@"photoMaskNormal"];
        } else if (index == 1){
            assetMultiTwoLab.text = @"";
            assetSingleTwoImageView.image = nil;
            assetMaskTwoImageView.image = [UIImage imageNamed:@"photoMaskNormal"];
        } else if (index == 2){
            assetMultiThrLab.text = @"";
            assetSingleThrImageView.image = nil;
            assetMaskThrImageView.image = [UIImage imageNamed:@"photoMaskNormal"];
        }
    }
}

#pragma mark -LabelProperty
- (void)setLabelProperty:(UILabel *)insertLab font:(NSInteger)fontSize titleColor:(NSString *)colorStr
{
    // set insertLab
    [insertLab setBackgroundColor:[UIColor clearColor]];
    // set colorStr
    [insertLab       setTextColor:[UIColor hexChangeFloat:colorStr]];
    // set fontSize
    [insertLab            setFont:[UIFont systemFontOfSize:fontSize]];
}

@end
