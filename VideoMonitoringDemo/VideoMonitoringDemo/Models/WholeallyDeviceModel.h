//
//  WholeallyDeviceModel.h
//  VideoMonitoringDemo
//
//  Created by 李超前 on 2017/4/14.
//  Copyright © 2017年 dvlproad. All rights reserved.
//

//#import "CJBaseSectionModel/CJBaseSectionModel.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface WholeallyDeviceModel : NSObject

@property (nonatomic, strong) NSMutableArray *values;//subDeviceList;
@property (nonatomic, assign, getter=isSelected) BOOL selected;  /**< section是否选中 */ //比较少用，常用比如展开列表或集合视图的section

@property (nonatomic, assign) long long channelID;
@property (nonatomic, strong) UIImage* localimage;
@property (nonatomic, assign) BOOL status;  /**< 状态 */

@end
