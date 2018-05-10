//
//  SubDeviceTableViewCell.h
//  VideoMonitoringDemo
//
//  Created by 李超前 on 2017/4/25.
//  Copyright © 2017年 dvlproad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubDeviceTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *channelImageView;
@property (nonatomic, strong) IBOutlet UILabel *channelAddressLabel;
@property (nonatomic, strong) IBOutlet UILabel *channelStatusLabel;

@end
