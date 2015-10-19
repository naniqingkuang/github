//
//  QSAssetLibraSelectPhotoViewController.m
//  AndEducationClient
//
//  Created by 独孤剑道(张洋) on 15/8/26.
//  Copyright (c) 2015年 zhyang. All rights reserved.
//

#import "QSAssetLibraSelectPhotoViewController.h"
#import "UIImageView+WebCache.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <objc/runtime.h>
#import "UIView+StringTag.h"
#import "AECConfig.h"
#import "XPhotoView.h"

#define kOriginalImageView      @"originalImageView"
#define kOriginalScrollView     @"originalScrollView"
#define kOriginalMaskImageView  @"originalMaskImageView"
#define kOriginalNaviBar        @"originalNaviBar"
#define kSelectionLabKey        @"selectionLabKey"
#define kSelectionImageKey      @"selectionOImageKey"

#define spacing  10



static char selectionAssetIndex;
//static char originalFrameKey;
static char hasSelectionKey;
static char assetOfIndicatorBtnKey;
static char cellOfIndicatorBtnKey;

@interface QSAssetLibraSelectPhotoViewController ()<UIScrollViewDelegate,UIActionSheetDelegate>
{
    NSMutableArray *selectArray;
    UILabel *labelTitle_m;
}
@property(nonatomic,strong) UIScrollView        *srcollView;
@property(nonatomic,assign) NSInteger           curIndex;
@property(nonatomic,strong) NSMutableArray      *arr;
//@property(nonatomic,strong) UIPageControl       *page;
@property(nonatomic,assign) BOOL                haveEdit;
@property (nonatomic, strong) NSDate *firstDate;
@property (nonatomic, assign) NSInteger curMax;
// luomingzhu 启用动态加载图片的算法，左中右三个显示图像的控件，根据用户的拖拽方向来加载图片到内存，耗时少，占内存少，可用时间戳函数测试
@property (nonatomic, strong) xPhotoView *leftImageView;
@property (nonatomic, strong) xPhotoView *currentImageView;
@property (nonatomic, strong) xPhotoView *rightImageView;
@end


@implementation QSAssetLibraSelectPhotoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBar.hidden animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    selectArray = [[NSMutableArray alloc]initWithArray:_selectedAssetsArr];
    
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // 防止操作传进来的数组
    _photoPaths = [[NSMutableArray alloc] initWithArray:_photoPaths];
    
    _srcollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _srcollView.contentSize = CGSizeMake(self.view.frame.size.width*3, self.view.frame.size.height);
    _srcollView.pagingEnabled = YES;
    _srcollView.delegate = self;
    _srcollView.alwaysBounceVertical = NO;
    _srcollView.directionalLockEnabled = YES;
    _srcollView.showsHorizontalScrollIndicator = NO;
    _srcollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_srcollView];
    
    [self threeImageViewInit];
    [self setInitImage];
    [self.currentImageView.Indicator addTarget:self action:@selector(actionOperationSelection:) forControlEvents:UIControlEventTouchUpInside];
    objc_setAssociatedObject(self.currentImageView.Indicator, &cellOfIndicatorBtnKey, _currentCell, OBJC_ASSOCIATION_RETAIN);
    [_srcollView setContentOffset:CGPointMake(self.srcollView.frame.size.width, 0) animated:NO];
    
    labelTitle_m = [[UILabel alloc] initWithFrame:CGRectMake(W_WIDTH/2-50, H_HIGH/2+250, 100, 20)];
    labelTitle_m.backgroundColor = COLOR_4;
    labelTitle_m.alpha = .5;
    labelTitle_m.layer.cornerRadius = 20/2;
    labelTitle_m.layer.masksToBounds = YES;
    labelTitle_m.text = [NSString stringWithFormat:@"%ld/%lu",_curIndex,(unsigned long)_photoPaths.count-1];
    labelTitle_m.textAlignment = HOME_TEXT_CENTER;
    labelTitle_m.textColor = COLOR_3;
    [self.view addSubview:labelTitle_m];
}
- (void)threeImageViewInit
{
    self.leftImageView = [[xPhotoView alloc]initWithFrame:CGRectMake(0 * (self.view.frame.size.width), 0, self.view.frame.size.width, _srcollView.frame.size.height)];
    self.currentImageView = [[xPhotoView alloc]initWithFrame:CGRectMake(1 * (self.view.frame.size.width), 0, self.view.frame.size.width, _srcollView.frame.size.height)];
    self.rightImageView = [[xPhotoView alloc]initWithFrame:CGRectMake(2 * (self.view.frame.size.width), 0, self.view.frame.size.width, _srcollView.frame.size.height)];
    
    self.leftImageView.superView = self.navigationController;
    self.leftImageView.contentMode = UIViewContentModeScaleAspectFit;
    [_srcollView addSubview:self.leftImageView];
    
    self.currentImageView.superView = self.navigationController;
    self.currentImageView.contentMode = UIViewContentModeScaleAspectFit;
    [_srcollView addSubview:self.currentImageView];
    
    __weak QSAssetLibraSelectPhotoViewController *weakSelf = self;
    __weak NSMutableArray *weakSelectArray = selectArray;
    self.currentImageView.sigleTapReturn_block = ^{
        if (weakSelf.finishSelectBlock) {
            weakSelf.finishSelectBlock(weakSelectArray);
        }
        [weakSelf.navigationController popViewControllerAnimated:YES];
        
    };
    
    self.rightImageView.superView = self.navigationController;
    self.rightImageView.contentMode = UIViewContentModeScaleAspectFit;
    [_srcollView addSubview:self.rightImageView];
    
    [self.srcollView addSubview:self.currentImageView.Indicator];
    
    _curIndex = _index;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark scrollview 代理方法
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self reloadImage];
    [_srcollView setContentOffset:CGPointMake(self.srcollView.frame.size.width, 0) animated:NO];
    labelTitle_m.text = [NSString stringWithFormat:@"%ld/%lu",_curIndex,(unsigned long)_photoPaths.count-1];
}

