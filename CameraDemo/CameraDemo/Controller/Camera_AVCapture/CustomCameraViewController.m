//
//  CustomCameraViewController.m
//  Lee
//
//  Created by lichq on 5/25/15.
//  Copyright (c) 2015 lichq. All rights reserved.
//

#import "CustomCameraViewController.h"

@interface CustomCameraViewController ()

@end

@implementation CustomCameraViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"CustomCamera", nil);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    BasicCameraViewController *vc1 = [[BasicCameraViewController alloc]initWithNibName:@"BasicCameraViewController" bundle:nil];
    ServerCameraViewController *vc2 = [[ServerCameraViewController alloc]initWithNibName:@"ServerCameraViewController" bundle:nil];
    ClientCameraViewController *vc3 = [[ClientCameraViewController alloc]initWithNibName:@"ClientCameraViewController" bundle:nil];
    [self addChildViewController:vc1];
    [self addChildViewController:vc2];
    [self addChildViewController:vc3];
    
    vc1.view.tag = 1000;
    vc2.view.tag = 1001;
    vc3.view.tag = 1002;
    [self.showView addSubview:vc1.view];
    [self.showView addSubview:vc2.view];
    [self.showView addSubview:vc3.view];
    
    //UITabBarItem *item = (UITabBarItem *)[self.tabBar viewWithTag:1000];//item = nil;
    UITabBarItem *item = [self.tabBar.items objectAtIndex:0];
    [self.tabBar setSelectedItem:item];
    
    UIView *view = [self.showView viewWithTag:item.tag];
    [self.showView bringSubviewToFront:view];
    
}

//注意这里要在xib中关联UITabBarDelegate后，才会被调用到
-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    UIView *view = [self.showView viewWithTag:item.tag];
    [self.showView bringSubviewToFront:view];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
