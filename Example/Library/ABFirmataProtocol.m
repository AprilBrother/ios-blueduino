//
//  ABFimataProtocol.m
//  Example
//
//  Created by liaojinhua on 14-8-21.
//  Copyright (c) 2014年 AprilBrother. All rights reserved.
//

#import "ABFirmataProtocol.h"
#import "ABArduinoDefine.h"

@implementation ABFirmataProtocol

@synthesize delegate;

- (void)queryTotalPinCount
{
    
}
- (void)queryPinAll
{
    uint8_t buf[] = {START_SYSEX, CAPABILITY_QUERY, END_SYSEX};
    
    NSData *nsData = [[NSData alloc] initWithBytes:buf length:3];
    [self write:nsData];
}
- (void)setPinMode:(uint8_t)pin mode:(uint8_t)mode
{
    uint8_t buf[] = {SET_PIN_MODE, pin, mode};
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [self write:data];
}
- (void)digitalWrite:(uint8_t)pin value:(uint8_t)value
{
    
}
- (void)setPinPWM:(uint8_t)pin pwm:(uint8_t)pwm
{
    uint8_t buf[] = {START_SYSEX, EXTENDED_ANALOG, pin, pwm, pwm >> 7, END_SYSEX};
    NSData *data = [[NSData alloc] initWithBytes:buf length:6];
    [self write:data];
}
- (void)parseData:(unsigned char*)data length:(int)lenght
{
    uint8_t i = 0;
    
    while (i < lenght) {
        
        uint8_t command = data[i++];
        if (command == START_SYSEX) {
            uint8_t startIndex = i;
            uint8_t j = 0;
            while (i < lenght) {
                command = data[i++];
                if (command == END_SYSEX) {
                    j = --i;
                    break;
                }
            }
            if (j == 0) {
                // drop dirty data
            } else {
                [self parseCommand:&data[startIndex] length:j - startIndex];
            }
        }
    }
}


#pragma mark - private

- (void)queryPinState:(uint8_t)pin
{
    uint8_t buf[] = {START_SYSEX, PIN_STATE_QUERY, pin, END_SYSEX};
    NSData *nsData = [[NSData alloc] initWithBytes:buf length:4];
    [self write:nsData];
}

- (void)queryAnalogMapPin
{
    uint8_t buf[] = {START_SYSEX, ANALOG_MAPPING_QUERY, END_SYSEX};
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [self write:data];
}
- (void)parseCommand:(unsigned char *)data length:(int)length
{
    uint8_t i = 0;
    uint8_t command = data[i++];
    switch (command) {
        case CAPABILITY_RESPONSE:
        {
            uint8_t pin = 0;
            uint8_t value = data[i++];
            while (i < length) {
                uint8_t pinCap = 0;
                while (value != 127) {
                    if (value == INPUT || value == OUTPUT) {
                        pinCap |= PIN_CAPABILITY_DIGITAL;
                    } else if (value == ANALOG) {
                        pinCap |= PIN_CAPABILITY_ANALOG;
                    } else if (value == PWM) {
                        pinCap |= PIN_CAPABILITY_PWM;
                    }
                    // skip resolution value;
                    i++;
                    value = data[i++];
                }
                if (pinCap != PIN_CAPABILITY_NONE) {
                    [self.delegate protocolDidReceivePinCapability:pin value:pinCap];
                    [self queryPinState:pin];
                }
                value = data[i++];
                pin++;
            }
            [self queryAnalogMapPin];
        }
            break;
        case PIN_STATE_RESPONSE:
        {
            uint8_t pin = data[i++];
            uint8_t mode = data[i++];
            if (mode != END_SYSEX) {
                uint32_t value = data[i++];
                uint32_t hightValue = data[i++];
                if (hightValue != END_SYSEX) {
                    value += hightValue << 7;
                }
                hightValue = data[i++];
                if (hightValue != END_SYSEX) {
                    value += hightValue << 14;
                }
                [self.delegate protocolDidReceivePinData:pin mode:mode value:value];
            }
            
        }
            break;
            
        case ANALOG_MAPPING_RESPONSE:
        {
            if (!self.delegate || ![self.delegate respondsToSelector:@selector(protocolDidReceiveAnalogMapPin:mapPin:)]) {
                break;
            }
            uint8_t pin = 0;
            while (i < length) {
                uint8_t mapPin = data[i++];
                if (mapPin != 127) {
                    [self.delegate protocolDidReceiveAnalogMapPin:pin mapPin:mapPin];
                }
                pin++;
            }
        }
            break;
            
        default:
            break;
    }

}
- (void)write:(NSData *)data
{
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(protocolDidPrepareDataToWrite:)]) {
        [self.delegate protocolDidPrepareDataToWrite:data];
    }
}
@end
