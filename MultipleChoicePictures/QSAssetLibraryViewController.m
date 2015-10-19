//
//  QSAssetLibraryViewController.m
//  QuicklyShop
//
//  Created by 独孤剑道(张洋) on 15-6-22.
//  Copyright (c) 2015年 com. All rights reserved.
//

#import "QSAssetCommonRowCell.h"
#import "UIImage+ImageEffects.h"
#import "QSImageCropViewController.h"
#import "QSAssetLibraryViewController.h"
#import "UIView+StringTag.h"
#import "UIImage+RenderedImage.h"
#import "UIColor+extended.h"
#import "AECConfig.h"
#import <objc/runtime.h>
#import "QSAssetLibraSelectPhotoViewController.h"

#define VideoFps                50

#define kOriginalImageView      @"originalImageView"
#define kOriginalScrollView     @"originalScrollView"
#define kOriginalMaskImageView  @"originalMaskImageView"
#define kOriginalNaviBar        @"originalNaviBar"
#define kSelectionLabKey        @"selectionLabKey"
#define kSelectionImageKey      @"selectionOImageKey"

@interface QSAssetLibraryViewController () <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    NSString *ablumName;
    NSMutableArray *assetsArr;
    NSMutableArray *ablumsArr;
    ALAssetsLibrary *assetLibrary;
    NSMutableArray *selectedAssetsArr;
    
    AVCaptureSession *captureSession;
    
    UIImage *blurImage;
    UIBarButtonItem *rightBtn;
    UITableView *assetsTableView;
    UITableView *ablumsTableView;
    
    dispatch_queue_t videoSessionQueue;
    AVCaptureVideoPreviewLayer *previewLayer;
}

- (NSUInteger)getAssetsRowCount;
- (NSUInteger)getLastRowCountOfAssets;
- (NSArray *)getAssetsWithIndexPath:(NSIndexPath *)indexPath;
@end

static char selectionAssetIndex;
static char originalFrameKey;
static char hasSelectionKey;
static char assetOfIndicatorBtnKey;
static char cellOfIndicatorBtnKey;

@implementation QSAssetLibraryViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self actionPrepareDataComponents];
    [self actionPrepareUIComponents];
    
    self.navigationController.navigationBar.barTintColor = COLOR_0;
    self.navigationItem.title = @"添加图片";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -actionPrepareDataComponents
- (void)actionPrepareDataComponents {
    ablumsArr = [NSMutableArray array];
    selectedAssetsArr = [NSMutableArray array];
    assetLibrary = [[ALAssetsLibrary alloc] init];
    
    if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusDenied) {
       
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请在iPhone的\"设置－隐私－照片\"选项中，允许块店访问你的手机相册" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];
        
        return;
    }
    
    
    __weak typeof(self) weakSelf = self;
    void (^assetsEnumerationBlock)(ALAssetsGroup *,BOOL *) = ^(ALAssetsGroup *group,
                                                               BOOL *stop){
        if (!weakSelf) {
            return ;
        }
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (group) {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        }
        if (group.numberOfAssets > 0) {
            [strongSelf->ablumsArr addObject:group];
        }
        if (strongSelf->ablumsArr.count == 1) {
            if (group.numberOfAssets > 0) {
                [strongSelf actionEnumerateAssetsWithGroup:group];
                NSUInteger numberOfRow = [strongSelf->assetsTableView numberOfRowsInSection:0];
                [strongSelf->assetsTableView scrollToRowAtIndexPath:[NSIndexPath
                                                                     indexPathForRow:numberOfRow-1
                                                                     inSection:0]
                                                   atScrollPosition:UITableViewScrollPositionBottom
                                                           animated:NO];
            }
        } else if (strongSelf->ablumsArr.count == 0) {
            if (!strongSelf->previewLayer) {
                strongSelf->assetsArr = [NSMutableArray array];
                [strongSelf actionCaptureWithCurrentCamera];
                [strongSelf->assetsTableView reloadData];
                if (!strongSelf->captureSession.isRunning) {
                    [strongSelf actionRunningCapture];
                    
                    for (CALayer *subLayer in strongSelf->previewLayer.sublayers) {
                        if ([subLayer.name isEqualToString:@"maskPhotoLayer"]) {
                            [subLayer removeFromSuperlayer];
                            break;
                        }
                    }
                    CALayer *maskPhotoLayer = [CALayer layer];
                    maskPhotoLayer.name = @"maskPhotoLayer";
                    maskPhotoLayer.frame = CGRectMake(0, 0, ASSET_WIDTH, ASSET_HEIGT);
                    maskPhotoLayer.contents = (id)[UIImage imageNamed:@"takePhotoHigh"].CGImage;
                    [strongSelf->previewLayer addSublayer:maskPhotoLayer];
                }
            }
        }
    };
    [assetLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:assetsEnumerationBlock
                              failureBlock:NULL];
    [assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:assetsEnumerationBlock
                              failureBlock:NULL];
}

