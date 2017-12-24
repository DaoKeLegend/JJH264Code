//
//  JJH264VC.m
//  JJH264Code
//
//  Created by lucy on 2017/12/24.
//  Copyright © 2017年 com.daoKeLegend. All rights reserved.
//

#import "JJH264VC.h"
#import "JJEAGLLayer.h"
#import "JJConfigFile.h"

@interface JJH264VC ()
{
    AVCaptureSession *captureSession;
    AVCaptureConnection* connectionVideo;
    AVCaptureDevice *cameraDeviceB;
    AVCaptureDevice *cameraDeviceF;
    BOOL cameraDeviceIsF;
    JJH264Encoder *h264Encoder;
    AVCaptureVideoPreviewLayer *recordLayer;

    JJH264Decoder *h264Decoder;
    JJEAGLLayer *playLayer;
}
@end

@implementation JJH264VC

#pragma mark - Override Base Function

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.frame = [UIScreen mainScreen].bounds;
    self.view.backgroundColor = [UIColor whiteColor];
    cameraDeviceIsF = YES;
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in videoDevices) {
        if (device.position == AVCaptureDevicePositionFront) {
            cameraDeviceF = device;
        }
        else if(device.position == AVCaptureDevicePositionBack)
        {
            cameraDeviceB = device;
        }
    }
    
    h264Encoder = [JJH264Encoder alloc];
    [h264Encoder initWithConfiguration];
    [h264Encoder initEncode:h264outputWidth height:h264outputHeight];
    h264Encoder.delegate = self;
    
    h264Decoder = [[JJH264Decoder alloc] init];
    h264Decoder.delegate = self;
    
    UIButton *switchButton = [[UIButton alloc] initWithFrame:CGRectMake(30,80,100,40)];
    [switchButton setTitle:@"打开摄像头" forState:UIControlStateNormal];
    [switchButton setTitle:@"关闭摄像头" forState:UIControlStateSelected];
    [switchButton setBackgroundColor:[UIColor lightGrayColor]];
    [switchButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [switchButton addTarget:self
                   action:@selector(switchButtonDidClick:)
         forControlEvents:UIControlEventTouchUpInside];
    switchButton.selected = NO;
    [self.view addSubview:switchButton];
    
    UIButton *frontBackBtn = [[UIButton alloc] initWithFrame:CGRectMake(220,80,120,40)];
    [frontBackBtn setTitle:@"切换后摄像头" forState:UIControlStateNormal];
    [frontBackBtn setTitle:@"切换前摄像头" forState:UIControlStateSelected];
    [frontBackBtn setBackgroundColor:[UIColor lightGrayColor]];
    [frontBackBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [frontBackBtn addTarget:self
                   action:@selector(frontBackButtonDidClick:)
         forControlEvents:UIControlEventTouchUpInside];
    frontBackBtn.selected = NO;
    [self.view addSubview:frontBackBtn];
    
    playLayer = [[JJEAGLLayer alloc] initWithFrame:CGRectMake(200, 150, 160, 300)];
    playLayer.backgroundColor = [UIColor blackColor].CGColor;
}

#pragma mark - Object Private Function

- (void) initCamera:(BOOL)type
{
    NSError *deviceError;
    AVCaptureDeviceInput *inputCameraDevice;
    if (type==false)
    {
        inputCameraDevice = [AVCaptureDeviceInput deviceInputWithDevice:cameraDeviceB error:&deviceError];
    }
    else
    {
        inputCameraDevice = [AVCaptureDeviceInput deviceInputWithDevice:cameraDeviceF error:&deviceError];
    }
    AVCaptureVideoDataOutput *outputVideoDevice = [[AVCaptureVideoDataOutput alloc] init];
    
    NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
    NSNumber* val = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange];
    NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:val forKey:key];
    outputVideoDevice.videoSettings = videoSettings;
    [outputVideoDevice setSampleBufferDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)];
    captureSession = [[AVCaptureSession alloc] init];
    [captureSession addInput:inputCameraDevice];
    [captureSession addOutput:outputVideoDevice];
    [captureSession beginConfiguration];
    
    [captureSession setSessionPreset:[NSString stringWithString:AVCaptureSessionPreset1280x720]];
    connectionVideo = [outputVideoDevice connectionWithMediaType:AVMediaTypeVideo];
