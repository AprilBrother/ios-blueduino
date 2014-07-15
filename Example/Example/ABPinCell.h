//
//  ABPinCell.h
//  ABDuino
//
//  Created by liaojinhua on 14-7-10.
//  Copyright (c) 2014年 AprilBrother. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ABPinCell : UITableViewCell

@property (strong, nonatomic) UILabel *lblPin;
@property (strong, nonatomic) UIButton *btnMode;
@property (strong, nonatomic) UISegmentedControl *sgmHL;
@property (strong, nonatomic) UILabel *lblAnalog;
@property (strong, nonatomic) UISlider *sldPWM;

@end
