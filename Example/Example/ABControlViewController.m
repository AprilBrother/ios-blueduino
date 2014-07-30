//
//  ABControlViewController.m
//  ABDuino
//
//  Created by liaojinhua on 14-7-9.
//  Copyright (c) 2014年 AprilBrother. All rights reserved.
//

#import "ABControlViewController.h"
#import "ABPinCell.h"
#import "ABArduinoDefine.h"
#import <MBProgressHUD/MBProgressHUD.h>


uint8_t total_pin_count  = 0;
uint8_t pin_mode[128]    = {0};
uint8_t pin_cap[128]     = {0};
uint8_t pin_digital[128] = {0};
uint16_t pin_analog[128]  = {0};
uint8_t pin_pwm[128]     = {0};

uint8_t current_pin = 0;

@interface ABControlViewController ()<UIActionSheetDelegate, ABArduinoDelegate, ABProtocolDelegate>

@property (nonatomic, strong) CBCharacteristic *txChar;
@property (nonatomic, strong) CBCharacteristic *rxChar;

@end

@implementation ABControlViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.arduino.peripheral.name;
    self.arduino.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self clearData];
    [self.arduino connect];
    [self showHUD];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.arduino disconnect];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clearData
{
    
    total_pin_count = 0;
    memset(pin_mode, 0, 128);
    memset(pin_cap, 0, 128);
    memset(pin_digital, 0, 128);
    memset(pin_analog, 0, 128);
    memset(pin_pwm, 0, 128);
    
    current_pin = 0;
}

- (void)showHUD
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}
- (void)hideHUD
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (IBAction)toggleHL:(id)sender
{
    NSLog(@"High/Low clicked, pin id: %ld", (long)[sender tag]);
    
    uint8_t pin = [sender tag];
    UISegmentedControl *sgmControl = (UISegmentedControl *)sender;
    if ([sgmControl selectedSegmentIndex] == LOW)
    {
        [self.arduino digitalWrite:pin value:LOW];
        pin_digital[pin] = LOW;
    }
    else
    {
        [self.arduino digitalWrite:pin value:HIGH];
        pin_digital[pin] = HIGH;
    }
}

- (IBAction)sliderChange:(id)sender
{
    uint8_t pin = [sender tag];
    UISlider *sld = (UISlider *) sender;
    uint8_t value = sld.value;
    
    if (pin_mode[pin] == PWM) {
        pin_pwm[pin] = value; // for updating the GUI
        [self.arduino setPinPWM:pin pwm:value];
    }
}

- (IBAction)modeChange:(UIButton *)sender
{
    uint8_t pin = [sender tag];

    NSString *title = [NSString stringWithFormat:@"Select Pin %d Mode", pinSerial[pin]];
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:title
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:nil];
    
    if (pin_cap[pin] & PIN_CAPABILITY_DIGITAL) {
        [sheet addButtonWithTitle:@"Input"];
        [sheet addButtonWithTitle:@"Output"];
    }
    
    if (pin_cap[pin] & PIN_CAPABILITY_PWM) {
        [sheet addButtonWithTitle:@"PWM"];
    }

    if (pin_cap[pin] & PIN_CAPABILITY_ANALOG) {
        [sheet addButtonWithTitle:@"Analog"];
    }
    
    sheet.cancelButtonIndex = [sheet addButtonWithTitle: @"Cancel"];
    
    current_pin = pin;
    
    // Show the sheet
    [sheet showInView:self.view];
}

#pragma mark - ABAruduinoDelegate, ABProtocolDelegate
- (void)arduino:(ABArduino *)arduino didConnected:(NSError *)error
{
    if (!error) {
        [self.arduino queryTotalPinCount];
    }
    [self hideHUD];
}

- (void)arduino:(ABArduino *)arduino didDisConnected:(NSError *)error
{
    
}

- (void)protocolDidReceiveTotalPinCount:(uint8_t)count
{
    total_pin_count = count;
    [self.arduino queryPinAll];
    [self.tableView reloadData];
}

