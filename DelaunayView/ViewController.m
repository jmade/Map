//
//  ViewController.m
//  DelaunayView
//
//  Created by Justin Madewell on 7/17/14.
//  Copyright (c) 2014 Justin Madewell. All rights reserved.
//

#import "ViewController.h"
#import "DelaunayView.h"
#import "DelaunayTriangulation.h"
#import "DelaunayPoint.h"
#import "VoronoiCell.h"

#import "MapView.h"
#import "MapUtility.h"

#import "Colours.h"

#import "SettingsView.h"



#define POINTS 400



@interface ViewController ()
{
    DelaunayView * _delView;
    DelaunayTriangulation *_triangulation;
    CGRect _delRect;
    CGRect _relaxRect;
    CGRect inset;
    NSMutableArray *centroids;
    
    NSMutableArray *randomPoints;
    
    NSMutableArray *dPoints;
    
    MapUtility *mapUtility;
    MapView *mapView;
    
    UIView *dotView;
    UIImageView *debugView;
    UIImageView *dotImageView;
    
    UILabel *statusLabel;
    
    UIView *_relaxView;
    UILabel *_relaxLabel;
    
    CGFloat _points;
    CGFloat _lastTime;
    NSInteger _relaxCount;
    BOOL _isRelaxing;
    BOOL _isLoading;
    BOOL _debugShowing;
    
}

@end

@implementation ViewController
            
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _debugShowing = NO;
    
    NSLog(@"self.pts: %f",self.pts);
    NSLog(@"self.areLinesJagged value: %d", self.areLinesJagged);
    
    
    dPoints = [[NSMutableArray alloc]init];
    centroids = [[NSMutableArray alloc]init];
    
    UITapGestureRecognizer *loadTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleLoadTap:)];
    
    CGRect usableSpace = [UIScreen mainScreen].bounds;
    
    CGFloat screenWidth = usableSpace.size.width;
    CGFloat screenHeight = usableSpace.size.height;
    
    CGFloat recWidth = screenWidth / 1.14;
    CGFloat recHeight = screenHeight / 1.62;
    CGFloat widthPadding = screenWidth / 17;
    CGFloat heightPadding = 8;
    
    self.activityIndicatorView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(40, 40, 50, 50)];
   
    
   
    
    _delRect = CGRectMake(widthPadding, heightPadding+30, recWidth, recHeight);
    CGRectMake(widthPadding+5, heightPadding+30, recWidth-4, recHeight);
    inset = CGRectInset(_delRect, recWidth * 0.05, recHeight * 0.05);
    inset = CGRectMake(widthPadding+5, heightPadding+30, recWidth-4, recHeight);
    
    _relaxRect = CGRectMake(widthPadding,  heightPadding+recHeight+50, recWidth, 40);
    CGRect loadRect = CGRectMake(widthPadding,  heightPadding+ recHeight + _relaxRect.size.height + 60, recWidth, 40);
    
    
    CGRect labelRect =  CGRectMake(widthPadding, heightPadding+ _delRect.size.height+30, recWidth, 20);
    statusLabel = [[UILabel alloc]initWithFrame:labelRect];
    statusLabel.textAlignment = NSTextAlignmentCenter;
    statusLabel.text = @"Status Label";
    statusLabel.textColor = [UIColor blackColor];
    
    
    
    
    UIView *loadView = [[UIView alloc] initWithFrame:loadRect];
    [loadView addGestureRecognizer:loadTap];
    loadView.backgroundColor = [UIColor fuschiaColor];
    [self.view addSubview:loadView];
    
    UILabel *loadlabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, loadRect.size.width, loadRect.size.height)];
    loadlabel.textAlignment = NSTextAlignmentCenter;
    loadlabel.text = @"Reset Map";
    loadlabel.textColor = [UIColor whiteColor];
    [loadView addSubview:loadlabel];
    
    
    UITapGestureRecognizer *relaxTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleRelaxTap:)];
    _relaxView = [[UIView alloc]initWithFrame:_relaxRect];
    [_relaxView addGestureRecognizer:relaxTap];
    _relaxView.backgroundColor = [UIColor lavenderColor];
    
    
    _relaxLabel = [[UILabel alloc]initWithFrame:_relaxRect];
    _relaxLabel.textAlignment = NSTextAlignmentCenter;
    _relaxLabel.text = @"Relax Map";
    _relaxLabel.textColor = [UIColor whiteColor];
    
    
    [self generateRandomPoints:self.pts inRect:_delRect];
    
    dotImageView = [[UIImageView alloc]initWithFrame:_delRect];
    UIImage *dotImage = [self dotImage];
    dotImageView.image = dotImage;
    [self.view addSubview:dotImageView];
    

    [self.view addSubview:statusLabel];
    
    [self setupAndAddMapView];
    
    [self reset];
    
    debugView = [[UIImageView alloc]initWithFrame:_delRect];


}



