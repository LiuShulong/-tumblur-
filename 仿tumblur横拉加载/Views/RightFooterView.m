//
//  RightFooterView.m
//  仿tumblur横拉加载
//
//  Created by LiuShulong on 5/23/15.
//  Copyright (c) 2015 LiuShulong. All rights reserved.
//

#import "RightFooterView.h"

const CGFloat RefreshViewWidth = 64.0;
const CGFloat RefreshFastAnimationDuration = 0.25;
const CGFloat RefreshSlowAnimationDuration = 0.4;

NSString *const RefreshHeaderTimeKey = @"RefreshHeaderView";

NSString *const RefreshContentOffset = @"contentOffset";
NSString *const RefreshContentSize = @"contentSize";

@interface RightFooterView ()

@property (assign, nonatomic) NSInteger lastRefreshCount;

@end

@implementation RightFooterView

+ (instancetype)rightFooterView
{
    return [[RightFooterView alloc] init];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    frame.size.width = RefreshViewWidth;
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.state = RefreshStateNormal;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.activityView.frame = CGRectMake(10,
                                         (CGRectGetHeight(self.frame) - 15)/2.0f,
                                         15,
                                         15);
}


- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    
    // 旧的父控件
    [self.superview removeObserver:self forKeyPath:RefreshContentOffset context:nil];
    [self.superview removeObserver:self forKeyPath:RefreshContentSize context:nil];
    
    
    if (newSuperview) { // 新的父控件
        [newSuperview addObserver:self forKeyPath:RefreshContentOffset options:NSKeyValueObservingOptionNew context:nil];
        // 监听
        [newSuperview addObserver:self forKeyPath:RefreshContentSize options:NSKeyValueObservingOptionNew context:nil];
        
        // 记录UIScrollView
        _scrollView = (UIScrollView *)newSuperview;
        // 记录UIScrollView最开始的contentInset
        _scrollViewOriginalInset = _scrollView.contentInset;
        
        // 重新调整frame
        [self adjustFrameWithContentSize];
    }
}

#pragma mark 重写调整frame
- (void)adjustFrameWithContentSize
{
    // 内容的宽度
    CGFloat contentWidth = self.scrollView.contentSize.width;
    // 表格的宽度
    CGFloat scrollWidth = self.scrollView.frame.size.width - self.scrollViewOriginalInset.left - self.scrollViewOriginalInset.right;
    // 设置位置和尺寸
    CGFloat x = MAX(contentWidth, scrollWidth);
    
    CGRect frame = self.frame;
    frame.size.width = RefreshViewWidth;
    frame.origin.x = x;
    frame.size.height = CGRectGetHeight(self.scrollView.frame);
    self.frame = frame;
}

#pragma mark 监听UIScrollView的属性
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // 不能跟用户交互，直接返回
    if (!self.userInteractionEnabled || self.alpha <= 0.01 || self.hidden) return;
    
    if ([RefreshContentSize isEqualToString:keyPath]) {
        // 调整frame
        [self adjustFrameWithContentSize];
    } else if ([RefreshContentOffset isEqualToString:keyPath]) {
        
        // 如果正在刷新，直接返回
        if (self.state == RefreshStateRefreshing || self.endingRefresh) return;
        
        // 调整状态
        [self adjustStateWithContentOffset];
    }
}

/**
 *  调整状态
 */
- (void)adjustStateWithContentOffset
{
    // 当前的contentOffset
    CGFloat currentOffsetX = self.scrollView.contentOffset.x;
    // 尾部控件刚好出现的offsetY
    CGFloat happenOffsetX = [self happenOffsetX];
    // 如果是向下滚动到看不见尾部控件，直接返回
    if (currentOffsetX <= happenOffsetX) return;
    
    if (self.scrollView.isDragging) {
        // 普通 和 即将刷新 的临界点
        CGFloat normal2pullingOffsetX = happenOffsetX + RefreshViewWidth;
        
        if (self.state == RefreshStateNormal && currentOffsetX > normal2pullingOffsetX) {
            // 转为即将刷新状态
            self.state = RefreshStatePulling;
        } else if (self.state == RefreshStatePulling && currentOffsetX <= normal2pullingOffsetX) {
            // 转为普通状态
            self.state = RefreshStateNormal;
        }
    } else if (self.state == RefreshStatePulling) {// 即将刷新 && 手松开
        // 开始刷新
        self.state = RefreshStateRefreshing;
    }
}

