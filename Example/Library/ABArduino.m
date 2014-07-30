//
//  ABArduino.m
//  ABDuino
//
//  Created by liaojinhua on 14-7-15.
//  Copyright (c) 2014年 AprilBrother. All rights reserved.
//

#import "ABArduino.h"
#import "ABProtocol.h"
#import "ABArduinoDefine.h"
#import "ABArduinoManager.h"

@interface ABArduino ()

@property (nonatomic, strong) CBCharacteristic *rxChar;
@property (nonatomic, strong) CBCharacteristic *txChar;

@property (nonatomic, strong) ABProtocol *protocol;

@end

@implementation ABArduino

- (id)init
{
    if (self = [super init]) {
        self.protocol = [[ABProtocol alloc] init];
        self.protocol.arduino = self;
    }
    return self;
}

- (void)setDelegate:(id<ABArduinoDelegate,ABProtocolDelegate>)delegate
{
    _delegate = delegate;
    self.protocol.delegate = delegate;
}

- (void)setPeripheral:(CBPeripheral *)peripheral
{
    _peripheral = peripheral;
    _peripheral.delegate = self;
}

- (void)connect
{
    [self.manager connectToPeripheral:self.peripheral];
}

- (void)didConnected:(NSError *)error
{
    if (_delegate && [_delegate respondsToSelector:@selector(arduino:didDisConnected:)]) {
        [_delegate arduino:self didConnected:error];
    }
}

- (void)disconnect
{
    [self.manager cancelConnectToPeripheral:self.peripheral];
}
- (void)didDisconnected:(NSError *)error
{
    if (_delegate && [_delegate respondsToSelector:@selector(arduino:didDisConnected:)]) {
        [_delegate arduino:self didDisConnected:error];
    }
}

- (void)writeData:(NSData *)data
{
    if (_rxChar) {
        [self.peripheral writeValue:data forCharacteristic:_rxChar type:CBCharacteristicWriteWithResponse];
    }
}

#pragma mark - arduino protocol
- (void)queryTotalPinCount
{
    [self.protocol queryTotalPinCount];
}
- (void)queryPinAll
{
    [self.protocol queryPinAll];
}
- (void)setPinMode:(uint8_t)pin mode:(uint8_t)mode
{
    [self.protocol setPinMode:pin mode:mode];
}
- (void)digitalWrite:(uint8_t)pin value:(uint8_t)value
{
    [self.protocol digitalWrite:pin value:value];
}
- (void)setPinPWM:(uint8_t)pin pwm:(uint8_t)pwm
{
    [self.protocol setPinPWM:pin pwm:pwm];
}

#pragma mark - CBPeripheralDelegate
- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverServices:(NSError *)error
{
    if (error) {
        if (_delegate && [_delegate respondsToSelector:@selector(arduino:didConnected:)]) {
            [_delegate arduino:self didConnected:error];
        }
        [self.manager cancelConnectToPeripheral:peripheral];
        return;
    }
    for (CBService *service in peripheral.services) {
        if ([service.UUID.UUIDString isEqualToString:SERVICE_UUID.UUIDString]) {
            [peripheral discoverCharacteristics:nil forService:service];
            break;
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverCharacteristicsForService:(CBService *)service
             error:(NSError *)error
{
    if(_delegate && [_delegate respondsToSelector:@selector(arduino:didConnected:)]) {
        if (error) {
            [self.manager cancelConnectToPeripheral:peripheral];
        } else {
            for (CBCharacteristic *aChar in service.characteristics) {
                if ([aChar.UUID isEqual:CHAR_TX_UUID]) {
                    self.txChar = aChar;
                    [peripheral setNotifyValue:YES forCharacteristic:aChar];
                } else if ([aChar.UUID isEqual:CHAR_RX_UUID]) {
                    self.rxChar = aChar;
                }
            }
        }
        [_delegate arduino:self didConnected:error];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral
didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error
{
    unsigned char data[20];
    
    static unsigned char buf[512];
    static int len = 0;
    NSInteger data_len;
    
    if (!error) {
        if ([characteristic.UUID isEqual:CHAR_TX_UUID]) {
            data_len = characteristic.value.length;
            [characteristic.value getBytes:data length:data_len];
            
            if (data_len == 20) {
                memcpy(&buf[len], data, 20);
                len += data_len;
                
                if (len >= 64) {
                    [self.protocol parseData:buf length:len];
                    memset(buf, 0, 512);
                    len = 0;
                }
            } else if (data_len < 20) {
                memcpy(&buf[len], data, data_len);
                len += data_len;
                
                [self.protocol parseData:buf length:len];
                memset(buf, 0, 512);
                len = 0;
            }
        }
    } else {
        NSLog(@"updateValueForCharacteristic failed!");
    }

}


@end