#if TARGET_OS_IPHONE
    [self setRelativeVideoOrientation];
    
    NSNotificationCenter* notify = [NSNotificationCenter defaultCenter];
    [notify addObserver:self
               selector:@selector(statusBarOrientationDidChange:)
                   name:@"StatusBarOrientationDidChange"
                 object:nil];
#endif
    
    [captureSession commitConfiguration];
    recordLayer = [AVCaptureVideoPreviewLayer    layerWithSession:captureSession];
    [recordLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
}

- (void)startCamera
{
    recordLayer = [AVCaptureVideoPreviewLayer    layerWithSession:captureSession];
    [recordLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    recordLayer.frame = CGRectMake(0, 120, 160, 300);
    [self.view.layer addSublayer:recordLayer];
    [captureSession startRunning];
    [self.view.layer addSublayer:playLayer];
}
- (void)stopCamera
{
    [captureSession stopRunning];
    [recordLayer removeFromSuperlayer];
    [playLayer removeFromSuperlayer];
}

#pragma mark - Action && Notification

- (void)switchButtonDidClick:(UIButton *)btn
{
    btn.selected = !btn.selected;
    
    if (btn.selected==YES)
    {
        [self stopCamera];
        [self initCamera:cameraDeviceIsF];
        [self startCamera];
    }
    else
    {
        [self stopCamera];
    }
}

- (void)frontBackButtonDidClick:(UIButton *)btn
{
    btn.selected = !btn.selected;
    
    if (captureSession.isRunning==YES)
    {
        cameraDeviceIsF = !cameraDeviceIsF;
        NSLog(@"变位置");
        [self stopCamera];
        [self initCamera:cameraDeviceIsF];
        [self startCamera];
    }
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput*)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection*)connection
{
    if (connection==connectionVideo)
    {
        [h264Encoder encode:sampleBuffer];
    }
}

#pragma mark - JJH264EncoderDelegate 编码回调

- (void)gotSpsPps:(NSData*)sps pps:(NSData*)pps
{
    const char bytes[] = "\x00\x00\x00\x01";
    size_t length = (sizeof bytes) - 1;
    NSData *ByteHeader = [NSData dataWithBytes:bytes length:length];
    //发sps
    NSMutableData *h264Data = [[NSMutableData alloc] init];
    [h264Data appendData:ByteHeader];
    [h264Data appendData:sps];
    [h264Decoder decodeNalu:(uint8_t *)[h264Data bytes] withSize:(uint32_t)h264Data.length];
    //发pps
    [h264Data resetBytesInRange:NSMakeRange(0, [h264Data length])];
    [h264Data setLength:0];
    [h264Data appendData:ByteHeader];
    [h264Data appendData:pps];
    
    [h264Decoder decodeNalu:(uint8_t *)[h264Data bytes] withSize:(uint32_t)h264Data.length];
}

- (void)gotEncodedData:(NSData*)data isKeyFrame:(BOOL)isKeyFrame
{
    const char bytes[] = "\x00\x00\x00\x01";
    size_t length = (sizeof bytes) - 1;
    NSData *ByteHeader = [NSData dataWithBytes:bytes length:length];
    NSMutableData *h264Data = [[NSMutableData alloc] init];
    [h264Data appendData:ByteHeader];
    [h264Data appendData:data];
    [h264Decoder decodeNalu:(uint8_t *)[h264Data bytes] withSize:(uint32_t)h264Data.length];
}

#pragma mark - JJH264DecoderDelegate 解码回调

- (void)displayDecodedFrame:(CVImageBufferRef )imageBuffer
{
    if(imageBuffer)
    {
        playLayer.pixelBuffer = imageBuffer;
        CVPixelBufferRelease(imageBuffer);
    }
}

#pragma mark -  方向设置

#if TARGET_OS_IPHONE

- (void)statusBarOrientationDidChange:(NSNotification*)notification
{
    [self setRelativeVideoOrientation];
}

- (void)setRelativeVideoOrientation
{
    switch ([[UIDevice currentDevice] orientation]) {
        case UIInterfaceOrientationPortrait:
#if defined(__IPHONE_8_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
        case UIInterfaceOrientationUnknown:
#endif
            recordLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
            connectionVideo.videoOrientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            recordLayer.connection.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
            connectionVideo.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            recordLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
            connectionVideo.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIInterfaceOrientationLandscapeRight:
            recordLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
            connectionVideo.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        default:
            break;
    }
}
#endif

@end