#pragma mark 为了防止头尾滑动的问题
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(_curIndex+1 >= _photoPaths.count )
    {
        CGPoint offset=[_srcollView contentOffset];
        if ((offset.x -_srcollView.frame.size.width) >0)
        {
            scrollView.scrollEnabled = NO;
            return;
        }
    }
    if(_curIndex == 0)
    {
        CGPoint offset=[_srcollView contentOffset];
        if ((_srcollView.frame.size.width - offset.x) >0)
        {
            scrollView.scrollEnabled = NO;
            return;
        }
    }
    scrollView.scrollEnabled = YES;
}
- (void)setInitImage
{
    if((_curIndex-1) >0)
    {
        ALAsset *asset = [_photoPaths objectAtIndex:_curIndex-1];
        self.leftImageView.img = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
    }
    if(_curIndex < _photoPaths.count)
    {
        ALAsset *asset = [_photoPaths objectAtIndex:_curIndex];
        self.currentImageView.img = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
    }
    if((_curIndex+1) < _photoPaths.count)
    {
        ALAsset *asset = [_photoPaths objectAtIndex:_curIndex+1];
        self.rightImageView.img = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
    }
    ALAsset *asset = [_photoPaths objectAtIndex:_curIndex];
    BOOL hasSelectedAsset = NO;
    NSUInteger indexOfSelectionAsset = 0;
    for (ALAsset *selectedAsset in selectArray) {
        if ([[[selectedAsset valueForProperty:ALAssetPropertyAssetURL] description] isEqualToString:[[asset valueForProperty:ALAssetPropertyAssetURL] description]]) {
            hasSelectedAsset = YES;
            indexOfSelectionAsset = [selectArray indexOfObject:selectedAsset];
            break;
        }
    }
    [self.currentImageView.Indicator setImage:[UIImage imageNamed:hasSelectedAsset?@"selectPhoto":@"unSelectPhoto"] forState:  UIControlStateNormal];
    objc_setAssociatedObject(self.currentImageView.Indicator, &hasSelectionKey, [NSNumber numberWithBool:hasSelectedAsset], OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(self.currentImageView.Indicator, &assetOfIndicatorBtnKey, asset, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(self.currentImageView.Indicator, &cellOfIndicatorBtnKey, _currentCell, OBJC_ASSOCIATION_RETAIN);
    if (hasSelectedAsset) {
        if (_isOnlyOneSelectable) {
            self.currentImageView.assetSingleImageView.image = [UIImage imageNamed:@"singleSelect"];
            [self.currentImageView.Indicator setImage:nil forState:UIControlStateNormal];
        } else {
            self.currentImageView.indexNumLab.text = [NSString stringWithFormat:@"%lu",indexOfSelectionAsset+1];
        }
    }
    else
    {
        self.currentImageView.indexNumLab.text=@"";
    }

}
//动态加载算法
- (void)reloadImage
{
    if(self.currentImageView.zoomScale != 1.0)
    {
        [self.currentImageView setZoomScale:1. animated:NO];
    }
    NSInteger leftImageIndex,rightImageIndex,currentImageIndex;
    CGPoint offset=[_srcollView contentOffset];
    if (offset.x>_srcollView.frame.size.width) { //向右滑动
            currentImageIndex = _curIndex +1;
            leftImageIndex = _curIndex;
            rightImageIndex = _curIndex +2;
            if(currentImageIndex < _photoPaths.count)
            {
                ALAsset *asset = nil;
                asset = [_photoPaths objectAtIndex:leftImageIndex];
                self.leftImageView.img = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
                asset = [_photoPaths objectAtIndex:currentImageIndex];
                self.currentImageView.img = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
                if(rightImageIndex < _photoPaths.count)
                {
                    asset = [_photoPaths objectAtIndex:rightImageIndex];
                    self.rightImageView.img = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
                }
                else
                {
                    self.rightImageView.img = nil;
                }
                _curIndex = currentImageIndex;
            }
        }else if(offset.x<_srcollView.frame.size.width){ //向左滑动
            currentImageIndex = _curIndex - 1;
            leftImageIndex = _curIndex -2;
            rightImageIndex = _curIndex;
            if(currentImageIndex >=0 )
            {
                ALAsset *asset = nil;
                if(leftImageIndex >=0)
                {
                    asset = [_photoPaths objectAtIndex:leftImageIndex];
                    self.leftImageView.img = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
                }
                else
                {
                    self.leftImageView.img = nil;
                }
                asset = [_photoPaths objectAtIndex:currentImageIndex];
                self.currentImageView.img = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
                asset = [_photoPaths objectAtIndex:rightImageIndex];
                self.rightImageView.img = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
                _curIndex = currentImageIndex;
            }
    }
    
    //判断是否选中
    ALAsset *asset = [_photoPaths objectAtIndex:_curIndex];
    BOOL hasSelectedAsset = NO;
    NSUInteger indexOfSelectionAsset = 0;
    for (ALAsset *selectedAsset in selectArray) {
        if ([[[selectedAsset valueForProperty:ALAssetPropertyAssetURL] description] isEqualToString:[[asset valueForProperty:ALAssetPropertyAssetURL] description]]) {
            hasSelectedAsset = YES;
            indexOfSelectionAsset = [selectArray indexOfObject:selectedAsset];
            break;
        }
    }
    [self.currentImageView.Indicator setImage:[UIImage imageNamed:hasSelectedAsset?@"selectPhoto":@"unSelectPhoto"] forState:  UIControlStateNormal];
    objc_setAssociatedObject(self.currentImageView.Indicator, &hasSelectionKey, [NSNumber numberWithBool:hasSelectedAsset], OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(self.currentImageView.Indicator, &assetOfIndicatorBtnKey, asset, OBJC_ASSOCIATION_RETAIN);
     objc_setAssociatedObject(self.currentImageView.Indicator, &cellOfIndicatorBtnKey, _currentCell, OBJC_ASSOCIATION_RETAIN);
       if (hasSelectedAsset) {
        if (_isOnlyOneSelectable) {
            
            self.currentImageView.assetSingleImageView.image = [UIImage imageNamed:@"singleSelect"];
            [self.currentImageView.Indicator setImage:nil forState:UIControlStateNormal];
        } else {
            self.currentImageView.indexNumLab.text = [NSString stringWithFormat:@"%lu",indexOfSelectionAsset+1];
        }
    }
    else
    {
        self.currentImageView.indexNumLab.text=@"";
    }
}
#pragma mark -actionOperationSelection
- (void)actionOperationSelection:(UIButton *)btn{
    BOOL hasSelectedAsset = [objc_getAssociatedObject(btn, &hasSelectionKey) boolValue];
    UILabel *indexNumLab = (UILabel *)[btn viewWithStringTag:kSelectionLabKey];
    UIImageView *assetSingleImageView = (UIImageView *)[btn viewWithStringTag:kSelectionImageKey];
    ALAsset *assetOfbtn = (ALAsset *)objc_getAssociatedObject(btn, &assetOfIndicatorBtnKey);
    NSUInteger indexOfReload = [objc_getAssociatedObject(assetOfbtn, &selectionAssetIndex) intValue];
    if (hasSelectedAsset) {
        for (ALAsset *selectedAsset in selectArray) {
            if ([[[selectedAsset valueForProperty:ALAssetPropertyAssetURL] description] isEqualToString:[[assetOfbtn valueForProperty:ALAssetPropertyAssetURL] description]]) {
                [selectArray removeObject:selectedAsset];
                break;
            }
        }
        [btn setImage:[UIImage imageNamed:@"unSelectPhoto"] forState:UIControlStateNormal];
        objc_setAssociatedObject(btn, &hasSelectionKey, [NSNumber numberWithBool:NO], OBJC_ASSOCIATION_RETAIN);
        self.currentImageView.indexNumLab.text = @"";

        
    } else {
        if (_isOnlyOneSelectable) {
            if (selectArray.count == 1) {
                return;
            }
        } else {
            if (selectArray.count == _numberOfCouldSelectAssets) {
                return;
            }
        }
        [selectArray addObject:assetOfbtn];
        
        if (_isOnlyOneSelectable) {
            assetSingleImageView.stringTag = kSelectionImageKey;
            assetSingleImageView.image = [UIImage imageNamed:@"singleSelect"];
        } else {
            [btn setImage:[UIImage imageNamed:@"selectPhoto"] forState:UIControlStateNormal];
            
            indexNumLab.text = [NSString stringWithFormat:@"%lu",(unsigned long)selectArray.count];
        }
        objc_setAssociatedObject(btn, &hasSelectionKey, [NSNumber numberWithBool:YES], OBJC_ASSOCIATION_RETAIN);
        [_currentCell actionReloadSelectionStateWithIndex:indexOfReload%3 isSelection:YES];
        
    }
}

@end
