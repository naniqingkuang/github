//
//  BlueToothUtil.m
//  MotionMeasurement
//
//  Created by 猪猪 on 15/9/11.
//  Copyright © 2015年 @猪猪. All rights reserved.
//

#import "BlueToothUtil.h"
static BlueToothUtil* blueTooth;
@interface BlueToothUtil()<CBPeripheralDelegate>

@property (strong, nonatomic) NSMutableArray *discoverPeripheral;
@property (strong, nonatomic) CBCharacteristic *connectCharacristic; //连接的蓝牙
@property (strong, nonatomic) CBPeripheral *connectBlueTooth;
@property (copy, nonatomic) NSString *m_connectBlueToothName;
@property (copy, nonatomic) void(^m_ConnectedBlock)(void);
@property (copy, nonatomic) void(^m_readCurrentMotionMeasurement)(float equivalent,  float inpulse);
@property (copy, nonatomic) void(^m_readDeviceID)(NSString *name);
@property (copy, nonatomic) void(^m_readSoftEdition)(NSString *softEdition);
@property (copy, nonatomic) void(^m_readHardwareEdition)(NSString *hardWareEdition);
@property (copy, nonatomic) void(^m_readDoorLimit)(short doorLimit);
@end

@implementation BlueToothUtil
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.centerManager = [[CBCentralManager alloc]initWithDelegate:self queue:dispatch_get_main_queue()];
        [self.centerManager setDelegate:self];
        self.discoverPeripheral = [[NSMutableArray alloc]initWithCapacity:10];

    }
    return self;
}
+ (BlueToothUtil *)getBlueToothInstance
{
    if(!blueTooth)
    {
        blueTooth = [[BlueToothUtil alloc]init];
    }
    return blueTooth;
}
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSString *state = nil;
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    switch ([central state]) {
        case CBCentralManagerStateUnknown:
            state = @"unknown";
            break;
        case CBCentralManagerStateResetting:
            state = @"resetting";
            break;
        case CBCentralManagerStateUnsupported:
            state = @"unsupported";
            break;
        case CBCentralManagerStateUnauthorized:
            state = @"Unauthorized";
            break;
        case CBCentralManagerStatePoweredOff:
            state = @"off";
            break;
        case CBCentralManagerStatePoweredOn:
            state = @"on";
            [self.centerManager scanForPeripheralsWithServices:nil options:options];
            break;
        default:
            break;
    }
    NSLog(@"blue tooth state: %@",state);
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSString *str = [NSString stringWithFormat:@"Did discover peripheral. peripheral: %@ rssi: %@,  advertisementData: %@ ", peripheral, RSSI,  advertisementData];
    NSLog(@"%@",str);
    NSLog(@"%@",peripheral.name);
    for (CBPeripheral *item in self.discoverPeripheral) {
        if([item.name isEqual:peripheral.name])
        {
            return;
        }
    }
    [self.discoverPeripheral addObject:peripheral];
    [self connectPeripheral:peripheral];
    //    NSArray *keys = [advertisementData allKeys];
    //    NSData *dataAmb, *dataObj;
    //    for (int i = 0; i < [keys count]; ++i) {
    //        id key = [keys objectAtIndex: i];
    //        NSString *keyName = (NSString *) key;
    //        NSObject *value = [advertisementData objectForKey: key];
    //        if ([value isKindOfClass: [NSArray class]]) {
    //            printf("   key: %s\n", [keyName cStringUsingEncoding: NSUTF8StringEncoding]);
    //            NSArray *values = (NSArray *) value;
    //            for (int j = 0; j < [values count]; ++j) {
    //                if ([[values objectAtIndex: j] isKindOfClass: [CBUUID class]]) {
    //                    CBUUID *uuid = [values objectAtIndex: j];
    //                    NSData *data = uuid.data;
    //                    if (j == 0) {
    //                        dataObj = uuid.data;
    //                    } else {
    //                        dataAmb = uuid.data;
    //                    }
    //                    printf("      uuid(%d):", j);
    //                    for (int j = 0; j < data.length; ++j)
    //                        printf(" %02X", ((UInt8 *) data.bytes)[j]);
    //                    printf("\n");
    //                } else {
    //                    const char *valueString = [[value description] cStringUsingEncoding: NSUTF8StringEncoding];
    //                    printf("      value(%d): %s\n", j, valueString);
    //                }
    //            }
    //        } else {
    //            const char *valueString = [[value description] cStringUsingEncoding: NSUTF8StringEncoding];
    //            printf("   key: %s, value: %s\n", [keyName cStringUsingEncoding: NSUTF8StringEncoding], valueString);
    //        }
    //    }
    // [self.tabBarController.navigationController popViewControllerAnimated:YES];
}

