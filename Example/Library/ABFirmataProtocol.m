//
//  ABFimataProtocol.m
//  Example
//
//  Created by liaojinhua on 14-8-21.
//  Copyright (c) 2014年 AprilBrother. All rights reserved.
//

#import "ABFirmataProtocol.h"
#import "ABArduinoDefine.h"

@interface ABFirmataProtocol ()

@property (nonatomic, strong) NSMutableArray *reportPort;
@property (nonatomic, strong) NSMutableArray *portConfigInput;
@property (nonatomic, strong) NSMutableArray *portValue;

@end

@implementation ABFirmataProtocol

@synthesize delegate;

- (id)init
{
    if (self = [super init]) {
        _reportPort = [NSMutableArray array];
        _portConfigInput = [NSMutableArray array];
        _portValue = [NSMutableArray array];
        for (NSInteger index = 0; index < TOTAL_PORTS; index++) {
            [_reportPort addObject:@(NO)];
            [_portConfigInput addObject:@(0)];
            [_portValue addObject:@(0)];
        }
    }
    return self;
}

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
    if (mode == INPUT) {
        [self checkPinReport:pin];
    }
    
    NSInteger portConfg = [_portConfigInput[[self pinToPort:pin]] intValue];
    if (mode == INPUT) {
        portConfg |= (1 << (pin & 7));
    } else {
        portConfg &= ~(1 << (pin & 7));
    }
    _portConfigInput[[self pinToPort:pin]] = @(portConfg);
}
- (void)digitalWrite:(uint8_t)pin value:(uint8_t)value
{
    NSInteger port = [self pinToPort:pin];
    NSInteger portValue = [_portValue[port] intValue];
    if (value == 0) {
        portValue &= ~(1 << (pin & 7));
    } else {
        portValue |= (1 << (pin & 7));
    }
    uint8_t buf[] = {DIGITAL_MESSAGE | port, portValue & 0x7F, (portValue >> 7) & 0x7F};
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [self write:data];
    _portValue[port] = @(portValue);
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
        } else {
            uint8_t cmd = command & 0xF0;
            if (cmd == ANALOG_MESSAGE) {
                uint8_t analogPin = command & 0x0F;
                if (i + 1 < lenght) {
                    int value = data[i++] & 0x7F;
                    int hight = data[i++] & 0x7f;
                    value += (hight << 7);
                    [self.delegate protocolDidReceivePinData:ANALOG_TO_PIN(analogPin) mode:ANALOG value:value];
                }
            } else if (cmd == DIGITAL_MESSAGE) {
                uint8_t port = command & 0x0F;
                int value = data[i++] & 0x7F;
                int height = data[i++] & 0x7F;
                value += height << 7;
                [self parsePortReport:port value:value];

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
                if (mode == INPUT) {
                    [self checkPinReport:pin];
                }
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

- (void)checkPinReport:(NSInteger)pin
{
    NSInteger port = [self pinToPort:pin];
    if (port < _reportPort.count && ![_reportPort[port] boolValue]) {
        [self reportPort:port];
        _reportPort[port] = @(YES);
    }
}

- (void)reportPort:(NSInteger)port
{
    uint8_t buf[] = {REPORT_DIGITAL | port, 1};
    NSData *data = [[NSData alloc] initWithBytes:buf length:2];
    [self write:data];
}

- (NSInteger)pinToPort:(NSInteger)pin
{
    return pin/8;
}

- (void)parsePortReport:(NSInteger)port value:(NSInteger)value
{
    NSInteger portConfg = [_portConfigInput[port] intValue];
    NSInteger portValue = [_portValue[port] intValue];
    NSInteger pin = port * 8;
    NSInteger bitmask = 0x1;
    for (NSInteger count = 0; count < 8; count++) {
        if (portConfg & bitmask) {
            if (value & bitmask) {
                portValue |= (value & bitmask);
                [self.delegate protocolDidReceivePinData:pin + count mode:INPUT value:1];
            } else {
                portValue &= ~(value & bitmask);
                [self.delegate protocolDidReceivePinData:pin + count mode:INPUT value:0];
            }
        }
        bitmask = bitmask << 1;
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
