//
//  CustomCell.m
//  仿tumblur横拉加载
//
//  Created by LiuShulong on 5/23/15.
//  Copyright (c) 2015 LiuShulong. All rights reserved.
//

#import "CustomCell.h"

@interface CustomCell ()

@property (nonatomic,strong) UILabel *label;

@end

@implementation CustomCell

#pragma mark - lifeCycle

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor redColor];
        [self.contentView addSubview:self.label];
        [self configureFrames];

    }
    return self;
}

- (void)configureFrames
{
    self.label.frame = self.contentView.bounds;
}


#pragma mark - public method 

- (void)configureWithText:(NSString *)text
{
    self.label.text = text;

}

#pragma mark - get

- (UILabel *)label
{
    if (_label == nil) {
        _label = [[UILabel alloc] init];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.backgroundColor = [UIColor cyanColor];
        _label.textColor = [UIColor whiteColor];
    }
    return _label;
}

@end
