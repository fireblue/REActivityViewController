//
//  REActivityView.m
//  REActivityViewControllerExample
//
//  Created by Roman Efimov on 1/24/13.
//  Copyright (c) 2013 Roman Efimov. All rights reserved.
//

#import "REActivityView.h"
#import "REActivityViewController.h"

@implementation REActivityView

- (id)initWithFrame:(CGRect)frame activities:(NSArray *)activities
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        _activities = activities;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 417)];
            _backgroundImageView.image = [UIImage imageNamed:@"Background"];
            _backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [self addSubview:_backgroundImageView];
        }
    
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 39, frame.size.width, self.frame.size.height - 104)];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate = self;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
     //   _scrollView.backgroundColor = [UIColor blueColor];
        [self addSubview:_scrollView];
        
        NSInteger index = 0;
        NSInteger row = -1;
        NSInteger page = -1;
        for (REActivity *activity in _activities) {
            NSInteger col;
            
            col = index%3;
            if (index % 3 == 0) row++;
            if (index % 9 == 0) {
                row = 0;
                page++;
            }
        //    NSLog(@"index = %i", index % 9);
            UIView *view = [self viewForActivity:activity
                                           index:index
                                               x:(20 + col*80 + col*20) + page * frame.size.width
                                               y:row*80 + row*20];
            [_scrollView addSubview:view];
            index++;
        }
        _scrollView.contentSize = CGSizeMake((page +1) * frame.size.width, _scrollView.frame.size.height);
        _scrollView.pagingEnabled = YES;
        
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, frame.size.height - 86, frame.size.width, 10)];
        _pageControl.numberOfPages = page + 1;
        [_pageControl addTarget:self action:@selector(pageControlValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_pageControl];
        
        if (_pageControl.numberOfPages <= 1)
            _pageControl.hidden = YES;
        
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setBackgroundImage:[[UIImage imageNamed:@"Button"] stretchableImageWithLeftCapWidth:22 topCapHeight:47] forState:UIControlStateNormal];
        _cancelButton.frame = CGRectMake(22, 352, 276, 47);
        [_cancelButton setTitle:NSLocalizedString(@"Cancel", @"Cancel") forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_cancelButton setTitleShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4] forState:UIControlStateNormal];
        [_cancelButton.titleLabel setShadowOffset:CGSizeMake(0, -1)];
        [_cancelButton.titleLabel setFont:[UIFont boldSystemFontOfSize:19]];
        [_cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
      //  _cancelButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:_cancelButton];
    }
    return self;
}

- (UIView *)viewForActivity:(REActivity *)activity index:(NSInteger)index x:(NSInteger)x y:(NSInteger)y
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(x, y, 80, 80)];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(10, 0, 59, 59);
    button.tag = index;
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button setBackgroundImage:activity.image forState:UIControlStateNormal];
    [view addSubview:button];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 59, 80, 30)];
    label.textAlignment = UITextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.75];
    label.shadowOffset = CGSizeMake(0, 1);
    label.text = activity.title;
    label.font = [UIFont boldSystemFontOfSize:12];
    label.numberOfLines = 0;
    [label setNumberOfLines:0];
    [label sizeToFit];
    CGRect frame = label.frame;
    frame.origin.x = (view.frame.size.width - frame.size.width) / 2.0f;
    label.frame = frame;
    [view addSubview:label];
    
    return view;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = _cancelButton.frame;
    frame.origin.y = self.frame.size.height - 47 - 16;
    frame.origin.x = (self.frame.size.width - frame.size.width) / 2.0f;
    _cancelButton.frame = frame;
    
   //_scrollView.frame = CGRectMake(_scrollView.frame.origin.x, _scrollView.frame.origin.y, _scrollView.frame.size.width, self.frame.size.height - 104);
}

#pragma mark -
#pragma mark Button action

- (void)cancelButtonPressed
{
    [_activityViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)buttonPressed:(UIButton *)button
{
    REActivity *activity = [_activities objectAtIndex:button.tag];
    if (activity.actionBlock) {
        activity.actionBlock(activity, _activityViewController);
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _pageControl.currentPage = scrollView.contentOffset.x / scrollView.frame.size.width;
}

#pragma mark -

- (void)pageControlValueChanged:(UIPageControl *)pageControl
{
    CGFloat pageWidth = _scrollView.contentSize.width /_pageControl.numberOfPages;
    CGFloat x = _pageControl.currentPage * pageWidth;
    [_scrollView scrollRectToVisible:CGRectMake(x, 0, pageWidth, _scrollView.frame.size.height) animated:YES];
}

@end
