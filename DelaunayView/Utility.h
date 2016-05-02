//
//  Utility.h
//  DelaunayView
//
//  Created by Justin Madewell on 8/11/14.
//  Copyright (c) 2014 Justin Madewell. All rights reserved.
//



#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BaseGeometry.h"




#define RANDOM(_X_)     (NSInteger)(random() % _X_)
#define RANDOM_01       ((double) random() / (double) LONG_MAX)
#define RANDOM_BOOL     (BOOL)((NSInteger)random() % 2)
#define RANDOM_PT(_RECT_) CGPointMake(_RECT_.origin.x + RANDOM_01 * _RECT_.size.width, _RECT_.origin.y + RANDOM_01 * _RECT_.size.height)






