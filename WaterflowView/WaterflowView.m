//
//  WaterflowView.m
//  WaterflowView
//
//  Created by Youhui Tian on 11/5/12.
//  Copyright (c) 2013 YT. All rights reserved.
//

#import "WaterflowView.h"

#import <QuartzCore/QuartzCore.h>

#ifdef DEBUG
#if 1
#define TRACE(format, ...)  \
    NSLog(@"##%s "format"##", __PRETTY_FUNCTION__, ##__VA_ARGS__)
#define LOG(format, ...)  NSLog(@"--"format"--", ##__VA_ARGS__)
#else
#define TRACE(format, ...)
#define LOG(format, ...)
#endif
#else
#define TRACE(format, ...)
#define LOG(format, ...)
#endif

static const NSInteger kWaterflowDefaultColumn = 2;

// This is a private class that describe each cell layout;
@interface VerticalLayout : NSObject {
 @private
  NSInteger column_;
  CGFloat height_;
  NSInteger index_;
  CGFloat originY_;
}

@property(nonatomic) NSInteger column;
@property(nonatomic) CGFloat height;
@property(nonatomic) NSInteger index;
@property(nonatomic) CGFloat originY;

@end

@implementation VerticalLayout

@synthesize column = column_;
@synthesize height = height_;
@synthesize index = index_;
@synthesize originY = originY_;

- (NSString *)description {
  NSString *string = [super description];
  string = [NSString stringWithFormat:@"%@; index = %d; column = %d;"
      " originY = %.0f; height = %.0f>",
      [string substringToIndex:string.length - 1],
      index_, column_, originY_, height_];
  return string;
}

@end

@interface WaterflowView ()

- (void)addVerticalLayout;

- (void)addVisibleCells;

- (void)calculateContentSize;

- (void)calculateFooterViewFrame;

- (void)tileSubviews;

@end

@implementation WaterflowView
@dynamic delegate;
@synthesize dataSource = dataSource_;
@synthesize headerView = headerView_;
@synthesize footerView = footerView_;

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code
    cellsVerticalLayout_ = [[NSMutableDictionary alloc] init];
    needTiles_ = YES;
    reusableCells_ = [[NSMutableDictionary alloc] init];
    visibleCells_ = [[NSMutableDictionary alloc] init];
    UITapGestureRecognizer *tapGesture = [[[UITapGestureRecognizer alloc]
        initWithTarget:self action:@selector(tapView:)] autorelease];
    [self addGestureRecognizer:tapGesture];
  }
  return self;
}

- (void)dealloc {
  dataSource_ = nil;
  [cellsVerticalLayout_ release];
  [reusableCells_ release];
  [visibleCells_ release];
  [super dealloc];
}

