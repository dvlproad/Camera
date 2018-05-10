//
//  DeviceListViewController.m
//  VideoMonitoringDemo
//
//  Created by 李超前 on 2017/4/14.
//  Copyright © 2017年 dvlproad. All rights reserved.
//

#import "DeviceListViewController.h"
#import "WholeallyNetworkClient.h"
#import "WholeallyDeviceModel.h"
#import <qysdk/QYType.h>

#import "HeadView.h"
#import "VideoViewController.h"

#import "SubDeviceTableViewCell.h"

@interface DeviceListViewController () <UITableViewDelegate, UITableViewDataSource>
{
    
}
@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonatomic, strong) NSMutableArray<WholeallyDeviceModel *> *sectionModels;

@end

@implementation DeviceListViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationItem.title = @"摄像头列表";
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton = YES;
    
    if(![[WholeallyNetworkClient sharedManager] hasLogin]) {
        NSString *appid = @"wholeally";
        NSString *auth = @"czFYScb5pAu+Ze7rXhGh/xibO7LQ3VKU8sO8+A9lcIwNJH59OnUiGbVzFwUj6QcIXADfGqno4BNHB6g4CJoj2+aWsFoIyu2f0UC3vlxxsNQ=";
        [[WholeallyNetworkClient sharedManager] loginSessionByAppid:appid auth:auth success:^{
            [self getDeviceList];
        } failure:nil];
    } else {
        [self getDeviceList];
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"退出" style:UIBarButtonItemStyleDone target:self action:@selector(logout)];
}

- (void)logout {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"HeadView" bundle:[NSBundle mainBundle]] forHeaderFooterViewReuseIdentifier:@"HeadView"];
    [self.tableView registerNib:[UINib nibWithNibName:@"SubDeviceTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cell"];
}

/// 获取设备列表
- (void)getDeviceList {
    __weak typeof(self)weakSelf = self;
    [[WholeallyNetworkClient sharedManager] getDeviceListSuccess:^(NSArray *array) {
        weakSelf.sectionModels = [NSMutableArray array];
        
        NSInteger deviceCount = array.count;
        if (deviceCount <= 0) {
            NSLog(@"Error:当前可用设备为空");
            return;
        }
        
        for(NSInteger i = 0; i < deviceCount; i++) {
            QY_DEVICE_INFO deviceinfo;
            NSValue *valueObj = [array objectAtIndex:i];
            [valueObj getValue:&deviceinfo];
            
            WholeallyDeviceModel *device = [[WholeallyDeviceModel alloc] init];
            device.selected = YES;
            device.channelID = deviceinfo.deviceID;
            device.status = deviceinfo.status;
            
            device.values = [NSMutableArray array];
            [weakSelf.sectionModels addObject:device];
        }
        
        for (WholeallyDeviceModel *device in weakSelf.sectionModels) {
            [self getChannelListOnDeviceId:device.channelID completeBlock:^(NSMutableArray *subDeviceList) {
                device.values = subDeviceList;
                [self.tableView reloadData];
            }];
            
            [self getChannelImageOnChannelId:device.channelID completeBlock:^(UIImage *image) {
                device.localimage = image;
            }];
            
        }
        
    } failure:^{
        NSLog(@"获取设备失败");
    }];
}


///获取指定设备的通道列表
- (void)getChannelListOnDeviceId:(uint64_t)deviceId completeBlock:(void(^)(NSMutableArray *subDeviceList))completeBlock {
    [[WholeallyNetworkClient sharedManager] getChannelListOnDeviceId:deviceId success:^(NSArray *ret) {
        NSMutableArray *subDeviceList = [NSMutableArray array];
        for(NSValue *valueObj in ret) {
            QY_CHANNEL_INFO chanel;
            [valueObj getValue:&chanel];
            
            WholeallyDeviceModel *chanleDevice = [WholeallyDeviceModel new];
            chanleDevice.channelID = chanel.channelID;
            chanleDevice.status = chanel.status;
            [subDeviceList addObject:chanleDevice];
        }
        
        if (completeBlock) {
            completeBlock(subDeviceList);
        }
    } failure:^{
        NSMutableArray *subDeviceList = [NSMutableArray array];
        if (completeBlock) {
            completeBlock(subDeviceList);
        }
    }];
}

