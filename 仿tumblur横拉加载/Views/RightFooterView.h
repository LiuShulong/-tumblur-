//
//  RightFooterView.h
//  仿tumblur横拉加载
//
//  Created by LiuShulong on 5/23/15.
//  Copyright (c) 2015 LiuShulong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomActivityView.h"

typedef NS_ENUM(NSInteger, RefreshState) {
    RefreshStatePulling = 1, //松开可以进行刷新的状态
    RefreshStateNormal  = 2,//普通状态
    RefreshStateRefreshing = 3,//正在刷新中得状态
    RefreshStateWillRefreshing = 4
};


@interface RightFooterView : UIView

#pragma mark - 父控件
@property (nonatomic, weak, readonly) UIScrollView *scrollView;
@property (nonatomic, assign, readonly) UIEdgeInsets scrollViewOriginalInset;

#pragma mark - 内部控件
@property (nonatomic,strong) CustomActivityView *activityView;

+ (instancetype)rightFooterView;

#pragma mark - 刷新相关
/**
 *  是否正在刷新
 */
@property (nonatomic, readonly, getter=isRefreshing) BOOL refreshing;

@property (nonatomic,assign) RefreshState state;

/** 处于刷新结束的状态 */
@property (readonly, getter=isEndingRefresh) BOOL endingRefresh;

/**
 *  开始进入刷新状态就会调用
 */
@property (nonatomic, copy) void (^beginRefreshingCallback)();

/**
 *  开始刷新
 */
- (void)beginRefreshing;
/**
 *  结束刷新
 */
- (void)endRefreshing;

@end
