//
//  MapUtility.h
//  DelaunayView
//
//  Created by Justin Madewell on 8/11/14.
//  Copyright (c) 2014 Justin Madewell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@class DelaunayTriangulation;


@interface MapUtility : NSObject {
    
    NSInteger integer;
    CGFloat floatNumber;
    
}

-(void)setupMapView;
-(void)processMap;
-(void)processMapVanilla;
+(instancetype)wakeUp;
+(MapUtility*)mapWithTriangulation:(DelaunayTriangulation*)triangulation;

@property (nonatomic, strong) DelaunayTriangulation* triangulation;

@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) CGFloat floatNumber;

@property (nonatomic, strong) NSMutableDictionary *mapCells;
@property (nonatomic, strong) NSMutableDictionary *masterPaths;
@property (nonatomic, strong) NSMutableDictionary *islandNodes;
@property (nonatomic, strong) NSMutableDictionary *islandSegmentPaths;

@property (nonatomic, strong) NSMutableDictionary *mapPaths;


@property (nonatomic, strong) NSMutableArray *frameNodes;

@property (nonatomic, strong) UIImage *frameImage;


@property (assign) BOOL isJagged;
@property (assign) BOOL colorIsRandom;

-(UIImage*)dotImage;






@end
