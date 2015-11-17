//
//  FeedBackViewController.m
//  MotionMeasurement
//
//  Created by 猪猪 on 15/9/10.
//  Copyright © 2015年 @猪猪. All rights reserved.
//

#import "FeedBackViewController.h"
#import "RequestUtil.h"
#import "UserUtil.h"
#import "QSAssetLibraryViewController.h"
#import "UIImage+Util.h"
#import "xPhotoViewController.h"
#import "MBProgressHUD+Util.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#define COLLECTION_IDENTIFIER @"feedBackCollectionIndentifier"
@interface FeedBackViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) IBOutlet UITextView *contentTExtView;
@property (strong, nonatomic) IBOutlet UIButton *button1;
@property (strong, nonatomic) IBOutlet UIButton *button2;
@property (strong, nonatomic) IBOutlet UIButton *button3;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSString *fdType;
@property (strong, nonatomic) NSMutableArray *imgArr;
@property (strong, nonatomic) AVAudioRecorder *recoder;
@property (strong, nonatomic) NSURL *recoderFileUrlTemp;
@property (strong, nonatomic) AVAudioPlayer * player;
@property (strong, nonatomic) IBOutlet UIButton *voiceBT;

@end

@implementation FeedBackViewController
- (IBAction)feedBackComit:(id)sender {
    [self startPlay];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fdType = @"1";
    [self audioInit];
    self.voiceBT.hidden = YES;
    self.button1.backgroundColor = [UIColor grayColor];
    _imgArr = [[NSMutableArray alloc]initWithCapacity:8];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:COLLECTION_IDENTIFIER];

    // Do any additional setup after loading the view from its nib.
}
- (void)dealloc {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:NO error:nil];
}
- (void)audioInit {

    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [session setActive:YES error:nil];
    
    NSArray *arr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *str = [arr[0] stringByAppendingPathComponent:@"recoder.wav"];
    self.recoderFileUrlTemp = [NSURL fileURLWithPath:str];
    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:                                   [NSNumber numberWithFloat: 44100.0],AVSampleRateKey,                                    [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,[NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,[NSNumber numberWithInt: 2], AVNumberOfChannelsKey,[NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,[NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,nil];
    ////采样信号是整数还是浮点数
    

    NSError *err = nil;
    self.recoder = [[AVAudioRecorder alloc]initWithURL:self.recoderFileUrlTemp settings:recordSetting error:&err];
}
- (IBAction)startRecordAction:(id)sender {
    [self.recoder prepareToRecord];
    [self.recoder record];
    UIButton *button = sender;
    button.backgroundColor = [UIColor grayColor];
}

- (IBAction)stopRecordAction:(id)sender {
    [self.recoder stop];
    UIButton *button = sender;
    button.backgroundColor = [UIColor greenColor];
    self.voiceBT.hidden = NO;
}
- (IBAction)commitRequset:(id)sender {
    NSMutableArray *imgUrlList = [[NSMutableArray alloc]initWithCapacity:self.imgArr.count +1];
    UserUtil *item = [RequestUtil getCurrentUser];
    NSArray *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [docDir objectAtIndex:0];
    NSString *dataPath = nil;
    NSData *imgData = nil;
    if(self.imgArr && self.imgArr.count) {
        for (int i = 0; i < _imgArr.count; i++) {
            UIImage *item = [_imgArr objectAtIndex:i];
            dataPath = [filePath stringByAppendingFormat:@"/%d.jpg",i];
            if(UIImagePNGRepresentation(item)) {
                imgData = UIImagePNGRepresentation(item);
            } else {
                imgData = UIImageJPEGRepresentation(item, 1);
            }
            [imgData writeToFile:dataPath atomically:YES];
            [imgUrlList addObject:dataPath];
        }
    }
    [MBProgressHUD showMessage:@"正在上传..."];
    [RequestUtil uploadFeedBack:item.userName32 device:item.deviceID18 content:self.contentTExtView.text type:self.fdType image:imgUrlList voice:self.recoderFileUrlTemp block:^{
        [MBProgressHUD hideHUD];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)startPlay {
    if(self.recoderFileUrlTemp) {
        NSError *err = nil;
        NSData *data = [NSData dataWithContentsOfURL:self.recoderFileUrlTemp];
        self.player = [[AVAudioPlayer alloc]initWithData:data error:&err];
        _player.volume = 1.0;
        _player.numberOfLoops = 0;
        _player.currentTime = 0.0;
        [_player prepareToPlay];
        [_player play];
    }
}
- (void)endPlay {
    if(_player) {
        [_player stop];
    }
}
- (IBAction)backButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)selectType:(id)sender {
    self.button1.backgroundColor = [UIColor clearColor];
    self.button2.backgroundColor = [UIColor clearColor];
    self.button3.backgroundColor = [UIColor clearColor];
    UIButton *button = sender;
    button.backgroundColor = [UIColor grayColor];
    if(button == self.button1) {
        self.fdType = @"1";
    } else if(button == self.button2) {
        self.fdType = @"2";
    } else if(button == self.button3) {
        self.fdType = @"3";
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imgArr.count +1;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:COLLECTION_IDENTIFIER forIndexPath:indexPath];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:111];
    if (!imageView) {
        imageView =[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 55., 55.)];
        imageView.tag = 111;
        [cell addSubview:imageView];
    }
    
    if (indexPath.row == _imgArr.count) {
        imageView.image = [UIImage imageNamed:@"add"];
    } else {
        imageView.image = _imgArr[indexPath.row];
    }
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
#pragma mark UICollectionViewDelegate


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.imgArr && indexPath.row == _imgArr.count) {
        [self actionEnterAssetLibrary:5 - _imgArr.count];
    } else {
        xPhotoViewController *photoViewController = [[xPhotoViewController alloc] init];
        photoViewController.index = indexPath.row;
        photoViewController.photoPaths = _imgArr;
        photoViewController.canEdit = YES;
        __weak FeedBackViewController *weakSelf = self;
        photoViewController.editBlock = ^(NSInteger index) {
            [weakSelf removeImage:index];
        };
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:photoViewController];
        [self presentViewController:nav animated:YES completion:nil];
    }
    
}
#pragma mark UICollectionViewDelegateFlowLayout 
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(55, 55);
}

#pragma private methods
// 多选图片调用方法
- (void)actionEnterAssetLibrary:(NSInteger)counts {
    QSAssetLibraryViewController *assetLibraryViewController = [[QSAssetLibraryViewController alloc] init];
    assetLibraryViewController.numberOfCouldSelectAssets = counts;
    __weak typeof(self) weakSelf = self;
    assetLibraryViewController.selectAssetsBlock = ^(NSArray *assetArr){
        if (weakSelf) {
            for (int i=0; i != assetArr.count; i++) {
                ALAsset *asset = [assetArr objectAtIndex:i];
                UIImage *image = [[UIImage alloc] initWithCGImage:[[asset  defaultRepresentation] fullScreenImage]];
                //by haijian
                UIImage *scaledImage=[image scaleToSize:CGSizeMake(200, 200)];
                [weakSelf addImage:scaledImage];
            }
            [self.collectionView reloadData];
        }
    };
    
    UINavigationController *assetNavigationController = [[UINavigationController alloc] initWithRootViewController:assetLibraryViewController];
    [self presentViewController:assetNavigationController animated:YES completion:nil];
}
// 添加图片
- (void)addImage:(UIImage *)image {
    [self.imgArr addObject:image];
}
- (void)removeImage:(NSInteger )index {
    [self.imgArr removeObjectAtIndex:index];
    [self.collectionView reloadData];
}
@end
