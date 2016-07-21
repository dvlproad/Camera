# Camera
Camera demo

##参考
[iOS RTMP 视频直播开发笔记（1）](http://www.360doc.com/content/16/0304/14/19175681_539367835.shtml)

[iOS RTMP 视频直播开发笔记（2）](http://www.360doc.com/content/16/0304/14/19175681_539368429.shtml)

[iOS RTMP 视频直播开发笔记（3）](http://www.360doc.com/content/15/1020/03/19175681_507079027.shtml)

[iOS RTMP 视频直播开发笔记（5）](http://www.360doc.com/content/16/0304/14/19175681_539368687.shtml)

[通过AVAssetWriter将录像视频写到指定文件](http://blog.csdn.net/zengconggen/article/details/7595449)

[做一款仿映客的直播App？看这篇就够了](http://www.cocoachina.com/ios/20160721/17133.html)


##客户端效果 
点击“直播”，进入“直播”页，首先通过CFSoket判断与流媒体服务器地址的连接是否正常，如果正常才可以开始直播。
直播是通过摄像头`UIImagePickerController`来进行采集数据，

iOS 编码实现中需要首先生成 MP4 视频文件，然后从 MP4 文件中提取 NALU 交给下一步做处理，因此这里首先介绍一下 MP4 和 H.264 的相关知识吧。

MP4 是一种视频容器格式，而 H.264 是一种图像编码标准。


##原理
实时直播：

* 低清Baseline Level 1.3
* 标清Baseline Level 3
* 半高清Baseline Level 3.1
* 全高清Baseline Level 4.1

存储媒体：

* 低清 Main Level 1.3
* 标清 Main Level 3
* 半高清 Main Level 3.1
* 全高清 Main Level 4.1

既然我们是实时直播，那就应该选择Baseline级别，通过根据视频分辨率和比特率，选择编码标准，例如标清视频使用AVVideoProfileLevelH264Baseline30。

但在iOS7.0以上，可以直接选择AVVideoProfileLevelH264BaselineAutoLevel



原理：`采用硬件加速编码视频`，苹果提供的只有 AVAssetWriter 类，而它只能写入编码后的文件到指定路径的文件中。我们如果想要实时硬编码，例如将视频流输出到网络，这时就需要从输出文件中不断读取新的编码后视频数据。

从代码上看，AVEncoder 通过使用GCD Dispatch Source监听文件的内容改变，通过此方式高效的读取编码后的数据，然而简单的读取 raw data 并不能满足我们的需求，因此在代码中根据Mp4的文件结构（要看懂这里就需要前面介绍的知识了），每次读取一个完整的NALU后再将数据通过 block 传递给外部调用者处理。

AVEncoder -> 读入CMBuffer -> 调用AVAssetWriter编码Buffer -> 设置 header 的 FileHandler -> 获得第一帧（moov[sps, pps]），切换写入文件（寻找mdat），重设FileHandle -> [输入数据 -> 编码 处理循环 ] -> 发送给调用者处理。

##思路
通过`UIImagePickerController`调用摄像头`UIImagePickerControllerSourceTypeCamera`进行数据的捕捉/采集。

对于采集到的数据，我们需要将采集到的原始数据输出成我们所需要的格式，才可以供我们使用。所以这里我们利用AVFoundation建立一个`AVCaptureSession`会话，然后将数据的采集/输入以及输出工作都放在该会话中进行。如：

```
_session = [[AVCaptureSession alloc] init];
......
[_session addInput:videoInput];
[_session addOutput:videoOutput];
```
其中：
①数据的采集，包括采集视频数据`AVMediaTypeVideo`和 音频数据`AVMediaTypeAudio`两种，这两种的采集我们都直接通过`AVCaptureDeviceInput`这个AVCaptureInput的子类来从输入设备`AVCaptureDevice`

```
    NSError *error = nil;
    AVCaptureDevice *dev = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:dev error:&error];
    if (error) {
        NSLog(@"Error: getting video input device: %@", error.description);
    }
    [_session addInput:videoInput];
``` 
②