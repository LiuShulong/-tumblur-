//
//  UIScrollView+LeftLoad.m
//  仿tumblur横拉加载
//
//  Created by LiuShulong on 5/23/15.
//  Copyright (c) 2015 LiuShulong. All rights reserved.
//

#import "UIScrollView+LeftLoad.h"
#import "RightFooterView.h"
#import <objc/runtime.h>

static char * const RefreshRightFooterKey = "RefreshRightFooterKey";


@interface UIScrollView ()

@property (nonatomic,weak) RightFooterView *rightFooter;

@end

@implementation UIScrollView(LeftLoad)


- (void)setRightFooter:(RightFooterView *)rightFooter
{
    [self willChangeValueForKey:@"RefreshRightFooterKey"];
    
    objc_setAssociatedObject(self, &RefreshRightFooterKey, rightFooter, OBJC_ASSOCIATION_ASSIGN);
    
    [self didChangeValueForKey:@"RefreshRightFooterKey"];
}

- (RightFooterView *)rightFooter
{
    return objc_getAssociatedObject(self, &RefreshRightFooterKey);
}

- (void)addRightFooterWithRefreshBlcok:(void (^)())block
{
    if (!self.rightFooter) {
        RightFooterView *rightFooterView = [RightFooterView rightFooterView];
        [self addSubview:rightFooterView];
        
        self.rightFooter = rightFooterView;
    }
    
    self.rightFooter.beginRefreshingCallback = block;
}



- (BOOL)isRightFooterRefreshing
{
    return self.rightFooter.isRefreshing;
}

- (void)endRefreshing
{
    [self.rightFooter endRefreshing];
}

@end
