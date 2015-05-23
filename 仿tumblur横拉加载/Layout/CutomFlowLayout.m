//
//  CutomFlowLayout.m
//  仿tumblur横拉加载
//
//  Created by LiuShulong on 5/23/15.
//  Copyright (c) 2015 LiuShulong. All rights reserved.
//

#import "CutomFlowLayout.h"


@interface CutomFlowLayout ()

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, assign) CGFloat springDamping;
@property (nonatomic, assign) CGFloat springFrequency;
@property (nonatomic, assign) CGFloat resistanceFactor;

@end

@implementation CutomFlowLayout

- (id)init{
    self = [super init];
    
    if (self) {
        self.itemSize = CGSizeMake(100, 100);
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.minimumLineSpacing = 10.0;
        //设置动画属性
        _springDamping = 1;
        _springFrequency = 1;
        _resistanceFactor = 600;
        
    }
    
    return self;
}

- (void)prepareLayout{
    [super prepareLayout];
    
    CGSize contentSize = [self collectionViewContentSize];
    NSArray *items = [super layoutAttributesForElementsInRect:CGRectMake(0, 0, contentSize.width, contentSize.height)];
    if (_animator == nil) {
        _animator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
        for (UICollectionViewLayoutAttributes *item in items) {
            UIAttachmentBehavior *spring = [[UIAttachmentBehavior alloc] initWithItem:item attachedToAnchor:item.center];
            
            spring.length = 0;
            spring.damping = self.springDamping;
            spring.frequency = self.springFrequency;
            
            [self.animator addBehavior:spring];
        }
    }

}


- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    
    UIScrollView *scrollView = self.collectionView;
    CGFloat scrollDelta = newBounds.origin.x - scrollView.bounds.origin.x;
    CGPoint touchLocation = [scrollView.panGestureRecognizer locationInView:scrollView];
    
    for (UIAttachmentBehavior *spring in self.animator.behaviors) {
        CGPoint anchorPoint = spring.anchorPoint;
        CGFloat distanceFromTouch = fabs(touchLocation.x - anchorPoint.x);
        CGFloat scrollResistance = distanceFromTouch / self.resistanceFactor;
        UICollectionViewLayoutAttributes *item = [spring.items firstObject];
        CGPoint center = item.center;
        center.x += (scrollDelta > 0)?MIN(scrollDelta, scrollDelta * scrollResistance):MAX(scrollDelta, scrollDelta * scrollResistance);
        item.center = center;
        
        [_animator updateItemUsingCurrentState:item];
    }
    
    return NO;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect{
    
    return [self.animator itemsInRect:rect];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [self.animator layoutAttributesForCellAtIndexPath:indexPath];
}

#pragma mark - set

-(void)setSpringDamping:(CGFloat)springDamping {
    if (springDamping >= 0 && _springDamping != springDamping) {
        _springDamping = springDamping;
        for (UIAttachmentBehavior *spring in _animator.behaviors) {
            spring.damping = _springDamping;
        }
    }
}

-(void)setSpringFrequency:(CGFloat)springFrequency {
    if (springFrequency >= 0 && _springFrequency != springFrequency) {
        _springFrequency = springFrequency;
        for (UIAttachmentBehavior *spring in _animator.behaviors) {
            spring.frequency = _springFrequency;
        }
    }
}


@end