#pragma mark -actionPrepareUIComponents
- (void)actionPrepareUIComponents {
    __weak typeof(self) weakSelf = self;

    [self aecBarButtonItemLeftWithTitle:@"取消" withColor:COLOR_3 withActionBlock:^{
        
        [weakSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    rightBtn = [self aecBarButtonItemRightWithTitle:@"确定" withColor:COLOR_3 withActionBlock:^{
        
        if (!weakSelf) {
            return ;
        }
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.isOnlyOneSelectable) {
            ALAsset *selectAlAsset = [strongSelf->selectedAssetsArr objectAtIndex:0];
            QSImageCropViewController *imageCropViewController = [[QSImageCropViewController alloc] init];
            imageCropViewController.imageURL = [[selectAlAsset valueForProperty:ALAssetPropertyAssetURL] absoluteString];
            imageCropViewController.shouldNotAnimation = YES;
            imageCropViewController.cropCompletedBlock = ^(NSString *imagePathOfCropped, UIImage *thumbnailImage,UIImage *cropedImage){
                if (weakSelf.singleSelectImageBlock) {
                    strongSelf.singleSelectImageBlock(cropedImage);
                }
                [strongSelf.navigationController dismissViewControllerAnimated:YES completion:NULL];
            };
            [strongSelf.navigationController pushViewController:imageCropViewController animated:YES];
        } else {
            if (weakSelf.selectAssetsBlock) {
                strongSelf.selectAssetsBlock(strongSelf->selectedAssetsArr);
            }
            [weakSelf.navigationController dismissViewControllerAnimated:YES completion:NULL];
        }
    }];
    
    rightBtn.enabled = NO;
    
//    self.title = @"添加图片";
//    self.barSubTitle = @"相机胶卷";
    
    UIButton *showAblumsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    showAblumsBtn.frame = self.navigationItem.titleView.bounds;
    [showAblumsBtn setImage:[UIImage imageNamed:@"arrow_down"] forState:UIControlStateNormal];
    [showAblumsBtn setImage:[UIImage imageNamed:@"arrow_down"] forState:UIControlStateHighlighted];
    CGFloat verticalInset = (CGRectGetHeight(showAblumsBtn.frame)-8)/2.;
    CGFloat horizontalInset = CGRectGetWidth(showAblumsBtn.frame)-12;
    showAblumsBtn.imageEdgeInsets = UIEdgeInsetsMake(verticalInset, horizontalInset-48, verticalInset, 48);
    [showAblumsBtn addTarget:self action:@selector(actionShowAblums) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem.titleView addSubview:showAblumsBtn];
    
    assetsTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    assetsTableView.delegate = self;
    assetsTableView.dataSource = self;
    assetsTableView.backgroundColor = COLOR_3;
    assetsTableView.contentInset = UIEdgeInsetsMake(15, 0, 15, 0);
    assetsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    assetsTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:assetsTableView];
    
    ablumsTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 64, CGRectGetWidth(self.view.bounds) - 20, 0) style:UITableViewStylePlain];
    ablumsTableView.delegate = self;
    ablumsTableView.dataSource = self;
    ablumsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    ablumsTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    ablumsTableView.layer.cornerRadius = 5.;
    ablumsTableView.layer.masksToBounds = YES;
    ablumsTableView.layer.zPosition = MAXFLOAT;
    [self.navigationController.view addSubview:ablumsTableView];
}

#pragma mark -actionCaptureWithCurrentCamera
- (void)actionCaptureWithCurrentCamera {
    if (!captureSession) {
        NSArray *camerasArr = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        AVCaptureDevice *backCaptureDevice;
        for (AVCaptureDevice *device in camerasArr) {
            if (device.position == AVCaptureDevicePositionBack){
                backCaptureDevice = device;
                break;
            }
        }
        
        if (backCaptureDevice) {
            NSError *error = nil;
            AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:backCaptureDevice error:&error];
            if (!videoInput||error) {
                return ;
            }
            
            captureSession = [[AVCaptureSession alloc] init];
            captureSession.sessionPreset = AVCaptureSessionPresetLow;
            [captureSession addInput:videoInput];
            
            AVCaptureVideoDataOutput *avCaptureVideoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
            NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                      [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA],
                                      kCVPixelBufferPixelFormatTypeKey,
                                      nil];
            avCaptureVideoDataOutput.videoSettings = settings;
            if (!IS_IOS7_LATER) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                avCaptureVideoDataOutput.minFrameDuration = CMTimeMake(1, VideoFps);
#pragma clang diagnositc pop
            }
            previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        }
    }
}

