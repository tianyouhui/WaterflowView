//
//  WaterflowDemoController.h
//  WaterflowDemo
//
//  Created by Youhui Tian on 1/9/13.
//  Copyright (c) 2013 Youhui Tian. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AutoloadWaterflowView.h"

@interface WaterflowDemoController : UIViewController<WaterflowViewDataSource,
    WaterflowViewDelegate> {
 @private
  AutoloadWaterflowView *waterflowView_;
}

@end
