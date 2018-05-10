//
//  VideoViewController.m
//  VideoMonitoringDemo
//
//  Created by 李超前 on 2017/4/14.
//  Copyright © 2017年 dvlproad. All rights reserved.
//

#import "VideoViewController.h"
#import "WholeallyDeviceModel.h"
#import <qysdk/QYView.h>
#import "WholeallyNetworkClient.h"

@interface VideoViewController ()<QYViewDelegate>
{
    QYView* talk;
    QYView* replay;
}
@property (nonatomic, weak) QYView *channelVideoView;

@property (nonatomic,strong) IBOutlet UIView* videoView;
@property (nonatomic, weak) IBOutlet UIButton *leftBtn;
@property (nonatomic, weak) IBOutlet UIButton *rightBtn;
@property (nonatomic, weak) IBOutlet UIButton *upBtn;
@property (nonatomic, weak) IBOutlet UIButton *downBtn;


@property (nonatomic, weak) IBOutlet UIView *clondView;
@property (nonatomic, weak) IBOutlet UIView *funcView;
@property (nonatomic, weak) IBOutlet UIView *talkView;


-(IBAction)closeBtn;//关闭云台
-(IBAction)cloudControlBtn;//云台控制
-(IBAction)talkBtn;//云台控制
- (IBAction)stopClickBtn;//停止
- (IBAction)startRecordBtn;//开始录音
- (IBAction)endRecordBtn;//停止录音
- (IBAction)replayBtn;//回放



-(IBAction)back;
@end

@implementation VideoViewController

- (instancetype)initWithChannel:(WholeallyDeviceModel *)channelModel
{
    self = [super init];
    self.chanel = channelModel;
    return  self;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self back];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[WholeallyNetworkClient sharedManager] createChannelVideoView:self.chanel.channelID success:^(QYView *channelVideoView) {
        [channelVideoView SetEventDelegate:self]; //获取观看时间回调
        [channelVideoView SetCanvas:self.videoView];
        
        self.channelVideoView = channelVideoView;
        
//        [self getVideoAbility];     //获取设备能力
//        [self getVideoQuaility];    //获取画质
//        [self getAlarmConfig];      //获取布防
//        [self loadVoiceConfig];
        
    } failure:nil];
    
    [self addButtonListener];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = [NSString stringWithFormat:@"%lld", self.chanel.channelID];
}

///获取设备能力
- (void)getVideoAbility {
    [[WholeallyNetworkClient sharedManager] getChannelAbilityForChannelId:self.chanel.channelID success:^(QY_DEVICE_FUN function) {
        if (0 == function.ptz) {
            NSLog(@"该设备不具备云台能力");
        }
        if (0 == function.audio) {
            NSLog(@"该设备不具备语音能力");
        }
        if (0 == function.talk) {
            NSLog(@"该设备不具备对讲能力");
        }
        
    } failure:^{
        
    }];
}

///获取画质
- (void)getVideoQuaility {
    
}

///获取布防
- (void)getAlarmConfig {
    
}

- (void)loadVoiceConfig {
    
}

///为上下左右添加长按手势
-(void)addButtonListener {
    //left
    UILongPressGestureRecognizer *longPress1 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    longPress1.minimumPressDuration = 0.3;
    [self.leftBtn addGestureRecognizer:longPress1];
    
    //right
    UILongPressGestureRecognizer *longPress2 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    longPress2.minimumPressDuration = 0.3;
    [self.rightBtn addGestureRecognizer:longPress2];
    
    //up
    UILongPressGestureRecognizer *longPress3 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    longPress3.minimumPressDuration = 0.3;
    [self.upBtn addGestureRecognizer:longPress3];
    
    //down
    UILongPressGestureRecognizer *longPress4 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    longPress4.minimumPressDuration = 0.3;
    [self.downBtn addGestureRecognizer:longPress4];
}