#pragma mark -actionRunningCapture
- (void)actionRunningCapture {
    
    if (!videoSessionQueue) {
        videoSessionQueue = dispatch_queue_create("com.kkkd.Hotshop", NULL);
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(videoSessionQueue, ^{
        if (!weakSelf) {
            return ;
        }
        __strong typeof(weakSelf) strongSelf  = weakSelf;
        [strongSelf->captureSession startRunning];
    });
}

#pragma mark -actionEnumerateAssetsWithGroup
- (void)actionEnumerateAssetsWithGroup:(ALAssetsGroup *)group {
    if (!assetsArr) {
        assetsArr = [NSMutableArray array];
    } else {
        [assetsArr removeAllObjects];
    }
    
    __weak typeof(self) weakSelf = self;
    [group  enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        __strong typeof(weakSelf) strongSelf  = weakSelf;
        if (result) {
            objc_setAssociatedObject(result, &selectionAssetIndex, [NSNumber numberWithLong:index], OBJC_ASSOCIATION_RETAIN);
            [strongSelf->assetsArr addObject:result];
        }
    }];
    self.title = [group valueForProperty:ALAssetsGroupPropertyName];
    ablumName = self.title;
    [self actionCaptureWithCurrentCamera];
    [assetsTableView reloadData];
    blurImage = [[self screenShoot:self.navigationController.view]
                 applyDarkEffect];
    
    if (!captureSession.isRunning) {
        [self actionRunningCapture];
        
        for (CALayer *subLayer in previewLayer.sublayers) {
            if ([subLayer.name isEqualToString:@"maskPhotoLayer"]) {
                [subLayer removeFromSuperlayer];
                break;
            }
        }
        CALayer *maskPhotoLayer = [CALayer layer];
        maskPhotoLayer.name = @"maskPhotoLayer";
        maskPhotoLayer.frame = CGRectMake(0, 0, ASSET_WIDTH, ASSET_HEIGT);
        maskPhotoLayer.contents = (id)[UIImage imageNamed:@"takePhotoHigh"].CGImage;
        [previewLayer addSublayer:maskPhotoLayer];
    }
}

#pragma mark -actionReCaptureVideo
- (void)actionReCaptureVideo{
    QSAssetCommonRowCell *cellOfLastRow = (QSAssetCommonRowCell *)[assetsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self getAssetsRowCount]-1 inSection:0]];
    cellOfLastRow.captureVideoPreviewLayer = previewLayer;
    
    for (CALayer *subLayer in previewLayer.sublayers) {
        if ([subLayer.name isEqualToString:@"maskPhotoLayer"]) {
            [subLayer removeFromSuperlayer];
            break;
        }
    }
    CALayer *maskPhotoLayer = [CALayer layer];
    maskPhotoLayer.name = @"maskPhotoLayer";
    maskPhotoLayer.frame = CGRectMake(0, 0, ASSET_WIDTH, ASSET_HEIGT);
    maskPhotoLayer.contents = (id)[UIImage imageNamed:@"takePhotoHigh"].CGImage;
    [previewLayer addSublayer:maskPhotoLayer];
}

#pragma mark -actionShowAblums
- (void)actionShowAblums {
    if (ablumsArr.count == 0) {
        if (ablumsArr.count == 0) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"手机当前相册为空" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alertView show];
            
            return ;
        }
    }
    BOOL hadShowAblumTableView = (CGRectGetHeight(ablumsTableView.frame) == CGRectGetHeight(self.view.bounds)-64);
    UIImageView *blurImageView = (UIImageView *)[self.navigationController.view viewWithStringTag:@"blurImageView"];
    if (!blurImageView) {
        blurImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        blurImageView.userInteractionEnabled = YES;
        blurImageView.stringTag = @"blurImageView";
        blurImageView.image = blurImage;
        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionDismissAblums)];
        [blurImageView addGestureRecognizer:gesture];
    }
    if (!hadShowAblumTableView) {
        [self.navigationController.view insertSubview:blurImageView belowSubview:ablumsTableView];
    }
    
    if (hadShowAblumTableView) {
        ablumsTableView.frame = CGRectMake(10, 64, CGRectGetWidth(self.view.bounds)-20, 0);
        [blurImageView removeFromSuperview];
    } else {
        if ([ablumsTableView numberOfRowsInSection:0] == 0) {
            [ablumsTableView reloadData];
        }
        ablumsTableView.frame = CGRectMake(10, 64, CGRectGetWidth(self.view.bounds)-20, CGRectGetHeight(self.view.bounds)-64);
    }
}

#pragma mark -actionDismissAblums
- (void)actionDismissAblums {
    [self actionShowAblums];
}

#pragma mark -actionPresentImagePickerController
- (void)actionPresentImagePickerController {
    [[NSNotificationCenter defaultCenter] postNotificationName:HIDE_STATUS_BAR_VIEW object:nil];
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.allowsEditing = YES;
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:^{
        
    }];
}

