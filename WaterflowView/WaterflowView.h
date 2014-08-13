//
//  WaterflowView.h
//  WaterflowView
//
//  Created by Youhui Tian on 11/5/12.
//  Copyright (c) 2013 YT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WaterflowView;

@protocol WaterflowViewDelegate <NSObject, UIScrollViewDelegate>

@optional
// If not set, default is self.frame.size.width / column.
- (CGFloat)waterflowView:(WaterflowView *)flowView
     heightForRowAtIndex:(NSInteger)index;
- (void)waterflowView:(WaterflowView *)flowView
 didSelectCellAtIndex:(NSInteger)index;

@end

@protocol WaterflowViewDataSource <NSObject>

@optional
// If not set, default is 2.
- (NSInteger)numberOfColumnsInWaterflowView:(WaterflowView *)flowView;

@required
- (NSInteger)numberOfCellsInWaterflowView:(WaterflowView *)flowView;
- (UITableViewCell *)waterflowView:(WaterflowView *)flowview
                       cellAtIndex:(NSInteger)index;

@end

// View that like a waterflow.
@interface WaterflowView : UIScrollView {
 @private
  NSMutableDictionary *cellsVerticalLayout_;
  NSInteger columnCount_;
  NSInteger currentIndex_;
  __weak id<WaterflowViewDataSource> dataSource_;
  UIView *footerView_;
  UIView *headerView_;
  BOOL needTiles_;
  NSMutableDictionary *reusableCells_;
  NSMutableDictionary *visibleCells_;
}

@property(nonatomic, assign) id<WaterflowViewDataSource> dataSource;
@property(nonatomic, assign) id<WaterflowViewDelegate> delegate;
@property(nonatomic, retain) UIView *footerView;
@property(nonatomic, retain) UIView *headerView;

- (NSArray *)visibleCells;

- (NSArray *)visibleIndexes;

- (UITableViewCell *)visibleCellForIndex:(NSInteger)index;

// See tableView dequeueReusableCellWithIdentifier:
- (UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;

// Append more cells;
- (void)appendDataAnimated:(BOOL)animated;

// See tableView reloadData
- (void)reloadData;

@end