-(void)runTest
{
    [self generateRandomPoints:1000 inRect:inset];
    
}


-(void)loadrelaxView
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self.view addSubview:_relaxView];
                       [self.view addSubview:_relaxLabel];
                   });
}


- (void)reset
{
    
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   
                   ^{
                       // Time
                       dispatch_async(dispatch_get_main_queue(), ^
                                      {
                                          _isLoading = YES;
                                          CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
                                          _lastTime = startTime;
                                      });
                       //
                       
                       
                       [self setupForMap];
                       
                       dispatch_async(dispatch_get_main_queue(), ^
                                      {
                                          // Update UI
                                          [self.view addSubview:dotImageView];
                                      });

                       
                     
                       
                       [self setAndDrawMapCells];
                       
                      
                       
                       [self loadrelaxView];
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       // Update UI
                       [statusLabel setText:@"Finished!"];
                       [self makeMapViewDisappear];
                       [self makeMapViewAppear];
                       
                   });
                       // Time
                       dispatch_async(dispatch_get_main_queue(), ^
                                      {
                                          CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent();
                                          CGFloat since = endTime - _lastTime;
                                          // NSLog(@"Reset Took: %f",since);
                                          NSString *string = [self timeSinceThen:_lastTime];
                                          //NSLog(@"string:%@",string);
//                                          NSLog(@"Reset Took: %f",since);
                                          
                                          NSInteger cellCt = mapUtility.mapCells.count;
                                          NSString *message = [NSString stringWithFormat:@"Render Time: %@  Cell cnt: %li",string,(long)cellCt];
                                          

                                          
//                                          
                                          [statusLabel setText:message];
                                          _isLoading = NO;
                                          
                                          
                                      });
                       //

    
                       [self getRelaxed];
                       
                       
                       
                   });
    
   
}


#pragma mark - SETUP


#pragma mark - MapView

-(void)killMapView
{
    // dPoints = [[NSMutableArray alloc]init];
    //_triangulation = nil;
    [mapView removeGestureRecognizer:[[mapView gestureRecognizers] firstObject]];
    [mapView removeFromSuperview];
}

-(void)makeMapViewAppear
{
    NSLog(@"Making View Appear");
    
    mapView.alpha = 0.0;
    [self.view addSubview:mapView];
    
    [UIView animateWithDuration:1.0 animations:^{
        mapView.alpha = 1.0;
    }];
}

-(void)makeMapViewDisappear
{
    if ([mapView isDescendantOfView:self.view])
    {
        
        [UIView animateWithDuration:1.0 animations:^{
            mapView.alpha = 0.0;
        }];
        
        [mapView removeGestureRecognizer:[[mapView gestureRecognizers] firstObject]];
        [mapView removeFromSuperview];
    }
}


-(void)setupAndAddMapView
{
    NSLog(@"Load Map View and Add to MainView");
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    
    mapView = [MapView drawMap:_delRect];
    mapView.areColorsRandom = self.areColorsRandom;
    
    [mapView addGestureRecognizer:tap];
}

