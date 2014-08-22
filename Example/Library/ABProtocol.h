//
//  ABProtocol.h
//  ABDuino
//
//  Created by liaojinhua on 14-7-15.
//  Copyright (c) 2014年 AprilBrother. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ABProtocolDelegate <NSObject>

- (void)protocolDidReceiveCustomData:(uint8_t *)data length:(uint8_t)length;

- (void)protocolDidReceiveTotalPinCount:(uint8_t)count;
- (void)protocolDidReceivePinCapability:(uint8_t)pin value:(uint8_t)value;
- (void)protocolDidReceivePinMode:(uint8_t)pin mode:(uint8_t)mode;
- (void)protocolDidReceivePinData:(uint8_t)pin mode:(uint8_t)mode value:(uint)value;
- (void)protocolDidPrepareDataToWrite:(NSData *)data;

@optional
- (void)protocolDidReceiveAnalogMapPin:(uint8_t)pin mapPin:(uint8_t)mapPin;

@end

@protocol ABProtocol 

@property (nonatomic, weak) id<ABProtocolDelegate> delegate;

- (void)queryTotalPinCount;
- (void)queryPinAll;
- (void)setPinMode:(uint8_t)pin mode:(uint8_t)mode;
- (void)digitalWrite:(uint8_t)pin value:(uint8_t)value;
- (void)setPinPWM:(uint8_t)pin pwm:(uint8_t)pwm;
- (void)parseData:(unsigned char*)data length:(int)lenght;

@end
