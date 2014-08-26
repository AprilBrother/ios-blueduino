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

#define TOTAL_PINS              22
#define TOTAL_PORTS             ((TOTAL_PINS + 7) / 8)

#define ANALOG_TO_PIN(p)        ((p) <= 3 ? (p) + 18:((p) >= 8 ? (p):((p) == 7 ? 6 :4)))

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


// Firmata protocol
#define DIGITAL_MESSAGE         0x90 // send data for a digital pin
#define ANALOG_MESSAGE          0xE0 // send data for an analog pin (or PWM)
#define REPORT_ANALOG           0xC0 // enable analog input by pin #
#define REPORT_DIGITAL          0xD0 // enable digital input by port pair
//
#define SET_PIN_MODE            0xF4 // set a pin to INPUT/OUTPUT/PWM/etc
//
#define REPORT_VERSION          0xF9 // report protocol version
#define SYSTEM_RESET            0xFF // reset from MIDI
//
#define START_SYSEX             0xF0 // start a MIDI Sysex message
#define END_SYSEX               0xF7 // end a MIDI Sysex message

// extended command set using sysex (0-127/0x00-0x7F)
/* 0x00-0x0F reserved for user-defined commands */
#define RESERVED_COMMAND        0x00 // 2nd SysEx data byte is a chip-specific command (AVR, PIC, TI, etc).
#define ANALOG_MAPPING_QUERY    0x69 // ask for mapping of analog to pin numbers
#define ANALOG_MAPPING_RESPONSE 0x6A // reply with mapping info
#define CAPABILITY_QUERY        0x6B // ask for supported modes and resolution of all pins
#define CAPABILITY_RESPONSE     0x6C // reply with supported modes and resolution
#define PIN_STATE_QUERY         0x6D // ask for a pin's current mode and value
#define PIN_STATE_RESPONSE      0x6E // reply with a pin's current mode and value
#define EXTENDED_ANALOG         0x6F // analog write (PWM, Servo, etc) to any pin
#define SERVO_CONFIG            0x70 // set max angle, minPulse, maxPulse, freq
#define STRING_DATA             0x71 // a string message with 14-bits per char
#define SHIFT_DATA              0x75 // shiftOut config/data message (34 bits)
#define I2C_REQUEST             0x76 // I2C request messages from a host to an I/O board
#define I2C_REPLY               0x77 // I2C reply messages from an I/O board to a host
#define I2C_CONFIG              0x78 // Configure special I2C settings such as power pins and delay times
#define REPORT_FIRMWARE         0x79 // report name and version of the firmware
#define SAMPLING_INTERVAL       0x7A // sampling interval
#define SYSEX_NON_REALTIME      0x7E // MIDI Reserved for non-realtime messages
#define SYSEX_REALTIME          0x7F // MIDI Reserved for realtime messages