-(void)showDotView
{
    
}

-(void)paintNodes:(NSArray*)nodes with:(UIColor*)color dotSize:(CGFloat)percent
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat dotSize = 1.5 * percent;
    
    for (NSValue *nodeValue in nodes)
    {
        CGPoint point = [nodeValue CGPointValue];
        [color set];
        CGContextMoveToPoint(ctx, point.x + dotSize, point.y);
        CGContextAddArc(ctx, point.x, point.y, dotSize, 0, 2 * M_PI, 0);
        CGContextFillPath(ctx);
    }
    
}


-(UIImage*)dots
{
    UIImage *dots = [mapUtility frameImage];
    
    return dots;
}


-(UIImage*)dotImage
{
    
    UIGraphicsBeginImageContextWithOptions(_delRect.size, NO, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat dotSize = 1.5;
    
    NSLog(@"randomPoints.count: %lu",(unsigned long)randomPoints.count);
    
    
    for (NSValue *nodeValue in randomPoints)
    {
        CGPoint point = [nodeValue CGPointValue];
        [[UIColor blackColor] set];
        CGContextMoveToPoint(ctx, point.x + dotSize, point.y);
        CGContextAddArc(ctx, point.x, point.y, dotSize, 0, 2 * M_PI, 0);
        CGContextFillPath(ctx);
    }

 
    UIImage * createdImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return createdImage;
    
    
}

-(void)setAndDrawMapCells
{
    NSLog(@"Set MapCell Dictionary and Call Paint Draw");
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       // Update UI
                       [statusLabel setText:@"Painting Map"];
                       
                   });

    [mapView setShowVanilla:self.showVanillaMap];
    [mapView setMapCells:mapUtility.mapCells];
    [mapView setIslandNodes:mapUtility.islandNodes];
    [mapView setIslandSegmentPaths:mapUtility.islandSegmentPaths];
    
    
    NSLog(@"self.showVanillaMap value: %d", self.showVanillaMap);
    
}

-(void)striding
{
    int stride = 15;
    int count = 300;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_apply(count / stride, queue, ^(size_t idx){
        size_t j = idx * stride;
        size_t j_stop = j + stride;
        do {
            printf("%u\n", (unsigned int)j++);
        }while (j < j_stop);
    });
    
    size_t i;
    for (i = count - (count % stride); i < count; i++)
        printf("%u\n", (unsigned int)i);
}

-(void)addPointsToTriangulationFaster
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    NSMutableArray *newDPoints = [NSMutableArray arrayWithArray:dPoints];

    
    dispatch_apply(dPoints.count, queue, ^(size_t i) {
        // Perform Code Here:
        NSLog(@"Starting to triangulate point %zu",i);
        
        [_triangulation addPoint:[newDPoints objectAtIndex:i] withColor:nil];
        
    });

     NSLog(@"DPoints Added To Triangulation");
}

-(void)addPointsToTriangulationFast
{
//    dispatch_async(dispatch_get_main_queue(), ^
//                   {
//                       dPoints = [[NSMutableArray alloc]init]; 
//                   });

    
    NSInteger total = dPoints.count;
    
    for (DelaunayPoint *newPoint in dPoints) {
        [_triangulation addPoint:newPoint withColor:nil];
        
        NSInteger index = [dPoints indexOfObject:newPoint];
        
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           // Update UI
                           NSString *message = [NSString stringWithFormat:@"Triangulating Point : %li of %li",(long)index,(long)total];
                           [statusLabel setText:message];
                           
                       });

    }
    NSLog(@"DPoints Added");
}



-(void)gcdStuff
{
    dispatch_block_t handler = ^{ NSLog(@"Fire!"); };
}


-(void)setupQueue
{
    
}




#pragma mark - MAP UTILITY

