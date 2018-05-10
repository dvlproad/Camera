//
//  HeadView.m
//  VideoMonitoringDemo
//
//  Created by 李超前 on 2017/4/14.
//  Copyright © 2017年 dvlproad. All rights reserved.
//

#import "HeadView.h"

@interface HeadView()

@property (nonatomic, weak) IBOutlet UIImageView *deviceIcon;
@property (nonatomic, weak) IBOutlet UILabel *deviceNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *deviceAddressLabel;

@end



@implementation HeadView

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    
    [self commonInit];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(heaerOrFooterTapAction)];
    tapGestureRecognizer.numberOfTouchesRequired = 1;
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tapGestureRecognizer];
}


- (void)heaerOrFooterTapAction {
    if (self.tapHandle) {
        self.tapHandle(self.belongToSection);
    }
}


- (void)setDeviceGroup:(WholeallyDeviceModel *)deviceGroup
{
    _deviceGroup = deviceGroup;
    self.deviceNameLabel.text = [NSString stringWithFormat:@"%lld",deviceGroup.channelID] ;
    self.deviceAddressLabel.text =[NSString stringWithFormat:@"%lld",deviceGroup.channelID] ;
    self.deviceIcon.image = [UIImage imageNamed:@"device"];
    
    if(!deviceGroup.status) {
        UIColor *textColor = [UIColor colorWithRed:196/255.0 green:196/255.0 blue:196/255.0 alpha:1];//#666666
        self.deviceNameLabel.textColor = textColor;
        self.deviceAddressLabel.textColor = textColor;
        
    } else {
        self.deviceNameLabel.textColor = [UIColor blackColor];
        self.deviceAddressLabel.textColor = [UIColor blackColor];
    }
}

@end
