//
//  TKCardScrollView.m
//  TKCardScrollView
//
//  Created by 同乐 on 16/6/28.
//  Copyright © 2016年 tKyle. All rights reserved.
//

#import "TKCardScrollView.h"

#define TKRatio 0.8
/**
 *  TKCardScrollView 的宽度
 */
#define TKViewWidth CGRectGetWidth(self.frame)
/**
 *  TKCardScrollView 的高度
 */
#define TKViewHeight CGRectGetHeight(self.frame)
/**
 *  scrollView 宽度
 */
#define TKScrollViewWidth TKViewWidth*TKRatio

@interface TKCardScrollView ()<UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *cards;
@property (nonatomic, assign) NSInteger totalNumberOfCards;
@property (nonatomic, assign) NSInteger startCardIndex;
@property (nonatomic, assign) NSInteger currentCardIndex;

@end

@implementation TKCardScrollView

-(id) init
{
    self = [super init];
    
    [self SetUp];
    
    return self;
}

-(void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    /**
     *  设置 _scrollView 坐标
     *  x   设置 _scrollView 居中
     */
    if (_scrollView)
    {
        CGFloat x = (TKViewWidth-TKScrollViewWidth)/2;
        _scrollView.frame = CGRectMake(x, 0, TKScrollViewWidth, TKViewHeight);
    }
}

/**
 *  初始化控件
 */
- (void) SetUp
{
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.backgroundColor = [UIColor orangeColor];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.clipsToBounds = NO;
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    [self addSubview:_scrollView];
    
    _cards = [NSMutableArray array];
    _startCardIndex = 0;
    _currentCardIndex = 0;
}

#pragma mark - public methods

/**
 *  读取并加载多个card
 */
- (void) LoadCard
{
    /**
     *  删除之前加载的view,避免重复加载
     */
    for (UIView *card in _cards)
    {
        [card removeFromSuperview];
    }
    /**
     *  获取 SuperView 需要加载card 数量
     *  如果 card 数落 为0，不加载
     */
    _totalNumberOfCards = [_cardScrollDataSource NumberOfCards];
    if (_totalNumberOfCards == 0)
    {
        return;
    }
    /**
     *  设置 _scrollView 的内容大小。 width = (_scrollView 宽度 * card数量) , height = _scrollView 高度;
     */
    [_scrollView setContentSize:CGSizeMake(TKScrollViewWidth*_totalNumberOfCards, TKViewHeight)];
    /**
     *  设置 _scrollView 初始内容显示位置
     */
    [_scrollView setContentOffset:[self ContentOffsetWithIndex:0]];
    
    /**
     *  通过SuperView获取每个card View,设置坐标，并加载显示
     */
    for (NSInteger index = 0; index < (self.totalNumberOfCards < 4 ? self.totalNumberOfCards : 4); index++)
    {
        UIView *card = [_cardScrollDataSource CardReuseView:nil AtIndex:index];
        card.frame = CGRectMake(0,0, TKScrollViewWidth, TKViewHeight);
        card.center = [self CenterForCardWithIndex:index];
        card.tag = index;
        [_scrollView addSubview:card];
        [_cards addObject:card];

        [_cardScrollDelegate UpdateCard:card WithProgress:1 Direction:TKCardMoveDirectionNone];
    }
}

/**
 *  获取所有Card Views;
 */
- (NSArray *) AllCards
{
    return self.cards;
}

/**
 *  当前显示Card View的索引
 */
- (NSInteger) CurrentCard
{
    return self.currentCardIndex;
}

#pragma mark - private methods

- (void) ScrollToIndex:(NSInteger)index animated:(BOOL)animated
{
    [self.scrollView setContentOffset:[self ContentOffsetWithIndex:index] animated:animated];
}

- (CGPoint) CenterForCardWithIndex:(NSInteger)index
{
    CGFloat x = TKScrollViewWidth*(index + 0.5);
    CGFloat y = self.scrollView.center.y;
    return CGPointMake(x, y);
}

- (CGPoint) ContentOffsetWithIndex:(NSInteger)index
{
    return CGPointMake(TKScrollViewWidth*index, 0);
}

- (void) ReuseCardWithMoveDirection:(TKCardMoveDirection)moveDirection
{
    BOOL isLeft = moveDirection == TKCardMoveDirectionLeft;
    UIView *card = nil;
    if (isLeft)
    {
        if (_currentCardIndex > _totalNumberOfCards - 3 || _currentCardIndex < 2)
        {
            return;
        }
        card = [_cards objectAtIndex:0];
        card.tag += 4;
    }
    else
    {
        if (_currentCardIndex > _totalNumberOfCards - 4 || _currentCardIndex < 1)
        {
            return;
        }
        card = [_cards objectAtIndex:3];
        card.tag-=4;
    }
    card.center = [self CenterForCardWithIndex:card.tag];
    [_cardScrollDataSource CardReuseView:card AtIndex:card.tag];
    [self AscendingSortCards];
}



- (void) ResetTagFromIndex:(NSInteger)index
{
    [_cards enumerateObjectsUsingBlock:^(UIView *card, NSUInteger idx, BOOL * _Nonnull stop)
    {
        if ((NSInteger)idx > index)
        {
            card.tag -= 1;
            [UIView animateWithDuration:0.3 animations:^
            {
                card.center = [self CenterForCardWithIndex:card.tag];
            }];
        }
    }];
}

- (void) AscendingSortCards
{
    [_cards sortUsingComparator:^NSComparisonResult(UIView *obj1, UIView *obj2)
    {
        return obj1.tag > obj2.tag;
    }];
}


#pragma mark - UIScrollViewDelegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat orginContentOffset = self.currentCardIndex*TKScrollViewWidth;
    CGFloat diff = scrollView.contentOffset.x - orginContentOffset;
    CGFloat progress = fabs(diff)/(TKViewWidth*0.8);
    TKCardMoveDirection direction = diff > 0 ? TKCardMoveDirectionLeft : TKCardMoveDirectionRight;
    for (UIView *card in self.cards)
    {
        [_cardScrollDelegate UpdateCard:card WithProgress:progress Direction:direction];
    }
    
    if (fabs(diff) >= TKScrollViewWidth*0.8)
    {
        _currentCardIndex = direction == TKCardMoveDirectionLeft ? _currentCardIndex + 1 : _currentCardIndex - 1;
        [self ReuseCardWithMoveDirection:direction];
    }
}



@end