#pragma mark -UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == assetsTableView) {
        return [self getAssetsRowCount];
    } else if (tableView == ablumsTableView) {
        return ablumsArr.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == assetsTableView) {
        static NSString *identifierOfCommonRow = @"identifierOfCommonRow";
        QSAssetCommonRowCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierOfCommonRow];
        if (!cell) {
            cell = [[QSAssetCommonRowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifierOfCommonRow];
            cell.backgroundColor = COLOR_3;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        __weak typeof(self) weakSelf  = self;
        cell.isOnlyOneSelectable = _isOnlyOneSelectable;
        cell.assetsArr = [self getAssetsWithIndexPath:indexPath];
        cell.hasSelectionArr = selectedAssetsArr;
        cell.numberOfCouldSelection = self.numberOfCouldSelectAssets;
        if (indexPath.row == [self getAssetsRowCount]-1) {
            cell.captureVideoPreviewLayer = previewLayer;
        }
        cell.takePhotoBlock = ^{
            if (![UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera]) {
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                    message:@"当前设备不可用"
                                                                   delegate:self
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:@"确定", nil];
                [alertView show];
                
                return ;
            }
            __strong typeof(weakSelf) strongSelf  = weakSelf;
            if ([strongSelf->captureSession isRunning]) {
                [strongSelf->captureSession stopRunning];
                
                [strongSelf performSelector:@selector(actionPresentImagePickerController) withObject:nil afterDelay:1.];
            } else {
                
                return;
            }
        };
        cell.selectionAssetBlock = ^(ALAsset *asset,BOOL showOriginalPicture, QSAssetCommonRowCell *operationCell,UIImageView *operationImageView){
            if (!showOriginalPicture) {
                if (!weakSelf) {
                    return ;
                }
                __strong typeof(weakSelf) strongSelf  = weakSelf;
                for (ALAsset *selectedAsset in operationCell.hasSelectionArr) {
                    if ([[[selectedAsset valueForProperty:ALAssetPropertyAssetURL] description] isEqualToString:[[asset valueForProperty:ALAssetPropertyAssetURL] description]]) {
                        NSUInteger indexOfDelettingAsset = [operationCell.hasSelectionArr indexOfObject:selectedAsset];
                        [operationCell.hasSelectionArr removeObject:selectedAsset];
                        if (!operationCell.isOnlyOneSelectable) {
                            [strongSelf actionReloadIndexValue:indexOfDelettingAsset];
                        }
                        if (operationCell.hasSelectionArr.count == 0) {
                            strongSelf->rightBtn.enabled = NO;
                        }
                        return;
                        break;
                    }
                }
                [operationCell.hasSelectionArr addObject:asset];
                if (operationCell.hasSelectionArr.count>0 && !strongSelf->rightBtn.enabled) {
                    strongSelf->rightBtn.enabled = YES;
                }
            } else {
                [weakSelf actionShowOriginalPhotoWithAsset:asset]; // 左右滑动预览图片方法
                
//                [weakSelf actionShowOriginalPhotoWithAsset:asset thumailImageView:operationImageView cell:operationCell];
            }
        };
        return cell;
    } else if (tableView == ablumsTableView) {
        static NSString *identifierOfAblumsRow = @"identifierOfAblumsRow";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierOfAblumsRow];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifierOfAblumsRow];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            
            UIImageView *posterImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 6, 50, 50)];
            posterImageView.stringTag = @"posterImageView";
            [cell addSubview:posterImageView];
            
            UILabel *ablumLab = [[UILabel alloc] init];
            ablumLab.stringTag = @"ablumLab";
            ablumLab.font = [UIFont systemFontOfSize:15.];
            ablumLab.backgroundColor = [UIColor clearColor];
            [cell addSubview:ablumLab];
            
            UILabel *numberOfAblumLab = [[UILabel alloc] init];
            numberOfAblumLab.stringTag = @"numberOfAblumLab";
            numberOfAblumLab.font = [UIFont systemFontOfSize:12.];
            numberOfAblumLab.textColor = COLOR_1;
            numberOfAblumLab.backgroundColor = [UIColor clearColor];
            [cell addSubview:numberOfAblumLab];
        }
        ALAssetsGroup *ablum = (ALAssetsGroup *)[ablumsArr objectAtIndex:indexPath.row];
        
        UIImageView *posterImageView = (UIImageView *)[cell viewWithStringTag:@"posterImageView"];
        UILabel *ablumLab = (UILabel *)[cell viewWithStringTag:@"ablumLab"];
        UILabel *numberOfAblumLab = (UILabel *)[cell viewWithStringTag:@"numberOfAblumLab"];
        
        posterImageView.image = [UIImage imageWithCGImage:ablum.posterImage];
        ablumLab.text = [ablum valueForProperty:ALAssetsGroupPropertyName];
        numberOfAblumLab.text = [NSString stringWithFormat:@"%ld",(long)[ablum numberOfAssets]];
        return cell;
    }
    return nil;
}

