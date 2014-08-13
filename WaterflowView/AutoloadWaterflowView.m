//
//  AutoloadWaterflowView.m
//  WaterflowView
//
//  Created by Youhui Tian on 11/16/12.
//  Copyright (c) 2013 YT. All rights reserved.
//

#import "AutoloadWaterflowView.h"

#import "LoadMoreFooterView.h"

static const CGFloat kFooterLoadingViewHeight = 25;

@interface AutoloadWaterflowView (SuperMethod)<WaterflowViewDelegate>

@end

@implementation AutoloadWaterflowView
@synthesize loadMoreView = loadMoreView_;
@dynamic delegate;
@dynamic dataSource;

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    // We need to handle UIScrollViewDelegate ourselves.
    self.delegate = self;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.alwaysBounceVertical = YES;
    loadMoreView_ = [[LoadMoreFooterView alloc] initWithFrame:
        CGRectMake(0, 0, frame.size.width, kFooterLoadingViewHeight)];
    loadMoreView_.backgroundColor = [UIColor clearColor];
    self.footerView = loadMoreView_;
  }
  return self;
}

- (void)dealloc {
  [startBlock_ release];
  startBlock_ = nil;
  delegate_ = nil;
  [loadMoreView_ release];
  [super dealloc];
}

- (void)setDelegate:(id<WaterflowViewDelegate>)delegate {
  if (delegate == self) {
    [super setDelegate:delegate];
  } else {
    delegate_ = delegate;
  }
}

- (id<WaterflowViewDelegate>)delegate {
  return delegate_;
}

- (BOOL)isLoading {
  return loadMoreView_.loading;
}

- (void)setAutoloadStart:(void (^)(void))startBlock {
  if (startBlock) {
    [startBlock_ autorelease];
    startBlock_ = [startBlock copy];
  }
}

- (void)setAutoloadState:(AutoloadWaterflowState)state {
  if (state == kAutoloadStateSuccess) {
    [self appendDataAnimated:YES];
  } else if (state == kAutoloadStateNoData) {
    loadMoreView_.loadEnd = YES;
  }
  loadMoreView_.loading = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  if ([delegate_ respondsToSelector:@selector(scrollViewDidScroll:)]) {
    [delegate_ scrollViewDidScroll:scrollView];
  }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
  if ([delegate_ respondsToSelector:
          @selector(scrollViewWillBeginDecelerating:)]) {
    [delegate_ scrollViewWillBeginDecelerating:scrollView];
  }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
  if (bottomEdge >= scrollView.contentSize.height) {
    if (!loadMoreView_.loading && !loadMoreView_.loadEnd && startBlock_) {
      loadMoreView_.loading = YES;
      dispatch_async(dispatch_get_main_queue(), ^{
          startBlock_();
      });
    }
  }
  if ([delegate_ respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
    [delegate_ scrollViewDidEndDecelerating:scrollView];
  }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  if ([delegate_ respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
    [delegate_ scrollViewWillBeginDragging:scrollView];
  }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset {
  if ([delegate_ respondsToSelector:@selector(scrollViewWillEndDragging:
                                              withVelocity:
                                              targetContentOffset:)]) {
    [delegate_ scrollViewWillEndDragging:scrollView
                            withVelocity:velocity
                     targetContentOffset:targetContentOffset];
  }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {
  if ([delegate_ respondsToSelector:@selector(scrollViewDidEndDragging:
                                              willDecelerate:)]) {
    [delegate_ scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
  }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
  if ([delegate_ respondsToSelector:
          @selector(scrollViewDidEndScrollingAnimation:)]) {
    [delegate_ scrollViewDidEndScrollingAnimation:scrollView];
  }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
  if ([delegate_ respondsToSelector:@selector(scrollViewShouldScrollToTop:)]) {
    return [delegate_ scrollViewShouldScrollToTop:scrollView];
  }
  return YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
  if ([delegate_ respondsToSelector:@selector(scrollViewDidScrollToTop:)]) {
    [delegate_ scrollViewDidScrollToTop:scrollView];
  }
}

@end
