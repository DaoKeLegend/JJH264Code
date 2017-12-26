//
//  ViewController.m
//  JJMusic_demo2
//
//  Created by mac on 2017/12/26.
//  Copyright © 2017年 DaoKeLegend. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) UISlider *progressSlide;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIImageView *animatedView;
@property (nonatomic, strong) id timeObserver;


@end

@implementation ViewController

#pragma mark -  Override Base Function

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //UI界面
    [self initUI];
    
    //可播放可录音，更可以后台播放，还可以在其他程序播放的情况下暂停播放
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord
             withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
                   error:nil];
}

- (void)dealloc
{
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    [self.player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    if (self.timeObserver) {
        [self.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }
}

#pragma mark -  Object Private Function

- (void)initUI
{
    //背景图案
    self.animatedView = [[UIImageView alloc] init];
    self.animatedView.image = [UIImage imageNamed:@"backView"];
    self.animatedView.frame = CGRectMake((self.view.bounds.size.width - 200.0) * 0.5, (self.view.bounds.size.height - 200.0) * 0.5, 200.0, 200.0);
    self.animatedView.layer.cornerRadius = 100.0;
    self.animatedView.layer.masksToBounds = YES;
    [self.view addSubview:self.animatedView];
    
    //开始按钮
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake((self.view.bounds.size.width - 200.0) * 0.5, (self.view.bounds.size.height - 200.0) * 0.5, 200.0, 200.0);
    button.layer.cornerRadius = 100.0;
    button.layer.masksToBounds = YES;
    [button setTitle:@"开始播放" forState:UIControlStateNormal];
    [button setTitle:@"停止播放" forState:UIControlStateSelected];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    [button addTarget:self action:@selector(playButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    self.button = button;
    
    //滑动条
    UISlider *progressSlide = [[UISlider alloc] initWithFrame:CGRectMake(30.0, self.view.bounds.size.height - 100.0, self.view.bounds.size.width - 60.0, 50.0)];
    progressSlide.backgroundColor = [UIColor purpleColor];
    [progressSlide addTarget:self action:@selector(sliderDidSlide:) forControlEvents:UIControlEventValueChanged];
    self.progressSlide = progressSlide;
    [self.view addSubview:progressSlide];
}

- (void)playMusic
{
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    [self.player play];
}

- (void)stopMusic
{
    [self.player pause];
}

- (AVPlayerItem *)getItemWithIndex:(NSInteger)index
{
    //这里是用本地数据模拟网络数据，网络资源不好找
//    NSString *str = [[NSBundle mainBundle] pathForResource:@"sound" ofType:@"m4a"];
    NSString *str = [[NSBundle mainBundle] pathForResource:@"music" ofType:@"mp3"];
    NSURL *url = [NSURL fileURLWithPath:str];
    
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:url];
    //KVO监听播放状态
    [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //KVO监听缓存大小
    [item addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    //通知监听item播放完毕
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopMusic) name:AVPlayerItemDidPlayToEndTimeNotification object:item];
    return item;
}

#pragma mark -  Action && Notification

- (void)playButtonDidClick:(UIButton *)button
{
    button.selected = !button.selected;
    
    if (button.selected) {
        [self playMusic];
    }
    else {
        [self stopMusic];
        self.player = nil;
        if (_timer) {
            [_timer invalidate];
            _timer = nil;
        }
        self.animatedView.transform = CGAffineTransformMakeRotation(0.0);
        self.progressSlide.value = 0.0;
    }
}

- (void)sliderDidSlide:(UISlider *)slider
{
    NSLog(@"拖动");
    
    if (self.player.status == AVPlayerStatusReadyToPlay) {
        [self.player seekToTime:CMTimeMake(CMTimeGetSeconds(self.player.currentItem.duration) * slider.value, 1)];
    }
}

#pragma mark -  KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    
    AVPlayerItem *item = object;
    
    //状态的监听
    if ([keyPath isEqualToString:@"status"]) {
        switch (self.player.status) {
            case AVPlayerStatusUnknown:
                NSLog(@"未知状态，不能播放");
                break;
            case AVPlayerStatusReadyToPlay:
                NSLog(@"准备完毕，可以播放");
                break;
            case AVPlayerStatusFailed:
                NSLog(@"加载失败, 网络相关问题");
                break;
                
            default:
                break;
        }
    }
    
    //下载时长，获取缓冲时间
    if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSArray *array = item.loadedTimeRanges;
        //本次缓存的时间
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];
        NSTimeInterval totalBufferTime = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration);
        //这里，获取的是缓存的总长度，我这里是本地音乐模拟网络音乐，所以这里totalBufferTime一直就是总时长
        NSLog(@"totalBufferTime = %lf", totalBufferTime);
    }
}

#pragma mark -  Lazy load

- (AVPlayer *)player
{
    if (!_player) {
        
        //根据链接数组获取第一个播放的item， 用这个item来初始化AVPlayer
        AVPlayerItem *item = [self getItemWithIndex:self.currentIndex];
        //初始化AVPlayer
        _player = [[AVPlayer alloc] initWithPlayerItem:item];
        
        //监听播放的进度的方法，addPeriodicTime: ObserverForInterval: usingBlock:
        /*
         CMTime 每到一定的时间会回调一次，包括开始和结束播放
         block回调，用来获取当前播放时长
         return 返回一个观察对象，当播放完毕时需要，移除这个观察
         */
        __weak typeof(self) weakSelf = self;
        self.timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            
            float current = CMTimeGetSeconds(time);
            NSLog(@"时间 = %lf - duration = %lf", current, CMTimeGetSeconds(item.duration));
            if (current) {
                weakSelf.progressSlide.value = current / CMTimeGetSeconds(item.duration);
            }
        }];
    }
    return _player;
}

- (NSTimer *)timer
{
    __weak typeof(self) weakSelf = self;
    _timer = [NSTimer timerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
         weakSelf.animatedView.transform = CGAffineTransformRotate(weakSelf.animatedView.transform, M_PI * 0.1);
    }];
    return _timer;
}

@end
