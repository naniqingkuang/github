//
//  mainView.m
//  testProject
//
//  Created by 猪猪 on 15/8/18.
//  Copyright (c) 2015年 @猪猪. All rights reserved.
//

#import "mainView.h"
@interface mainView()
{
    CAShapeLayer *_progressLayer;  //进度条
    CAShapeLayer *_progressLayer1; //内环
    CAShapeLayer *_progressLayer2;
    CAShapeLayer *_trackLayer;  // 进度条底图
   // UIWebView *_webView;  //gif 动画
    CALayer *_layerShandow; //阴影
    float percent;  //进度比例
    float lineWidth; //进度条宽度
    float offSet; //内环的宽度
    CALayer *_circleHeadLayer;
    UIView *_dataView;
    UILabel *_todaySumLB;
    UILabel *_titleNameLB;
    UILabel *_targetSumLB;
    CALayer *pngLayer;
    NSString *_title;
    NSString *_targetSum;
    NSString *_curSum;
    BOOL _isShadowSet;
}
@end

@implementation mainView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
        [self setUp];
    }
    return self;
}

- (void)setUp
{
    _isShadowSet = NO;
    float width = self.layer.frame.size.width;
    float height = self.layer.frame.size.height;
    float radius =  width > height ? ((height)/2) *2/3: ((width )/2 *2/3);
    _trackLayer = [CAShapeLayer layer];
    _trackLayer.frame = self.bounds;
    _trackLayer.fillColor = [[UIColor whiteColor]CGColor];
    _trackLayer.strokeColor =[[UIColor colorWithRed:249.0/255.0 green:249.0/255.0 blue:249.0/255.0 alpha:100.0]CGColor];
    _trackLayer.opacity = 1;
    //_trackLayer.shadowColor = [[UIColor blackColor]CGColor];
    //_trackLayer.shadowOffset = CGSizeMake(4, 4);
   // _trackLayer.shadowRadius = 4;
    
    //进度条，遮挡层
    _progressLayer = [CAShapeLayer layer];
    _progressLayer.frame = self.bounds;
    _progressLayer.fillColor =  [[UIColor clearColor] CGColor];
    _progressLayer.strokeColor  = [[UIColor blueColor] CGColor];
    _progressLayer.lineCap = kCALineCapRound;
    _progressLayer.opacity = 1;
    _progressLayer.strokeStart = 0.0;
    
    //渐变层
    CALayer *gradientLayer = [CALayer layer];
    gradientLayer.frame = self.bounds;
    gradientLayer.backgroundColor = [[UIColor whiteColor]CGColor];
    
    //子渐变层1
    CAGradientLayer *gradientLayer1 =  [CAGradientLayer layer];
    gradientLayer1.frame = CGRectMake(0, 0, width/2, height);
    gradientLayer1.colors = @[(__bridge id)[UIColor colorWithRed:76.0/255.0 green:233.0/255.0 blue:204.0/255.0 alpha:100.0].CGColor,
                              (__bridge id)[UIColor colorWithRed:233.0/255.0 green:193.0/255.0 blue:76.0/255.0 alpha:100.0].CGColor,
                              (__bridge id)[UIColor colorWithRed:203.0/255.0 green:66.0/255.0 blue:120.0/255.0 alpha:0.5].CGColor];
    
    gradientLayer1.locations  = @[@(0.25), @(0.7), @(1.0)];
    
    [gradientLayer1 setStartPoint:CGPointMake(0, 0)];
    [gradientLayer1 setEndPoint:CGPointMake(0, 1)];
    
    //子渐变层2
    CAGradientLayer *gradientLayer2 =  [CAGradientLayer layer];
    gradientLayer2.frame = CGRectMake(width/2, 0, width/2, height);
    gradientLayer2.colors = @[(__bridge id)[UIColor colorWithRed:76/255 green:233.0/255.0 blue:204.0/255.0 alpha:100.0].CGColor ,(__bridge id)[UIColor colorWithRed:73.0/255.0 green:159.0/255.0 blue:203.0/255.0 alpha:100.0].CGColor,(__bridge id)[UIColor colorWithRed:203.0/255.0 green:66.0/255.0 blue:120.0/255.0 alpha:0.5].CGColor];
    gradientLayer2.locations  = @[@(0.25), @(0.7), @(1.0)];
    [gradientLayer2 setStartPoint:CGPointMake(0, 0)];
    [gradientLayer2 setEndPoint:CGPointMake(0, 1)];
    
//    //图像层
    pngLayer = [CALayer layer];
    pngLayer.opacity = 1;
    pngLayer.backgroundColor = [[UIColor whiteColor]CGColor];
    pngLayer.masksToBounds = YES;
    pngLayer.anchorPoint = CGPointMake(0.5, 0.5);
    
    //内环，
    _progressLayer1 = [CAShapeLayer layer];
    _progressLayer1.frame = self.bounds;
    _progressLayer1.fillColor =  [[UIColor whiteColor] CGColor];
    _progressLayer1.strokeColor  = [[UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:100.0]CGColor];
    _progressLayer1.lineCap = kCALineCapRound;
    _progressLayer1.opacity = 1;
    _progressLayer1.strokeStart = 0.0;
    _progressLayer1.strokeEnd = 1;
    
    //设置阴影
    _layerShandow = [CALayer layer];
    _layerShandow.backgroundColor = [[UIColor blackColor] CGColor];
    _layerShandow.shadowColor = [UIColor blackColor].CGColor;
    _layerShandow.shadowOffset = CGSizeMake(1,2);
    _layerShandow.shadowOpacity = 0.8;
    _layerShandow.shadowRadius = 5.0;
    _layerShandow.shadowPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake((width-radius*2)/2, (height-radius*2)/2, radius*2, radius*2) cornerRadius:radius].CGPath;
    
    //动画
