//
//  ABArduinoDefine.h
//  ABDuino
//
//  Created by liaojinhua on 14-7-14.
//  Copyright (c) 2014年 AprilBrother. All rights reserved.
//

#define SERVICE_UUID [CBUUID UUIDWithString:@"FFF0"]
#define CHAR_TX_UUID [CBUUID UUIDWithString:@"FFF1"]
#define CHAR_RX_UUID [CBUUID UUIDWithString:@"FFF2"]

#define ABArduinoPrefixName @"ZeroBeacon"

#define UNAVAILABLE             0xFF
#define INPUT                   0x00
#define OUTPUT                  0x01
#define ANALOG                  0x02
#define PWM                     0x03

#define PIN_CAPABILITY_NONE     0x00
#define PIN_CAPABILITY_DIGITAL  0x01
#define PIN_CAPABILITY_ANALOG   0x02
#define PIN_CAPABILITY_PWM      0x04

#define HIGH                    0x01
#define LOW                     0x00

extern uint8_t pinSerial[];
