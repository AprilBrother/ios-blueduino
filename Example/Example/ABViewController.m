//
//  ABViewController.m
//  ABDuino
//
//  Created by liaojinhua on 14-7-9.
//  Copyright (c) 2014年 AprilBrother. All rights reserved.
//

#import "ABViewController.h"
#import "ABArduinoManager.h"
#import "ABControlViewController.h"

@interface ABViewController () <ABArduinoManagerDelegate>

@property (nonatomic, strong) ABArduinoManager *manager;

@property (nonatomic, strong) NSArray *devices;

@end

@implementation ABViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.manager = [[ABArduinoManager alloc] init];
    self.manager.delegate = self;
    [self.manager startScanAprilArduino];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ControlSegue"]) {
        ABControlViewController *vc = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        vc.arduino = _devices[indexPath.row];
    }}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _devices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DuinoCell"];
    ABArduino *arduino = _devices[indexPath.row];
    cell.textLabel.text = arduino.peripheral.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"RSSI:%@", arduino.peripheral.RSSI];
    return cell;
}

#pragma mark - ABAruduinoDelegate
- (void)arduino:(ABArduinoManager *)arduino didDiscoverPeripherals:(NSArray *)peripherals
{
    _devices = peripherals;
    [self.tableView reloadData];
}

@end