- (void)protocolDidReceivePinMode:(uint8_t)pin mode:(uint8_t)mode
{
    pin_mode[pin] = mode;
    [self.tableView reloadData];
}

- (void)protocolDidReceivePinData:(uint8_t)pin mode:(uint8_t)mode value:(uint8_t)value
{
    pin_mode[pin] = mode;
    if ((mode == INPUT) || (mode == OUTPUT)) {
        pin_digital[pin] = value;
    }
    else if (mode == ANALOG) {
        pin_analog[pin] = ((mode >> 4) << 8) + value;
    }
    else if (mode == PWM) {
        pin_pwm[pin] = value;
    }
    [self.tableView reloadData];
}

- (void)protocolDidReceivePinCapability:(uint8_t)pin value:(uint8_t)value
{
    pin_cap[pin] = value;
    [self.tableView reloadData];
}

- (void)protocolDidReceiveCustomData:(uint8_t *)data length:(uint8_t)length
{
    
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return total_pin_count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"PinCell";
    uint8_t pin = indexPath.row;
    
    ABPinCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell.lblPin setText:[NSString stringWithFormat:@"%d", pinSerial[pin]]];
    [cell.btnMode setTag:pin];
    [cell.sgmHL setTag:pin];
    [cell.sldPWM setTag:pin];
    
    // Pin availability
    if (pin_cap[pin] == 0x00) {
        [cell setHidden:TRUE];
    }
    
    // Pin mode
    if (pin_mode[pin] == INPUT)
    {
        [cell.btnMode setTitle:@"Input" forState:UIControlStateNormal];
        [cell.sgmHL setHidden:FALSE];
        [cell.sgmHL setEnabled:FALSE];
        [cell.sgmHL setSelectedSegmentIndex:pin_digital[pin]];
        [cell.lblAnalog setHidden:TRUE];
        [cell.sldPWM setHidden:TRUE];
    }
    else if (pin_mode[pin] == OUTPUT)
    {
        [cell.btnMode setTitle:@"Output" forState:UIControlStateNormal];
        [cell.sgmHL setHidden:FALSE];
        [cell.sgmHL setEnabled:TRUE];
        [cell.sgmHL setSelectedSegmentIndex:pin_digital[pin]];
        [cell.lblAnalog setHidden:TRUE];
        [cell.sgmHL setHidden:FALSE];
        [cell.sldPWM setHidden:TRUE];
    }
    else if (pin_mode[pin] == ANALOG)
    {
        [cell.btnMode setTitle:@"Analog" forState:UIControlStateNormal];
        [cell.lblAnalog setText:[NSString stringWithFormat:@"%d", pin_analog[pin]]];
        [cell.lblAnalog setHidden:FALSE];
        [cell.sgmHL setHidden:TRUE];
        [cell.sldPWM setHidden:TRUE];
    }
    else if (pin_mode[pin] == PWM)
    {
        [cell.btnMode setTitle:@"PWM" forState:UIControlStateNormal];
        [cell.lblAnalog setText:[NSString stringWithFormat:@"%d", pin_analog[pin]]];
        [cell.sldPWM setHidden:FALSE];
        [cell.lblAnalog setHidden:TRUE];
        [cell.sgmHL setHidden:TRUE];
        [cell.sldPWM setMinimumValue:0];
        [cell.sldPWM setMaximumValue:255];
        [cell.sldPWM setValue:pin_pwm[pin]];
    }
    
    return cell;

}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSString *mode_str = [actionSheet buttonTitleAtIndex:buttonIndex];
    uint8_t mode = INPUT;
    
    if ([mode_str isEqualToString:@"Output"])
    {
        mode = OUTPUT;
    }
    else if ([mode_str isEqualToString:@"Analog"])
    {
        mode = ANALOG;
    }
    else if ([mode_str isEqualToString:@"PWM"])
    {
        mode = PWM;
    }
    [self.arduino setPinMode:current_pin mode:mode];
    [self.tableView reloadData];
}


@end
