//
//  LoadMoreFooterView.h
//  WaterflowView
//
//  Created by Youhui Tian on 11/19/12.
//  Copyright (c) 2013 YT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadMoreFooterView : UIView {
 @private
  UILabel *label_;
  UIActivityIndicatorView *activityIndicator_;
  struct {
    unsigned int loading : 1;
    unsigned int loadEnd : 1;
  } moreFlags_;
}
@property(nonatomic, readonly) UILabel *label;
@property(nonatomic, readonly) UIActivityIndicatorView *activityIndicator;
@property(nonatomic) BOOL loading;
@property(nonatomic) BOOL loadEnd;

@end
