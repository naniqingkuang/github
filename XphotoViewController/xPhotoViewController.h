//
//  xPhotoViewController.h
//  ImagePicker
//
//  Created by 徐方舟 on 14-5-25.
//  Copyright (c) 2014年 Seungbo Cho. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface xPhotoVCTransitionPushAnimator : NSObject <UIViewControllerAnimatedTransitioning>
@end
@interface xPhotoVCTransitionPopAnimator : NSObject <UIViewControllerAnimatedTransitioning>
@end
@protocol xPhotoViewTransitionProtcol <UINavigationControllerDelegate>
@property (nonatomic, weak) UIImage *animationBeginImage;
@property (nonatomic, assign) NSInteger imageIndex;
@property (nonatomic, strong) NSArray *animationImageViewFramesFromWindow;
@end

typedef void(^editPhotoPathsBlock)(NSInteger index);

@interface xPhotoViewController : UIViewController
@property(nonatomic,strong) NSMutableArray *photoPaths;
@property(nonatomic,assign) NSInteger index;
/// can edit - Default is no
@property(assign, nonatomic, getter = isCanEdit) BOOL canEdit;
@property (nonatomic, strong) editPhotoPathsBlock editBlock;
@end