- (UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier {
  NSMutableSet *cacheSet =
      (NSMutableSet *)[reusableCells_ objectForKey:identifier];
  if (cacheSet) {
    id reused = [cacheSet anyObject];
    if (reused != nil) {
      [[reused retain] autorelease];
      [cacheSet removeObject:reused];
      return (UITableViewCell *)reused;
    }
  }
  return nil;
}

- (void)setHeaderView:(UIView *)headerView {
  [headerView_ removeFromSuperview];
  [headerView_ autorelease];
  headerView_ = [headerView retain];
  CGRect headerFrame = headerView_.frame;
  headerFrame.origin = CGPointZero;
  headerView_.frame = headerFrame;
  [self addSubview:headerView];
}

- (void)setFooterView:(UIView *)footerView {
  [footerView_ removeFromSuperview];
  [footerView_ autorelease];
  footerView_ = [footerView retain];
  [self addSubview:footerView];
}

- (NSArray *)visibleCells {
  return [visibleCells_ allValues];
}

- (NSArray *)visibleIndexes {
  return [visibleCells_ allKeys];
}

- (UITableViewCell *)visibleCellForIndex:(NSInteger)index {
  return [visibleCells_ objectForKey:[NSNumber numberWithInt:index]];
}

- (void)calculateFooterViewFrame {
  CGRect footFrame = footerView_.frame;
  footFrame.origin.y = self.contentSize.height -
      headerView_.frame.size.height - footerView_.frame.size.height;
  footerView_.frame = footFrame;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  if (needTiles_) {
    [self tileSubviews];
    needTiles_ = NO;
  } else {
    [self addVisibleCells];
  }
}

- (void)appendDataAnimated:(BOOL)animated {
  if (!self.dataSource) {
    return;
  }
  [self tileSubviews];
  if (animated) {
    [CATransaction begin];
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionFade;
    transition.duration = 0.3f;
    transition.fillMode = kCAFillModeForwards;
    [self.layer addAnimation:transition forKey:@"appendDataAnimation"];
    [CATransaction commit];
  }
}

- (void)tileSubviews {
  if ([self.dataSource respondsToSelector:
       @selector(numberOfColumnsInWaterflowView:)]) {
    columnCount_ = [self.dataSource numberOfColumnsInWaterflowView:self];
  }
  if (columnCount_ == 0) {
    return;
  }
  [self addVerticalLayout];
  [self calculateContentSize];
  [self addVisibleCells];
  [self calculateFooterViewFrame];
}

- (void)reloadData {
  currentIndex_ = 0;
  needTiles_ = YES;
  [cellsVerticalLayout_ removeAllObjects];
  [self setNeedsLayout];
}

- (CGFloat)heightForColumn:(NSInteger)column {
  NSArray *array =
      [cellsVerticalLayout_ objectForKey:[NSNumber numberWithInt:column]];
  return [[array valueForKeyPath:@"@sum.height"] floatValue];
}

- (void)calculateContentSize {
  CGFloat height = 0;
  for (int i = 0; i < columnCount_; ++i) {
    CGFloat sumHeight = [self heightForColumn:i];
    height = MAX(height, sumHeight);
  }
  height = MAX(height, self.frame.size.height);
  self.contentSize =
      CGSizeMake(self.frame.size.width,
                 headerView_.frame.size.height +
                     footerView_.frame.size.height + height);
}

// Everyonce we calculate a column which sum height is minimize.
- (NSInteger)currentColumn:(CGFloat *)minHeight {
  if ([cellsVerticalLayout_ count] < columnCount_) {
    *minHeight = 0;
    return [cellsVerticalLayout_ count];
  }
  NSInteger column = 0;
  *minHeight = [self heightForColumn:0];
  for (int i = 1; i < columnCount_; ++i) {
    CGFloat sumHeight = [self heightForColumn:i];
    if (*minHeight > sumHeight) {
      *minHeight = sumHeight;
      column = i;
    }
  }
  return column;
}

// Calculate height of all cells and store to |cellsVerticalLayout_|.
- (void)addVerticalLayout {
  int count = [self.dataSource numberOfCellsInWaterflowView:self];
  BOOL customHeight = [self.delegate respondsToSelector:
      @selector(waterflowView:heightForRowAtIndex:)];
  for (int i = currentIndex_; i < count; ++i) {
    CGFloat height = customHeight ?
        [self.delegate waterflowView:self heightForRowAtIndex:i] :
        (self.frame.size.width / columnCount_);
    VerticalLayout *layout = [[VerticalLayout alloc] init];
    CGFloat minHeight = 0;
    NSInteger column = [self currentColumn:&minHeight];
    layout.index = i;
    layout.column = column;
    layout.originY = minHeight;
    layout.height = height;
    id columnKey = [NSNumber numberWithInt:column];
    NSMutableArray *array = [cellsVerticalLayout_ objectForKey:columnKey];
    if (!array) {
      array = [[[NSMutableArray alloc] init] autorelease];
      [cellsVerticalLayout_ setObject:array forKey:columnKey];
    }
    [array addObject:layout];
    [layout release];
  }
  currentIndex_ = count;
}

// Binary search for visible cell indexes in |cellsVerticalLayout_| because
// index is ordered.
- (NSArray *)calculateVisibleCellIndexes {
  if (![cellsVerticalLayout_ count]) {
    return nil;
  }
  NSMutableArray *array = [NSMutableArray array];
  CGFloat lowerBound = MAX(0, self.contentOffset.y);
  CGFloat upperBound = MIN(self.contentOffset.y + self.bounds.size.height,
                           self.contentSize.height);
  int firstIndex, lastIndex;
  for (id columnKey in cellsVerticalLayout_) {
    NSArray *layouts = [cellsVerticalLayout_ objectForKey:columnKey];
    NSComparator predicate = ^NSComparisonResult(id obj1, id obj2) {
        VerticalLayout *layout1 = obj1;
        VerticalLayout *layout2 = obj2;
        if (layout1.originY < layout2.originY) {
          return NSOrderedAscending;
        } else if (layout1.originY > layout2.originY) {
          return NSOrderedDescending;
        }
        return NSOrderedSame;
    };

    VerticalLayout *layout = [[[VerticalLayout alloc] init] autorelease];
    layout.originY = lowerBound;
    firstIndex = [layouts indexOfObject:layout
                          inSortedRange:NSMakeRange(0, layouts.count)
                                options:NSBinarySearchingInsertionIndex
                        usingComparator:predicate];
    firstIndex = (firstIndex == 0 ? 0 : firstIndex - 1);
    layout.originY = upperBound;
    lastIndex = [layouts indexOfObject:layout
                         inSortedRange:NSMakeRange(0, layouts.count)
                               options:NSBinarySearchingInsertionIndex
                       usingComparator:predicate];
    for (int i = firstIndex; i < lastIndex; ++i) {
      VerticalLayout *layout = [layouts objectAtIndex:i];
      [array addObject:layout];
    }
  }
  return array;
}

// Only show visible cells and move invisible cells to |reusableCells_|.
- (void)addVisibleCells {
  NSArray *visibleLayouts = [self calculateVisibleCellIndexes];
  NSSet *visibleIndexes =
      [NSSet setWithArray:[visibleLayouts valueForKey:@"index"]];
  NSMutableSet *reusableKeys =
      [NSMutableSet setWithArray:[visibleCells_ allKeys]];
  // minus show keys.
  [reusableKeys minusSet:visibleIndexes];
  for (NSNumber *key in reusableKeys) {
    UITableViewCell *cell = [visibleCells_ objectForKey:key];
    NSMutableSet *viewSet =
        [reusableCells_ objectForKey:cell.reuseIdentifier];
    if (viewSet) {
      [viewSet addObject:cell];
    } else {
      viewSet = [NSMutableSet setWithObject:cell];
      [reusableCells_ setObject:viewSet forKey:cell.reuseIdentifier];
    }
    [cell removeFromSuperview];
    [visibleCells_ removeObjectForKey:key];
  }
  CGFloat cellWidth = self.frame.size.width / columnCount_;
  for (VerticalLayout *layout in visibleLayouts) {
    NSNumber *key = [NSNumber numberWithInt:layout.index];
    if (![visibleCells_ objectForKey:key]) {
      UITableViewCell *cell =
          [self.dataSource waterflowView:self cellAtIndex:key.intValue];
      [visibleCells_ setObject:cell forKey:key];
      cell.frame = CGRectMake(layout.column * cellWidth,
                              layout.originY + headerView_.frame.size.height,
                              cellWidth,
                              layout.height);
      [self addSubview:cell];
    }
  }
}

- (void)tapView:(UITapGestureRecognizer *)tapGesture {
  if ([self.delegate respondsToSelector:
         @selector(waterflowView:didSelectCellAtIndex:)]) {
    CGPoint p = [tapGesture locationInView:self];
    for (NSNumber *key in visibleCells_) {
      UITableViewCell *cell = [visibleCells_ objectForKey:key];
      if (CGRectContainsPoint(cell.frame, p)) {
        [self.delegate waterflowView:self
                didSelectCellAtIndex:[key intValue]];
      }
    }
  }
}

@end
