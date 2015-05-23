//
//  CustomActivityView.h
//  仿tumblur横拉加载
//
//  Created by LiuShulong on 5/23/15.
//  Copyright (c) 2015 LiuShulong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <UIKit/UIKit.h>

@interface RectView : UIView

@end


@interface CustomActivityView : UIView

@property(readwrite , nonatomic) NSUInteger numberOfRect;

@property(strong , nonatomic) UIColor* rectBackgroundColor;

@property(readwrite , nonatomic) CGSize defaultSize;

@property(readwrite , nonatomic) CGFloat spacing;

-(void)startAnimate;

-(void)stopAnimate;

@end