- (void)connectPeripheral:(CBPeripheral *)peripheral
{
    if([peripheral.name isEqual:self.m_connectBlueToothName])
    {
        [self.centerManager connectPeripheral:peripheral options:nil];
    }
}
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [self.centerManager stopScan];
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
    if(self.m_ConnectedBlock)
    {
        self.m_ConnectedBlock();
    }
}
- (void)centralManager:(nonnull CBCentralManager *)central didDisconnectPeripheral:(nonnull CBPeripheral *)peripheral error:(nullable NSError *)error
{
    
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if(error)
    {
        return;
    }
    for (CBService *service in peripheral.services) {
        NSLog(@"service:%@",service.UUID.description);
        //  NSString *str = [NSString stringWithUTF8String:service.UUID.description];
        //        if([[service.UUID description] isEqual:[NSString stringWithFormat:@"%@",@"FEE0"]])
        {
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if(error)
    {
        return;
    }
    for (CBCharacteristic *characteristic in service.characteristics) {
        [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        self.connectCharacristic = characteristic;
        self.connectBlueTooth = peripheral;
    }
}
- (void)writeData:(NSData *)anData
{
    [self.connectBlueTooth writeValue:anData forCharacteristic:self.connectCharacristic type:CBCharacteristicWriteWithResponse];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(error)
    {
        return;
    }
    if(characteristic != self.connectCharacristic)
    {
        return;
    }
    else
    {
        unsigned char data[30] = {'\0'};
        unsigned char temp[4] = {'\0'};
        [characteristic.value getBytes:data];
        if(data[0] == 0xA5 && data[1] == 0x02)
        {
            switch (data[3]) {
                case 0x00:
                    if(self.m_readDeviceID)
                    {
                        NSString *str = [NSString stringWithUTF8String:(char *)&data[4]];
                        self.m_readDeviceID(str);
                        self.m_readDeviceID = nil;
                    }
                    break;
                case 0x01:
                    if(self.m_readSoftEdition)
                    {
                        NSString *str = [NSString stringWithUTF8String:(char *)&data[4]];
                        self.m_readSoftEdition(str);
                        self.m_readSoftEdition = nil;
                    }
                    break;
                case 0x02:
                    if(self.m_readHardwareEdition)
                    {
                        NSString *str = [NSString stringWithUTF8String:(char *)&data[4]];
                        self.m_readHardwareEdition(str);
                        self.m_readHardwareEdition = nil;
                    }
                    break;
                case 0x22:
                    if(self.m_readDoorLimit)
                    {
                        temp[0] = data[4];
                        temp[1] = data[5];
                        short *doorLimit = (short *)&temp;
                        self.m_readDoorLimit(*doorLimit);
                        self.m_readDoorLimit = nil;
                    }
                    break;
                case 0x30:
                    if(self.m_readCurrentMotionMeasurement)
                    {
                        temp[0] = data[4];
                        temp[1] = data[5];
                        temp[2] = data[6];
                        temp[3] = data[7];
                        float *Fdata1 = (float*)&temp;
                        temp[0] = data[4];
                        temp[1] = data[5];
                        temp[2] = data[6];
                        temp[3] = data[7];
                        float *Fdata2 = (float*)&temp;
                        self.m_readCurrentMotionMeasurement(*Fdata1, *Fdata2);
                    }
                    break;
                default:
                    break;
            }
        }
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    if(error)
    {
        return;
    }
    if(characteristic != self.connectCharacristic)
    {
        return;
    }
    else
    {
        NSLog(@"%@",characteristic);
        NSString *str = [[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding];;
        NSLog(@"Notification : %@",str);
        //        NSLog(@"str::::::::%s",[characteristic.value bytes]);
        // characteristic.value
    }
    
}
- (void)reConnectBlueTooth
{
    [self.discoverPeripheral removeAllObjects];
    [self.centerManager stopScan];
    if (self.connectBlueTooth && self.connectCharacristic && self.centerManager) {
        [self.connectBlueTooth setNotifyValue:NO forCharacteristic:self.connectCharacristic];
        [self.centerManager cancelPeripheralConnection:self.connectBlueTooth];
        self.connectBlueTooth = nil;
        self.connectCharacristic = nil;
    }
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    [self.centerManager scanForPeripheralsWithServices:nil options:options];
}

- (NSArray *)getNameOfBlueToothList
{
    NSMutableArray *arr = [[NSMutableArray alloc]initWithCapacity:10];
    if(self.discoverPeripheral && self.discoverPeripheral.count)
    {
        for (CBPeripheral *item in self.discoverPeripheral) {
            if(item.name)
            [arr addObject:item.name];
        }
    }
    return arr;
}
- (void)blueToothConnectTo:(NSString *)name block:(void (^)(void)) m_block
{
    if([name isEqual:self.connectBlueTooth.name])
    {
        m_block();
        return;
    }
    self.m_connectBlueToothName = name;
    self.m_ConnectedBlock = m_block;
    [self reConnectBlueTooth];
}
- (void)reScan
{
    [self.centerManager stopScan];
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    [self.centerManager scanForPeripheralsWithServices:nil options:options];
}
- (void)stopConnect:(NSString *)name
{
    [self.centerManager stopScan];
    if([self.m_connectBlueToothName isEqual:name])
    {
        self.m_connectBlueToothName = nil;
        if (self.connectBlueTooth && self.connectCharacristic && self.centerManager) {
            [self.connectBlueTooth setNotifyValue:NO forCharacteristic:self.connectCharacristic];
            [self.centerManager cancelPeripheralConnection:self.connectBlueTooth];
            self.connectBlueTooth = nil;
            self.connectCharacristic = nil;
        }

    }
}
- (void)writeCmcToBlueTooth:(unsigned char)cmd
{
    unsigned char temp[8] = {'\0'};
    temp[0] = 0xA5;
    temp[1] = 0x02;
    temp[2] = 0x01;
    temp[3] = cmd;
    temp[4] = temp[2] + temp[3];
    temp[5] = 0x03;
    [self writeData:[NSData dataWithBytes:&temp length:6]];
}
- (void)setDoorLimit:(short)doorLimit
{
    unsigned char temp[8] = {'\0'};
    unsigned char *data = (unsigned char*)&doorLimit;
    temp[0] = 0xA5;
    temp[1] = 0x02;
    temp[2] = 0x03;
    temp[3] = data[0];
    temp[4] = data[1];
    temp[5] = temp[2] + temp[3] + temp[4];
    temp[6] = 0x03;
    [self writeData:[NSData dataWithBytes:&temp length:7]];
}
- (void)readCurrentMotionMeasurement:( void(^)(float equivalent,  float inpulse)) aBlock
{
    self.m_readCurrentMotionMeasurement = aBlock;
}
- (void)readDeviceID:(void(^)(NSString *name)) deviceIDBlock
{
    self.m_readDeviceID = deviceIDBlock;
    [self writeCmcToBlueTooth:0x00];
}
- (void)readSoftEdition:(void(^)(NSString *softEdition)) softEditionBlock
{
    self.m_readSoftEdition = softEditionBlock;
    [self writeCmcToBlueTooth:0x01];
}
- (void)readHareEdition:(void(^)(NSString *hardWareEdition)) aHardWareEditionBlock
{
    self.m_readHardwareEdition = aHardWareEditionBlock;
    [self writeCmcToBlueTooth:0x02];
}
- (void)readDoorLimit:(void(^)(short doorLimit)) aReadDoorLimitBlock
{
    self.m_readDoorLimit = aReadDoorLimitBlock;
    [self writeCmcToBlueTooth:0x22];

}

@end
