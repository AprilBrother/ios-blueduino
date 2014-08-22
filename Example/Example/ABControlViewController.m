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

uint8_t current_pin = 0;

@interface ABControlViewController ()<UIActionSheetDelegate, ABArduinoDelegate>


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
    }
    else
    {
        [self.arduino digitalWrite:pin value:HIGH];
    }
}

- (IBAction)sliderChange:(id)sender
{
    uint8_t pin = [sender tag];
    UISlider *sld = (UISlider *) sender;
    uint8_t value = sld.value;
    
    [self.arduino setPinPWM:pin pwm:value];
}

- (IBAction)modeChange:(UIButton *)sender
{
    NSInteger pin = [sender tag];
    ABPin *pinObj = [self.arduino pin:pin];

    NSString *title = [NSString stringWithFormat:@"Select Pin %d Mode", pin];
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:title
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:nil];
    
    if (pinObj.capability & PIN_CAPABILITY_DIGITAL) {
        [sheet addButtonWithTitle:@"Input"];
        [sheet addButtonWithTitle:@"Output"];
    }
    
    if (pinObj.capability & PIN_CAPABILITY_PWM) {
        [sheet addButtonWithTitle:@"PWM"];
    }

    if (pinObj.capability & PIN_CAPABILITY_ANALOG) {
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
        [self.arduino queryPinAll];
    }
    [self hideHUD];
}

- (void)arduino:(ABArduino *)arduino didDisConnected:(NSError *)error
{
    
}

- (void)arduinoDidUpdateData
{
    [self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.arduino totalPinCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"PinCell";
    ABPin *pinObj = [self.arduino pinAtIndex:indexPath.row];
    
    ABPinCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell.lblPin setText:[NSString stringWithFormat:@"%@", @(pinObj.pin)]];
    [cell.btnMode setTag:pinObj.pin];
    [cell.sgmHL setTag:pinObj.pin];
    [cell.sldPWM setTag:pinObj.pin];
    
    // Pin availability
    if (pinObj.capability == 0x00) {
        [cell setHidden:TRUE];
    }
    
    // Pin mode
    if (pinObj.currentMode == INPUT)
    {
        [cell.btnMode setTitle:@"Input" forState:UIControlStateNormal];
        [cell.sgmHL setHidden:FALSE];
        [cell.sgmHL setEnabled:FALSE];
        [cell.sgmHL setSelectedSegmentIndex:pinObj.value];
        [cell.lblAnalog setHidden:TRUE];
        [cell.sldPWM setHidden:TRUE];
    }
    else if (pinObj.currentMode == OUTPUT)
    {
        [cell.btnMode setTitle:@"Output" forState:UIControlStateNormal];
        [cell.sgmHL setHidden:FALSE];
        [cell.sgmHL setEnabled:TRUE];
        [cell.sgmHL setSelectedSegmentIndex:pinObj.value];
        [cell.lblAnalog setHidden:TRUE];
        [cell.sgmHL setHidden:FALSE];
        [cell.sldPWM setHidden:TRUE];
    }
    else if (pinObj.currentMode == ANALOG)
    {
        [cell.btnMode setTitle:@"Analog" forState:UIControlStateNormal];
        [cell.lblAnalog setText:[NSString stringWithFormat:@"%@", @(pinObj.value)]];
        [cell.lblAnalog setHidden:FALSE];
        [cell.sgmHL setHidden:TRUE];
        [cell.sldPWM setHidden:TRUE];
    }
    else if (pinObj.currentMode == PWM)
    {
        [cell.btnMode setTitle:@"PWM" forState:UIControlStateNormal];
        [cell.sldPWM setHidden:FALSE];
        [cell.lblAnalog setHidden:TRUE];
        [cell.sgmHL setHidden:TRUE];
        [cell.sldPWM setMinimumValue:0];
        [cell.sldPWM setMaximumValue:255];
        [cell.sldPWM setValue:pinObj.value];
    }
    
    return cell;

}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
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