#pragma mark -UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == ablumsTableView) {
        return 62;
    }else if (tableView == assetsTableView) {
        return (2*ASSET_Y_SPACE+ASSET_HEIGT);
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView == ablumsTableView) {
        return 40.;
    }
    return 0.;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == ablumsTableView) {
        UILabel *headerLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(ablumsTableView.frame), 40)];
        headerLab.backgroundColor = [UIColor whiteColor];
        headerLab.font = [UIFont systemFontOfSize:16.];
        headerLab.text = @"相册";
        headerLab.textAlignment = UITextAlignmentCenter;
        
        UIImageView *separatorView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 39.5, CGRectGetWidth(ablumsTableView.frame), 0.5)];
        separatorView.backgroundColor = COLOR_1;
        [headerLab addSubview:separatorView];
        
        return headerLab;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == ablumsTableView) {
        UIImageView *posterImageView = (UIImageView *)[cell viewWithStringTag:@"posterImageView"];
        UILabel *ablumLab = (UILabel *)[cell viewWithStringTag:@"ablumLab"];
        UILabel *numberOfAblumLab = (UILabel *)[cell viewWithStringTag:@"numberOfAblumLab"];
        [ablumLab sizeToFit];
        [numberOfAblumLab sizeToFit];
        
        posterImageView.frame = CGRectMake(12, 6, 50, 50);
        ablumLab.frame = (CGRect){CGPointMake(72, 12),ablumLab.frame.size};
        numberOfAblumLab.frame = (CGRect){CGPointMake(72, 22+CGRectGetHeight(ablumLab.frame)),numberOfAblumLab.frame.size};
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == ablumsTableView) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        ALAssetsGroup *group = (ALAssetsGroup *)[ablumsArr objectAtIndex:indexPath.row];
        [self actionEnumerateAssetsWithGroup:group];
        [self actionShowAblums];
        [assetsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[assetsTableView numberOfRowsInSection:0]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

- (void)actionShowOriginalPhotoWithAsset:(ALAsset *)asset {
    QSAssetLibraSelectPhotoViewController *pVC = [[QSAssetLibraSelectPhotoViewController alloc] init];
    pVC.selectedAssetsArr = selectedAssetsArr;
    pVC.photoPaths = assetsArr;
    pVC.isOnlyOneSelectable = _isOnlyOneSelectable;
    pVC.index = [assetsArr indexOfObject:asset];
    pVC.canEdit = YES;
    pVC.numberOfCouldSelectAssets = _numberOfCouldSelectAssets;
    pVC.numberOfSelectingAssets = _numberOfSelectingAssets;
    pVC.finishSelectBlock = ^(NSMutableArray * selectArray){
        
    [selectedAssetsArr removeAllObjects];
    [selectedAssetsArr addObjectsFromArray:selectArray];
    if ([selectArray count] != 0) {
        rightBtn.enabled = YES;
    }
    else {
        rightBtn.enabled = NO;
    }
    [assetsTableView reloadData];
    };
    [self.navigationController pushViewController:pVC animated:YES];
}

#pragma mark -actionShowOriginalPhoto
- (void)actionShowOriginalPhotoWithAsset:(ALAsset *)asset thumailImageView:(UIImageView *)thumailImageView cell:(QSAssetCommonRowCell *)currentCell {
    UIScrollView *originalScrollView = (UIScrollView *)[self.view.window viewWithStringTag:kOriginalScrollView];
    if (originalScrollView) {
        return;
    }
    CGRect convertFrame = [currentCell convertRect:thumailImageView.superview.frame toView:self.view.window];
    originalScrollView = [[UIScrollView alloc] initWithFrame:convertFrame];
    originalScrollView.stringTag = kOriginalScrollView;
    originalScrollView.layer.zPosition = MAXFLOAT;
    originalScrollView.delegate = self;
    originalScrollView.layer.masksToBounds = YES;
    originalScrollView.backgroundColor = [UIColor blackColor];
    originalScrollView.showsHorizontalScrollIndicator = NO;
    originalScrollView.showsVerticalScrollIndicator = NO;
    
    UIImageView *originalImageView = [[UIImageView alloc] initWithFrame:originalScrollView.bounds];
    originalImageView.stringTag = kOriginalImageView;
    UIImage *originalImage = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
    originalImage = [UIImage scaleDown:originalImage withSize:CGSizeMake(320, 320*originalImage.size.height/originalImage.size.width)];
    originalImageView.image = originalImage;
    originalImageView.contentMode = UIViewContentModeScaleAspectFit;
    [originalScrollView addSubview:originalImageView];
    [self.view.window addSubview:originalScrollView];
    
    CGFloat imageRadio = originalImage.size.width/originalImage.size.height;
    CGFloat screenRadio = CGRectGetWidth(self.view.window.frame)/CGRectGetHeight(self.view.window.frame);
    if (imageRadio >= screenRadio) {
        CGFloat currentImageHeight = CGRectGetWidth(self.view.window.frame)/imageRadio;
        originalScrollView.maximumZoomScale = CGRectGetHeight(self.view.window.frame)/currentImageHeight;
    } else {
        CGFloat currentImageWidth = CGRectGetWidth(self.view.window.frame)*imageRadio;
        originalScrollView.maximumZoomScale = CGRectGetWidth(self.view.window.frame)/currentImageWidth;
    }
    originalScrollView.minimumZoomScale = 1.;
    
    [UIView animateWithDuration:.5 delay:0. options:UIViewAnimationOptionCurveEaseInOut animations:^{
        originalScrollView.frame = self.navigationController.view.bounds;
        originalImageView.frame = self.navigationController.view.bounds;
    } completion:^(BOOL finished) {
        UIImageView *  maskImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.window.frame), 64)];
        maskImageView.stringTag = kOriginalMaskImageView;
        maskImageView.layer.zPosition = originalScrollView.layer.zPosition+0.01;
        maskImageView.backgroundColor = [UIColor blackColor];
        maskImageView.alpha = 0.1;
        [self.view.window addSubview:maskImageView];
        
        UIImage *naviBackgroundImage = [UIImage imageWithRenderColor:[UIColor clearColor] renderSize:CGSizeMake(10, 10.)];
        UINavigationBar *naviBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 20, 320, 44)];
        naviBar.stringTag = kOriginalNaviBar;
        [naviBar setBackgroundImage:naviBackgroundImage forBarMetrics:UIBarMetricsDefault];
        naviBar.layer.zPosition = maskImageView.layer.zPosition + 0.01;
        UINavigationItem *naviItem = [[UINavigationItem alloc] init];
        
        UIButton *dismissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [dismissBtn setTitle:@"返回" forState:UIControlStateNormal];
        [dismissBtn setImage:[UIImage imageNamed:@"navBar_back_nor"] forState:UIControlStateNormal];
        [dismissBtn setImage:[UIImage imageNamed:@"navBar_back_hlt"] forState:UIControlStateHighlighted];
        [dismissBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [dismissBtn setTitleColor:COLOR_1 forState:UIControlStateHighlighted];
        [[dismissBtn titleLabel] setFont:[UIFont systemFontOfSize:14.]];
        [dismissBtn sizeToFit];
        [dismissBtn addTarget:self action:@selector(actionDismissOriginalPhoto:) forControlEvents:UIControlEventTouchUpInside];
        objc_setAssociatedObject(dismissBtn, &originalFrameKey, [NSValue valueWithCGRect:convertFrame], OBJC_ASSOCIATION_RETAIN);
        [naviItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:dismissBtn]];
        
        BOOL hasSelectedAsset = NO;
        NSUInteger indexOfSelectionAsset = 0;
        for (ALAsset *selectedAsset in selectedAssetsArr) {
            if ([[[selectedAsset valueForProperty:ALAssetPropertyAssetURL] description] isEqualToString:[[asset valueForProperty:ALAssetPropertyAssetURL] description]]){
                hasSelectedAsset = YES;
                indexOfSelectionAsset = [selectedAssetsArr indexOfObject:selectedAsset];
                break;
            }
        }
        
        UIButton *indicatorBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        indicatorBtn.frame = CGRectMake(0, 0, 44, 44);
        [indicatorBtn setImage:[UIImage imageNamed:hasSelectedAsset?@"selectPhoto":@"unSelectPhoto"] forState:  UIControlStateNormal];
        objc_setAssociatedObject(indicatorBtn, &hasSelectionKey, [NSNumber numberWithBool:hasSelectedAsset], OBJC_ASSOCIATION_RETAIN);
        objc_setAssociatedObject(indicatorBtn, &assetOfIndicatorBtnKey, asset, OBJC_ASSOCIATION_RETAIN);
        objc_setAssociatedObject(indicatorBtn, &cellOfIndicatorBtnKey, currentCell, OBJC_ASSOCIATION_RETAIN);
        indicatorBtn.imageEdgeInsets = UIEdgeInsetsMake(9, 9, 9, 9);
        if (hasSelectedAsset) {
            if (_isOnlyOneSelectable) {
                UIImageView * assetSingleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(9, 9, 26, 26)];
                assetSingleImageView.stringTag = kSelectionImageKey;
                assetSingleImageView.image = [UIImage imageNamed:@"singleSelect"];
                [indicatorBtn setImage:nil forState:UIControlStateNormal];
                [indicatorBtn addSubview:assetSingleImageView];
            } else {
                UILabel *indexNumLab = [[UILabel alloc] init];
                [self setLabelProperty:indexNumLab font:16 titleColor:@"FFFFFF"];
                indexNumLab.frame = CGRectMake(10, 10, 24, 24);
                indexNumLab.stringTag = kSelectionLabKey;
                indexNumLab.textAlignment = UITextAlignmentCenter;
                indexNumLab.text = [NSString stringWithFormat:@"%lu",indexOfSelectionAsset+1];
                [indicatorBtn addSubview:indexNumLab];
            }
        }
        [indicatorBtn addTarget:self action:@selector(actionOperationSelection:) forControlEvents:UIControlEventTouchUpInside];
        naviItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:indicatorBtn];
        
        [naviBar pushNavigationItem:naviItem animated:NO];
        
        [self.view.window addSubview:naviBar];
    }];
}

