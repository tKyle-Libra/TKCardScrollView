//
//  ViewController.m
//  TKCardScrollView
//
//  Created by 同乐 on 16/6/28.
//  Copyright © 2016年 tKyle. All rights reserved.
//

#import "ViewController.h"
#import "TKCardScrollView.h"
/**
 *  color config
 */
#define GCUIColorFromRGB(rgbValue)  [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 blue:((float)(rgbValue & 0xFF)) / 255.0 alpha:1.0]

#define kGCCardRatio 0.8

@interface ViewController ()<TKCardScrollViewDelegate,TKCardScrollViewDataSource>

@property (nonatomic, strong) TKCardScrollView *cardScrollView;
@property (nonatomic, strong) NSMutableArray *cards;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = GCUIColorFromRGB(0xFF5050);
    
    self.cardScrollView = [[TKCardScrollView alloc] init];
    self.cardScrollView.frame = CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 300);
    self.cardScrollView.cardScrollDelegate = self;
    self.cardScrollView.cardScrollDataSource = self;
    [self.view addSubview:self.cardScrollView];
    
    self.cards = [NSMutableArray array];
    for (NSInteger i = 0; i < 8; i++) {
        [self.cards addObject:@(i)];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.cardScrollView LoadCard];
}

-(void) UpdateCard:(UIView *)card WithProgress:(CGFloat)progress Direction:(TKCardMoveDirection)direction
{
    if (direction == TKCardMoveDirectionNone)
    {
        if (card.tag != [self.cardScrollView CurrentCard])
        {
            CGFloat scale = 1 - 0.1 * progress;
            card.layer.transform = CATransform3DMakeScale(scale, scale, 1.0);
            card.layer.opacity = 1 - 0.2*progress;
        }
        else
        {
            card.layer.transform = CATransform3DIdentity;
            card.layer.opacity = 1;
        }
    }
    else
    {
        NSInteger transCardTag = direction == TKCardMoveDirectionLeft ? [self.cardScrollView CurrentCard] + 1 : [self.cardScrollView CurrentCard] - 1;
        if (card.tag != [self.cardScrollView CurrentCard] && card.tag == transCardTag)
        {
            card.layer.transform = CATransform3DMakeScale(0.9 + 0.1*progress, 0.9 + 0.1*progress, 1.0);
            card.layer.opacity = 0.8 + 0.2*progress;
        }
        else if (card.tag == [self.cardScrollView CurrentCard])
        {
            card.layer.transform = CATransform3DMakeScale(1 - 0.1 * progress, 1 - 0.1 * progress, 1.0);
            card.layer.opacity = 1 - 0.2*progress;
        }
    }
}

#pragma mark - CardScrollViewDataSource
- (NSInteger) NumberOfCards {
    return self.cards.count;
}

- (UIView *) CardReuseView:(UIView *)reuseView AtIndex:(NSInteger)index {
    if (reuseView)
    {
        // you can set new style
        return reuseView;
    }

    UIView *card = [[UIView alloc] init];
    card.layer.backgroundColor = [UIColor whiteColor].CGColor;
    card.layer.cornerRadius = 4;
    card.layer.masksToBounds = YES;
    
    return card;
}

@end
