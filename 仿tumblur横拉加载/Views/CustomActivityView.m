//
//  CustomActivityView.m
//  仿tumblur横拉加载
//
//  Created by LiuShulong on 5/23/15.
//  Copyright (c) 2015 LiuShulong. All rights reserved.
//

#import "CustomActivityView.h"

@implementation CustomActivityView

/**
 *  defaultSize为空时，使用默认normalSize
 */
static CGSize normalSize = {70,15};

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefaultAttribute];
    }
    return self;
}


-(instancetype)init
{
    self = [super init];
    
    if (self) {
        [self setDefaultAttribute];
    }
    
    return self;
}


/**
 *   设置默认属性
 */
-(void)setDefaultAttribute
{
    _numberOfRect = 3;
    _defaultSize = normalSize;
    _spacing = 3;
    
    
    [self setBackgroundColor:[UIColor clearColor]];
    if (CGRectEqualToRect(self.frame, CGRectZero)) {
        [self setFrame:CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), _defaultSize.width, _defaultSize.height)];
    } else{
        _defaultSize = self.frame.size;
    }
}


-(CAAnimation*)addAnimateWithDelay:(CGFloat)delay delegate:(id)delegate
{
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];

    animation.fromValue = [NSNumber numberWithFloat:1.0F];
    animation.toValue = [NSNumber numberWithFloat:1.25f];
    
    CABasicAnimation *colorAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    colorAnimation.fromValue = (id)([UIColor
                                     lightGrayColor].CGColor);
    colorAnimation.toValue = (id)([UIColor whiteColor].CGColor);
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = [NSArray arrayWithObjects:animation,colorAnimation,nil];
    //设置组动画的时间
    group.duration = _numberOfRect * 0.2;;
    //    group2.fillMode = kCAFillModeForwards;
    group.delegate = delegate;
    group.removedOnCompletion = YES;
    group.autoreverses = YES;
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    group.beginTime = CACurrentMediaTime() + delay;
    group.repeatCount = MAXFLOAT;
    
    return group;
}


/**
 *  添加矩形
 */
-(void)addRect
{
    
    [self removeRect];
    [self setHidden:NO];
    
    for (int i = 0; i < _numberOfRect; i++) {
        
        RectView* rectView = [[RectView alloc] initWithFrame:CGRectMake(i * (_defaultSize.height + _spacing) , 0, _defaultSize.height, _defaultSize.height)];
        [rectView.layer setBackgroundColor:[UIColor lightGrayColor].CGColor];
        [rectView.layer addAnimation:[self addAnimateWithDelay:i*0.2 delegate:rectView] forKey:@"Scale"];
        [self addSubview:rectView];
        rectView.layer.masksToBounds = YES;
        rectView.layer.cornerRadius = 3.5;
    }
}



/**
 *  移除矩形
 */
-(void)removeRect
{
    if (self.subviews.count) {
        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    [self setHidden:YES];
}


#pragma mark - public method

- (void)startAnimate
{
    [self addRect];
}


- (void)stopAnimate
{
    [self removeRect];
}


@end


@implementation RectView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}




/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end

