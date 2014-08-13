//
//  WaterflowDemoController.m
//  WaterflowDemo
//
//  Created by Youhui Tian on 1/9/13.
//  Copyright (c) 2013 Youhui Tian. All rights reserved.
//

#import "WaterflowDemoController.h"

#import <QuartzCore/QuartzCore.h>
#import "LoadMoreFooterView.h"

static const NSInteger kWaterflowViewColumnNumber = 3;
// Test
static NSInteger loadTimes_;

@implementation WaterflowDemoController

- (void)dealloc {
  [waterflowView_ release];
  [super dealloc];
}

#pragma mark - View lifecycle

- (void)loadView {
  waterflowView_ = [[AutoloadWaterflowView alloc] initWithFrame:
      [[UIScreen mainScreen] applicationFrame]];
  waterflowView_.alwaysBounceVertical = YES;
  waterflowView_.delegate = self;
  waterflowView_.dataSource = self;
  waterflowView_.autoresizingMask = UIViewAutoresizingFlexibleHeight;
  self.view = waterflowView_;
  loadTimes_ = 1;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [waterflowView_ setAutoloadStart:^{
    [NSThread sleepForTimeInterval:3];
    if (loadTimes_++ == 10) {
      [self dataComeBack:2];
    } else if (loadTimes_ < 10) {
      [self dataComeBack:1];
    } else {
      [self dataComeBack:0];
    }
  }];
}

#pragma mark - WaterflowView delegate and dataSource

- (NSInteger)numberOfColumnsInWaterflowView:(WaterflowView *)flowView {
  return kWaterflowViewColumnNumber;
}

- (NSInteger)numberOfCellsInWaterflowView:(WaterflowView *)flowView {
  return loadTimes_ * 40;
}

- (UITableViewCell *)waterflowView:(WaterflowView *)flowview
                       cellAtIndex:(NSInteger)index {
  static NSString *reuseIdentifier = @"WaterflowViewCell";
  UITableViewCell *cell =
      [flowview dequeueReusableCellWithIdentifier:reuseIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:reuseIdentifier]
        autorelease];
    cell.textLabel.textColor = [UIColor redColor];
    cell.textLabel.backgroundColor = [UIColor whiteColor];
    cell.textLabel.textAlignment = UITextAlignmentCenter;
    cell.layer.borderColor = [UIColor lightGrayColor].CGColor;
    cell.layer.borderWidth = 1;
  }
  cell.textLabel.text = [NSString stringWithFormat:@"%d", index];
  return cell;
}


- (CGFloat)waterflowView:(WaterflowView *)flowView
     heightForRowAtIndex:(NSInteger)index {
  static CGFloat randomHeight[] = { 130, 190, 246, 187, 152 };
  return randomHeight[rand() % 5];
}

- (void)waterflowView:(WaterflowView *)flowView
 didSelectCellAtIndex:(NSInteger)index {
  NSLog(@"You clicked index:%d", index);
}

- (void)dataComeBack:(int)result {
  [waterflowView_ setAutoloadState:result];
}

@end