#pragma mark -actionOperationSelection
- (void)actionOperationSelection:(UIButton *)btn {
    BOOL hasSelectedAsset = [objc_getAssociatedObject(btn, &hasSelectionKey) boolValue];
    UILabel *indexNumLab = (UILabel *)[btn viewWithStringTag:kSelectionLabKey];
    UIImageView *assetSingleImageView = (UIImageView *)[btn viewWithStringTag:kSelectionImageKey];
    ALAsset *assetOfbtn = (ALAsset *)objc_getAssociatedObject(btn, &assetOfIndicatorBtnKey);
    QSAssetCommonRowCell *currentCell = (QSAssetCommonRowCell *)objc_getAssociatedObject(btn, &cellOfIndicatorBtnKey);
    NSUInteger indexOfReload = [objc_getAssociatedObject(assetOfbtn, &selectionAssetIndex) intValue];
    if (hasSelectedAsset) {
        for (ALAsset *selectedAsset in selectedAssetsArr) {
            if ([[[selectedAsset valueForProperty:ALAssetPropertyAssetURL] description] isEqualToString:[[assetOfbtn valueForProperty:ALAssetPropertyAssetURL] description]]) {
                NSUInteger indexOfDelettingAsset = [selectedAssetsArr indexOfObject:selectedAsset];
                [selectedAssetsArr removeObject:selectedAsset];
                if (!_isOnlyOneSelectable) {
                    [self actionReloadIndexValue:indexOfDelettingAsset];
                }
                break;
            }
        }
        [indexNumLab removeFromSuperview];
        [assetSingleImageView removeFromSuperview];
        [btn setImage:[UIImage imageNamed:@"unSelectPhoto"] forState:UIControlStateNormal];
        objc_setAssociatedObject(btn, &hasSelectionKey, [NSNumber numberWithBool:NO], OBJC_ASSOCIATION_RETAIN);
        [currentCell actionReloadSelectionStateWithIndex:indexOfReload%3 isSelection:NO];
        if (rightBtn.enabled) {
            rightBtn.enabled = NO;
        }
    } else {
        if (_isOnlyOneSelectable) {
            if (selectedAssetsArr.count == 1) {
                return;
            }
        } else {
            if (selectedAssetsArr.count == _numberOfCouldSelectAssets) {
                return;
            }
        }
        [selectedAssetsArr addObject:assetOfbtn];
        
        if (_isOnlyOneSelectable) {
            UIImageView * assetSingleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(9, 9, 26, 26)];
            assetSingleImageView.stringTag = kSelectionImageKey;
            assetSingleImageView.image = [UIImage imageNamed:@"singleSelect"];
            [btn addSubview:assetSingleImageView];
        } else {
            [btn setImage:[UIImage imageNamed:@"selectPhoto"] forState:UIControlStateNormal];
            UILabel *indexNumLab = [[UILabel alloc] init];
            [self setLabelProperty:indexNumLab font:16 titleColor:@"FFFFFF"];
            indexNumLab.frame = CGRectMake(10, 10, 24, 24);
            indexNumLab.stringTag = kSelectionLabKey;
            indexNumLab.textAlignment = UITextAlignmentCenter;
            indexNumLab.text = [NSString stringWithFormat:@"%lu",(unsigned long)selectedAssetsArr.count];
            [btn addSubview:indexNumLab];
        }
        objc_setAssociatedObject(btn, &hasSelectionKey, [NSNumber numberWithBool:YES], OBJC_ASSOCIATION_RETAIN);
        [currentCell actionReloadSelectionStateWithIndex:indexOfReload%3 isSelection:YES];
        if (!rightBtn.enabled) {
            rightBtn.enabled = YES;
        }
    }
}

