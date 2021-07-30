//
//  CXfloatingButtonController.m
//  FloatWindowDemo
//
//  Created by peak on 2020/9/21.
//  Copyright © 2020 peak. All rights reserved.
//

#import "CXfloatingButtonController.h"
#import "CXFloatDeviceUtils.h"

@implementation CXfloatingButtonController
{
    UIButton *_floatingButton;
    
    NSTimer *_timer;
    NSByteCountFormatter *_formatter;
    NSString *_memoryText;
    
    CADisplayLink *_link;
    NSUInteger _count;
    NSTimeInterval _lastTime;
}

- (instancetype)init {
    if (self = [super init]) {
        _formatter = [NSByteCountFormatter new];
    }
    return self;
}

- (void)loadView {
    _floatingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.view = _floatingButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _floatingButton.titleLabel.numberOfLines = 0;
    _floatingButton.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.700];
    _floatingButton.titleLabel.font = [UIFont systemFontOfSize:11];
    _floatingButton.titleLabel.textColor = [UIColor whiteColor];
    _floatingButton.clipsToBounds = YES;
    _floatingButton.layer.cornerRadius = 5;
    [_floatingButton setTitle:@"IMP/FPS" forState:UIControlStateNormal];
      
    [_floatingButton addTarget:self action:@selector(buttonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [self update];
    [self setupFPS:60];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(update) userInfo:nil repeats:YES];
    _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
    [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [_timer invalidate];
    _timer = nil;
    
    [_link invalidate];
    _link = nil;
}

- (void)update {
    _memoryText = [_formatter stringFromByteCount:CXResidentMemoryInBytes()];
    NSLog(@"%@", _memoryText);
}

- (void)tick:(CADisplayLink *)link {
    if (_lastTime == 0) {
        _lastTime = link.timestamp;
        return;
    }
    
    _count++;
    NSTimeInterval delta = link.timestamp - _lastTime;
    if (delta < 1) {
        return;
    }
    
    _lastTime = link.timestamp;
    CGFloat fps = _count / delta;
    _count = 0;
    
    [self setupFPS:fps];
}

- (void)setupFPS:(CGFloat)fps {
    if (_memoryText.length == 0) {
        return;
    }
    
    CGFloat progress = fps / 60.0;
    UIColor *color = [UIColor colorWithHue:0.27 * (progress - 0.2) saturation:1 brightness:0.9 alpha:1];
    
    NSString *impStr = _memoryText;
    NSString *fpsStr = [NSString stringWithFormat:@"%d FPS",(int)round(fps)];
    
    NSString *str = [NSString stringWithFormat:@"%@\n%@", impStr, fpsStr];
    NSMutableAttributedString *ma = [[NSMutableAttributedString alloc] initWithString:str];
    [ma addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11] range:NSMakeRange(0, impStr.length)];
    [ma addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, impStr.length)];
    [ma addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(impStr.length +  1, fpsStr.length - 3)];
    [ma addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(str.length - 3, 3)];
    [ma addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11] range:NSMakeRange(impStr.length +  1, fpsStr.length)];
    [ma addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:4] range:NSMakeRange(str.length - 4, 1)];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 2;
    style.alignment = NSTextAlignmentCenter;
    [ma addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, ma.length)];
    
    [_floatingButton setAttributedTitle:ma forState:UIControlStateNormal];
}

- (void)buttonTapped
{
    NSLog(@"--- buttonTapped ");
    
    [self.presentationModeDelegate presentationDelegateChangezpresentationModeToMode:CXPresentationModeFullWindow];
}

#pragma mark CXMovableViewController

- (void)containerWillMove:(UIViewController *)container
{
  // No extra behavior
}

- (BOOL)shouldStretchInMoableContrainer
{
  return YES;
}

- (CGFloat)minimumHeightInMovableContainer
{
  return 0;
}

@end