-(void)setupForMap
{
    CGRect mapRect = _delRect;
    
    _triangulation = [DelaunayTriangulation triangulationWithRect:mapRect];
    
    // Update UI
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [statusLabel setText:@"Generating Points"];
                       
                   });
    
    
    [self addPointsToTriangulationFast];
    
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       // Update UI
                       
                    [statusLabel setText:@"Processing Map Data"];

                       
                   });
    
    [self mapUtilitySetup];
    
    
    CFAbsoluteTime afterMapHasProcessed = CFAbsoluteTimeGetCurrent();
    
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       NSString *timeSince = [self timeSinceThen:afterMapHasProcessed];
                       NSString *job =@"Finished With Map Data";
                       NSString *message = [NSString stringWithFormat:@"%@ %@",job,timeSince];
                       [statusLabel setText:message];
                       
                       [self setupDebugView];
                       //[self dots];

                   });
    
}

-(void)mapUtilitySetup
{
    mapUtility = [MapUtility wakeUp];
    
    mapUtility.triangulation = _triangulation;
    
    mapUtility.frame = _delRect;
    
    if (self.areLinesJagged) {
        
        [mapUtility setIsJagged:YES];
    }
    else
    {
        [mapUtility setIsJagged:NO];
    }
    
    
    if (self.showVanillaMap) {
        
        [mapUtility processMapVanilla];
    }
    else
    {
        [mapUtility processMap];
    }

}

-(void)relaxedSetupForMap
{
    _triangulation = [DelaunayTriangulation triangulationWithRect:_delRect];
    
    NSLog(@"Processing Relaxed Data For Map");
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       // Update UI
                       [statusLabel setText:@"Adding Relaxed Points"];
                       
                   });
    
    [self setRelaxed];
    [self mapUtilitySetup];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [statusLabel setText:@"Processing Map Data"];
        [self setupDebugView];
        //[self dots];
    });
    
    
   
    

}


-(void)setupForDelaunayView
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    
    _delView = [[DelaunayView alloc]initWithFrame:_delRect];
    
    [_delView addGestureRecognizer:tap];
    
    [self.view addSubview:_delView];
}

-(void)setupTriangulationWithRect:(CGRect)rect andPoints:(NSInteger)points
{
    _triangulation = [DelaunayTriangulation triangulationWithRect:rect];
    [self generateRandomPoints:1000 inRect:rect];
   
}

-(void)assignTriangulationForDelaunayViewRelaxed:(BOOL)isRelaxed
{
    if (isRelaxed)
    {
        [self addRelaxedPointsToTriangulation];
    }
    else
    {
     [self setupTriangulationWithRect:_delRect andPoints:POINTS];
    }
    
    _delView.triangulation = _triangulation;
}


#pragma mark - HELPERS

-(void)slowPoints:(NSInteger)thisManyPoints
{
    
    
    for (int i = 0; i < thisManyPoints; i++)
    {
        NSLog(@"Start Point: %i",i);
        
        CGPoint loc = CGPointMake(inset.size.width * (arc4random() / (float)0x100000000),
                                  inset.size.height * (arc4random() / (float)0x100000000));
        
        DelaunayPoint *newPoint = [DelaunayPoint pointAtX:loc.x andY:loc.y];
        
        [_triangulation addPoint:newPoint withColor:nil];
        
        NSLog(@"Ending Points");
    }
    
   
}

-(void)generateRandomPoints:(NSInteger)thisManyPoints inRect:(CGRect)rectFrame
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc]init];
    randomPoints = [[NSMutableArray alloc]init];

    dispatch_apply(thisManyPoints, queue, ^(size_t i) {
        // Perform Code Here:
         NSLog(@"Start");
        CGPoint loc = CGPointMake(inset.size.width * (arc4random() / (float)0x100000000), inset.size.height * (arc4random() / (float)0x100000000));
        [randomPoints addObject:[NSValue valueWithCGPoint:loc]];
            
        DelaunayPoint *newPoint = [DelaunayPoint pointAtX:loc.x andY:loc.y];
        
        [mutableArray addObject:newPoint];
        
    });
    
    dPoints =  mutableArray;
    
}


