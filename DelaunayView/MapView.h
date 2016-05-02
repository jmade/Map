//
//  MapView.h
//  DelaunayView
//
//  Created by Justin Madewell on 8/11/14.
//  Copyright (c) 2014 Justin Madewell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapView : UIView

typedef void(^UIImageRenderBlock)(CGContextRef context);

@property (nonatomic, strong) NSMutableDictionary *mapCells;
@property (nonatomic, strong) NSMutableDictionary *masterPaths;
@property (nonatomic, strong) NSMutableDictionary *islandNodes;
@property (nonatomic, strong) NSMutableDictionary *islandSegmentPaths;
@property (nonatomic, assign) CGRect rect;
@property (assign) BOOL showVanilla;
@property (assign) BOOL areColorsRandom;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

+(instancetype)drawMap:(CGRect)frame;
+(instancetype)map;

-(void)makeMapImage;
-(void)setMapImage;

-(UIImage *)imageWithSize:(CGSize) canvasSize block:(UIImageRenderBlock) aBlock;

//-(UIImage *)drawImageWithSize:(CGSize)size withBlock:(id)drawBlock;


@end
