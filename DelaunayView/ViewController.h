//
//  ViewController.h
//  DelaunayView
//
//  Created by Justin Madewell on 7/17/14.
//  Copyright (c) 2014 Justin Madewell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController


@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic, assign) CGFloat pts;
@property (assign) BOOL showVanillaMap;
@property (assign) BOOL areLinesJagged;
@property (assign) BOOL areColorsRandom;


-(void)setPts:(CGFloat)pts;


+(UIImage*)frameNodeImage;

@end