-(void)addPointsToTriangulation:(NSInteger)points
{
    
    
    NSLog(@"Start Points");
    for (int i = 0; i < points; i++)
    {
        CGPoint loc = CGPointMake(inset.size.width * (arc4random() / (float)0x100000000),
                                  inset.size.height * (arc4random() / (float)0x100000000));
        
        DelaunayPoint *newPoint = [DelaunayPoint pointAtX:loc.x andY:loc.y];
        
        [_triangulation addPoint:newPoint withColor:nil];
    }
    
  
    NSLog(@"Ending Points");
    
    //
}

-(void)addRelaxedPointsToTriangulation
{
    NSInteger total = [centroids count];

    
    for (NSValue *value in centroids)
    {
        CGPoint relaxedPoint = [value CGPointValue];
        DelaunayPoint *newPoint = [DelaunayPoint pointAtX:relaxedPoint.x andY:relaxedPoint.y];
        [_triangulation addPoint:newPoint withColor:nil];
        
        NSInteger index = [centroids indexOfObject:newPoint];
        
        
       
    }

}

-(void)kill
{
//    NSLog(@"Killing Everything");
    [_delView removeFromSuperview];
    [mapView removeFromSuperview];
     mapView = nil;
    _delView = nil;
    mapUtility = nil;
//    _triangulation = [DelaunayTriangulation triangulationWithRect:_delRect];
}


-(void)relaxCells
{
    NSMutableArray *mutableArray = [[NSMutableArray alloc]init];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    dispatch_apply([_triangulation.voronoiCells allKeys].count, queue, ^(size_t i) {
        id key;
        VoronoiCell *cell = [_triangulation.voronoiCells objectForKey:key];
        [mutableArray addObject:[NSValue valueWithCGPoint:cell.centroid]];
    });
    
    centroids = mutableArray;
    
    NSLog(@"Cells Are Relaxed");
}

-(void)getRelaxed
{
    centroids = [[NSMutableArray alloc]init];
    
    NSDictionary *vorDict = _triangulation.voronoiCells;
    NSArray *vorDictKeys = [vorDict allKeys];
    
    for (int x = 0; x<vorDictKeys.count; x++)
    {
        VoronoiCell *cell = [vorDict objectForKey:[vorDictKeys objectAtIndex:x]];
        CGPoint cellCentroid = cell.centroid;
        NSValue *centroidValue = [NSValue valueWithCGPoint:cellCentroid];
        [centroids insertObject:centroidValue atIndex:x];
    }
}

-(void)setRelaxed
{
    NSInteger total = centroids.count;
    
    for (int x =0; x<centroids.count; x++)
    {
        NSValue *centroidValue = [centroids objectAtIndex:x];
        CGPoint relaxedPoint = [centroidValue CGPointValue];
        
        DelaunayPoint *newPoint = [DelaunayPoint pointAtX:relaxedPoint.x andY:relaxedPoint.y];
        [_triangulation addPoint:newPoint withColor:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           // Update UI
                           NSString *message = [NSString stringWithFormat:@"Relaxing Triangulation: %li of %li",(long)x,(long)total];
                           [statusLabel setText:message];
                           
                       });

        
    }

}

#pragma mark - Utility

-(NSString*)timeSinceThen:(CGFloat)then
{
    CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();
//    NSLog(@"now: %f",now);
//    NSLog(@"then: %f",then);
    
    
    
    CGFloat since = now-then;
    //NSLog(@"since: %f",since);
    
    
    
    NSNumber *sinceNumber = [NSNumber numberWithFloat:since];
    // NSLog(@"sinceNumber: %@",sinceNumber);
    
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.alwaysShowsDecimalSeparator = YES;
    numberFormatter.minimumFractionDigits = 3;
    numberFormatter.maximumFractionDigits = 3;
    numberFormatter.minimumIntegerDigits = 1;
   NSString *string =[numberFormatter stringFromNumber:sinceNumber];
    
    
//    NSString *string = [NSNumberFormatter localizedStringFromNumber:sinceNumber numberStyle:NSNumberFormatterDecimalStyle];
    
    //  NSLog(@"string:%@",string);
    
    return string;
}


