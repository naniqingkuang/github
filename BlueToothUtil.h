//
//  BlueToothUtil.h
//  MotionMeasurement
//
//  Created by 猪猪 on 15/9/11.
//  Copyright © 2015年 @猪猪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
@interface BlueToothUtil : NSObject<CBCentralManagerDelegate>
@property (strong, nonatomic) CBCentralManager *centerManager;
+ (BlueToothUtil *)getBlueToothInstance;
- (NSArray *)getNameOfBlueToothList;
- (void)blueToothConnectTo:(NSString *)name block:(void (^)(void)) m_block;
- (void)reScan;
- (void)stopConnect:(NSString *)name;
- (void)readCurrentMotionMeasurement:( void(^)(float equivalent,  float inpulse)) aBlock;
- (void)readDeviceID:(void(^)(NSString *name)) deviceIDBlock;
- (void)readSoftEdition:(void(^)(NSString *softEdition)) softEditionBlock;
- (void)readHareEdition:(void(^)(NSString *hardWareEdition)) aHardWareEditionBlock;
- (void)readDoorLimit:(void(^)(short doorLimit)) aReadDoorLimitBlock;
- (BOOL)isBlueToothConnected;
- (void)stopScan;
- (int)getConnectFlag;
@end
