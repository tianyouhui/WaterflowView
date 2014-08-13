//
//  AutoloadWaterflowView.h
//  WaterflowView
//
//  Created by Youhui Tian on 11/16/12.
//  Copyright (c) 2013 YT. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WaterflowView.h"

@class LoadMoreFooterView;

typedef enum {
  kAutoloadStateNoData,
  kAutoloadStateSuccess,
  kAutoloadStateFailed,
} AutoloadWaterflowState;

typedef void (^AutoloadStart)(void);

@interface AutoloadWaterflowView : WaterflowView<UIScrollViewDelegate> {
 @private
  AutoloadStart startBlock_;
  id delegate_;
  LoadMoreFooterView *loadMoreView_;
}
@property(nonatomic, retain) LoadMoreFooterView *loadMoreView;

- (BOOL)isLoading;

- (void)setAutoloadStart:(void (^)(void))startBlock;

- (void)setAutoloadState:(AutoloadWaterflowState)state;

@end