#pragma mark - 状态相关
#pragma mark 设置状态
- (void)setState:(RefreshState)state
{
    // 1.一样的就直接返回
    if (self.state == state) return;
    
    // 2.保存旧状态
    RefreshState oldState = self.state;
    
    _state = state;
    // 3.根据状态来设置属性
    switch (state)
    {
        case RefreshStateNormal:
        {
            // 刷新完毕
            if (RefreshStateRefreshing == oldState) {
                
                //正在结束刷新
                _endingRefresh = NO;
            }
            
            
            CGFloat deltaw = [self widthForContentBreakView];
            NSInteger currentCount = [self totalDataCountInScrollView];
            self.scrollView.contentInset = self.scrollViewOriginalInset;
            
            // 刚刷新完毕
            if (RefreshStateRefreshing == oldState && deltaw > 0 && currentCount != self.lastRefreshCount) {
                UIEdgeInsets insets = self.scrollView.contentInset;
                insets.right = self.scrollViewOriginalInset.right;
                self.scrollView.contentInset = insets;
            }
            break;
        }
            
        case RefreshStatePulling:
        {
            break;
        }
            
        case RefreshStateRefreshing:
        {
            // 记录刷新前的数量
            self.lastRefreshCount = [self totalDataCountInScrollView];
            
            [UIView animateWithDuration:RefreshFastAnimationDuration animations:^{
                CGFloat right = self.frame.size.width + self.scrollViewOriginalInset.right;
                CGFloat deltaw = [self widthForContentBreakView];
                if (deltaw < 0) { // 如果内容宽度小于view的宽度
                    right -= deltaw;
                }
                
                UIEdgeInsets insets = self.scrollView.contentInset;
                insets.right = right;
                self.scrollView.contentInset = insets;
                
                if (self.beginRefreshingCallback) {
                    _beginRefreshingCallback();
                }
                
            }];
            break;
        }
            
        default:
            break;
    }
}

- (NSInteger)totalDataCountInScrollView
{
    NSInteger totalCount = 0;
    if ([self.scrollView isKindOfClass:[UICollectionView class]]) {
        UICollectionView *collectionView = (UICollectionView *)self.scrollView;
        
        for (NSInteger section = 0; section<collectionView.numberOfSections; section++) {
            totalCount += [collectionView numberOfItemsInSection:section];
        }
    }
    return totalCount;
}


#pragma mark 获得scrollView的内容 超出 view 的宽度
- (CGFloat)widthForContentBreakView
{
    CGFloat w = self.scrollView.frame.size.width - self.scrollViewOriginalInset.left - self.scrollViewOriginalInset.right;
    return self.scrollView.contentSize.width - w;
}

#pragma mark -
/**
 *  刚好看刷新控件时的contentOffset.x
 */
- (CGFloat)happenOffsetX
{
    CGFloat deltaw = [self widthForContentBreakView];
    if (deltaw > 0) {
        return deltaw - self.scrollViewOriginalInset.left;
    } else {
        return - self.scrollViewOriginalInset.left;
    }
}


#pragma mark - 显示到屏幕上
- (void)drawRect:(CGRect)rect
{
    if (self.state == RefreshStateWillRefreshing) {
        self.state = RefreshStateRefreshing;
    }
}

#pragma mark - 刷新相关
#pragma mark 是否正在刷新
- (BOOL)isRefreshing
{
    return RefreshStateRefreshing == self.state;
}

#pragma mark 开始刷新
- (void)beginRefreshing
{
    if (self.state == RefreshStateRefreshing) {
        // 回调
        
    } else {
        if (self.window) {
            self.state = RefreshStateRefreshing;
        } else {
            _state = RefreshStateWillRefreshing;
            
            [self setNeedsDisplay];
        }
    }
}

#pragma mark 结束刷新
- (void)endRefreshing
{
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.state = RefreshStateNormal;
    });
}

#pragma mark - get

- (CustomActivityView *)activityView
{
    if (!_activityView) {
        CustomActivityView *activity = [[CustomActivityView alloc] init];
        [self addSubview:_activityView = activity];
        [activity startAnimate];
    }
    return _activityView;
}

@end
