//
//  BlueToothSetViewController.h
//  testProject
//
//  Created by 猪猪 on 15/8/13.
//  Copyright (c) 2015年 @猪猪. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BlueToothSetViewController : UIViewController<CBCentralManagerDelegate>
@property (strong, nonatomic) CBCentralManager *centerManager;
@end
