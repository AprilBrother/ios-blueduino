//
//  ABArduino.m
//  ABDuino
//
//  Created by liaojinhua on 14-7-14.
//  Copyright (c) 2014年 AprilBrother. All rights reserved.
//

#import "ABArduinoManager.h"
#import "ABArduinoDefine.h"
#import "ABArduino.h"


@interface ABArduinoManager () <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) NSMutableDictionary *peripheralDic;

@property (nonatomic, strong) CBPeripheral *activePeripheral;

@property (nonatomic, strong) CBCharacteristic *txChar;
@property (nonatomic, strong) CBCharacteristic *rxChar;

@property (nonatomic, strong) ABProtocol *protocol;

@property (nonatomic) BOOL startScanWhenPowerOn;

@end

@implementation ABArduinoManager

- (id)init
{
    if (self = [super init]) {
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        
        self.peripheralDic = [NSMutableDictionary dictionary];
        
        self.protocol = [[ABProtocol alloc] init];
    }
    return self;
}

- (void)startScanAprilArduino
{
    if (self.centralManager.state != CBCentralManagerStatePoweredOn) {
        _startScanWhenPowerOn = YES;
    } else {
        [self startScan];
    }
}

- (void)stopScan
{
    [_centralManager stopScan];
}

- (void)connectToPeripheral:(CBPeripheral *)peripheral
{
    NSDictionary *options = @{};
    [self.centralManager connectPeripheral:peripheral options:options];
}

- (void)cancelConnectToPeripheral:(CBPeripheral *)peripheral
{
    [self.centralManager cancelPeripheralConnection:peripheral];
}

- (void)startScan
{
    NSDictionary *options = @{CBCentralManagerScanOptionAllowDuplicatesKey:@(YES)};
    [self.centralManager scanForPeripheralsWithServices:nil options:options];
}

#pragma makr - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state == CBCentralManagerStatePoweredOn) {
        if (_startScanWhenPowerOn) {
            [self startScan];
            _startScanWhenPowerOn = NO;
        }
    }
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI
{
    NSLog(@"find peripheral:%@ has prefix:%d", peripheral, [peripheral.name hasPrefix:ABArduinoPrefixName]);
    
    if ([peripheral.name hasPrefix:ABArduinoPrefixName]) {

        if (!self.peripheralDic[peripheral]) {
            ABArduino *arduino = [[ABArduino alloc] init];
            arduino.peripheral = peripheral;
            arduino.manager = self;
            [self.peripheralDic setObject:arduino forKey:peripheral];
        }
        if(_delegate && [_delegate respondsToSelector:@selector(arduino:didDiscoverPeripherals:)]) {
            [_delegate arduino:self didDiscoverPeripherals:[self.peripheralDic allValues]];
        }
    }
}

- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)peripheral
{
    [peripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central
didFailToConnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error
{
    ABArduino *arduino = _peripheralDic[peripheral];
    if (arduino) {
        [arduino didConnected:error];
    }
}

- (void)centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error
{
    ABArduino *arduino = _peripheralDic[peripheral];
    if (arduino) {
        [arduino didDisconnected:error];
    }
}

@end
