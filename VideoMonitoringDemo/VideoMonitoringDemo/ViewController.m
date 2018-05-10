//
//  ViewController.m
//  VideoMonitoringDemo
//
//  Created by 李超前 on 2017/4/14.
//  Copyright © 2017年 dvlproad. All rights reserved.
//

#import "ViewController.h"
#import "DeviceListViewController.h"

#import "WholeallyNetworkClient.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)loginWholeally:(id)sender {
    __weak typeof(self)weakSelf = self;
    
    NSString *appid = @"wholeally";
    NSString *auth = @"czFYScb5pAu+Ze7rXhGh/xibO7LQ3VKU8sO8+A9lcIwNJH59OnUiGbVzFwUj6QcIXADfGqno4BNHB6g4CJoj2+aWsFoIyu2f0UC3vlxxsNQ=";
    [[WholeallyNetworkClient sharedManager] loginSessionByAppid:appid auth:auth success:^{
        DeviceListViewController *viewController = [[DeviceListViewController alloc] initWithNibName:@"DeviceListViewController" bundle:nil];
        [weakSelf.navigationController pushViewController:viewController animated:YES];
    } failure:^{
        [[[UIAlertView alloc] initWithTitle:@"登录失败" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
