//
//  LoadMoreFooterView.m
//  WaterflowView
//
//  Created by Youhui Tian on 11/19/12.
//  Copyright (c) 2013 YT. All rights reserved.
//

#import "LoadMoreFooterView.h"

static const NSInteger kLabelActivityIndicatorSpace = 10;
static const NSInteger kLabelFontSize = 12;

NSString *LocalizedString(NSString *key, NSString *comment) {
  static NSBundle* bundle = nil;
  if (!bundle) {
    NSString* path = [[[NSBundle mainBundle] resourcePath]
        stringByAppendingPathComponent:@"Strings.bundle"];
    bundle = [[NSBundle bundleWithPath:path] retain];
  }
  return [bundle localizedStringForKey:key value:key table:nil];
}

@implementation LoadMoreFooterView
@synthesize label = label_;
@synthesize activityIndicator = activityIndicator_;

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code
    label_ = [[UILabel alloc] initWithFrame:CGRectZero];
    label_.font = [UIFont systemFontOfSize:kLabelFontSize];
    label_.text = LocalizedString(@"pull_up_load_more",
                                  @"Default state.");
    [self addSubview:label_];
    activityIndicator_ =
        [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
            UIActivityIndicatorViewStyleGray];
    [self addSubview:activityIndicator_];
  }
  return self;
}

- (void)dealloc {
  [activityIndicator_ release];
  [super dealloc];
}

- (void)setLoading:(BOOL)loading {
  moreFlags_.loading = loading;
  if (moreFlags_.loadEnd) {
    label_.text = LocalizedString(@"no_any_more", @"Loading finished");
    [activityIndicator_ stopAnimating];
  } else if (loading) {
    label_.text = LocalizedString(@"loading", @"Loading");
    [activityIndicator_ startAnimating];
  } else {
    label_.text = LocalizedString(@"pull_up_load_more",
                                  @"Default state.");
    [activityIndicator_ stopAnimating];
  }
  [self setNeedsLayout];
}

- (BOOL)loading {
  return moreFlags_.loading;
}

- (void)setLoadEnd:(BOOL)loadEnd {
  moreFlags_.loadEnd = loadEnd;
}

- (BOOL)loadEnd {
  return moreFlags_.loadEnd;
}

- (void)layoutSubviews {
  [label_ sizeToFit];
  CGFloat width = label_.frame.size.width +
      ([activityIndicator_ isAnimating] ?
      (kLabelActivityIndicatorSpace +
      activityIndicator_.frame.size.width) : 0);
  label_.frame =
      CGRectMake((self.frame.size.width - width) / 2,
                 (self.frame.size.height - label_.frame.size.height) / 2,
                 label_.frame.size.width,
                 label_.frame.size.height);
  CGFloat activityOriginX = label_.frame.origin.x + label_.frame.size.width +
      kLabelActivityIndicatorSpace;
  CGFloat activityOriginY =
      (self.frame.size.height - activityIndicator_.frame.size.height) / 2;
  activityIndicator_.frame =
      CGRectMake(activityOriginX,
                 activityOriginY,
                 activityIndicator_.frame.size.width,
                 activityIndicator_.frame.size.height);
}

@end
