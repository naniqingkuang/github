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
@property (copy, nonatomic) void(^m_readBatterySumBlock)(short sum);
@property (assign, nonatomic) BOOL isConnetct;
@end
#define SERVICE_UUID     0xFFE0
#define CHAR_UUID        0xFFE1

@implementation BlueToothUtil
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.centerManager = [[CBCentralManager alloc]initWithDelegate:self queue:dispatch_get_main_queue()];
        [self.centerManager setDelegate:self];
        self.isConnetct = NO;
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
    printf("Now we found device\n");
    if (!_discoverPeripheral) {
        _discoverPeripheral = [[NSMutableArray alloc] initWithObjects:peripheral, nil];
//        for (int i = 0; i < [_discoverPeripheral count]; i++) {
//            [delegate peripheralFound: peripheral];
//        }
    }
    
    {
        if((__bridge CFUUIDRef )peripheral.identifier == NULL) return;
        //if(peripheral.name == NULL) return;
        //if(peripheral.name == nil) return;
        if(peripheral.name.length < 1) return;
        // Add the new peripheral to the peripherals array
        for (int i = 0; i < [_discoverPeripheral count]; i++) {
            CBPeripheral *p = [_discoverPeripheral objectAtIndex:i];
            if((__bridge CFUUIDRef )p.identifier == NULL) continue;
            CFUUIDBytes b1 = CFUUIDGetUUIDBytes((__bridge CFUUIDRef )p.identifier);
            CFUUIDBytes b2 = CFUUIDGetUUIDBytes((__bridge CFUUIDRef )peripheral.identifier);
            if (memcmp(&b1, &b2, 16) == 0) {
                // these are the same, and replace the old peripheral information
                [_discoverPeripheral replaceObjectAtIndex:i withObject:peripheral];
                printf("Duplicated peripheral is found...\n");
                //[delegate peripheralFound: peripheral];
                return;
            }
        }
        printf("New peripheral is found...\n");
        [_discoverPeripheral addObject:peripheral];
        [self connectPeripheral:peripheral];
        //[delegate peripheralFound:peripheral];
        return;
    }
//    NSLog(@"name:  %@",peripheral.name);
//    [self.discoverPeripheral addObject:peripheral];
//    [self connectPeripheral:peripheral];
}

