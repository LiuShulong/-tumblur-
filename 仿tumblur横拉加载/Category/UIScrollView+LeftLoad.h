//
//  UIScrollView+LeftLoad.h
//  仿tumblur横拉加载
//
//  Created by LiuShulong on 5/23/15.
//  Copyright (c) 2015 LiuShulong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (LeftLoad)

- (void)addRightFooterWithRefreshBlcok:(void(^)())block;

- (void)endRefreshing;

@end
