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

@protocol ABArduinoDelegate <NSObject>

- (void)arduino:(ABArduino *)arduino didConnected:(NSError *)error;
- (void)arduino:(ABArduino *)arduino didDisConnected:(NSError *)error;
- (void)arduinoDidUpdateData;

@end

@interface ABPin : NSObject

@property (nonatomic) NSInteger pin;
@property (nonatomic) NSInteger capability;
@property (nonatomic) NSInteger currentMode;
@property (nonatomic) NSInteger value;

@end

@interface ABArduino : NSObject<CBPeripheralDelegate, ABProtocolDelegate>

@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, weak) ABArduinoManager *manager;
@property (nonatomic, weak) id<ABArduinoDelegate> delegate;

- (void)connect;
- (void)didConnected:(NSError *)error;
- (void)disconnect;
- (void)didDisconnected:(NSError *)error;
- (void)writeData:(NSData *)data;
- (ABPin *)pinAtIndex:(NSInteger)index;
- (ABPin *)pin:(NSInteger)pin;
- (NSInteger)totalPinCount;

#pragma mark - arduino protocol
- (void)queryTotalPinCount;
- (void)queryPinAll;
- (void)setPinMode:(uint8_t)pin mode:(uint8_t)mode;
- (void)digitalWrite:(uint8_t)pin value:(uint8_t)value;
- (void)setPinPWM:(uint8_t)pin pwm:(uint8_t)pwm;

@end