//    _webView = [[UIWebView alloc]init];
//    _webView.layer.masksToBounds = YES;
//    NSData *gifData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"hello" ofType:@"gif"]];
//    [_webView setUserInteractionEnabled:NO];
//    [_webView loadData:gifData MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
   
    float rectWidth =(radius*2 - (lineWidth +offSet)*2 )/1.414;
    _dataView = [[UIView alloc]init];
    _dataView.backgroundColor = [UIColor clearColor];
    _todaySumLB = [[UILabel alloc]init];
    [_todaySumLB setTextAlignment:NSTextAlignmentCenter];
    [_todaySumLB setFont:[UIFont systemFontOfSize:26]];
    _todaySumLB.frame =CGRectMake(0, rectWidth/2, rectWidth,rectWidth /2);
    _titleNameLB = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, rectWidth,rectWidth/4)];
    _titleNameLB.textAlignment = NSTextAlignmentCenter;
    _titleNameLB.font = [UIFont systemFontOfSize:16];
    _titleNameLB.textColor = [UIColor grayColor];
//    _targetSumLB = [[UILabel alloc]init];
//    _targetSumLB.frame = CGRectMake(0, rectWidth*3/4, rectWidth,rectWidth /4);
//    _targetSumLB.font = [UIFont systemFontOfSize:16];
//    _targetSumLB.textColor = [UIColor grayColor];
    //_targetSumLB.textAlignment = NSTextAlignmentCenter;
    [_dataView addSubview:_titleNameLB];
 //   [_dataView addSubview:_targetSumLB];
    [_dataView addSubview:_todaySumLB];
    
    //进度条的头部图像
    _circleHeadLayer = [[CALayer alloc]init];
    _circleHeadLayer.masksToBounds = YES;
    _circleHeadLayer.backgroundColor = [UIColor clearColor].CGColor;
    _circleHeadLayer.cornerRadius = lineWidth;
    _circleHeadLayer.contents = (id)[UIImage imageNamed:@"police"].CGImage;
    _circleHeadLayer.opacity = 1;
    _circleHeadLayer.anchorPoint = CGPointMake(0.5, 0.5);
    _circleHeadLayer.frame = CGRectMake(width/2 + (radius - lineWidth/2) * sin(0.15+(percent)*(2*M_PI - 0.30)), height/2 - ((radius - lineWidth/2) * cos(0.15+(percent)*(2*M_PI - 0.30))), lineWidth*2, lineWidth*2);
    //层次加载
    gradientLayer.mask = _progressLayer;
    [gradientLayer addSublayer:gradientLayer1];
    [gradientLayer addSublayer:gradientLayer2];
    [self.layer addSublayer:_layerShandow];
    [self.layer addSublayer:_trackLayer];
    [self.layer addSublayer:gradientLayer];
    [self.layer addSublayer:_progressLayer1];
    [self.layer addSublayer:pngLayer];
    [self.layer addSublayer:_circleHeadLayer];
   // [self addSubview:_dataView];
    [self.layer addSublayer:_dataView.layer];
    //_circleHeadLayer.frame = CGRectMake(0, 0, lineWidth*2, lineWidth*2);
}
- (void)circleFullAction:(float )aPercent
{
    if(aPercent - 1.0 < 0.0001 && aPercent > 1.0)
    {
        //[_layerShandow removeFromSuperlayer];
        _isShadowSet = NO;
        [_progressLayer addSublayer:_layerShandow];
    }
    else if(!_isShadowSet)
    {
        _isShadowSet = YES;
        [_layerShandow removeFromSuperlayer];
        //[self.layer addSublayer:_layerShandow];
    }
}
- (void)drawRect:(CGRect)rect
{
    float width = self.layer.frame.size.width ;
    float height = self.layer.frame.size.height;
    float radius =  width > height ? ((height)/2) - 15.0: ((width )/2 - 15.0);
   // 底图
    if (_trackLayer) {
        _trackLayer.lineWidth = lineWidth;
        _trackLayer.lineCap = kCALineCapRound;
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width/2, height/2) radius:(radius - lineWidth/2) startAngle:0 endAngle:M_PI *2 clockwise:YES];
        _trackLayer.path = [path CGPath];
    }
    //进度条
    if(_progressLayer)
    {
        _progressLayer.lineWidth = lineWidth;
        UIBezierPath *path1 = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width/2, height/2) radius:(radius - lineWidth/2) startAngle:M_PI*3/2 + 0.15 endAngle:M_PI*3/2 - 0.15 clockwise:YES];
        _progressLayer.strokeEnd = percent;
        _progressLayer.path = [path1 CGPath];
    }
   // 内环
    if(_progressLayer1)
    {
        UIBezierPath *path2 = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width/2, height/2) radius:(radius -lineWidth-offSet/2) startAngle:0 endAngle:M_PI*2 clockwise:YES];
        _progressLayer1.path = [path2 CGPath];
        _progressLayer1.lineWidth = offSet;
    }
   // 阴影
    if(_layerShandow)
    {
        _layerShandow.shadowPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake((width-radius*2)/2, (height-radius*2)/2, radius*2, radius*2) cornerRadius:radius].CGPath;
    }
