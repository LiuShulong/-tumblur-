//
//  ViewController.m
//  仿tumblur横拉加载
//
//  Created by LiuShulong on 5/23/15.
//  Copyright (c) 2015 LiuShulong. All rights reserved.
//

#import "ViewController.h"
#import "CustomCell.h"
#import "CutomFlowLayout.h"
#import "CustomActivityView.h"
#import "UIScrollView+LeftLoad.h"

@interface ViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (strong, nonatomic) UICollectionView *collectionView;
@property (nonatomic,strong) UICollectionView *collectionView2;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) NSMutableArray *dataArray2;
@property (nonatomic,strong) CustomActivityView *activityView;
@property (nonatomic,assign) NSUInteger count;

@end

@implementation ViewController

#pragma mark - lifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.count = 5;
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.collectionView2];
    
    [self.view addSubview:self.activityView];
    [self.activityView startAnimate];
    [self configureFrames];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureFrames
{
    self.collectionView.frame = CGRectMake(0, 20, CGRectGetWidth(self.view.bounds), 100);
    self.collectionView2.frame = CGRectMake(0, CGRectGetMaxY(self.collectionView.frame) + 20, CGRectGetWidth(self.view.bounds), 100);
    self.activityView.frame = CGRectMake(100, 300, 100, 100);
}

#pragma mark - click

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.dataArray addObjectsFromArray:self.dataArray];
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSLog(@"count:%@",@(self.dataArray.count));
    
    if (collectionView == _collectionView) {
        return self.dataArray.count;
    } else {
        return self.dataArray2.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellID" forIndexPath:indexPath];
    
    NSString *text = nil;
    if (collectionView == _collectionView) {
        text = self.dataArray[indexPath.row];
    } else {
        text = self.dataArray2[indexPath.row];
    }
    
    [cell configureWithText:text];
    
    NSLog(@"text:%@",text);
    return cell;
}

#pragma mark - private method

- (void)addData
{
    NSInteger last = [[self.dataArray2 lastObject] integerValue];
    [self.dataArray2 addObject:[NSString stringWithFormat:@"%@",@(++last)]];
    [self.collectionView2 reloadData];
    [self.collectionView2 endRefreshing];
}


#pragma mark - get

- (NSMutableArray *)dataArray
{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
        for (int i = 1; i <= self.count ; i++) {
            NSString *text = [NSString stringWithFormat:@"%@",@(i)];
            [_dataArray addObject:text];
        }
    }
    return _dataArray;
}

- (NSMutableArray *)dataArray2
{
    if (_dataArray2 == nil) {
        _dataArray2 = [NSMutableArray array];
        for (int i = 1; i <= self.count ; i++) {
            NSString *text = [NSString stringWithFormat:@"%@",@(i)];
            [_dataArray2 addObject:text];
        }

    }
    return _dataArray2;
}

- (UICollectionView *)collectionView
{
    if (_collectionView == nil) {
        CutomFlowLayout *layout = [[CutomFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_collectionView registerClass:[CustomCell class] forCellWithReuseIdentifier:@"cellID"];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}

- (CustomActivityView *)activityView
{
    if (_activityView == nil) {
        _activityView = [[CustomActivityView alloc] init];
    }
    return _activityView;
}

- (UICollectionView *)collectionView2
{
    if (_collectionView2 == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(100, 100);
        _collectionView2 = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_collectionView2 registerClass:[CustomCell class] forCellWithReuseIdentifier:@"cellID"];
        _collectionView2.dataSource = self;
        _collectionView2.delegate = self;
        
        __weak ViewController *weakSelf = self;
        [_collectionView2 addRightFooterWithRefreshBlcok:^{
            
            
            [weakSelf performSelector:@selector(addData) withObject:nil afterDelay:3];

            
        }];
    }
    return _collectionView2;
}


@end
