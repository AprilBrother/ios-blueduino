//
//  ABLeftViewController.m
//  Example
//
//  Created by liaojinhua on 14-8-27.
//  Copyright (c) 2014年 AprilBrother. All rights reserved.
//

#import "ABLeftViewController.h"
#import "ABViewController.h"
#import <MMDrawerController/UIViewController+MMDrawerController.h>

@interface ABLeftViewController ()

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end

@implementation ABLeftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.contentInset = UIEdgeInsetsMake(20.0f, 0.0f, 0.0f, 0.0f);
    self.selectedIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView selectRowAtIndexPath:_selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}

#pragma mark - Table view data source
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return nil;
    }
    return indexPath;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return;
    }
    NSString *protocolClassName = @"ABCustomProtocol";
    if (indexPath.row == 2) {
        protocolClassName = @"ABFirmataProtocol";
    }
    MMDrawerController *drawer = self.mm_drawerController;
    UINavigationController *center = (UINavigationController *)drawer.centerViewController;
    ABViewController *vc = (ABViewController *)[center.viewControllers firstObject];
    vc.protcolClassName = protocolClassName;
    [drawer closeDrawerAnimated:YES completion:nil];
    _selectedIndexPath = indexPath;
}

@end