//    //动画
//    if(_webView)
//    {
//        _webView.frame = CGRectMake((width/2 - radius + lineWidth + offSet), (height/2 - radius + lineWidth + offSet), (radius*2 - (lineWidth +offSet)*2)   , (radius*2 - (lineWidth +offSet)*2 ));
//        _webView.layer.cornerRadius = radius - lineWidth - offSet;
//    }
    //进度条的头部
    _circleHeadLayer.position = CGPointMake(width/2 + (radius - lineWidth/2) * sin(0.15+(percent)*(2*M_PI - 0.30)), height/2 - ((radius - lineWidth/2) * cos(0.15+(percent)*(2*M_PI - 0.30))));
    
    //小圆
    pngLayer.frame = CGRectMake((width/2 - radius + lineWidth+offSet), (height/2-radius + lineWidth+offSet), (radius*2 - lineWidth*2 - 2*offSet)   , (radius*2 - lineWidth*2 - 2*offSet));
    pngLayer.cornerRadius = radius -lineWidth - offSet;
    
    
    //显示内容
    float rectWidth =(radius*2 - (lineWidth +offSet)*2 )/1.414;
    _dataView.layer.frame = CGRectMake((width/2 - rectWidth/2 + 15.), (height/2 - rectWidth/2 +15.), rectWidth , rectWidth);
    _todaySumLB.text = _curSum;
    if(![_titleNameLB.text isEqual:_title])
    {
        _titleNameLB.text = _title;

    }
//    if(![_targetSumLB.text isEqual:_targetSum])
//    {
//        _targetSumLB.text = _targetSum;
//    }
}
- (void)setPersentMaskOfCircle:(CGFloat)value
{
    if (value != percent) {
        percent = value;
        [self setNeedsDisplay];
    }
    return;
}
- (void)setLineWidth:(float)bigCircleLineWidth AndOffset:(float)smallCircleLineWidth
{
    lineWidth = bigCircleLineWidth;
    offSet = smallCircleLineWidth;
    [self setNeedsDisplay];
}
- (void)setTitle:(NSString *)title andTarget:(NSString *)targetSum
{
    _title = title;
    _targetSum = targetSum;
}
- (void)setCurrentSum:(NSString *)curSum
{
    _curSum = curSum;
}
- (void)aninationStart {
    static int i = 0;
    i++;
    CABasicAnimation *cabasicAM = [CABasicAnimation animationWithKeyPath:@"transform"];
    cabasicAM.fillMode = kCAFillModeForwards;
    cabasicAM.removedOnCompletion = NO;
    cabasicAM.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.5, 0.5, 0.5)];
    cabasicAM.duration = 1;
    [self.layer addAnimation:cabasicAM forKey:nil];
    CABasicAnimation *cabasicAM1 = [CABasicAnimation animationWithKeyPath:@"transform"];
    cabasicAM1.fillMode = kCAFillModeForwards;
    cabasicAM1.removedOnCompletion = NO;
    cabasicAM1.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)];
    cabasicAM.duration = 10;
    [self.layer addAnimation:cabasicAM1 forKey:nil];

}

@end