#pragma mark -actionDismissOriginalPhoto
- (void)actionDismissOriginalPhoto:(UIButton *)btn {
    UIScrollView *originalScrollView = (UIScrollView *)[self.view.window viewWithStringTag:kOriginalScrollView];
    UIImageView *originalImageView = (UIImageView *)[originalScrollView viewWithStringTag:kOriginalImageView];
    UIImageView *maskImageView = (UIImageView *)[self.view.window viewWithStringTag:kOriginalMaskImageView];
    UINavigationBar *originalNaviBar = (UINavigationBar *)[self.view.window viewWithStringTag:kOriginalNaviBar];
    CGRect originalFrame = (CGRect)[objc_getAssociatedObject(btn, &originalFrameKey) CGRectValue];
    
    [maskImageView removeFromSuperview];
    [originalNaviBar removeFromSuperview];
    
    [UIView animateWithDuration:.5 animations:^{
        originalScrollView.frame = originalFrame;
        originalScrollView.layer.cornerRadius = 5;
        originalScrollView.alpha = 0.;
        originalImageView.frame = CGRectMake(0, 0, CGRectGetWidth(originalFrame), CGRectGetHeight(originalFrame));
    } completion:^(BOOL finished) {
        [originalScrollView removeFromSuperview];
    }];
}

#pragma mark -UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    UIImageView *originalImageView = (UIImageView *)[scrollView viewWithStringTag:kOriginalImageView];
    if (originalImageView) {
        return originalImageView;
    }
    return nil;
}