- (void)connectPeripheral:(CBPeripheral *)peripheral
{
    if(self.connectBlueTooth) {
        if([self.connectBlueTooth.name isEqualToString: peripheral.name] && self.isConnetct) {
            return;
        }
    }
    if([peripheral.name isEqualToString:self.m_connectBlueToothName])
    {
        [self.centerManager stopScan];
        [self.centerManager connectPeripheral:peripheral options:nil];
    }
}
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    self.isConnetct = YES;
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
    if(self.m_ConnectedBlock)
    {
        self.m_ConnectedBlock();
    }
}
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    self.isConnetct = false;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reScan];
    });
}
- (void)centralManager:(nonnull CBCentralManager *)central didDisconnectPeripheral:(nonnull CBPeripheral *)peripheral error:(nullable NSError *)error
{
    self.isConnetct = false;
    dispatch_async(dispatch_get_main_queue(), ^{
            [self reScan];
        });
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
       // if([[service.UUID description] isEqual:[NSString stringWithFormat:@"%@",@"FEE0"]])
        {
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
}
-(void) notification:(int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p on:(BOOL)on {
    UInt16 s = [self swap:serviceUUID];
    UInt16 c = [self swap:characteristicUUID];
    NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
    NSData *cd = [[NSData alloc] initWithBytes:(char *)&c length:2];
    CBUUID *su = [CBUUID UUIDWithData:sd];
    CBUUID *cu = [CBUUID UUIDWithData:cd];
    CBService *service = [self findServiceFromUUIDEx:su p:p];
    if (!service) {
        printf("Could not find service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:su],[self UUIDToString:(__bridge CFUUIDRef )p.identifier]);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUIDEx:cu service:service];
    self.connectCharacristic = characteristic;
    if (!characteristic) {
        printf("Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],[self UUIDToString:(__bridge CFUUIDRef )p.identifier]);
        return;
    }
    [p setNotifyValue:on forCharacteristic:characteristic];
}

-(void) notify: (CBPeripheral *)peripheral on:(BOOL)on
{
    [self notification:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral on:YES];
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (!error) {
        printf("Characteristics of service with UUID : %s found\r\n",[self CBUUIDToString:service.UUID]);
        for(int i = 0; i < service.characteristics.count; i++) { //Show every one
            CBCharacteristic *c = [service.characteristics objectAtIndex:i];
            printf("Found characteristic %s\r\n",[ self CBUUIDToString:c.UUID]);
        }
        
        char t[16];
        t[0] = (SERVICE_UUID >> 8) & 0xFF;
        t[1] = SERVICE_UUID & 0xFF;
        NSData *data = [[NSData alloc] initWithBytes:t length:16];
        CBUUID *uuid = [CBUUID UUIDWithData:data];
        //CBService *s = [peripheral.services objectAtIndex:(peripheral.services.count - 1)];
        if([self compareCBUUID:service.UUID UUID2:uuid]) {
            printf("Try to open notify\n");
            [self notify:peripheral on:YES];
            self.connectBlueTooth = peripheral;
        }
    }
    else {
        printf("Characteristic discorvery unsuccessfull !\r\n");
    }

//    if(error)
//    {
//        return;
//    }
//    for (CBCharacteristic *characteristic in service.characteristics) {
////        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_ISSC_TRANS_RX]]){
////            
////        }
//        [peripheral setNotifyValue:YES forCharacteristic:characteristic];
//        self.connectCharacristic = characteristic;
//        self.connectBlueTooth = peripheral;
//    }
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
                case 0x03:
                    if(self.m_readBatterySumBlock)
                    {
                        temp[0] = data[4];
                        temp[1] = data[5];
                        short *sum = (short *)&temp;
                        self.m_readBatterySumBlock(*sum);
                        self.m_readBatterySumBlock = nil;
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
                        self.m_readCurrentMotionMeasurement(*(float*)&data[4], *(float*)&data[8]);
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
    if([name isEqualToString:self.connectBlueTooth.name])
    {
        m_block();
        return;
    }
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if([name isEqualToString:[userDefault objectForKey:@"blueToothName"]]) {
        self.m_connectBlueToothName = [userDefault objectForKey:@"blueToothName"];
    }
    self.m_ConnectedBlock = m_block;
    [self reConnectBlueTooth];
}
- (void)reScan
{
    if(!self.isConnetct) {
        [self.centerManager stopScan];
        self.m_connectBlueToothName = [[NSUserDefaults standardUserDefaults] objectForKey:@"blueToothName"];
        if(self.discoverPeripheral) {
            [self.discoverPeripheral removeAllObjects];
        }
        NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
        [self.centerManager scanForPeripheralsWithServices:nil options:options];
    }
}
- (void)stopConnect:(NSString *)name
{
    [self.centerManager stopScan];
    if([self.m_connectBlueToothName isEqualToString:name])
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
- (void)stopScan {
    [self.centerManager stopScan];
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
    [self writeValue:SERVICE_UUID characteristicUUID:CHAR_UUID p:self.connectBlueTooth data:[NSData dataWithBytes:&temp length:6]];
    //[self writeData:[NSData dataWithBytes:&temp length:6]];
}

-(UInt16) swap:(UInt16)s {
    UInt16 temp = s << 8;
    temp |= (s >> 8);
    return temp;
}
-(CBService *) findServiceFromUUIDEx:(CBUUID *)UUID p:(CBPeripheral *)p {
    for(int i = 0; i < p.services.count; i++) {
        CBService *s = [p.services objectAtIndex:i];
        if ([self compareCBUUID:s.UUID UUID2:UUID]) return s;
    }
    return nil; //Service not found on this peripheral
}
-(int) compareCBUUID:(CBUUID *) UUID1 UUID2:(CBUUID *)UUID2 {
    char b1[16];
    char b2[16];
    [UUID1.data getBytes:b1];
    [UUID2.data getBytes:b2];
    if (memcmp(b1, b2, UUID1.data.length) == 0)return 1;
    else return 0;
}

-(const char *) UUIDToString:(CFUUIDRef)UUID {
    if (!UUID) return "NULL";
    CFStringRef s = CFUUIDCreateString(NULL, UUID);
    return CFStringGetCStringPtr(s, 0);
    
}
-(const char *) CBUUIDToString:(CBUUID *) UUID {
    return [[UUID.data description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy];
}
-(CBCharacteristic *) findCharacteristicFromUUIDEx:(CBUUID *)UUID service:(CBService*)service {
    for(int i=0; i < service.characteristics.count; i++) {
        CBCharacteristic *c = [service.characteristics objectAtIndex:i];
        if ([self compareCBUUID:c.UUID UUID2:UUID]) return c;
    }
    return nil; //Characteristic not found on this service
}

-(void) writeValue:(int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p data:(NSData *)data {
    UInt16 s = [self swap:serviceUUID];
    UInt16 c = [self swap:characteristicUUID];
    NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
    NSData *cd = [[NSData alloc] initWithBytes:(char *)&c length:2];
    CBUUID *su = [CBUUID UUIDWithData:sd];
    CBUUID *cu = [CBUUID UUIDWithData:cd];
    CBService *service = [self findServiceFromUUIDEx:su p:p];
    if (!service) {
        printf("Could not find service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:su],[self UUIDToString:(__bridge CFUUIDRef )p.identifier]);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUIDEx:cu service:service];
    if (!characteristic) {
        printf("Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],[self UUIDToString:(__bridge CFUUIDRef )p.identifier]);
        return;
    }
    
    if(characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse)
    {
        [p writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
    }else
    {
        [p writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    }
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
- (void)readBatterySum:(void(^)(short batterySum)) aBatterySumReadBlock{
    self.m_readBatterySumBlock = aBatterySumReadBlock;
    [self writeCmcToBlueTooth:0x03];
}
- (void)readDoorLimit:(void(^)(short doorLimit)) aReadDoorLimitBlock
{
    self.m_readDoorLimit = aReadDoorLimitBlock;
    [self writeCmcToBlueTooth:0x22];

}
- (BOOL)isBlueToothConnected {
    
    if(self.connectBlueTooth && self.connectCharacristic && (self.connectBlueTooth.state == CBPeripheralStateConnected || self.connectBlueTooth.state == CBPeripheralStateConnecting)) {
        if([self.connectBlueTooth.name isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"blueToothName"]]) {
            return true;
        }
    }
    return false;
}
- (int)getConnectFlag {
    if(self.connectBlueTooth && self.connectCharacristic ) {
        return self.connectBlueTooth.state;
    }
    return 0;
}
@end