#pragma mark - GestureRecognizers

-(void)handleRelaxTap:(UITapGestureRecognizer *)recognizer
{
    if (!_isRelaxing && !_isLoading) {
        [self relax];
    }
}

-(void)relax
{
     _isRelaxing = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^
                   {
                       dispatch_async(dispatch_get_main_queue(), ^
                                      {
                                          _isRelaxing = YES;
                                          _relaxCount++;
                                          
                                          NSString *message = [NSString stringWithFormat:@"Relaxing...  (%ld)",(long)_relaxCount];
                                          [_relaxLabel setText:message];
                                          
                                          
                                          
                                          NSLog(@"_relaxCount:%ld",(long)_relaxCount);
                                          CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
                                          _lastTime = startTime;
                                      });
                       
                       [self setupAndAddMapView];
                       
                       [self relaxedSetupForMap];
                       
                       [self setAndDrawMapCells];
                       
                       dispatch_async(dispatch_get_main_queue(), ^
                                      {
                                          // Update UI
                                          [statusLabel setText:@"Finished!"];
                                          [self makeMapViewDisappear];
                                          [self makeMapViewAppear];
                                          
                                      });
                       
                       // Time
                       dispatch_async(dispatch_get_main_queue(), ^
                                      {
                                          NSString *string = [self timeSinceThen:_lastTime];
                                          NSInteger cellCt = mapUtility.mapCells.count;
                                          NSString *message = [NSString stringWithFormat:@"Render Time: %@  Cell cnt: %li",string,(long)cellCt];
                                          
                                          
                                          [statusLabel setText:message];
                                          
                                          NSString *endMessage = [NSString stringWithFormat:@"Relax Again  (%ld)",(long)_relaxCount];
                                          [_relaxLabel setText:endMessage];
                                          
                                          
                                          _isRelaxing = NO;

                                          
                                          
                                      });
                       
                       
                       [self getRelaxed];
                   });

     }


-(void)handleTap:(UITapGestureRecognizer *)recognizer
{
    
    if (!_debugShowing) {
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           [self makeDebugViewAppear];
                       });
    }
    
    if (_debugShowing) {
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           [self makeDebugViewDisappear];
                       });

    }
    
    
}

-(void)setupDebugView
{
    debugView = [[UIImageView alloc]initWithFrame:_delRect];
    
}

-(void)mapTapped
{
    
   
    
}

-(void)setDebugImage
{
    UIImage *edgeDotImage = [mapUtility frameImage];
    debugView.image = edgeDotImage;
    
}

-(void)handleLoadTap:(UITapGestureRecognizer *)recognizer
{
    if (!_isLoading && !_isRelaxing) {
        [self load];
    }
}

-(void)load
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       // Update UI
                       [_relaxLabel setText:@"Relax Map"];
                       _relaxCount = 0;
                       [self makeMapViewDisappear];
                       //[self killMapView];
                       [self generateRandomPoints:self.pts inRect:_delRect];
                       [self setupAndAddMapView];
                       [self reset];
                       
                   });
    
   
    

}

-(void)makeDebugViewAppear
{
    _debugShowing = YES;
    
    [self setDebugImage];
    
    NSLog(@"Making Debug Appear");
    debugView.alpha = 0.0;
    [self.view addSubview:debugView];
    
    [UIView animateWithDuration:0.5 animations:^{
        debugView.alpha = 1.0;
    }];
}

-(void)makeDebugViewDisappear
{
    
    
    NSLog(@"Making Debug Disappear");
    
    
    [UIView animateWithDuration:0.5 animations:^{
        debugView.alpha = 0.0;
    }];

    
    
    [debugView removeFromSuperview];
    
    _debugShowing = NO;

    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
