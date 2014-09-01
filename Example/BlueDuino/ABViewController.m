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
#import <MMDrawerController/MMDrawerBarButtonItem.h>
#import <MMDrawerController/UIViewController+MMDrawerController.h>

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
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(startRefresh:) forControlEvents:UIControlEventValueChanged];
    
    MMDrawerBarButtonItem *button = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftButtonAction:)];
    self.navigationItem.leftBarButtonItem = button;
    
    self.protcolClassName = @"ABCustomProtocol";
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
        vc.protcolClassName = _protcolClassName;
    }
}

- (void)leftButtonAction:(id)sender
{
    if (self.mm_drawerController.openSide == MMDrawerSideNone) {
        [self.mm_drawerController openDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    } else {
        [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
    }
}

- (void)startRefresh:(id)sender
{
    self.devices = nil;
    [self.manager stopScan];
    [self.manager startScanAprilArduino];
}

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
    return cell;
}

#pragma mark - ABAruduinoDelegate
- (void)arduino:(ABArduinoManager *)arduino didDiscoverPeripherals:(NSArray *)peripherals
{
    [self.refreshControl endRefreshing];
    _devices = peripherals;
    [self.tableView reloadData];
}

@end
