//
//  TKCardScrollView.h
//  TKCardScrollView
//
//  Created by 同乐 on 16/6/28.
//  Copyright © 2016年 tKyle. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TKCardMoveDirection) {
    TKCardMoveDirectionNone,
    TKCardMoveDirectionLeft,
    TKCardMoveDirectionRight
};

@protocol TKCardScrollViewDataSource <NSObject>

- (NSInteger) NumberOfCards;

- (UIView *) CardReuseView:(UIView *)reuseView AtIndex:(NSInteger)index;

@end

@protocol TKCardScrollViewDelegate <NSObject>

- (void) UpdateCard:(UIView *)card WithProgress:(CGFloat)progress Direction:(TKCardMoveDirection)direction;

@end

@interface TKCardScrollView : UIView

@property (nonatomic, weak) id<TKCardScrollViewDataSource> cardScrollDataSource;

@property (nonatomic, weak) id<TKCardScrollViewDelegate> cardScrollDelegate;

- (void) LoadCard;

- (NSArray *) AllCards;

- (NSInteger) CurrentCard;

@end
