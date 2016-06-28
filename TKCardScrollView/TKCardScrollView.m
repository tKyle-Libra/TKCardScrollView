//
//  TKCardScrollView.m
//  TKCardScrollView
//
//  Created by 同乐 on 16/6/28.
//  Copyright © 2016年 tKyle. All rights reserved.
//

#import "TKCardScrollView.h"

#define kGCRatio 0.8
#define kGCViewWidth CGRectGetWidth(self.frame)
#define kGCViewHeight CGRectGetHeight(self.frame)
#define kGCScrollViewWidth kGCViewWidth*kGCRatio

@interface TKCardScrollView ()<UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *cards;
@property (nonatomic, assign) NSInteger totalNumberOfCards;
@property (nonatomic, assign) NSInteger startCardIndex;
@property (nonatomic, assign) NSInteger currentCardIndex;

@end

@implementation TKCardScrollView

-(void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.backgroundColor = [UIColor blueColor];
    [self SetUp];
}

- (void) SetUp
{
    CGFloat x = (kGCViewWidth-kGCScrollViewWidth)/2;
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(x, 0, kGCScrollViewWidth, kGCViewHeight)];
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

- (void) LoadCard
{
    for (UIView *card in _cards)
    {
        [card removeFromSuperview];
    }
    
    _totalNumberOfCards = [_cardScrollDataSource NumberOfCards];
    if (_totalNumberOfCards == 0)
    {
        return;
    }
    
    [_scrollView setContentSize:CGSizeMake(kGCScrollViewWidth*_totalNumberOfCards, kGCViewHeight)];
    [_scrollView setContentOffset:[self ContentOffsetWithIndex:0]];
    
    for (NSInteger index = 0; index < (self.totalNumberOfCards < 4 ? self.totalNumberOfCards : 4); index++) {
        UIView *card = [_cardScrollDataSource CardReuseView:nil AtIndex:index];
        CGFloat width =  CGRectGetWidth(self.frame)*kGCRatio;
        CGFloat height = CGRectGetHeight(self.frame);
        card.frame = CGRectMake(0,0, width, height);
        card.center = [self CenterForCardWithIndex:index];
        card.tag = index;
        [_scrollView addSubview:card];
        [_cards addObject:card];

        [_cardScrollDelegate UpdateCard:card WithProgress:1 Direction:TKCardMoveDirectionNone];
    }
}

- (NSArray *) AllCards
{
    return self.cards;
}

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
    CGFloat x = kGCScrollViewWidth*(index + 0.5);
    CGFloat y = self.scrollView.center.y;
    return CGPointMake(x, y);
}

- (CGPoint) ContentOffsetWithIndex:(NSInteger)index
{
    return CGPointMake(kGCScrollViewWidth*index, 0);
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

- (void) AscendingSortCards {
    [_cards sortUsingComparator:^NSComparisonResult(UIView *obj1, UIView *obj2)
    {
        return obj1.tag > obj2.tag;
    }];
}


#pragma mark - UIScrollViewDelegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat orginContentOffset = self.currentCardIndex*kGCScrollViewWidth;
    CGFloat diff = scrollView.contentOffset.x - orginContentOffset;
    CGFloat progress = fabs(diff)/(kGCViewWidth*0.8);
    TKCardMoveDirection direction = diff > 0 ? TKCardMoveDirectionLeft : TKCardMoveDirectionRight;
    for (UIView *card in self.cards) {
        [_cardScrollDelegate UpdateCard:card WithProgress:progress Direction:direction];
    }
    
    if (fabs(diff) >= kGCScrollViewWidth*0.8) {
        _currentCardIndex = direction == TKCardMoveDirectionLeft ? _currentCardIndex + 1 : _currentCardIndex - 1;
        [self ReuseCardWithMoveDirection:direction];
    }
}



@end