#pragma mark -UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    __weak typeof(self) weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^{
        if (!weakSelf) {
            return ;
        }
        __strong typeof(weakSelf) strongSelf  = weakSelf;
        UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
        [strongSelf->assetLibrary writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
            [strongSelf->assetLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                if (asset) {
                    NSUInteger index = 0;
                    ALAsset *lastAsset = (ALAsset *)[strongSelf->assetsArr lastObject];
                    if (lastAsset) {
                        index = [objc_getAssociatedObject(lastAsset, &selectionAssetIndex) intValue];
                        index ++;
                    }
                    objc_setAssociatedObject(asset, &selectionAssetIndex, [NSNumber numberWithLong:index], OBJC_ASSOCIATION_RETAIN);
                    
                    BOOL necessaryOfInsertting = strongSelf->assetsArr.count%3==2?YES:NO;
                    [strongSelf->selectedAssetsArr addObject:asset];
                    [strongSelf->assetsArr addObject:asset];
                    if (necessaryOfInsertting) {
                        [strongSelf->assetsTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[strongSelf getAssetsRowCount]-1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                        if ([strongSelf getAssetsRowCount]-2 > 0) {
                            [strongSelf->assetsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[strongSelf getAssetsRowCount]-2 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                            [strongSelf->assetsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[strongSelf getAssetsRowCount]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                        }
                    } else {
                        [strongSelf->assetsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[strongSelf getAssetsRowCount]-1 inSection:0]]  withRowAnimation:UITableViewRowAnimationNone];
                    }
                    if (!strongSelf->rightBtn.enabled) {
                        strongSelf->rightBtn.enabled = YES;
                    }
                    
                    if (strongSelf->ablumsArr.count == 0) {
                        void (^assetsEnumerationBlock)(ALAssetsGroup *,BOOL *) = ^(ALAssetsGroup *group,BOOL *stop) {
                            if (!weakSelf) {
                                return ;
                            }
                            __strong typeof(weakSelf) strongSelf = weakSelf;
                            if (group) {
                                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                            }
                            if (group.numberOfAssets > 0) {
                                [strongSelf->ablumsArr addObject:group];
                            }
                        };
                        [strongSelf->assetLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:assetsEnumerationBlock failureBlock:NULL];
                        [strongSelf->assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum
                                                                usingBlock:assetsEnumerationBlock
                                                              failureBlock:NULL];
                        strongSelf->blurImage = [[UIImage screenShoot:strongSelf.navigationController.view]
                                                 applyDarkEffect];
                    }
                }
            } failureBlock:^(NSError *error) {
                
            }];
            strongSelf->captureSession = nil;
            [strongSelf performSelector:@selector(actionRunningCaptureAgain) withObject:nil afterDelay:0.5];
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    __weak typeof(self) weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^{
        if (!weakSelf) {
            return ;
        }
        __strong typeof(weakSelf) strongSelf  = weakSelf;
        strongSelf->captureSession = nil;
        [strongSelf performSelector:@selector(actionRunningCaptureAgain) withObject:nil afterDelay:0.5];
    }];
}

#pragma mark -actionRunningCapture
- (void)actionRunningCaptureAgain {
    [self actionCaptureWithCurrentCamera];
    [self actionRunningCapture];
    [self actionReCaptureVideo];
}

#pragma mark -Private Methods
- (NSUInteger)getAssetsRowCount {
    if (!assetsArr) {
        return 0;
    }
    NSUInteger assetsCount = assetsArr.count;
    assetsCount ++;
    return (assetsCount/3+(assetsCount%3==0?0:1));
}

- (NSUInteger)getLastRowCountOfAssets{
    NSUInteger assetsCount = assetsArr.count;
    assetsCount ++;
    return assetsCount%3==0?3:assetsCount%3;
}

- (NSArray *)getAssetsWithIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = indexPath.row;
    if (assetsArr.count == 0) {
        return nil;
    }
    if (assetsArr.count >= row*3) {
        if (row < [self getAssetsRowCount] -1) {
            return [assetsArr subarrayWithRange:NSMakeRange(row*3, 3)];
        } else {
            NSUInteger assetsCount = assetsArr.count;
            return [assetsArr subarrayWithRange:NSMakeRange(row*3, assetsCount%3)];
        }
    }
    return nil;
}

#pragma mark -actionReloadIndexValue
- (void)actionReloadIndexValue:(NSUInteger)minIndexValue {
    NSArray *arrOfNeedReload = [selectedAssetsArr subarrayWithRange:NSMakeRange(minIndexValue, selectedAssetsArr.count-minIndexValue)];
    for (ALAsset *assetOfReloadIndex in arrOfNeedReload) {
        NSUInteger index = [objc_getAssociatedObject(assetOfReloadIndex, &selectionAssetIndex) intValue];
        NSUInteger row = index/3;
        QSAssetCommonRowCell *cellOfRow = (QSAssetCommonRowCell *)[assetsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
        [cellOfRow actionReloadTextValueWithIndex:index%3];
    }
}

- (UIImage *)screenShoot:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions([view bounds].size, YES, 1.);
    [[view layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *cropImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return cropImage;
}

#pragma mark -LabelProperty
- (void)setLabelProperty:(UILabel *)insertLab font:(NSInteger)fontSize titleColor:(NSString *)colorStr {
    // set insertLab
    [insertLab setBackgroundColor:[UIColor clearColor]];
    // set colorStr
    [insertLab       setTextColor:[UIColor hexChangeFloat:colorStr]];
    // set fontSize
    [insertLab            setFont:[UIFont systemFontOfSize:fontSize]];
}

@end