///获取指定通道的缩略图
- (void)getChannelImageOnChannelId:(uint64_t)channelId completeBlock:(void(^)(UIImage *image))completeBlock {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSLog(@"documentsDirectory = %@", documentsDirectory);
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:@"1.png"];
    
    [[WholeallyNetworkClient sharedManager] getCaptureImageForChannelId:channelId imagePath:imagePath success:^{
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        if (completeBlock) {
            completeBlock(image);
        }
        
    } failure:^{
        
    }];
}

#pragma mark - UITableViewDataSource & UITabeleViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionModels.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    WholeallyDeviceModel *sectionModel = [self.sectionModels objectAtIndex:section];
    NSInteger rowCount = [sectionModel.values count];
    
    return sectionModel.isSelected ? rowCount : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 80;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    WholeallyDeviceModel *sectionDataModel = [self.sectionModels objectAtIndex:section];
    
    HeadView *header = (HeadView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:@"HeadView"];
    header.belongToSection = section;
    __weak typeof(self)weakSelf = self;
    [header setTapHandle:^(NSInteger section) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf tapHeaderAtSection:section];
        }
    }];
    
    //header.tilteLabel.backgroundColor = [UIColor cyanColor];
    //header.tilteLabel.text = sectionDataModel.theme;
    header.deviceGroup = sectionDataModel;
    
    return header;
}

/**
 *  点击了第几个Header
 *
 *  @param section section
 */
- (void)tapHeaderAtSection:(NSInteger)section {
    WholeallyDeviceModel *secctionModel = [self.sectionModels objectAtIndex:section];
    secctionModel.selected = !secctionModel.isSelected;
    
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WholeallyDeviceModel *sectionDataModel = [self.sectionModels objectAtIndex:indexPath.section];
    WholeallyDeviceModel *subdevice = [sectionDataModel.values objectAtIndex:indexPath.row];
    
    SubDeviceTableViewCell *cell = (SubDeviceTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.channelAddressLabel.text = [NSString stringWithFormat:@"%lld",subdevice.channelID];
    cell.channelStatusLabel.text = sectionDataModel.status&& subdevice.status?@"在线":@"离线";
    
    
    //    SLLog(@"显示。。。。。。  %@",subdevice.calledName);
    if(sectionDataModel.status && subdevice.status) {
        cell.channelAddressLabel.textColor = [UIColor blackColor];
        cell.channelStatusLabel.textColor = [UIColor blackColor];
        
        if(subdevice.localimage != nil) {
            [cell.channelImageView setImage:subdevice.localimage];
            [cell.channelImageView setHighlightedImage:subdevice.localimage];
            cell.channelImageView.backgroundColor = [UIColor clearColor];
            
        } else {
            [cell.channelImageView setHighlightedImage:[UIImage imageNamed:@"passageway"]];
            [cell.channelImageView setImage:[UIImage imageNamed:@"passageway"]];
            cell.channelImageView.backgroundColor=[UIColor clearColor];
        }
    } else {
        UIColor *textColor = [UIColor colorWithRed:196/255.0 green:196/255.0 blue:196/255.0 alpha:1];//#666666
        cell.channelAddressLabel.textColor = textColor;
        cell.channelStatusLabel.textColor = textColor;
        
        
        [cell.channelImageView setHighlightedImage:[UIImage imageNamed:@"passageway"]];
        [cell.channelImageView setImage:[UIImage imageNamed:@"passageway"]];
        cell.channelImageView.backgroundColor = [UIColor clearColor];
    }
    return cell;
}


#pragma mark----实现跳转，就是缺少导航控制器
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WholeallyDeviceModel *sectionDataModel = [self.sectionModels objectAtIndex:indexPath.section];
    WholeallyDeviceModel *subdevice = [sectionDataModel.values objectAtIndex:indexPath.row];
    if(subdevice.status) {
        //VideoViewController *viewController = [[VideoViewController alloc] initWithChannel:subdevice];
        VideoViewController *viewController = [[VideoViewController alloc] initWithNibName:@"VideoViewController" bundle:nil];
        viewController.chanel = subdevice;
        //viewController.naDelegate=self.naDelegate;
        [self.navigationController pushViewController:viewController animated:true];
    }
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
