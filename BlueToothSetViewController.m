//
//  BlueToothSetViewController.m
//  testProject
//
//  Created by 猪猪 on 15/8/13.
//  Copyright (c) 2015年 @猪猪. All rights reserved.
//

#import "BlueToothSetViewController.h"
#import "SliderViewController.h"
@interface BlueToothSetViewController ()<CBPeripheralDelegate,UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) NSMutableArray *discoverPeripheral;
@property (strong, nonatomic) CBCharacteristic *connectCharacristic; //连接的蓝牙
@property (strong, nonatomic) CBPeripheral *connectBlueTooth;
@end

@implementation BlueToothSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //创建中心设备
    self.centerManager = [[CBCentralManager alloc]initWithDelegate:self queue:dispatch_get_main_queue()];
    [self.centerManager setDelegate:self];
    self.discoverPeripheral = [[NSMutableArray alloc]initWithCapacity:10];
    
    // Do any additional setup after loading the view.
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if(self.connectBlueTooth)
    [self.centerManager cancelPeripheralConnection:self.connectBlueTooth];
}
#pragma mark CBCentralManager的代理方法
////CBCentralManagerStateUnknown = 0,
//CBCentralManagerStateResetting,
//CBCentralManagerStateUnsupported,
//CBCentralManagerStateUnauthorized,
//CBCentralManagerStatePoweredOff,
//CBCentralManagerStatePoweredOn,

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
- (IBAction)scanBlueTooth:(UIButton *)sender {
    //[self.centerManager scanForPeripheralsWithServices:nil options:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSString *str = [NSString stringWithFormat:@"Did discover peripheral. peripheral: %@ rssi: %@,  advertisementData: %@ ", peripheral, RSSI,  advertisementData];
    NSLog(@"%@",str);
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
    if([peripheral.name isEqual:@"猪猪的MacBook Air"])
    {
        [self.centerManager connectPeripheral:peripheral options:nil];
    }
}
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [self.centerManager stopScan];
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
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
            [peripheral readValueForCharacteristic:characteristic];
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
//    if(characteristic != self.connectCharacristic)
//    {
//        return;
//    }
    else
    {
        NSLog(@"%@",characteristic);
        NSString *str = [[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding];;
        NSLog(@"%@",str);
//        NSLog(@"str::::::::%s",[characteristic.value bytes]);
       // characteristic.value
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)viewWillAppear:(BOOL)animated
{
   // [self.connectBlueTooth  readValueForCharacteristic:self.connectCharacristic];
}
- (IBAction)backToSetting:(UIBarButtonItem *)sender {
   // [[SliderViewController sharedSliderController]leftItemClick];
//    if(self.connectCharacristic && self.connectBlueTooth)
//    {
//        [self.connectBlueTooth  readValueForCharacteristic:self.connectCharacristic];
//    }
//    else
//    {
//        NSLog(@"NULL value...");
//    }
    [self.centerManager stopScan];
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    [self.centerManager scanForPeripheralsWithServices:nil options:options];}


#pragma mark tableview deledate an datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *myCellid = @"blueToothtableviewcell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myCellid];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]init];
    }
    return cell;
}
@end
