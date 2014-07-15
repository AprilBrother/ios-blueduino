//
//  ABArduino.h
//  ABDuino
//
//  Created by liaojinhua on 14-7-15.
//  Copyright (c) 2014年 AprilBrother. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "ABProtocol.h"

@class ABArduino;
@class ABArduinoManager;

@protocol  ABArduinoDelegate <NSObject>

- (void)arduino:(ABArduino *)arduino didConnected:(NSError *)error;
- (void)arduino:(ABArduino *)arduino didDisConnected:(NSError *)error;

@end

@interface ABArduino : NSObject<CBPeripheralDelegate>

@property (nonatomic, weak) ABArduinoManager *manager;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, weak) id<ABArduinoDelegate, ABProtocolDelegate> delegate;

- (void)connect;
- (void)didConnected:(NSError *)error;
- (void)disconnect;
- (void)didDisconnected:(NSError *)error;
- (void)writeData:(NSData *)data;

#pragma mark - arduino protocol
- (void)queryTotalPinCount;
- (void)queryPinAll;
- (void)setPinMode:(uint8_t)pin mode:(uint8_t)mode;
- (void)digitalWrite:(uint8_t)pin value:(uint8_t)value;
- (void)setPinPWM:(uint8_t)pin pwm:(uint8_t)pwm;

@end
