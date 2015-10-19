//
//  FeedBackDetialViewController.m
//  MotionMeasurement
//
//  Created by 猪猪 on 15/9/19.
//  Copyright © 2015年 @猪猪. All rights reserved.
//

#import "FeedBackDetialViewController.h"
#import "RequestUtil.h"
#import "UserUtil.h"
#import "xPhotoViewController.h"
#define COLLECTION_IDENTIFIER @"feedBackDetailCollectionCell"
#define FD_TYPE_DICT @"1":@"疾病反馈",@"2":@"产品反馈",@"3":@"其它"
@interface FeedBackDetialViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) IBOutlet UILabel *feedBackTypeLB;
@property (strong, nonatomic) IBOutlet UITextView *feedBackOontentTextView;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UITextView *answerTextView;
@property (strong, nonatomic) NSMutableArray *imgArr;
@end

@implementation FeedBackDetialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
       // Do any additional setup after loading the view from its nib.
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:COLLECTION_IDENTIFIER];
    [self initData];
}
- (void)initData
{
    UserUtil *item = [RequestUtil getCurrentUser];
    [RequestUtil getFDAnswer:item.userName32 device:item.deviceID18 feedBackID:self.feedBackID block:^(NSDictionary * dict){
        NSString *type = dict[@"msgtype"];
        NSString *content = dict[@"textmsg"];
        NSString *answerContent = dict[@"rcontent"];
        NSArray *arr = dict[@"files"];
        NSMutableArray *filePath = [[NSMutableArray alloc]initWithCapacity:arr.count];
        for (NSDictionary *dict in arr) {
            [filePath addObject:[dict objectForKey:@"file"]];
        }
        if(filePath.count) {
            dispatch_async(dispatch_get_main_queue(), ^{
                for (int i = 0; i < filePath.count; i++) {
                    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[filePath objectAtIndex:i]]];
                    UIImage *image = [UIImage imageWithData:data];
                    [self.imgArr addObject:image];
                }
                [self.collectionView reloadData];
            });
        }
        answerContent = [answerContent stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
        NSDictionary *typeDict = @{FD_TYPE_DICT};
        dispatch_async(dispatch_get_main_queue(), ^{
            self.feedBackTypeLB.text = [NSString stringWithFormat:@" 类型: %@",typeDict[type]];
            self.feedBackOontentTextView.text =[NSString stringWithFormat:@"内容: %@",content];
            self.answerTextView.text = [NSString stringWithFormat:@"%@",answerContent];

        });
    }];
}

- (IBAction)backButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imgArr.count;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(55, 55);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:COLLECTION_IDENTIFIER forIndexPath:indexPath];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:111];
    if(!imageView) {
        imageView = [[UIImageView alloc]init];
        imageView.tag = 111;
        [cell addSubview:imageView];
    }
    
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    xPhotoViewController *photoViewController = [[xPhotoViewController alloc] init];
    photoViewController.index = indexPath.row;
    photoViewController.photoPaths = _imgArr;
    photoViewController.canEdit = YES;
    photoViewController.editBlock = ^(NSInteger index) {
    };
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:photoViewController];
    [self presentViewController:nav animated:YES completion:nil];
}
@end