- (void)longPressAction:(UILongPressGestureRecognizer *)gestureRecognizer {
    UIView *gestureRecognizerView = [gestureRecognizer view];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        if([gestureRecognizerView isEqual:self.leftBtn]) {
            [self.channelVideoView CtrlPtz:0 action:QY_MOVE_LEFT callBack:^(int32_t ret) {
                
            }];
        } else if([gestureRecognizerView isEqual:self.rightBtn]) {
            [self.channelVideoView CtrlPtz:0 action:QY_MOVE_RIGHT callBack:^(int32_t ret) {
                
            }];

        } else if([gestureRecognizerView isEqual:self.downBtn]) {
            [self.channelVideoView CtrlPtz:0 action:QY_MOVE_DOWN callBack:^(int32_t ret) {
                
            }];

        } else if([gestureRecognizerView isEqual:self.upBtn]) {
            [self.channelVideoView CtrlPtz:0 action:QY_MOVE_UP callBack:^(int32_t ret) {
                
            }];
        }
        
        if([gestureRecognizerView isKindOfClass:[UIButton class]]) {
            [(UIButton*)gestureRecognizerView setSelected:YES];
        }
    }
    else if([gestureRecognizer state]==UIGestureRecognizerStateEnded)
    {
        if([gestureRecognizerView isKindOfClass:[UIButton class]]) {
            [self.channelVideoView CtrlPtz:0 action:QY_STOP callBack:^(int32_t ret) {
                
            }];

            [(UIButton*)gestureRecognizerView setSelected:false];
        }
    }
    
}
// 关闭对讲
- (IBAction)closeBtn
{
    [talk Release];
    [_funcView setHidden:NO];
    [_clondView setHidden:YES];
    [_talkView setHidden:YES];
}

// 打开云台控制
- (IBAction)cloudControlBtn
{
    NSLog(@"height:%d\n width:%d\n",[self.channelVideoView GetHeigh],[self.channelVideoView GetWidth]);
    [_funcView setHidden:YES];
    [_clondView setHidden:NO];
}

// 创建对讲房间
-(IBAction)talkBtn
{
    [[WholeallyNetworkClient sharedManager] createTalkView:self.chanel.channelID callback:^(int32_t ret, QYView *view) {
        if(ret==0)
        {
            talk=view;
            [talk SetEventDelegate:self];
            
        }
        
        if(talk)
        {
            [_funcView setHidden:YES];
            [_talkView setHidden:NO];
        }
    }];
}
//
- (IBAction)stopClickBtn
{
//    [video CtrlPtz:0 action:QY_MOVE_RIGHT];
}


// 开始对讲
- (IBAction)startRecordBtn
{
    [talk CtrlTalk:NO];

}

//  结束对讲
- (IBAction)endRecordBtn
{
    [talk CtrlTalk:YES];
}

// 回放数据测试
-(IBAction)replayBtn
{

//     QY_DAYS_INDEX days=[[WholeallyNetworkClient sharedManager]getDayList:chanel.device_id
//                              yearData:2015
//                             monthData:10
//                            cloundData:NO];
//    replay=[[WholeallyNetworkClient sharedManager] createReplayView:chanel.device_id
//                                          CloudStroe:NO];
//    replay.delegate=self;
//    QYTimeIndex* qyindex=[QYTimeIndex new];
//    [replay SetCanvas:self.videoView];
//    int result=[replay GetStoreFileList:&days.days[2] timeIndex:qyindex];
//    NSLog(@"%d",result);
//    QY_TIME_BUCKET2 time;
//    
//    if(qyindex->times.count<=0)
//        return;
//    
//    NSValue* value=qyindex->times[0];
//    [value getValue:&time];
//    [replay CtrlPlay:time.starttime ctrl:1];
    
}


// 返回
-(IBAction)back
{
    [self.channelVideoView Release];
    [self.navigationController popViewControllerAnimated:true];
}


#pragma mark - 观看事件回调QYViewDelegate
///断开通知
- (void)onDisConnect:(QY_DISCONNECT_REASON)reason {
    
}

///音量回调通知
- (void)onVolumeChange:(float)voiceValue {
    
}

///回放时间通知
- (void)onReplayTimeChange:(QY_TIME)time {
    
}

///画布显示画面通知
- (void)onVideoSizeChange:(int)width height:(int)height {
    
}

///录像事件
- (void)onRecordStatus:(QY_RECORD_STATUS)statues {
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
