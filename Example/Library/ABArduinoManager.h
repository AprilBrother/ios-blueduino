//
//  ABArduino.h
//  ABDuino
//
//  Created by liaojinhua on 14-7-14.
//  Copyright (c) 2014年 AprilBrother. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ABProtocol.h"

@import CoreBluetooth;

@class ABArduinoManager;

@protocol ABArduinoManagerDelegate <NSObject>

@optional
- (void)arduino:(ABArduinoManager *)arduino didDiscoverPeripherals:(NSArray *)peripherals;

@end

@interface ABArduinoManager : NSObject

@property (weak, nonatomic) id<ABArduinoManagerDelegate> delegate;

- (void)startScanAprilArduino;
- (void)connectToPeripheral:(CBPeripheral *)peripheral;
- (void)cancelConnectToPeripheral:(CBPeripheral *)peripheral;

@end
