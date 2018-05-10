//
//  HeadView.h
//  VideoMonitoringDemo
//
//  Created by 李超前 on 2017/4/14.
//  Copyright © 2017年 dvlproad. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WholeallyDeviceModel.h"

@interface HeadView : UITableViewHeaderFooterView {
    
}
@property (nonatomic, strong) WholeallyDeviceModel *deviceGroup;

@property (nonatomic, assign) NSInteger belongToSection;    /**< 当前header或footer属于哪个section下 */
@property (nonatomic, copy) void (^tapHandle)(NSInteger section);   /**< 当前视图的点击 */


@end
