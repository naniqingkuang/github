//
//  BlueToothTableViewCell.h
//  MotionMeasurement
//
//  Created by 猪猪 on 15/9/11.
//  Copyright © 2015年 @猪猪. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlueToothTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *contextLabel;
@property (strong, nonatomic) IBOutlet UIImageView *m_imageView;

@end
