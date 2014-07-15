//
//  ABPinCell.m
//  ABDuino
//
//  Created by liaojinhua on 14-7-10.
//  Copyright (c) 2014年 AprilBrother. All rights reserved.
//

#import "ABPinCell.h"

@implementation ABPinCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
