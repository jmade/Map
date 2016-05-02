//
//  MapUtility.m
//  DelaunayView
//
//  Created by Justin Madewell on 8/11/14.
//  Copyright (c) 2014 Justin Madewell. All rights reserved.
//

#import "Utility.h"
#import "MapUtility.h"
#import "MapView.h"
#import "DelaunayTriangulation.h"
#import "VoronoiCell.h"
#import "Colours.h"
//#import "Bezier.h"

#import "NSObject+GCD.h"


#define RANDOM(_X_)     (NSInteger)(random() % _X_)
#define RANDOM_01       ((double) random() / (double) LONG_MAX)
#define RANDOM_BOOL     (BOOL)((NSInteger)random() % 2)
#define RANDOM_PT(_RECT_) CGPointMake(_RECT_.origin.x + RANDOM_01 * _RECT_.size.width, _RECT_.origin.y + RANDOM_01 * _RECT_.size.height)

@interface MapUtility ()
{
    NSMutableArray *greenColorArray;
    NSMutableArray *outOfFrameCells;
    NSMutableArray *islandCells;
    NSMutableArray *outerCells;
    NSMutableArray *oceanNodes;
    NSMutableArray *coastWaterNodes;
    NSMutableArray *coastlineCells;
    NSMutableArray *averageSegmentsLengths;
    NSMutableArray *sharpCells;
    NSMutableArray *segmentIDArray;
    //    NSMutableArray *frameNodes;
    
    
//    NSMutableDictionary *mapCells;
//    NSMutableDictionary *masterPaths;
//    NSMutableDictionary *islandNodes;
//    NSMutableDictionary *islandSegmentPaths;
    
    
    
    NSInteger mountainInteger;
    
    NSMutableArray *regionColors;
    
    CGPoint centerP;
    
    BOOL firstMountainPointMadeYet;
    
    MapView *mapView;
    
    CGRect rectFrame;
}

@end


@implementation MapUtility

@synthesize floatNumber, mapCells, masterPaths,islandNodes,islandSegmentPaths;



+(instancetype)wakeUp
{
    MapUtility *map = [[self alloc] init];
    
    return map;
    
}

+(MapUtility *)mapWithTriangulation:(DelaunayTriangulation *)triangulation
{
    // NSLog(@"Wake Up Called");
    
    MapUtility *map = [[self alloc] init];
    
    map.triangulation = triangulation;
    
    return map;
}

-(UIImage *)frameImage
{
    //UIImage *frameImage = [self dotImageWithSize:self.frame.size dots:self.frameNodes];
    
    NSArray *dots = [self plotNodesToDraw];
    
    UIImage *newFrame = [self dtImageWithDots:dots];
    
    return newFrame;
}

-(void)makeAndSetFrameImage
{
    //self.frameImage = [self dotImageWithSize:self.frame.size dots:self.frameNodes];
    
}


#pragma mark - Nodes

-(NSArray*)plotNodesToDraw
{
    NSMutableArray *nodesToDraw = [[NSMutableArray alloc]init];

    
    NSArray *islandNodesArray = [self returnIslandNodes];
    
    NSLog(@" islandNodesArray.count: %lu",(unsigned long) islandNodesArray.count);
    
    NSArray *dots = [self getEdgePointsFromNodes:islandNodesArray ofRect:self.frame];
    
    UIBezierPath *dottedPath = [UIBezierPath bezierPath];
    
    CGPoint startPoint = [[dots firstObject] CGPointValue];
    [dottedPath moveToPoint:startPoint];
    
    for (int x=1; x<dots.count; x++) {
        [dottedPath addLineToPoint:[[dots objectAtIndex:x] CGPointValue]];
    }
    
    [dottedPath closePath];
    
    UIBezierPath *copyDottedPath = [dottedPath copy];
    //ScalePath(copyDottedPath, 0.10, 0.80);
    
    // CGRect dottedPathBox = PathBoundingBox(copyDottedPath);
    
//    // CGPoint randomDottedBoxPoint = [self randomPointInRect:dottedPathBox];
//    CGPoint rPoint = [self closestIslandNodeFromPoint:randomDottedBoxPoint];
//    [nodesToDraw addObject:[NSValue valueWithCGPoint:rPoint]];
//    
//    NSArray *segments = [self returnPathsConnectedToNode:rPoint];
//    
//    BOOL withCompanionNode = YES;
//    
//    if (withCompanionNode)
//    {
//        NSLog(@"Companion Mode Enabled");
//        
//        UIBezierPath *chosenPath = [self shortestPathFromPaths:segments];
//        CGPoint chosenNode = [self endPointFromPath:chosenPath];
//        [nodesToDraw addObject:[NSValue valueWithCGPoint:chosenNode]];
//        NSMutableArray *pathsFromChosenNode = [self returnPathsConnectedToNode:chosenNode];
//        [pathsFromChosenNode removeObject:chosenPath];
//        
//        for (UIBezierPath *path in pathsFromChosenNode) {
//            CGPoint start = [self startPointFromPath:path];
//            CGPoint end = [self endPointFromPath:path];
//            [nodesToDraw addObject:[NSValue valueWithCGPoint:start]];
//            [nodesToDraw addObject:[NSValue valueWithCGPoint:end]];
//            
//        }
//        
//        UIBezierPath *shortestPath = [self shortestPathFromPaths:pathsFromChosenNode];
//        
////        shortestPath.lineWidth = 0.50;
////        [[UIColor yellowColor] setStroke];
////        [shortestPath stroke];
//        
//        // 2
//        UIBezierPath *secondChosenPath = [self shortestPathFromPaths:pathsFromChosenNode];
//        CGPoint secondChosenNode = [self endPointFromPath:secondChosenPath];
//        [nodesToDraw addObject:[NSValue valueWithCGPoint:secondChosenNode]];
//        
//        NSMutableArray *secondPathsFromChosenNode = [self returnPathsConnectedToNode:secondChosenNode];
//        [secondPathsFromChosenNode removeObject:secondChosenPath];
//        
//        for (UIBezierPath *path in secondPathsFromChosenNode) {
//            CGPoint start = [self startPointFromPath:path];
//            CGPoint end = [self endPointFromPath:path];
//            [nodesToDraw addObject:[NSValue valueWithCGPoint:start]];
//            [nodesToDraw addObject:[NSValue valueWithCGPoint:end]];
//            
//        }
//        
//        UIBezierPath *secondShortestPath = [self shortestPathFromPaths:secondPathsFromChosenNode];
//        
////        secondShortestPath.lineWidth = 0.50;
////        [[UIColor yellowColor] setStroke];
////        [secondShortestPath stroke];
//        
//    }
    
    return nodesToDraw;

}

-(UIImage*)dtImageWithDots:(NSArray*)dots
{
    
 
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, [UIScreen mainScreen].scale);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat dotSize = 1.25;
    
    
    
    for (NSValue *nodeValue in dots)
    {
        CGPoint point = [nodeValue CGPointValue];
        [[UIColor redColor] set];
        CGContextMoveToPoint(ctx, point.x + dotSize, point.y);
        CGContextAddArc(ctx, point.x, point.y, dotSize, 0, 2 * M_PI, 0);
        CGContextFillPath(ctx);
    }

    UIImage * createdImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return createdImage;
    
}

//-(UIImage *)dotImageWithSize:(CGSize)size dots:(NSArray*)dots
//{
//
//    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    CGFloat dotSize = 2.5;
//    
//    for (NSValue *nodeValue in dots)
//    {
//        CGPoint point = [nodeValue CGPointValue];
//        [[UIColor redColor] set];
//        CGContextMoveToPoint(ctx, point.x + dotSize, point.y);
//        CGContextAddArc(ctx, point.x, point.y, dotSize, 0, 2 * M_PI, 0);
//        CGContextFillPath(ctx);
//    }
//    
//    UIBezierPath *dottedPath = [UIBezierPath bezierPath];
//    CGFloat dashes[] = {6,2};
//    [dottedPath setLineDash:dashes count:6 phase:0];
//    
//    CGPoint startPoint = [[dots firstObject] CGPointValue];
//    [dottedPath moveToPoint:startPoint];
//    
//    for (int x=1; x<dots.count; x++) {
//        [dottedPath addLineToPoint:[[dots objectAtIndex:x] CGPointValue]];
//    }
//    
//    [dottedPath closePath];
//    
//    [[UIColor redColor] setStroke];
//    [dottedPath stroke];
//    
//    UIBezierPath *copyDottedPath = [dottedPath copy];
//    ScalePath(copyDottedPath, 0.35, 0.35);
//    
//
//    
//    CGRect dottedPathBox = PathBoundingBox(copyDottedPath);
//    UIBezierPath *smallPath = [UIBezierPath bezierPathWithRect:dottedPathBox];
//    [smallPath setLineDash:dashes count:6 phase:0];
//    
//    [[UIColor blueColor] setStroke];
//    [smallPath stroke];
//    
//    
//    [self selectNodeInRect:dottedPathBox withContext:ctx withCompanionNode:NO];
//    
//    [self selectNodeInRect:dottedPathBox withContext:ctx withCompanionNode:YES];
//
//    
////    NSInteger dotInt = [self randomNumberBetweenMin:2 andMax:3];
////    
////    for (int x=0; x<dotInt; x++) {
////        
////        
////
////    }
//    
//    UIImage * createdImage = UIGraphicsGetImageFromCurrentImageContext();
//    
//    UIGraphicsEndImageContext();
//    
//    return createdImage;
// 
//}

-(void)initAndBuildMapPathsDictionary
{
    self.mapPaths = [[NSMutableDictionary alloc]init];
    
    NSMutableArray *segArray = [NSMutableArray arrayWithArray:segmentIDArray];

    //NSLog(@"[masterPaths objectForKey:[[masterPaths allKeys] firstObject]]:%@",[masterPaths objectForKey:[[masterPaths allKeys] firstObject]]);
    
    for (NSString *segmentID in segArray) {
        
        NSMutableDictionary *segmentDictionary = [[NSMutableDictionary alloc]init];
        
        CGPoint startPoint = [self firstPointFromSegmentPathID:segmentID];
        CGPoint endPoint = [self secondPointFromSegmentPathID:segmentID];
        
        NSArray *masterPathsNodesForPath = @[[NSValue valueWithCGPoint:startPoint],[NSValue valueWithCGPoint:endPoint]];
        
        UIBezierPath *path = [self returnJaggedPathFromNodes:masterPathsNodesForPath];
        
        [segmentDictionary setValue:[NSValue valueWithCGPoint:startPoint] forKey:@"STARTNODE"];
        [segmentDictionary setValue:[NSValue valueWithCGPoint:endPoint] forKey:@"ENDNODE"];
        [segmentDictionary setValue:path forKey:@"PATH"];
        [segmentDictionary setValue:segmentID forKey:@"ID"];
        
        [self.mapPaths setObject:segmentDictionary forKey:segmentID];
        
    }
       NSLog(@"MAP PATH DICTIONARY BUILT");
    NSLog(@"self.mapPaths.count: %lu",(unsigned long)self.mapPaths.count);
    
    
     NSLog(@"Map path Object:%@",[self.mapPaths objectForKey:[[self.mapPaths allKeys] firstObject]]);
    
}

-(UIBezierPath*)returnPathFromID:(NSString*)pathID
{
   return [[self.mapPaths objectForKey:pathID] valueForKey:@"PATH"];
 }

-(NSString*)returnPathIDFromPath:(UIBezierPath*)path
{
//    NSMutableDictionary *mapDict = self.mapPaths;
    
    NSString *ID = @"";
//    for (id key in self.mapPaths) {
//        UIBezierPath *mapPath = [[mapDict valueForKey:key] valueForKey:@"PATH"];
//        if ([mapPath.destinationPoints isEqualToArray:path.destinationPoints]) {
//                ID = [[self.mapPaths valueForKey:key] valueForKey:@"ID"];
//            }
//    }
    
    return ID;
}

-(CGPoint)endPointFromPath:(UIBezierPath*)path
{
    NSString *pathID = [self returnPathIDFromPath:path];
    
    CGPoint pathEndPoint = [[[self.mapPaths objectForKey:pathID] objectForKey:@"ENDNODE"] CGPointValue];
    
    return pathEndPoint;
}

-(CGPoint)startPointFromPath:(UIBezierPath*)path
{
    NSString *pathID = [self returnPathIDFromPath:path];
    
    CGPoint pathEndPoint = [[[self.mapPaths objectForKey:pathID] valueForKey:@"STARTNODE"] CGPointValue];
    
    return pathEndPoint;
}

-(UIBezierPath*)shortestPathFromPaths:(NSArray*)paths
{
    NSMutableArray *mutableArray = [[NSMutableArray alloc]init];
    
    for (UIBezierPath *path in paths) {
        CGPoint start = [self startPointFromPath:path];
        CGPoint end = [self endPointFromPath:path];
        CGFloat distance = PointDistanceFromPoint(start, end);
        // NSLog(@"distance: %f",distance);
        
        [mutableArray addObject:[NSNumber numberWithFloat:distance]];
    }
    
    NSInteger shortest = [self indexOfHighest:mutableArray];
    // NSLog(@"Highest: %lu",(unsigned long)shortest);
    
    
    
    UIBezierPath *returnPath = [paths objectAtIndex:shortest];
    
    return returnPath;
}






-(void)selectNodeInRect:(CGRect)rect withContext:(CGContextRef)ctx withCompanionNode:(BOOL)withCompanionNode
{
    CGFloat dotSize = 1.25;
    
    CGPoint randomDottedBoxPoint = [self randomPointInRect:rect];
    CGPoint rPoint = [self closestIslandNodeFromPoint:randomDottedBoxPoint];
    
    [[UIColor yellowColor] set];
    CGContextMoveToPoint(ctx, rPoint.x + dotSize, rPoint.y);
    CGContextAddArc(ctx, rPoint.x, rPoint.y, dotSize, 0, 2 * M_PI, 0);
    CGContextFillPath(ctx);
    
    NSArray *segments = [self returnPathsConnectedToNode:rPoint];
    
    if (withCompanionNode)
    {
        NSLog(@"Companion Mode Enabled");
        
        UIBezierPath *chosenPath = [self shortestPathFromPaths:segments];
        CGPoint chosenNode = [self endPointFromPath:chosenPath];
        [[UIColor yellowColor] set];
        CGContextMoveToPoint(ctx, chosenNode.x + dotSize, chosenNode.y);
        CGContextAddArc(ctx, chosenNode.x, chosenNode.y, dotSize, 0, 2 * M_PI, 0);
        CGContextFillPath(ctx);
        NSMutableArray *pathsFromChosenNode = [self returnPathsConnectedToNode:chosenNode];
        [pathsFromChosenNode removeObject:chosenPath];
        UIBezierPath *shortestPath = [self shortestPathFromPaths:pathsFromChosenNode];
        
        shortestPath.lineWidth = 0.50;
        [[UIColor yellowColor] setStroke];
        [shortestPath stroke];
        
        // 2
        UIBezierPath *secondChosenPath = [self shortestPathFromPaths:pathsFromChosenNode];
        CGPoint secondChosenNode = [self endPointFromPath:secondChosenPath];
        
        [[UIColor yellowColor] set];
        CGContextMoveToPoint(ctx, secondChosenNode.x + dotSize, secondChosenNode.y);
        CGContextAddArc(ctx, secondChosenNode.x, secondChosenNode.y, dotSize, 0, 2 * M_PI, 0);
        CGContextFillPath(ctx);
        
        NSMutableArray *secondPathsFromChosenNode = [self returnPathsConnectedToNode:secondChosenNode];
        [secondPathsFromChosenNode removeObject:secondChosenPath];
        UIBezierPath *secondShortestPath = [self shortestPathFromPaths:secondPathsFromChosenNode];
        
        secondShortestPath.lineWidth = 0.50;
        [[UIColor yellowColor] setStroke];
        [secondShortestPath stroke];
        
    }
    
   
    
    for (UIBezierPath *path in segments) {
        path.lineWidth = 0.50;
        [[UIColor yellowColor] setStroke];
        [path stroke];
    }
    
}

-(CGPoint)findLakeNodeFromRect:(CGRect)rect
{
    CGPoint lakeNode = CGPointMake(0, 0);
    
    
    
    
    
    
    return lakeNode;
}

-(id)init
{
    // NSLog(@"Wake Up Called From Init");
    return self;
}

-(void)processMapVanilla
{
    [self setupArrays];
    [self checkCellsForFrame];
    
    
    [self findShallowWater];
    [self findCoastline];
    [self loadCellsDictionaryVanilla];
    
    [self evaluatePaths];
    
    [self initAndBuildMapPathsDictionary];
    
    [self findEdgeStart];
    //[self lineSegmentsTouchingTheEdge];
//    [self frameImage];
//    [self makeAndSetFrameImage];
  
}
-(void)processMap
{
    NSLog(@"Started");
    
    [self preLoad];
    
    //  [self findLakes];
    //NSLog(@"Regions Are Found");
    
    [self evaluatePaths];

    // [self drawTest];
    //  NSLog(@"Tests Drawn");
    
    [self initAndBuildMapPathsDictionary];
    
    [self findEdgeStart];
//    [self frameImage];
//    [self makeAndSetFrameImage];
    
    NSLog(@"Finished Processing Map");
}





-(void)preLoad
{
    [self setupArrays];
    [self setupColors];
    [self evaluateMap];
    
   
}

-(void)evaluateMap
{
    /* EVALUATE */
    
    [self checkCellsForFrame];
    
    [self findShallowWater];
    [self findCoastline];
    //[self findLowTerrain];
    
    [self checkCellsForSharpLines:oceanNodes];
    [self checkCellsForSharpLines:coastWaterNodes];
    
    [self addCellsToCellDictionary];
    
    
}

-(void)setTriangulation:(DelaunayTriangulation *)triangulation
{
   _triangulation = triangulation;
    
}




#pragma mark - DRAW TEST

-(void)drawTest
{
    [self makeRiverFromRandomNode:YES];
    [self makeRiverFromRandomNode:NO];
    
    [self findDistanceNumbers];
}

-(void)makeRiverFromRandomNode:(BOOL)useRandom
{
    CGPoint mouth = CGPointZero;
    NSInteger nodeIndex = 0;
    
    if (!useRandom)
    {
        mouth = [self closestPointFromNodes:[self returnIslandNodes] toPoint:centerP];
        NSString *nodeID = [self generateNodeIDFromNode:mouth];
        NSUInteger nodeInt = [[islandNodes allKeys] indexOfObject:nodeID];
        NSNumber *indexNumber = [NSNumber numberWithUnsignedInteger:nodeInt];
        nodeIndex = [indexNumber integerValue];
    }
    else
    {
        NSArray *innerIslandNodes = [self returnInnerIslandNodes];
        nodeIndex = [self randomNumberBetweenMin:0 andMax:innerIslandNodes.count-1];
        CGPoint innderPoint = [[innerIslandNodes objectAtIndex:nodeIndex] CGPointValue];
        NSString *nodeID = [self generateNodeIDFromNode:innderPoint];
        NSUInteger nodeInt = [[islandNodes allKeys] indexOfObject:nodeID];
        NSNumber *indexNumber = [NSNumber numberWithUnsignedInteger:nodeInt];
        nodeIndex = [indexNumber integerValue];
    }
    
    [self walkIslandNodeToOcean:nodeIndex];
    
}

-(CGPoint)closestOceanNodeForIslandNode:(CGPoint)islandNode
{
    NSString *islandNodeID = [self generateNodeIDFromNode:islandNode];
    CGPoint nearestOceanNode = [[[islandNodes objectForKey:islandNodeID] objectForKey:@"NEAREST_OCEAN_NODE"] CGPointValue];
    
    return nearestOceanNode;
}

-(BOOL)checkArrayForBorders:(NSArray*)nodes
{
    BOOL isNodeInBorder = NO;
    
    NSArray *borderNodes = [self sharedNodesFromGroupA:coastlineCells andGroupB:coastWaterNodes];
    
    for (NSValue *nodeValue in nodes) {
        
        if ([borderNodes containsObject:nodeValue]) {
            isNodeInBorder = YES;
        }
    }
    
    return isNodeInBorder;
}

-(CGPoint)pointThatIsOnBorderFrom:(NSArray*)nodes
{
    CGPoint containedPoint = CGPointZero;
    
    NSArray *borderNodes = [self sharedNodesFromGroupA:coastlineCells andGroupB:coastWaterNodes];
    
    for (NSValue *nodeValue in nodes) {
        
        if ([borderNodes containsObject:nodeValue]) {
            
            containedPoint = [[nodes objectAtIndex:[nodes indexOfObject:nodeValue]] CGPointValue];
        }
    }
    
    return containedPoint;
}


-(NSArray*)walkIslandNodeToOcean:(NSInteger)index
{
    CGPoint startNode = [[[islandNodes objectForKey:[[islandNodes allKeys] objectAtIndex:index]] objectForKey:@"CGPOINT_VALUE"] CGPointValue];
    
    
    NSMutableArray *nodeArray = [[NSMutableArray alloc]init];
    NSMutableArray *purpleNodes = [[NSMutableArray alloc]init];
    
    
    [nodeArray addObject:[NSValue valueWithCGPoint:startNode]];
    [purpleNodes addObject:[NSValue valueWithCGPoint:startNode]];
    
    CGPoint currentPoint = startNode;
    
    NSArray *nodes = [self nodesFromPathConnectedTo:currentPoint];
    
    BOOL doesNodeTouchBorder = [self checkArrayForBorders:nodes];
    BOOL borderSwitch = NO;
    
    CGFloat count = 0;
    
    while (borderSwitch == NO)
        
    {
        ++count;
        
        NSArray *nextNodes = [self nodesFromPathConnectedTo:currentPoint];
        
        doesNodeTouchBorder = [self checkArrayForBorders:nextNodes];
        
        if (doesNodeTouchBorder)
        {
            borderSwitch = YES;
            CGPoint endPoint = [self pointThatIsOnBorderFrom:nextNodes];
            [purpleNodes addObject:[NSValue valueWithCGPoint:endPoint]];
            
        }
        
        else
            
        {
            [nodeArray addObjectsFromArray:nextNodes];
            
            CGPoint closestOceanPoint = [self closestOceanNodeForIslandNode:currentPoint];
            
            CGPoint closestPoint = [self closestPointFromNodes:nextNodes toPoint:closestOceanPoint];
            
            [purpleNodes addObject:[NSValue valueWithCGPoint:closestPoint]];
            
            currentPoint = closestPoint;
            
        }
    }
    
    // UIBezierPath *purplePath = [self returnJaggedPathFromNodes:purpleNodes];
    
    return purpleNodes;
}

-(NSArray*)nodesFromPathConnectedTo:(CGPoint)node
{
    NSMutableArray *nodesAtSegmentEnds = [[NSMutableArray alloc]init];
    
    NSString *nodePointPathID = [self generatePathIDFromOnePoint:node];
    
    for (NSString *segmentID in segmentIDArray)
    {
        if ([segmentID hasPrefix:nodePointPathID]) {
            
            CGPoint secondP = [self secondPointFromSegmentPathID:segmentID];
            
            [nodesAtSegmentEnds addObject:[NSValue valueWithCGPoint:secondP]];
            
        }
    }
    
    return nodesAtSegmentEnds;
}

//-(void)walkIslandNodeToOcean2:(NSInteger)index
//{
//    CGPoint randomIslandNode = [[[islandNodes objectForKey:[[islandNodes allKeys] objectAtIndex:index]] objectForKey:@"CGPOINT_VALUE"] CGPointValue];
//    // CGPoint nearestOceanNode = [[[islandNodes objectForKey:[[islandNodes allKeys] objectAtIndex:index]] objectForKey:@"NEAREST_OCEAN_NODE"] CGPointValue];
//    
//    CGPoint currentPoint = randomIslandNode;
//    CGFloat distance = 5.1;
//    CGFloat lastDistance = 1.0f;
//    
//    NSMutableArray *walkPoints = [[NSMutableArray alloc]init];
//    
//    // (!CGPointEqualToPoint(nearestOceanNode, CGPointZero))
//    
//    while (distance > 5.0f ) {
//        
//        NSString *nodeID = [self generateNodeIDFromNode:currentPoint];
//        NSValue *flowToValue = [[islandNodes objectForKey:nodeID] objectForKey:@"NEAREST_OCEAN_NODE"];
//        [walkPoints addObject:flowToValue];
//        distance = [[[islandNodes objectForKey:nodeID] objectForKey:@"OCEAN_DISTANCE"] floatValue];
//        NSLog(@"distance: %f",distance);
//        lastDistance = distance;
//        CGPoint flowtoPoint = [flowToValue CGPointValue];
//        currentPoint = flowtoPoint;
//    }
//    
//    //  [self paintNodes:walkPoints with:[UIColor greenColor] dotSize:1.0f];
//}


-(NSMutableArray*)distanceFromCenterArrayFrom:(NSArray*)nodes
{
    
    
    CGPoint center = centerP;
    
    NSMutableArray *distanceArray = [[NSMutableArray alloc]init];
    
    for (int x=0; x<nodes.count; x++)
    {
        CGPoint point = [self pointAtIndex:x of:nodes];
        CGFloat length =  PointDistanceFromPoint(point, center);
        NSUInteger lengthInt = length;
        
        NSNumber *lengthNumber = [NSNumber numberWithUnsignedInteger:lengthInt];
        
        [distanceArray insertObject:lengthNumber atIndex:x];
    }
    
    return distanceArray;
}


//-(NSArray*)cellsTouching:(CGPoint)touchPoint
//{
//    NSMutableArray *closestTouchingNodes = [[NSMutableArray alloc]init];
//    
//    
//    for (VoronoiCell *cell in islandCells) {
//        [self doesCellIn:@[cell] touchCellIn:@[]];
//        
//    }
//    
//    return closestTouchingNodes;
//}

// Used to in region definition
-(NSUInteger)closestNode:(NSArray*)nodes to:(CGPoint)sentPoint
{
    NSMutableArray *distanceArray = [[NSMutableArray alloc]init];
    
    for (int x=0; x<nodes.count; x++)
    {
        CGPoint point = [self pointAtIndex:x of:nodes];
        CGFloat length =  PointDistanceFromPoint(point, sentPoint);
        NSUInteger lengthInt = length;
        
        if (lengthInt == 0) {
            lengthInt = 100;
        }
        
        NSNumber *lengthNumber = [NSNumber numberWithUnsignedInteger:lengthInt];
        
        [distanceArray insertObject:lengthNumber atIndex:x];
    }
    
    return [self indexOfLowest:distanceArray];
}






-(CGPoint)pointAtIndex:(NSUInteger)index of:(NSArray*)nodes
{
    NSValue *value = [nodes objectAtIndex:index];
    CGPoint point = [value CGPointValue];
    return point;
}



-(void)checkCellsForSharpLines:(NSArray*)cells
{
    for (VoronoiCell *cell in cells)
    {
        if ([self checkForSharpPoints:cell.nodes]) {
            [sharpCells addObject:cell];
        }
    }
}

//-(void)findLowTerrain
//{
//    NSMutableArray *revisedIslandCells = [[NSMutableArray alloc]init];
//    
//    for (VoronoiCell *cell in islandCells)
//    {
//        if (![self checkIslandCellsForLowTerrain:cell.nodes]) {
//            
//            [revisedIslandCells addObject:cell];
//        }
//        else
//        {
//            [lowTerrainCells addObject:cell];
//        }
//        
//    }
//    
//    islandCells = revisedIslandCells;
//}


-(void)findCoastline
{
    NSMutableArray *revisedIslandCells = [[NSMutableArray alloc]init];
    
    for (VoronoiCell *cell in islandCells)
    {
        if (![self checkCellForCoastLine:cell.nodes]) {
            
            [revisedIslandCells addObject:cell];
        }
        else
        {
            [coastlineCells addObject:cell];
        }
        
    }
    
    islandCells = revisedIslandCells;
}

-(void)findShallowWater
{
    NSMutableArray *revisedIslandCells = [[NSMutableArray alloc]init];
    
    for (VoronoiCell *cell in islandCells)
    {
        if (![self checkCellForCoastWater:cell.nodes])
        {
            [revisedIslandCells addObject:cell];
            
        }
        else
        {
            [coastWaterNodes addObject:cell];
        }
        
    }
    
    islandCells = revisedIslandCells;
}

-(void)checkCellsForFrame
{
    BOOL cellIn = NO;
    BOOL cellOuter = NO;
    
    // Gather Cells
    NSDictionary *voronoiCells = [_triangulation voronoiCells];
    
    NSLog(@"Total Cell Count:%lu",(unsigned long)voronoiCells.count);
    
    CGRect viewFrame = _frame;
    
    for (VoronoiCell *cell in [voronoiCells objectEnumerator])
    {
        cellIn = NO;
        cellOuter = NO;
        
        // Get the Cell Nodes from Cell
        NSArray *nodeArray = cell.nodes;
        
        // Test the Cell to see if its nodes go out of the Frame or not
        NSUInteger qualifer = 0;
        
        for (int x = 0; x<nodeArray.count; x++)
        {
            
            
            NSValue *pointValue = [nodeArray objectAtIndex:x];
            CGPoint pointFromValue = [pointValue CGPointValue];
            if (CGRectContainsPoint(viewFrame, pointFromValue))
            {
                qualifer++;
            }
            
        }
        
        NSUInteger nodeCount = cell.nodes.count;
        
        if (qualifer == nodeCount)
        {
            cellIn = YES;
        }
        
        if (cellIn == NO)
        {
            [outOfFrameCells addObject:cell];
            [oceanNodes addObject:cell];
        }
        else
        {
            if ([self checkCellforTouchingOuterCells:cell.nodes])
            {
                [outerCells addObject:cell];
                [oceanNodes addObject:cell];
            }
            else
            {
                CGFloat areaThreshold = 999.0f;
                
                if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
                {
                    areaThreshold = 2999.f;
                }
                
                if (cell.area < areaThreshold)
                {
                    [islandCells addObject:cell];
                }
                if ((cell.area > areaThreshold))
                {
                    [oceanNodes addObject:cell];
                }
            }
        }
    }
}

-(NSArray*)sharedNodesFromGroupA:(NSArray*)groupA andGroupB:(NSArray*)groupB
{
    NSMutableArray *sharedNodes = [[NSMutableArray alloc]init];
    
    for (VoronoiCell *cell_A in groupA)
    {
        NSArray *cell_A_Nodes = cell_A.nodes;
        
        for (NSValue *cell_A_NodeValue in cell_A_Nodes)
        {
            CGPoint cell_A_NodePoint = [cell_A_NodeValue CGPointValue];
            
            for (VoronoiCell *cell_B in groupB)
            {
                NSArray *cell_B_Nodes = cell_B.nodes;
                
                for (NSValue *cell_B_NodeValue in cell_B_Nodes)
                {
                    CGPoint cell_B_NodePoint = [cell_B_NodeValue CGPointValue];
                    
                    if (CGPointEqualToPoint(cell_B_NodePoint, cell_A_NodePoint))
                    {
                        
                        if (![sharedNodes containsObject:[NSValue valueWithCGPoint:cell_B_NodePoint]]) {
                            [sharedNodes addObject:[NSValue valueWithCGPoint:cell_B_NodePoint]];
                        }
                        
                        
                    }
                }
            }
        }
    }
    
    return sharedNodes;
}

//-(BOOL)checkIslandCellsForLowTerrain:(NSArray*)nodesFromCheckingCell
//{
//    BOOL nodeIsLowTerrain = NO;
//    
//    for (VoronoiCell *coastlineCell in coastlineCells)
//    {
//        NSArray *coastLineCellNodes = coastlineCell.nodes;
//        
//        for (NSValue *coastlineCellNodeValue in coastLineCellNodes)
//        {
//            CGPoint coastlineCellNodePoint = [coastlineCellNodeValue CGPointValue];
//            
//            for (NSValue *checkingValue in nodesFromCheckingCell)
//            {
//                CGPoint checkingPoint = [checkingValue CGPointValue];
//                
//                if (CGPointEqualToPoint(checkingPoint, coastlineCellNodePoint))
//                {
//                    nodeIsLowTerrain = YES;
//                }
//            }
//        }
//    }
//    
//    
//    return nodeIsLowTerrain;
//}

-(BOOL)doesCellIn:(NSArray*)groupA touchCellIn:(NSArray*)groupB
{
    BOOL doesCellTouch = NO;
    
    for (VoronoiCell *cell_A in groupA)
    {
        for (NSValue *value_A in cell_A.nodes)
        {
            CGPoint point_A = [value_A CGPointValue];
            
            for (VoronoiCell *cell_B in groupB)
            {
                for (NSValue *value_B in cell_B.nodes)
                {
                    CGPoint point_B = [value_B CGPointValue];
                    
                    if (CGPointEqualToPoint(point_A, point_B))
                    {
                        doesCellTouch = YES;
                    }
                }
            }
        }
    }
    
    return doesCellTouch;
}


-(BOOL)checkCellForCoastLine:(NSArray*)nodesFromCheckingCell
{
    BOOL nodeIsOnCoastline = NO;
    
    for (VoronoiCell *coastWaterCell in coastWaterNodes) {
        
        NSArray *coastWaterCellNodes = coastWaterCell.nodes;
        
        for (NSValue *coastWaterCellNodeValue in coastWaterCellNodes) {
            
            CGPoint coastWaterNodePoint = [coastWaterCellNodeValue CGPointValue];
            
            for (NSValue *checkingValue in nodesFromCheckingCell) {
                
                CGPoint checkingPoint = [checkingValue CGPointValue];
                
                CGPointEqualToPoint(checkingPoint, coastWaterNodePoint);
                
                if (CGPointEqualToPoint(checkingPoint, coastWaterNodePoint)) {
                    nodeIsOnCoastline = YES;
                }
            }
        }
        
    }
    
    return nodeIsOnCoastline;
    
}


-(BOOL)checkCellForCoastWater:(NSArray*)nodesFromCheckingCell
{
    BOOL nodeIsOnCoastWater = NO;
    
    for (VoronoiCell *oceanCell in oceanNodes) {
        
        NSArray *oceanCellNodes = oceanCell.nodes;
        
        for (NSValue *oceanCellNodeValue in oceanCellNodes) {
            
            CGPoint oceanNodePoint = [oceanCellNodeValue CGPointValue];
            
            for (NSValue *checkingValue in nodesFromCheckingCell) {
                
                CGPoint checkingPoint = [checkingValue CGPointValue];
                
                CGPointEqualToPoint(checkingPoint, oceanNodePoint);
                
                if (CGPointEqualToPoint(checkingPoint, oceanNodePoint)) {
                    nodeIsOnCoastWater = YES;
                }
            }
        }
        
    }
    
    return nodeIsOnCoastWater;
}

-(BOOL)checkCellforTouchingOuterCells:(NSArray*)nodesFromCheckingCell
{
    BOOL aNodeIsShared = NO;
    
    for (VoronoiCell *cell in outOfFrameCells)
    {
        NSArray *outOfFrameCellNodes = cell.nodes;
        
        for (NSValue *outOfFrameValue in outOfFrameCellNodes)
        {
            CGPoint outOfFrameNode = [outOfFrameValue CGPointValue];
            
            for (NSValue *checkingValue in nodesFromCheckingCell) {
                CGPoint checkingPoint = [checkingValue CGPointValue];
                
                if (CGPointEqualToPoint(checkingPoint, outOfFrameNode)) {
                    aNodeIsShared = YES;
                }
            }
        }
    }
    
    return aNodeIsShared;
}



-(NSArray*)randomLineNodesFrom:(CGPoint)pointA to:(CGPoint)pointB intensity:(CGFloat)intensity
{
    NSMutableArray *randomLineNodes = [[NSMutableArray alloc]init];
    
    CGFloat segmentDistance = PointDistanceFromPoint(pointA, pointB);
    CGFloat segmentLength = segmentDistance/8;
    CGFloat segmentMultiplyer = segmentLength * 2;
    CGFloat sizeW = intensity * segmentMultiplyer;
    CGFloat sizeH = intensity * segmentMultiplyer;
    CGSize rectSize = CGSizeMake(sizeW, sizeH);
    
    CGRect wholeLineRect = PointsMakeRect(pointA, pointB);
    CGPoint lineCenter = RectGetCenter(wholeLineRect);
    
    // Divde Segment into 4ths, 8th
    // Draw Rects find the center Points, draw rects agian with those center points and segment points
    // Draw rect around the center points with the size being the segment length
    
    //
    CGRect firstHalfRect = PointsMakeRect(pointA, lineCenter);
    CGPoint firstHalfCenter = RectGetCenter(firstHalfRect);
    //
    CGRect secondHalfRect = PointsMakeRect(lineCenter, pointB);
    CGPoint secondHalfCenter = RectGetCenter(secondHalfRect);
    //
    //
    CGRect firstQtrRect = PointsMakeRect(pointA, firstHalfCenter);
    CGPoint firstQtrCenter = RectGetCenter(firstQtrRect);
    //CGRect firstCenteredQtrRect = RectAroundCenter(firstQtrCenter, rectSize);
    //
    CGRect secondQtrRect = PointsMakeRect(firstHalfCenter, lineCenter);
    CGPoint secondQtrCenter = RectGetCenter(secondQtrRect);
    //CGRect secondCenteredQtrRect = RectAroundCenter(secondQtrCenter, rectSize);
    //
    CGRect thirdQtrRect = PointsMakeRect(lineCenter, secondHalfCenter);
    CGPoint thirdQtrCenter = RectGetCenter(thirdQtrRect);
    // CGRect thirdCenteredQtrRect = RectAroundCenter(thirdQtrCenter, rectSize);
    //
    CGRect fourthQtrRect = PointsMakeRect(secondHalfCenter, pointB);
    CGPoint fourthQtrCenter = RectGetCenter(fourthQtrRect);
    //CGRect fourthCenteredQtrRect = RectAroundCenter(fourthQtrCenter, rectSize);
    
    // Chop 8 Times
    //
    CGRect firstEightRect = PointsMakeRect(pointA, firstQtrCenter);
    CGPoint pc1 = RectGetCenter(firstEightRect);
    CGRect r1 = RectAroundCenter(pc1, rectSize);
    CGPoint rpt1 = [self randomPointInRect:r1];
    
    CGRect secondEightRect = PointsMakeRect(firstQtrCenter, firstHalfCenter);
    CGPoint pc2 = RectGetCenter(secondEightRect);
    CGRect r2 = RectAroundCenter(pc2, rectSize);
    CGPoint rpt2 = [self randomPointInRect:r2];
    
    CGRect thirdEightRect = PointsMakeRect(firstHalfCenter, secondQtrCenter);
    CGPoint pc3 = RectGetCenter(thirdEightRect);
    CGRect r3 = RectAroundCenter(pc3, rectSize);
    CGPoint rpt3 = [self randomPointInRect:r3];
    
    CGRect fourthEightRect = PointsMakeRect(secondQtrCenter, lineCenter);
    CGPoint pc4 = RectGetCenter(fourthEightRect);
    CGRect r4 = RectAroundCenter(pc4, rectSize);
    CGPoint rpt4 = [self randomPointInRect:r4];
    
    CGRect fifthEightRect = PointsMakeRect(lineCenter, thirdQtrCenter);
    CGPoint pc5 = RectGetCenter(fifthEightRect);
    CGRect r5 = RectAroundCenter(pc5, rectSize);
    CGPoint rpt5 = [self randomPointInRect:r5];
    
    CGRect sixthEightRect = PointsMakeRect(thirdQtrCenter, secondHalfCenter);
    CGPoint pc6 = RectGetCenter(sixthEightRect);
    CGRect r6 = RectAroundCenter(pc6, rectSize);
    CGPoint rpt6 = [self randomPointInRect:r6];
    
    CGRect seventhEightRect = PointsMakeRect(secondHalfCenter, fourthQtrCenter);
    CGPoint pc7 = RectGetCenter(seventhEightRect);
    CGRect r7 = RectAroundCenter(pc7, rectSize);
    CGPoint rpt7 = [self randomPointInRect:r7];
    
    CGRect eightEightRect = PointsMakeRect(fourthQtrCenter, pointB);
    CGPoint pc8 = RectGetCenter(eightEightRect);
    CGRect r8 = RectAroundCenter(pc8, rectSize);
    CGPoint rpt8 = [self randomPointInRect:r8];
    
    // Draw First Segment
//    UIBezierPath *segmentPath = [UIBezierPath bezierPath];
//    [segmentPath moveToPoint:pointA];
    [randomLineNodes insertObject:[NSValue valueWithCGPoint:pointA] atIndex:0];
    
    //[segmentPath addLineToPoint:rpt1];
    [randomLineNodes insertObject:[NSValue valueWithCGPoint:rpt1] atIndex:0];
    // [segmentPath addLineToPoint:firstQtrCenter];
    [randomLineNodes insertObject:[NSValue valueWithCGPoint:firstQtrCenter] atIndex:0];
    // [segmentPath addLineToPoint:rpt2];
    [randomLineNodes insertObject:[NSValue valueWithCGPoint:rpt2] atIndex:0];
    // [segmentPath addLineToPoint:firstHalfCenter];
    [randomLineNodes insertObject:[NSValue valueWithCGPoint:firstHalfCenter] atIndex:0];
    // [segmentPath addLineToPoint:rpt3];
    [randomLineNodes insertObject:[NSValue valueWithCGPoint:rpt3] atIndex:0];
    //  [segmentPath addLineToPoint:secondQtrCenter];
    [randomLineNodes insertObject:[NSValue valueWithCGPoint:secondQtrCenter] atIndex:0];
    // [segmentPath addLineToPoint:rpt4];
    [randomLineNodes insertObject:[NSValue valueWithCGPoint:rpt4] atIndex:0];
    // [segmentPath addLineToPoint:lineCenter];
    [randomLineNodes insertObject:[NSValue valueWithCGPoint:lineCenter] atIndex:0];
    // [segmentPath addLineToPoint:rpt5];
    [randomLineNodes insertObject:[NSValue valueWithCGPoint:rpt5] atIndex:0];
    // [segmentPath addLineToPoint:thirdQtrCenter];
    [randomLineNodes insertObject:[NSValue valueWithCGPoint:thirdQtrCenter] atIndex:0];
    // [segmentPath addLineToPoint:rpt6];
    [randomLineNodes insertObject:[NSValue valueWithCGPoint:rpt6] atIndex:0];
    //  [segmentPath addLineToPoint:secondHalfCenter];
    [randomLineNodes insertObject:[NSValue valueWithCGPoint:secondHalfCenter] atIndex:0];
    //  [segmentPath addLineToPoint:rpt7];
    [randomLineNodes insertObject:[NSValue valueWithCGPoint:rpt7] atIndex:0];
    // [segmentPath addLineToPoint:fourthQtrCenter];
    [randomLineNodes insertObject:[NSValue valueWithCGPoint:fourthQtrCenter] atIndex:0];
    // [segmentPath addLineToPoint:rpt8];
    [randomLineNodes insertObject:[NSValue valueWithCGPoint:rpt8] atIndex:0];
    // [segmentPath addLineToPoint:pointB];
    [randomLineNodes insertObject:[NSValue valueWithCGPoint:pointB] atIndex:0];
    
    
    NSArray *reversedLineNodes = [[randomLineNodes reverseObjectEnumerator] allObjects];
    
    NSString *segmentIDString = [self generatePathIDFrom:pointA to:pointB];
    NSString *reversedSegmentIDString = [self generatePathIDFrom:pointB to:pointA];
    
    [segmentIDArray addObject:reversedSegmentIDString];
    [segmentIDArray addObject:segmentIDString];
    
    // Add the Paths Created to the Master Path Dictionary for fetching Later
    [masterPaths setValue:reversedLineNodes forKey:segmentIDString];
    [masterPaths setValue:randomLineNodes forKey:reversedSegmentIDString];
    
    return reversedLineNodes;
}

-(NSString*)generateNodeIDFromNode:(CGPoint)pointA
{
    CGFloat pax =  pointA.x;
    NSNumber *paxNumber = [NSNumber numberWithFloat:pax];
    CGFloat pay =  pointA.y;
    NSNumber *payNumber = [NSNumber numberWithFloat:pay];
    
    NSString *segmentString = [NSString stringWithFormat:@"%lu.%lu",(unsigned long)[paxNumber integerValue],(unsigned long)[payNumber integerValue]];
    
    return segmentString;
}

-(NSString*)generatePathIDFrom:(CGPoint)pointA to:(CGPoint)pointB
{
    CGFloat pax =  pointA.x;
    NSNumber *paxNumber = [NSNumber numberWithFloat:pax];
    CGFloat pay =  pointA.y;
    NSNumber *payNumber = [NSNumber numberWithFloat:pay];
    
    CGFloat pbx =  pointB.x;
    NSNumber *pbxNumber = [NSNumber numberWithFloat:pbx];
    CGFloat pby =  pointB.y;
    NSNumber *pbyNumber = [NSNumber numberWithFloat:pby];
    
    NSString *segmentString = [NSString stringWithFormat:@"%lu.%lu:%lu.%lu",(unsigned long)[paxNumber integerValue],(unsigned long)[payNumber integerValue],(unsigned long)[pbxNumber integerValue],(unsigned long)[pbyNumber integerValue]];
    
    return segmentString;
    
}

-(NSString*)generatePathIDFromOnePoint:(CGPoint)pointA
{
    CGFloat pax =  pointA.x;
    NSNumber *paxNumber = [NSNumber numberWithFloat:pax];
    CGFloat pay =  pointA.y;
    NSNumber *payNumber = [NSNumber numberWithFloat:pay];
    
    NSString *segmentString = [NSString stringWithFormat:@"%lu.%lu:",(unsigned long)[paxNumber integerValue],(unsigned long)[payNumber integerValue]];
    
    return segmentString;
}


-(BOOL)segmentBeenDrawn:(CGPoint)pointA to:(CGPoint)pointB
{
    BOOL hasSegmentBeenDrawn = NO;
    
    NSString *askingID = [self generatePathIDFrom:pointA to:pointB];
    
    for (int x=0; x<segmentIDArray.count; x++) {
        NSString *segmentID = [segmentIDArray objectAtIndex:x];
        
        if ([segmentID isEqualToString:askingID]) {
            
            hasSegmentBeenDrawn = YES;
        }
    }
    
    return hasSegmentBeenDrawn;
}



//-(void)jaggedOutLineCell:(NSArray*)nodes
//{
//    CGFloat tensity = 0.45f;
//    
//    for (int x=0; x<nodes.count-1; x++)
//    {
//        CGPoint ptA = [[nodes objectAtIndex:x] CGPointValue];
//        CGPoint ptB = [[nodes objectAtIndex:x+1] CGPointValue];
//        
//        if (![self segmentBeenDrawn:ptA to:ptB])
//        {
//            [self randomLineNodesFrom:ptA to:ptB intensity:tensity];
//        }
//        
//        
//    }
//    
//    CGPoint firstObject = [[nodes firstObject] CGPointValue];
//    CGPoint lastObject = [[nodes lastObject] CGPointValue];
//    
//    if (![self segmentBeenDrawn:firstObject to:lastObject]) {
//        
//        [self randomLineNodesFrom:firstObject to:lastObject intensity:tensity];
//    }
//    
//    
//}

//-(void)outlineCell:(NSArray*)nodes
//{
//    UIBezierPath *segmentPath = [UIBezierPath bezierPath];
//    [segmentPath moveToPoint:[[nodes firstObject] CGPointValue]];
//    
//    CGPoint lastPoint = [[nodes firstObject] CGPointValue];
//    
//    
//    for (int x=0; x<nodes.count; x++)
//    {
//        CGPoint nextPoint = [[nodes objectAtIndex:x] CGPointValue];
//        lastPoint = nextPoint;
//        
//        [segmentPath addLineToPoint:[[nodes objectAtIndex:x] CGPointValue]];
//    }
//    
//    
//    
//    [segmentPath closePath];
//    [[UIColor whiteColor] setStroke];
//    segmentPath.lineWidth = 1.0;
//    [segmentPath stroke];
//}

-(BOOL)checkForSharpPoints:(NSArray*)nodes
{
    BOOL isCellTooSharp = NO;
    
    CGPoint lastPoint = [[nodes firstObject] CGPointValue];
    
    for (int x=1; x<nodes.count; x++)
    {
        CGPoint nextPoint = [[nodes objectAtIndex:x] CGPointValue];
        
        CGFloat bearingAngleValue = [self pointPairToBearingDegrees:lastPoint secondPoint:nextPoint];
        
        
        if (bearingAngleValue < 19)
        {
            // Angle Lower than 30
            isCellTooSharp = YES;
            //NSLog(@"Angle: %f",bearingAngleValue);
        }
        
        
        
        lastPoint = nextPoint;
        
    }
    
    return isCellTooSharp;
}

#pragma mark - LAKES

-(void)findLakes
{
    
    islandNodes = [self buildIslansdNodeDictionary];
    
    [self calculateDistanceFromOceanNode];
    
    CGRect rect = _frame;
    
    NSMutableArray *islandCentroids = [[NSMutableArray alloc]init];
    
    for (VoronoiCell *cell in islandCells) {
        [islandCentroids addObject:[NSValue valueWithCGPoint:cell.centroid]];
    }
    
    // Closest Cell to Left Corner
    NSInteger center = [self closestCellIndex:islandCentroids toPoint:RectGetCenter(rect)];
    NSInteger topLeft = [self closestCellIndex:islandCentroids toPoint:RectGetTopLeft(rect)];
    NSInteger midTop = [self closestCellIndex:islandCentroids toPoint:RectGetMidTop(rect)];
    NSInteger topRight = [self closestCellIndex:islandCentroids toPoint:RectGetTopRight(rect)];
    NSInteger bottomLeft = [self closestCellIndex:islandCentroids toPoint:RectGetBottomLeft(rect)];
    NSInteger midBottom = [self closestCellIndex:islandCentroids toPoint:RectGetMidBottom(rect)];
    NSInteger bottomRight = [self closestCellIndex:islandCentroids toPoint:RectGetBottomRight(rect)];
    NSInteger midLeft = [self closestCellIndex:islandCentroids toPoint:RectGetMidLeft(rect)];
    NSInteger midRight = [self closestCellIndex:islandCentroids toPoint:RectGetMidRight(rect)];
    
    CGPoint TL = [[islandCentroids objectAtIndex:topLeft] CGPointValue];
    CGPoint MT = [[islandCentroids objectAtIndex:midTop] CGPointValue];
    CGPoint TR = [[islandCentroids objectAtIndex:topRight] CGPointValue];
    CGPoint BL = [[islandCentroids objectAtIndex:bottomLeft] CGPointValue];
    CGPoint MB = [[islandCentroids objectAtIndex:midBottom] CGPointValue];
    CGPoint BR = [[islandCentroids objectAtIndex:bottomRight] CGPointValue];
    CGPoint ML = [[islandCentroids objectAtIndex:midLeft] CGPointValue];
    CGPoint MR = [[islandCentroids objectAtIndex:midRight] CGPointValue];
    CGPoint CTR = [[islandCentroids objectAtIndex:center] CGPointValue];
    
    NSArray *mainPointArray = @[[NSValue valueWithCGPoint:TL],
                                [NSValue valueWithCGPoint:MT],
                                [NSValue valueWithCGPoint:TR],
                                [NSValue valueWithCGPoint:MR],
                                [NSValue valueWithCGPoint:BR],
                                [NSValue valueWithCGPoint:MB],
                                [NSValue valueWithCGPoint:BL],
                                [NSValue valueWithCGPoint:ML],
                                [NSValue valueWithCGPoint:CTR]];
    
    // 8 Regions
    
    NSMutableArray *regionArray = [NSMutableArray arrayWithArray:@[@0,@1,@2,@3,@4,@5,@6,@7]];
    
    NSInteger regionIndexA = [self randomNumberBetweenMin:0 andMax:regionArray.count];
    NSNumber *regionNumberA = [regionArray objectAtIndex:regionIndexA];
    [regionArray removeObjectAtIndex:regionIndexA];
    NSInteger regionA = [regionNumberA integerValue];
    
    NSInteger regionIndexB = [self randomNumberBetweenMin:0 andMax:regionArray.count];
    NSNumber *regionNumberB = [regionArray objectAtIndex:regionIndexB];
    [regionArray removeObjectAtIndex:regionIndexB];
    NSInteger regionB = [regionNumberB integerValue];
    
    NSInteger regionIndexC = [self randomNumberBetweenMin:0 andMax:regionArray.count];
    NSNumber *regionNumberC = [regionArray objectAtIndex:regionIndexC];
    [regionArray removeObjectAtIndex:regionIndexC];
    NSInteger regionC = [regionNumberC integerValue];
    
    NSInteger regionIndexD = [self randomNumberBetweenMin:0 andMax:regionArray.count];
    NSNumber *regionNumberD = [regionArray objectAtIndex:regionIndexD];
    [regionArray removeObjectAtIndex:regionIndexD];
    NSInteger regionD = [regionNumberD integerValue];
    
    NSInteger regionIndexE = [self randomNumberBetweenMin:0 andMax:regionArray.count];
    NSNumber *regionNumberE = [regionArray objectAtIndex:regionIndexE];
    [regionArray removeObjectAtIndex:regionIndexE];
    NSInteger regionE = [regionNumberE integerValue];
    
    NSInteger regionIndexF = [self randomNumberBetweenMin:0 andMax:regionArray.count];
    NSNumber *regionNumberF = [regionArray objectAtIndex:regionIndexF];
    [regionArray removeObjectAtIndex:regionIndexF];
    NSInteger regionF = [regionNumberF integerValue];
    
    NSInteger regionIndexG = [self randomNumberBetweenMin:0 andMax:regionArray.count];
    NSNumber *regionNumberG = [regionArray objectAtIndex:regionIndexG];
    [regionArray removeObjectAtIndex:regionIndexG];
    NSInteger regionG = [regionNumberG integerValue];
    
    NSInteger regionIndexH = [self randomNumberBetweenMin:0 andMax:regionArray.count];
    NSNumber *regionNumberH = [regionArray objectAtIndex:regionIndexH];
    [regionArray removeObjectAtIndex:regionIndexH];
    NSInteger regionH = [regionNumberH integerValue];
    
    [self defineRegion:regionA withNodes:mainPointArray];
    [self defineRegion:regionB withNodes:mainPointArray];
    [self defineRegion:regionC withNodes:mainPointArray];
    [self defineRegion:regionD withNodes:mainPointArray];
    [self defineRegion:regionE withNodes:mainPointArray];
    [self defineRegion:regionF withNodes:mainPointArray];
    [self defineRegion:regionG withNodes:mainPointArray];
    [self defineRegion:regionH withNodes:mainPointArray];
    
}

-(void)defineRegion:(NSInteger)regionInt withNodes:(NSArray*)nodes
{
    NSInteger nextInt = 0;
    
    if (regionInt == 7) {
        nextInt = 0;
    }
    else
    {
        nextInt = regionInt+1;
    }
    
    NSArray *regionNodes = @[[nodes objectAtIndex:regionInt],[nodes objectAtIndex:nextInt],[nodes lastObject]];
    
    [self claimRegion:regionInt withNodes:regionNodes];
}

-(void)claimRegion:(NSInteger)region withNodes:(NSArray*)nodes
{
    CGPoint center = [[nodes lastObject] CGPointValue];
    CGPoint pointA = [[nodes firstObject] CGPointValue];
    CGPoint pointB = [[nodes objectAtIndex:1] CGPointValue];
    
    CGRect rectA = PointsMakeRect(pointA, center);
    CGPoint centerA = RectGetCenter(rectA);
    
    CGRect rectB = PointsMakeRect(pointB, center);
    CGPoint centerB = RectGetCenter(rectB);
    
    CGRect rect = PointsMakeRect(centerA, centerB);
    CGPoint centerRect = RectGetCenter(rect);
    
    NSMutableArray *islandCentroids = [[NSMutableArray alloc]init];
    
    for (VoronoiCell *cell in islandCells) {
        [islandCentroids addObject:[NSValue valueWithCGPoint:cell.centroid]];
    }
    
    NSInteger centerRectIndex = [self closestNode:islandCentroids to:centerRect];
    [islandCentroids objectAtIndex:centerRectIndex];
    
    NSMutableArray *regionCentroids = [[NSMutableArray alloc]init];
    [regionCentroids addObject:[islandCentroids objectAtIndex:centerRectIndex]];
    
    
    
    UIColor *regionColor = [regionColors objectAtIndex:region];
    
    CGPoint regionPoint = [[regionCentroids firstObject] CGPointValue];
    
    [self claimRegion:regionPoint withColor:regionColor];
    
    
}




#pragma mark - MAP CELLS

-(void)claimRegion:(CGPoint)regionCentroid withColor:(UIColor*)regionColor
{
    [[mapCells objectForKey:[self generateIDForCellFromCentroid:regionCentroid]] setValue:regionColor forKey:@"COLOR"];
    
    NSString *regionColorString = [self stringFromColor:regionColor];
    
    NSString *lakeString = [self stringFromColor:[UIColor waveColor]];
    NSString *mntString = [self stringFromColor:[UIColor snowColor]];
    NSString *rainForestString = [self stringFromColor:[UIColor emeraldColor]];
    
    
    if ([regionColorString isEqualToString:rainForestString]) {
        [self clumpRegion:regionCentroid withColor:regionColor byAmount:1.0];
    }
    else if ([regionColorString isEqualToString:lakeString]) {
        
        CGFloat amount = randFloat(0.10, 0.35);
        
        [self clumpRegion:regionCentroid withColor:regionColor byAmount:amount];
    }
    else if ([regionColorString isEqualToString:mntString]) {
        
        // SET MOUNTAIN
        [self setMountainNodeFromCentroid:regionCentroid];
        
        [self clumpRegion:regionCentroid withColor:regionColor byAmount:1.0];
        
    }
}

-(void)setColor:(UIColor*)color forCellID:(NSString*)stringID
{
    [[mapCells objectForKey:stringID] setValue:color forKey:@"COLOR"];
}


//-(void)paintMapCells
//{
//    for (id key in [mapCells allKeys]) {
//        NSDictionary *cellDict = [mapCells objectForKey:key];
//        UIBezierPath *cellPath = [cellDict objectForKey:@"PATH"];
//        UIColor *cellColor = [cellDict objectForKey:@"COLOR"];
//        NSNumber *outlineNumber = [cellDict objectForKey:@"OUTLINE"];
//        BOOL outline = [outlineNumber boolValue];
//        [self paintPath:cellPath cellColor:cellColor outline:outline];
//    }
//    
//}

-(NSMutableDictionary*)buildDictionaryFromCells:(NSArray*)cells withType:(NSString*)typeString andColor:(UIColor*)color withOutline:(BOOL)outline
{
    NSMutableDictionary *dictionaryOfDictionariesFromCells = [[NSMutableDictionary alloc]init];
    
    for (VoronoiCell *cell in cells) {
        
        NSMutableDictionary *cellEntry = [[NSMutableDictionary alloc]init];
        NSString *cellID = [self generateIDForCellFromCentroid:cell.centroid];
        UIBezierPath *cellPath = [UIBezierPath bezierPath];
        
        
        if (self.isJagged) {
            NSLog(@"Jagged");
           cellPath = [self generateJaggedPathFromCellNodes:cell.nodes];
        }
        else {
            NSLog(@"Straight");
          cellPath = [self generateStraightPathFromCellNodes:cell.nodes];
        }
        
        
        
        [cellEntry setValue:cell forKey:cellID];
        [cellEntry setValue:typeString forKey:@"TYPE"];
        [cellEntry setValue:cellID forKey:@"ID"];
        [cellEntry setValue:cell.nodes forKey:@"NODES"];
        [cellEntry setValue:color forKey:@"COLOR"];
        [cellEntry setValue:cellPath forKey:@"PATH"];
        [cellEntry setValue:[NSNumber numberWithBool:outline] forKey:@"OUTLINE"];
        [cellEntry setValue:[NSNumber numberWithInteger:0] forKey:@"ELEVATION"];
        [cellEntry setValue:[NSNumber numberWithInteger:0] forKey:@"MOISTURE"];
        
        [dictionaryOfDictionariesFromCells setValue:cellEntry forKey:cellID];
    }
    
    return dictionaryOfDictionariesFromCells;
}

-(void)loadCellsDictionaryVanilla
{
    NSMutableDictionary *ocean = [self buildDictionaryFromCells:oceanNodes withType:@"OCEAN" andColor:[UIColor whiteColor] withOutline:NO];
    [mapCells addEntriesFromDictionary:ocean];
    
    NSMutableDictionary *coastWater = [self buildDictionaryFromCells:coastWaterNodes withType:@"COASTWATER" andColor:[UIColor whiteColor] withOutline:NO];
    [mapCells addEntriesFromDictionary:coastWater];
    
    NSMutableDictionary *coastLines = [self buildDictionaryFromCells:coastlineCells withType:@"COASTLINES" andColor:[UIColor whiteColor] withOutline:NO];
    [mapCells addEntriesFromDictionary:coastLines];
    
    //    NSMutableDictionary *lowTerrain = [self buildDictionaryFromCells:lowTerrainCells withType:@"LOWTERRAIN" andColor:[UIColor moneyGreenColor] withOutline:YES];
    //    [mapCells addEntriesFromDictionary:lowTerrain];
    
    NSMutableDictionary *island = [self buildDictionaryFromCells:islandCells withType:@"ISLAND" andColor:[UIColor whiteColor] withOutline:YES];
    [mapCells addEntriesFromDictionary:island];

}

-(void)addCellsToCellDictionary
{
    NSMutableDictionary *ocean = [self buildDictionaryFromCells:oceanNodes withType:@"OCEAN" andColor:[UIColor blueberryColor] withOutline:NO];
    [mapCells addEntriesFromDictionary:ocean];
    
    NSMutableDictionary *coastWater = [self buildDictionaryFromCells:coastWaterNodes withType:@"COASTWATER" andColor:[UIColor waveColor] withOutline:NO];
    [mapCells addEntriesFromDictionary:coastWater];
    
    NSMutableDictionary *coastLines = [self buildDictionaryFromCells:coastlineCells withType:@"COASTLINES" andColor:[UIColor sandColor] withOutline:NO];
    [mapCells addEntriesFromDictionary:coastLines];
    
//    NSMutableDictionary *lowTerrain = [self buildDictionaryFromCells:lowTerrainCells withType:@"LOWTERRAIN" andColor:[UIColor moneyGreenColor] withOutline:YES];
//    [mapCells addEntriesFromDictionary:lowTerrain];
    
    NSMutableDictionary *island = [self buildDictionaryFromCells:islandCells withType:@"ISLAND" andColor:[UIColor moneyGreenColor] withOutline:YES];
    [mapCells addEntriesFromDictionary:island];
}

-(VoronoiCell*)cellForID:(NSString*)stringID
{
    return [[mapCells objectForKey:stringID] objectForKey:stringID];
}

-(void)growRegion:(CGPoint)region withColor:(UIColor*)regionColor
{
    NSMutableArray *distanceArray = [[NSMutableArray alloc]init];
    NSMutableArray *closestCells = [[NSMutableArray alloc]init];
    
    for (VoronoiCell *islandCell in islandCells) {
        
        CGFloat distance = PointDistanceFromPoint(islandCell.centroid, region);
        
        if (distance > 0.0f) {
            [distanceArray addObject:[NSNumber numberWithFloat:distance]];
        }
    }
    
    for (int x=0; x<4; x++) {
        NSInteger closestIndex = [self indexOfLowest:distanceArray];
        VoronoiCell *closestCell = [islandCells objectAtIndex:closestIndex];
        NSString *stringID = [self generateIDForCellFromCentroid:closestCell.centroid];
        //        NSLog(@"stringID: %@",stringID);
        [closestCells addObject:stringID];
        [distanceArray removeObjectAtIndex:closestIndex];
    }
    
    for (NSString *stringID in closestCells) {
        [self setColor:regionColor forCellID:stringID];
    }
    
    
}

-(void)clumpRegion:(CGPoint)regionCentriod withColor:(UIColor*)color
{
    NSMutableArray *clumpCells = [[NSMutableArray alloc]init];
    
    NSArray *nodes =  [self cellForID:[self generateIDForCellFromCentroid:regionCentriod]].nodes;
    
    for (NSValue *nodeValue in nodes) {
        NSArray *cellsTouching =  [self cellsTouchingNode:[nodeValue CGPointValue]];
        [clumpCells addObjectsFromArray:cellsTouching];
    }
    
    for (VoronoiCell *cell in clumpCells) {
        NSString *stringID = [self generateIDForCellFromCentroid:cell.centroid];
        [self setColor:color forCellID:stringID];
    }
}

-(void)clumpRegion:(CGPoint)regionCentriod withColor:(UIColor*)color byAmount:(CGFloat)amount
{
    NSMutableArray *clumpCells = [[NSMutableArray alloc]init];
    NSString *stringID = [self generateIDForCellFromCentroid:regionCentriod];
    
    VoronoiCell *cell = [self cellForID:stringID];
    NSArray *nodes =  cell.nodes;
    
    CGFloat nodeCount = (amount * nodes.count) + 0.5f;
    NSNumber *nodeCountNumber = [NSNumber numberWithFloat:nodeCount];
    NSUInteger nodeCountInt = [nodeCountNumber unsignedIntegerValue];
    
    for (int x=0; x < nodeCountInt; x++)
    {
        CGPoint point = [[nodes objectAtIndex:x] CGPointValue];
        NSArray *cellsTouching =  [self cellsTouchingNode:point];
        [clumpCells addObjectsFromArray:cellsTouching];
        
    }
    
    for (VoronoiCell *cell in clumpCells) {
        NSString *checkString = [self generateIDForCellFromCentroid:regionCentriod];
        NSString *stringID = [self generateIDForCellFromCentroid:cell.centroid];
        UIColor *darkerColor = [self darkenColor:color amount:0.05];
        if (![checkString isEqualToString:stringID]) {
            [self setColor:darkerColor forCellID:stringID];
        }
    }
}




-(NSInteger)farthestNodeToPoint:(CGPoint)toPoint from:(NSArray*)nodes
{
    NSMutableArray *distanceArray = [[NSMutableArray alloc]init];
    
    for (NSValue *nodeValue in nodes) {
        CGPoint point = [nodeValue CGPointValue];
        CGFloat length =  PointDistanceFromPoint(point, toPoint);
        NSNumber *lengthNum = [NSNumber numberWithFloat:length];
        [distanceArray addObject:lengthNum];
    }
    return [self indexOfHighest:distanceArray];
}



-(NSInteger)closestNodeToPoint:(CGPoint)toPoint from:(NSArray*)nodes
{
    NSMutableArray *distanceArray = [[NSMutableArray alloc]init];
    
    for (NSValue *nodeValue in nodes) {
        CGPoint point = [nodeValue CGPointValue];
        CGFloat length =  PointDistanceFromPoint(point, toPoint);
        NSNumber *lengthNum = [NSNumber numberWithFloat:length];
        [distanceArray addObject:lengthNum];
    }
    return [self indexOfLowest:distanceArray];
}

-(NSInteger)closestNodeToCenter:(NSArray*)nodes
{
    NSMutableArray *distanceArray = [[NSMutableArray alloc]init];
    
    for (NSValue *nodeValue in nodes) {
        CGPoint point = [nodeValue CGPointValue];
        CGFloat length =  PointDistanceFromPoint(point, centerP);
        NSNumber *lengthNum = [NSNumber numberWithFloat:length];
        [distanceArray addObject:lengthNum];
    }
    return [self indexOfLowest:distanceArray];
}

-(NSInteger)farthestNodeFromCenter:(NSArray*)nodes
{
    NSMutableArray *distanceArray = [[NSMutableArray alloc]init];
    
    for (NSValue *nodeValue in nodes) {
        CGPoint point = [nodeValue CGPointValue];
        CGFloat length =  PointDistanceFromPoint(point, centerP);
        NSNumber *lengthNum = [NSNumber numberWithFloat:length];
        [distanceArray addObject:lengthNum];
    }
    return [self indexOfHighest:distanceArray];
}


// Find Cell at Node
-(NSArray*)cellsTouchingNode:(CGPoint)node
{
    NSMutableArray *cellsArray = [[NSMutableArray alloc]init];
    
    NSDictionary *voronoiCells = [self.triangulation voronoiCells];
    
    for (VoronoiCell *cell in [voronoiCells objectEnumerator])
    {
        NSArray *cellNodes = cell.nodes;
        
        for (NSValue *value in cellNodes)
        {
            CGPoint point = [value CGPointValue];
            
            if (CGPointEqualToPoint(point, node))
            {
                [cellsArray addObject:cell];
            }
        }
    }
    
    return cellsArray;
}

#pragma mark - ISLAND DICTIONARY

// grab the node point and find the segment by looking up the next point and finding it by getting the segment serial number.

// need node to node direction
// flow needs to be based off of distance from the ocean, and mountin point(s)

// ** maybe find the shortest distance between any node and ocean node




-(void)calculateDistanceFromOceanNode
{
    NSArray *borderNodes = [self sharedNodesFromGroupA:coastlineCells andGroupB:coastWaterNodes];
    
    for (id key in [islandNodes allKeys])
    {
        CGPoint point = [[[islandNodes objectForKey:key] objectForKey:@"CGPOINT_VALUE"] CGPointValue];
        NSInteger index = [self closestIndexFromNodes:borderNodes toPoint:point];
        NSValue *borderNodeValue = [borderNodes objectAtIndex:index];
        CGFloat distance = PointDistanceFromPoint([borderNodeValue CGPointValue], point);
        //
        [[islandNodes objectForKey:key] setValue:[NSNumber numberWithFloat:distance] forKey:@"OCEAN_DISTANCE"];
        [[islandNodes objectForKey:key] setValue:borderNodeValue forKey:@"NEAREST_OCEAN_NODE"];
    }
    
}

-(void)findDistanceNumbers
{
    for (id key in [islandNodes allKeys])
    {
        CGFloat oceanDistance = [[[islandNodes objectForKey:key] objectForKey:@"OCEAN_DISTANCE"] floatValue];
        CGFloat mountainDistance = [[[islandNodes objectForKey:key] objectForKey:@"MOUNTAIN_DISTANCE"] floatValue];
        
        CGFloat averageSegmentLength = [self averageIslandSegmentLength];
        CGFloat oceanNumber = oceanDistance/averageSegmentLength;
        CGFloat mountainNumber = mountainDistance/averageSegmentLength;
        
        [[islandNodes objectForKey:key] setValue:[NSNumber numberWithFloat:oceanNumber] forKey:@"O_NUMBER"];
        [[islandNodes objectForKey:key] setValue:[NSNumber numberWithFloat:mountainNumber] forKey:@"M_NUMBER"];
        
    }
    
}

-(void)calculateDistanceFromHighestNode:(CGPoint)mountainPoint
{
    for (id key in [islandNodes allKeys])
    {
        CGPoint point = [[[islandNodes objectForKey:key] objectForKey:@"CGPOINT_VALUE"] CGPointValue];
        CGFloat distance = PointDistanceFromPoint(point, mountainPoint);
        [[islandNodes objectForKey:key] setValue:[NSNumber numberWithFloat:distance] forKey:@"MOUNTAIN_DISTANCE"];
        
    }
}

-(CGPoint)findAndReturnHighestNode
{
    CGPoint highestNode = CGPointZero;
    
    for (id key in [islandNodes allKeys])
    {
        if ([[[islandNodes objectForKey:key] valueForKey:@"MOUNTAIN"] boolValue] == YES)
        {
            highestNode = [[[islandNodes objectForKey:key] objectForKey:@"CGPOINT_VALUE"] CGPointValue];
        }
    }
    
    return highestNode;
}

-(void)setMountainNodeFromCentroid:(CGPoint)mountainCentroid
{
    if (!firstMountainPointMadeYet == YES)
    {
        NSString *stringID = [self generateIDForCellFromCentroid:mountainCentroid];
        VoronoiCell *mountainCell = [self cellForID:stringID];
        NSArray *mountainNodes = mountainCell.nodes;
        
        NSInteger mountainIndex = [self randomNumberBetweenMin:0 andMax:mountainNodes.count-1];
        NSValue *mountainValue = [mountainNodes objectAtIndex:mountainIndex];
        
        CGPoint mountainPoint = [mountainValue CGPointValue];
        
        [self calculateDistanceFromHighestNode:mountainPoint];
        //
        [self findDistanceNumbers];
        //
        NSString *mountainNodeID = [self generateNodeIDFromNode:mountainPoint];
        
        [[islandNodes objectForKey:mountainNodeID] setValue:[NSNumber numberWithBool:YES] forKey:@"MOUNTAIN"];
        
    }
    
    firstMountainPointMadeYet = YES;
}


-(NSMutableDictionary*)buildIslansdNodeDictionary
{
    
    NSMutableDictionary *islandNodeDictionary = [[NSMutableDictionary alloc]init];
    
    NSMutableArray *islandArray = [[NSMutableArray alloc]init];
    
    [islandArray addObjectsFromArray:islandCells];
    [islandArray addObjectsFromArray:coastlineCells];
    
    for (VoronoiCell *cell in islandArray)
    {
        
        NSString *cellID = [self generateIDForCellFromCentroid:cell.centroid];
        
        for (NSValue *nodeValue in cell.nodes)
        {
            NSString *nodeID = [self generateNodeIDFromNode:[nodeValue CGPointValue]];
            
            NSMutableDictionary *islandNodeEntry = [[NSMutableDictionary alloc]init];
            
            [islandNodeEntry setValue:nodeID forKey:@"NODE_ID"];
            [islandNodeEntry setValue:nodeValue forKey:@"CGPOINT_VALUE"];
            [islandNodeEntry setValue:cellID forKey:@"CELL"];
            [islandNodeEntry setValue:[NSValue valueWithCGPoint:CGPointZero] forKey:@"FLOW_TO_NODE"];
            [islandNodeEntry setValue:[NSNumber numberWithInteger:0] forKey:@"ELEVATION"];
            [islandNodeEntry setValue:[NSNumber numberWithInteger:0] forKey:@"MOISTURE"];
            [islandNodeEntry setValue:[NSNumber numberWithFloat:0.0f] forKey:@"OCEAN_DISTANCE"];
            [islandNodeEntry setValue:[NSNumber numberWithFloat:0.0f] forKey:@"MOUNTAIN_DISTANCE"];
            [islandNodeEntry setValue:[NSNumber numberWithFloat:0.0f] forKey:@"O_NUMBER"];
            [islandNodeEntry setValue:[NSNumber numberWithFloat:0.0f] forKey:@"M_NUMBER"];
            [islandNodeEntry setValue:[NSNumber numberWithBool:NO] forKey:@"MOUNTAIN"];
            [islandNodeEntry setValue:@"ClosestOceanNodeID" forKey:@"NEAREST_OCEAN_NODE"];
            
            [islandNodeDictionary setValue:islandNodeEntry forKey:nodeID];
            
        }
        
        
    }
    
    NSLog(@"IslandNodeDictionary Count: %li",(long)islandNodeDictionary.count);
    
    return islandNodeDictionary;
}

-(CGPoint)nodeFromNodeID:(NSString*)nodeID
{
    CGPoint nodePoint = [[[islandNodes objectForKey:nodeID] objectForKey:@"CGPOINT_VALUE"] CGPointValue];
    return nodePoint;
}

-(void)flowToNode:(CGPoint)flowTo forNode:(CGPoint)node
{
    NSString *nodeID = [self generateNodeIDFromNode:node];
    
    [[islandNodes objectForKey:nodeID] setValue:[NSValue valueWithCGPoint:flowTo] forKey:@"FLOW_TO_NODE"];
}




#pragma mark - ISLAND PATHS

-(void)evaluatePaths
{
    
    islandNodes = [self buildIslansdNodeDictionary];
    
    //   NSArray *islandPaths = [self returnIslandPaths];
    
//    CGPoint highestNode = [self findAndReturnHighestNode];
//    
//    // Stock islandSegmentPaths
//    [self definePathDirectionForPaths:islandPaths from:highestNode];
    
    NSLog(@"Island Path Segments:%lu",(unsigned long)islandSegmentPaths.count);
    
    
    
}

-(void)addPathToDictionary:(UIBezierPath*)path from:(CGPoint)fromPoint to:(CGPoint)toPoint
{
    [self flowToNode:toPoint forNode:fromPoint];
    
    NSMutableDictionary *addedPath = [[NSMutableDictionary alloc]init];
    NSString *pathID = [self generatePathIDFrom:fromPoint to:toPoint];
    [addedPath setObject:[NSValue valueWithCGPoint:fromPoint] forKey:@"START_NODE"];
    [addedPath setObject:[NSValue valueWithCGPoint:toPoint] forKey:@"END_NODE"];
    [addedPath setObject:pathID forKey:@"PATH_ID"];
    [addedPath setObject:path forKey:@"PATH"];
    //
    [islandSegmentPaths setObject:addedPath forKey:pathID];
}

-(void)definePathDirectionForPaths:(NSArray*)paths from:(CGPoint)highestPoint
{
    for (UIBezierPath *path in paths) {
        
        NSString *onePointPathString = [self generatePathIDFromOnePoint:path.currentPoint];
        
        for (NSString *segmentID in segmentIDArray) {
            
            if ([segmentID hasPrefix:onePointPathString]) {
                
                CGPoint firstP = [self firstPointFromSegmentPathID:segmentID];
                CGPoint secondP = [self secondPointFromSegmentPathID:segmentID];
                
                CGFloat firstDistance = PointDistanceFromPoint(firstP, highestPoint);
                CGFloat secondDistance = PointDistanceFromPoint(secondP, highestPoint);
                
                if (firstDistance > secondDistance)
                {
                    [self addPathToDictionary:path from:secondP to:firstP];
                }
                else
                {
                    [self addPathToDictionary:path from:firstP to:secondP];
                }
            }
        }
    }
}

-(CGPoint)firstPointFromSegmentPathID:(NSString*)segmentID
{
    NSRange segmentRange = [segmentID rangeOfString:@":"];
    NSString *firstPointString = [segmentID substringToIndex:segmentRange.location];
    
    NSRange firstPointRange = [firstPointString rangeOfString:@"."];
    NSString *stringX = [firstPointString substringToIndex:firstPointRange.location];
    NSString *stringY = [firstPointString substringFromIndex:firstPointRange.location+1];
    
    CGPoint nodePoint = CGPointMake([stringX floatValue], [stringY floatValue]);
    return nodePoint;
    
}


-(CGPoint)secondPointFromSegmentPathID:(NSString*)segmentID
{
    NSRange segmentRange = [segmentID rangeOfString:@":"];
    NSString *secondPointString = [segmentID substringFromIndex:segmentRange.location+1];
    
    NSRange secondPointRange = [secondPointString rangeOfString:@"."];
    NSString *stringX = [secondPointString substringToIndex:secondPointRange.location];
    NSString *stringY = [secondPointString substringFromIndex:secondPointRange.location+1];
    
    CGPoint nodePoint = CGPointMake([stringX floatValue], [stringY floatValue]);
   
    
    return nodePoint;
}


-(NSArray*)returnInnerIslandNodes
{
    NSMutableArray *returnArray = [[NSMutableArray alloc]init];
    
    for (VoronoiCell *cell in islandCells) {
        
        for (NSValue *value in cell.nodes) {
            [returnArray addObject:value];
        }
        
    }
    
    return returnArray;
}

-(NSMutableArray*)returnIslandNodes
{
    NSMutableArray *islandNodeArray = [[NSMutableArray alloc]init];
    
    for (id key in [islandNodes allKeys])
    {
        [islandNodeArray addObject:[[islandNodes objectForKey:key] objectForKey:@"CGPOINT_VALUE"]];
    }
    
    return islandNodeArray;
}

-(NSArray*)returnIslandPaths
{
    NSMutableArray *islandPaths = [[NSMutableArray alloc]init];
    
    for (id key in [mapCells allKeys])
    {
        if ([[[mapCells objectForKey:key] objectForKey:@"TYPE"] isEqualToString:@"ISLAND"])
        {
            [islandPaths addObject:[[mapCells objectForKey:key] valueForKey:@"PATH"]];
        }
        else if ([[[mapCells objectForKey:key] objectForKey:@"TYPE"] isEqualToString:@"COASTLINES"])
        {
            [islandPaths addObject:[[mapCells objectForKey:key] valueForKey:@"PATH"]];
        }
        
    }
    
    return islandPaths;
    
}

-(CGFloat)averageIslandSegmentLength
{
    NSMutableArray *lengthArray = [[NSMutableArray alloc]init];
    
    for (id key in [islandSegmentPaths allKeys]) {
        
        CGPoint first = [self firstPointFromSegmentPathID:key];
        CGPoint second = [self secondPointFromSegmentPathID:key];
        CGFloat distance = PointDistanceFromPoint(first, second);
        
        if (distance < 100.0f && distance > 1.0f) {
            [lengthArray addObject:[NSNumber numberWithFloat:distance]];
        }
    }
    
    CGFloat avg = [[lengthArray valueForKeyPath:@"@avg.floatValue"] floatValue];
    
    return avg;
}

-(CGPoint)fixPoint:(CGPoint)point
{
    NSNumber *numberX = [NSNumber numberWithFloat:point.x];
    NSNumber *numberY = [NSNumber numberWithFloat:point.y];
    
    NSInteger intX = [numberX integerValue];
    NSInteger intY = [numberY integerValue];

    CGPoint fixedPoint = CGPointMake(intX, intY);
    
    NSLog(@"fixedPoint : %@",NSStringFromCGPoint(fixedPoint));
    
    return fixedPoint;
}

-(CGPoint)fixPointForEdge:(CGPoint)pointToFix
{
    CGPoint fixedPoint = CGPointMake(pointToFix.x, pointToFix.y);
    
    int c = 0;
    
    
    if (pointToFix.x < 1.0F) {
        c++;
        NSLog(@"pointToFix.x: %f",pointToFix.x);
       fixedPoint = CGPointMake(0, pointToFix.y);
    }
    
    if (pointToFix.y < 1.0F) {
        c++;
        NSLog(@"pointToFix.y: %f",pointToFix.y);
        fixedPoint = CGPointMake(pointToFix.x, 0);
    }
    
    if (fixedPoint.x > _frame.size.width) {
        c++;
        NSLog(@"fixedPoint.x: %f",fixedPoint.x);
        fixedPoint = CGPointMake(_frame.size.width, fixedPoint.y);
    }
    
    if (fixedPoint.y > _frame.size.height) {
         c++;
        NSLog(@"fixedPoint.y: %f",fixedPoint.y);
        fixedPoint = CGPointMake(fixedPoint.x, _frame.size.height);
    }
    
    
    if (c > 0) {
        NSLog(@"c: %lu",(unsigned long)c);
        
        if (![_frameNodes containsObject:[NSValue valueWithCGPoint:fixedPoint]]) {
            [_frameNodes addObject:[NSValue valueWithCGPoint:fixedPoint]];
        }
    }
    
    
    

    
    return fixedPoint;
    
}

#pragma mark - EDGE START

-(NSMutableArray*)returnPathsConnectedToNode:(CGPoint)node
{
    NSDictionary *mapPathDict = self.mapPaths;
    ////
    NSMutableArray *pathIDsTouchingNode = [[NSMutableArray alloc]init];
    
    NSString *onePointPathID = [self generatePathIDFromOnePoint:node];
    
    for (NSString *segmentID in segmentIDArray) {
        
        if ([segmentID hasPrefix:onePointPathID]) {
            [pathIDsTouchingNode addObject:segmentID];
        }
    }
    
    NSMutableArray *pathsTouchingNode = [[NSMutableArray alloc]init];
    
    for (NSString *segmentID in pathIDsTouchingNode) {
        UIBezierPath *path = [[mapPathDict objectForKey:segmentID] valueForKey:@"PATH"];
        [pathsTouchingNode addObject:path];
    }
    
    return pathsTouchingNode;


    
    
    ////
//    NSMutableArray *pathsConnected = [[NSMutableArray alloc]init];
//  
//    CGPoint fixedNode = [self fixPoint:node];
//    
//    
//    
//    for (id key in mapPathDict) {
//        
//        CGPoint startNode = [[[mapPathDict objectForKey:key] valueForKey:@"STARTNODE"] CGPointValue];
//        CGPoint endNode = [[[mapPathDict objectForKey:key] valueForKey:@"ENDNODE"] CGPointValue];
//        
//        if (CGPointEqualToPoint(fixedNode, startNode)) {
//            //NSLog(@"They are Equal %@ : %@",NSStringFromCGPoint(fixedNode),NSStringFromCGPoint(startNode));
//            UIBezierPath *connectedPath = [[mapPathDict objectForKey:key] valueForKey:@"PATH"];
//            if (![pathsConnected containsObject:connectedPath]) {
//                 [pathsConnected addObject:connectedPath];
//            }
//           
//        }
//        
//        if (CGPointEqualToPoint(fixedNode, endNode)) {
//            // NSLog(@"They are Equal %@ : %@",NSStringFromCGPoint(fixedNode),NSStringFromCGPoint(endNode));
//            UIBezierPath *connectedPath = [[mapPathDict objectForKey:key] valueForKey:@"PATH"];
//            if (![pathsConnected containsObject:connectedPath]) {
//                [pathsConnected addObject:connectedPath];
//            }
//
//        }
//    }
//
//    //NSLog(@"pathsConnected.count: %lu",(unsigned long)pathsConnected.count);
//    
//    return pathsConnected;
}

-(NSArray*)segmentsFromNode:(CGPoint)node
{
    
    
   
    NSMutableArray *segments = [[NSMutableArray alloc]init];
    NSMutableArray *segmentsIDs = [[NSMutableArray alloc]init];
    
    NSString *onePointPathID = [self generatePathIDFromOnePoint:node];
    
    
    for (NSString *segmentID in segmentIDArray) {
        
        if ([segmentID hasPrefix:onePointPathID]) {
            // NSLog(@"segmentID:%@",segmentID);
            
            [segmentsIDs addObject:segmentID];
        }
    }
    
    for (NSString *segmentIDTouchingNode in segmentsIDs) {
        
        UIBezierPath *returnedPath = [self returnPathFromID:segmentIDTouchingNode];
        
        [segments addObject:returnedPath];
    }
    
    UIBezierPath *testPath = [segments firstObject];
    NSString *returnedTestString =  [self returnPathIDFromPath:testPath];
    NSLog(@"returnedTestString:%@",returnedTestString);

    
    return segments;
}

-(CGPoint)closestIslandNodeFromPoint:(CGPoint)fromPoint
{
    NSMutableArray *allIslandNodes = [[NSMutableArray alloc]init];
    
    for (id key in [mapCells allKeys])
    {
        if ([[[mapCells objectForKey:key] objectForKey:@"TYPE"] isEqualToString:@"ISLAND"])
        {
            NSArray *nodes = [[mapCells objectForKey:key] objectForKey:@"NODES"];
            [allIslandNodes addObjectsFromArray:nodes];
        }
    }
    
    CGPoint closestIslandNode = [self closestPointFromNodes:allIslandNodes toPoint:fromPoint];

    return closestIslandNode;
}

-(void)findEdgeStart
{
    NSLog(@"Start Find Edge Start");
    
    NSMutableArray *allIslandNodes = [[NSMutableArray alloc]init];

    
    for (id key in [mapCells allKeys])
    {
        if ([[[mapCells objectForKey:key] objectForKey:@"TYPE"] isEqualToString:@"ISLAND"])
        {
            NSArray *nodes = [[mapCells objectForKey:key] objectForKey:@"NODES"];
            [allIslandNodes addObjectsFromArray:nodes];
        }
    }
    
    NSLog(@"allIslandNodes.count: %lu",(unsigned long)allIslandNodes.count);
    

    
    
    //NSArray *islandNodesArray = [self returnIslandNodes];
    
    NSArray *edgeNodes = [self getEdgePointsFromNodes:allIslandNodes ofRect:_frame];
    
    _frameNodes = [NSMutableArray arrayWithArray:edgeNodes];
   
}

-(NSArray*)getEdgePointsFromNodes:(NSArray*)sourceNodes ofRect:(CGRect)sourceRect
{
    CGPoint TL = [self closestPointFromNodes:sourceNodes toPoint:RectGetTopLeft(sourceRect)];
    
    CGPoint MT = [self closestPointFromNodes:sourceNodes toPoint:RectGetMidTop(sourceRect)];
    
    CGPoint TR = [self closestPointFromNodes:sourceNodes toPoint:RectGetTopRight(sourceRect)];
    
    CGPoint MR = [self closestPointFromNodes:sourceNodes toPoint:RectGetMidRight(sourceRect)];
    
    CGPoint BR = [self closestPointFromNodes:sourceNodes toPoint:RectGetBottomRight(sourceRect)];
    
    CGPoint MB = [self closestPointFromNodes:sourceNodes toPoint:RectGetMidBottom(sourceRect)];
    
    CGPoint BL = [self closestPointFromNodes:sourceNodes toPoint:RectGetBottomLeft(sourceRect)];
    
    CGPoint ML = [self closestPointFromNodes:sourceNodes toPoint:RectGetMidLeft(sourceRect)];
    
    return @[[NSValue valueWithCGPoint:TL],
             [NSValue valueWithCGPoint:MT],
             [NSValue valueWithCGPoint:TR],
             [NSValue valueWithCGPoint:MR],
             [NSValue valueWithCGPoint:BR],
             [NSValue valueWithCGPoint:MB],
             [NSValue valueWithCGPoint:BL],
             [NSValue valueWithCGPoint:ML]];
      
}



#pragma mark - EDGE SEGMENTS

-(NSArray*)lineSegmentsTouchingTheEdge
{
    NSMutableArray *lineSegmentsTouchingEdge = [[NSMutableArray alloc]init];
    
    for (id key in [mapCells allKeys])
    {
        NSArray *nodes = [[mapCells objectForKey:key] objectForKey:@"NODES"];
    
        for (NSValue *nodeValue in nodes) {
            
            CGPoint nodePoint = [self fixPointForEdge:[nodeValue CGPointValue]];
        }
    }
    
    return lineSegmentsTouchingEdge;
}



#pragma mark - CELL DICTIONARY

-(NSString*)generateIDForCellFromCentroid:(CGPoint)point
{
    CGFloat px =  point.x;
    NSNumber *pxNumber = [NSNumber numberWithFloat:px];
    CGFloat py =  point.y;
    NSNumber *pyNumber = [NSNumber numberWithFloat:py];
    
    NSString *stringID = [NSString stringWithFormat:@"C%lu%lu",(unsigned long)[pxNumber integerValue],(unsigned long)[pyNumber integerValue]];
    
    return stringID;
    
}

-(UIBezierPath*)generateStraightPathFromCellNodes:(NSArray*)nodes
{
    UIBezierPath *cellPath = [UIBezierPath bezierPath];
    NSMutableArray *segments = [[NSMutableArray alloc]init];
    
    for (int x=0; x<nodes.count-1; x++)
    {
        CGPoint ptA = [[nodes objectAtIndex:x] CGPointValue];
        CGPoint ptB = [[nodes objectAtIndex:x+1] CGPointValue];
        
        if (![self segmentBeenDrawn:ptA to:ptB])
        {
            // If Segment hasn't Been Drawn yet then we need to add it to the SegmentIDArray and also store it in the Master Path Dictionary
            
            NSString *segmentIDString = [self generatePathIDFrom:ptA to:ptB];
            NSString *reversedSegmentIDString = [self generatePathIDFrom:ptB to:ptA];
            
            [segmentIDArray addObject:reversedSegmentIDString];
            [segmentIDArray addObject:segmentIDString];
            
            NSArray *pointsForSegment = @[[NSValue valueWithCGPoint:ptA],[NSValue valueWithCGPoint:ptB]];
            [segments addObjectsFromArray:pointsForSegment];
            
            NSArray *reversedPointsForSegment =  @[[NSValue valueWithCGPoint:ptB],[NSValue valueWithCGPoint:ptA]];
            
            [masterPaths setValue:pointsForSegment forKey:segmentIDString];
            [masterPaths setValue:reversedPointsForSegment forKey:reversedSegmentIDString];
        }
        else
        {
            // If Its already been drawn then get That segment to claim it as part of the Cell's Path
            NSString *askingID = [self generatePathIDFrom:ptA to:ptB];
            NSArray *pointsForSegmentAlreadyMade = [masterPaths objectForKey:askingID];
            [segments addObjectsFromArray:pointsForSegmentAlreadyMade];
            
        }
    }
    
    CGPoint firstObject = [[nodes firstObject] CGPointValue];
    CGPoint lastObject = [[nodes lastObject] CGPointValue];
    
    if (![self segmentBeenDrawn:firstObject to:lastObject])
    {
        // If Segment hasn't Been Drawn yet then we need to add it to the SegmentIDArray and also store it in the Master Path Dictionary
        
        NSString *segmentIDString = [self generatePathIDFrom:firstObject to:lastObject];
        NSString *reversedSegmentIDString = [self generatePathIDFrom:lastObject to:firstObject];
        
        [segmentIDArray addObject:reversedSegmentIDString];
        [segmentIDArray addObject:segmentIDString];
        
        NSArray *pointsForSegment = @[[NSValue valueWithCGPoint:firstObject],[NSValue valueWithCGPoint:lastObject]];
        [segments addObjectsFromArray:pointsForSegment];
        
        NSArray *reversedPointsForSegment =  @[[NSValue valueWithCGPoint:lastObject],[NSValue valueWithCGPoint:firstObject]];
        
        [masterPaths setValue:pointsForSegment forKey:segmentIDString];
        [masterPaths setValue:reversedPointsForSegment forKey:reversedSegmentIDString];
    }
    else
    {
        // If Its already been drawn then get That segment to claim it as part of the Cell's Path
        NSString *askingID = [self generatePathIDFrom:firstObject to:lastObject];
        NSArray *pointsForSegmentAlreadyMade = [masterPaths objectForKey:askingID];
        [segments addObjectsFromArray:pointsForSegmentAlreadyMade];
        
    }
    
    [cellPath moveToPoint:[[segments firstObject] CGPointValue]];
    
    for (int x=0; x<segments.count; x++)
    {
        NSValue *value = [segments objectAtIndex:x];
        CGPoint valuePoint = [value CGPointValue];
        [cellPath addLineToPoint:valuePoint];
    }
    
    [cellPath closePath];
    
    cellPath.lineWidth = 0.50;
    
    return cellPath;
}

-(UIBezierPath*)generateJaggedPathFromCellNodes:(NSArray*)nodes
{
    UIBezierPath *cellPath = [UIBezierPath bezierPath];
    NSMutableArray *segments = [[NSMutableArray alloc]init];
    
    CGFloat intensity = 0.45f;
    
    for (int x=0; x<nodes.count-1; x++)
    {
        CGPoint ptA = [[nodes objectAtIndex:x] CGPointValue];
        CGPoint ptB = [[nodes objectAtIndex:x+1] CGPointValue];
        
        if (![self segmentBeenDrawn:ptA to:ptB])
        {
            NSArray *pointsForSegment = [self randomLineNodesFrom:ptA to:ptB intensity:intensity];
            [segments addObjectsFromArray:pointsForSegment];
        }
        else
        {
            NSString *askingID = [self generatePathIDFrom:ptA to:ptB];
            NSArray *pointsForSegmentAlreadyMade = [masterPaths objectForKey:askingID];
            [segments addObjectsFromArray:pointsForSegmentAlreadyMade];
        }
        
    }
    
    CGPoint firstObject = [[nodes firstObject] CGPointValue];
    CGPoint lastObject = [[nodes lastObject] CGPointValue];
    
    if (![self segmentBeenDrawn:firstObject to:lastObject])
    {
        NSArray *pointsForSegment = [self randomLineNodesFrom:firstObject to:lastObject intensity:intensity];
        [segments addObjectsFromArray:pointsForSegment];
    }
    else
    {
        NSString *askingID = [self generatePathIDFrom:firstObject to:lastObject];
        NSArray *pointsForSegmentAlreadyMade = [masterPaths objectForKey:askingID];
        [segments addObjectsFromArray:pointsForSegmentAlreadyMade];
        
    }
    
    
    [cellPath moveToPoint:[[segments firstObject] CGPointValue]];
    
    for (int x=0; x<segments.count; x++)
    {
        NSValue *value = [segments objectAtIndex:x];
        CGPoint valuePoint = [value CGPointValue];
        [cellPath addLineToPoint:valuePoint];
    }
    
    [cellPath closePath];
    
    cellPath.lineWidth = 0.50;
    
    return cellPath;
}

-(UIBezierPath*)returnJaggedPathFromNodes:(NSArray*)nodes
{
    UIBezierPath *cellPath = [UIBezierPath bezierPath];
    NSMutableArray *segments = [[NSMutableArray alloc]init];
    
    CGFloat intensity = 0.45f;
    
    for (int x=0; x<nodes.count-1; x++)
    {
        CGPoint ptA = [[nodes objectAtIndex:x] CGPointValue];
        CGPoint ptB = [[nodes objectAtIndex:x+1] CGPointValue];
        
        if (![self segmentBeenDrawn:ptA to:ptB])
        {
            NSArray *pointsForSegment = [self randomLineNodesFrom:ptA to:ptB intensity:intensity];
            [segments addObjectsFromArray:pointsForSegment];
        }
        else
        {
            NSString *askingID = [self generatePathIDFrom:ptA to:ptB];
            NSArray *pointsForSegmentAlreadyMade = [masterPaths objectForKey:askingID];
            [segments addObjectsFromArray:pointsForSegmentAlreadyMade];
        }
        
    }
    
    [cellPath moveToPoint:[[segments firstObject] CGPointValue]];
    
    cellPath.lineWidth = 1.0;
    
    //segments.count / 100;
    
    CGFloat lineW = 0.50f;
    CGFloat scale = 0.010f;
    
    //NSLog(@"segments.count: %lu",(unsigned long)segments.count);
    
    
    for (int x=0; x<segments.count; x++)
    {
        lineW += scale;
        //NSLog(@"lineW: %f",lineW);
        
        NSValue *value = [segments objectAtIndex:x];
        CGPoint valuePoint = [value CGPointValue];
        //cellPath.lineWidth = lineW;
        [cellPath addLineToPoint:valuePoint];
    }
    
    
    
    return cellPath;
}




#pragma mark - UITILITES

-(void)paintPath:(UIBezierPath*)path color:(UIColor*)pathColor
{
    [pathColor setStroke];
    [path stroke];
}

-(CGPoint)randomPointInRect:(CGRect)rect
{
    CGPoint p = rect.origin;
    
    p.x += rect.size.width * (arc4random() / (float)0x100000000);
    p.y += rect.size.height * (arc4random() / (float)0x100000000);
    
    return p;
}


-(CGPoint)closestPointFromNodes:(NSArray*)nodes toPoint:(CGPoint)measurePoint
{
    NSMutableArray *distanceArray = [[NSMutableArray alloc]init];
    
    for (NSValue *value in nodes) {
        
        CGPoint nodePoint = [value CGPointValue];
        CGFloat distance = PointDistanceFromPoint(nodePoint, measurePoint);
        
        if (distance == 0) {
            distance = 100.0f;
        }
        [distanceArray addObject:[NSNumber numberWithFloat:distance]];
    }
    
    CGPoint closestPoint = [[nodes objectAtIndex:[self indexOfLowest:distanceArray]] CGPointValue];
    
    return closestPoint;
}



-(NSInteger)closestIndexFromNodes:(NSArray*)nodes toPoint:(CGPoint)measurePoint
{
    NSMutableArray *distanceArray = [[NSMutableArray alloc]init];
    
    for (NSValue *value in nodes) {
        
        CGPoint nodePoint = [value CGPointValue];
        CGFloat distance = PointDistanceFromPoint(nodePoint, measurePoint);
        
        if (distance == 0) {
            distance = 100.0f;
        }
        [distanceArray addObject:[NSNumber numberWithFloat:distance]];
    }
    
    return [self indexOfLowest:distanceArray];
}

//
-(NSInteger)closestCellIndex:(NSArray*)cellCenters toPoint:(CGPoint)destinationPoint
{
    NSMutableArray *distanceArray = [[NSMutableArray alloc]init];
    
    
    for (NSValue *value in cellCenters) {
        CGPoint cellCenter = [value CGPointValue];
        CGFloat distance = PointDistanceFromPoint(cellCenter, destinationPoint);
        [distanceArray addObject:[NSNumber numberWithFloat:distance]];
    }
    
    return [self indexOfLowest:distanceArray];
}

-(UIColor*)lightenColor:(UIColor*)color amount:(CGFloat)amount
{
    CGFloat hue, saturation, brightness, alpha;
    
    [color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    
    UIColor *lighterColor = [UIColor colorWithHue:hue saturation:saturation * (1.0f - amount) brightness:brightness * (1.0f + amount) alpha:alpha];
    
    return lighterColor;
}


-(UIColor*)darkenColor:(UIColor*)color amount:(CGFloat)amount
{
    CGFloat hue, saturation, brightness, alpha;
    
    [color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    
    UIColor *darkerColor = [UIColor colorWithHue:hue saturation:saturation * (1.0f + amount) brightness:brightness * (1.0f - amount) alpha:alpha];
    
    return darkerColor;
}

- (NSString *)stringFromColor:(UIColor *)color
{
    const size_t totalComponents = CGColorGetNumberOfComponents(color.CGColor);
    const CGFloat * components = CGColorGetComponents(color.CGColor);
    return [NSString stringWithFormat:@"#%02X%02X%02X",(int)(255 * components[MIN(0,totalComponents-2)]),(int)(255 * components[MIN(1,totalComponents-2)]),(int)(255 * components[MIN(2,totalComponents-2)])];
}



-(NSInteger)indexOfLowest:(NSArray*)array
{
    CGFloat min = [[array valueForKeyPath:@"@min.floatValue"] floatValue];
    NSInteger numberIndex = [array indexOfObject:[NSNumber numberWithFloat:min]];
    return numberIndex;
}


-(NSInteger)indexOfHighest:(NSArray*)array
{
    CGFloat max = [[array valueForKeyPath:@"@max.floatValue"] floatValue];
    NSInteger numberIndex = [array indexOfObject:[NSNumber numberWithFloat:max]];
    return numberIndex;
}

-(void)findMax
{
    NSArray *numberArray = [NSArray arrayWithObjects:[NSNumber numberWithInt:10], [NSNumber numberWithInt:20], [NSNumber numberWithInt:1000], nil];
    NSInteger highestNumber = 0;
    NSInteger numberIndex = 0;
    for (NSNumber *theNumber in numberArray)
    {
        if ([theNumber integerValue] > highestNumber) {
            highestNumber = [theNumber integerValue];
            numberIndex = [numberArray indexOfObject:theNumber];
        }
    }
    NSLog(@"Highest number: %li at index: %li", (long)highestNumber, (long)numberIndex);
}



-(CGPoint)pointForQuadrant:(NSInteger)quad
{
    CGPoint pointForQuadrant = CGPointZero;
    
    
    
    CGRect rect = _frame;
    
    if (quad == 0)
    {
        if (RANDOM_BOOL)
        {
            pointForQuadrant = CGPointMake(RectGetTopLeft(rect).x, arc4random_uniform((RectGetMidLeft(rect).y) - RectGetTopLeft(rect).y));
        }
        else
        {
            pointForQuadrant = CGPointMake(arc4random_uniform((RectGetMidTop(rect).x - RectGetTopLeft(rect).x)), RectGetTopLeft(rect).y);
        }
    }
    else if (quad == 1)
    {
        if (RANDOM_BOOL) {
            NSInteger Q1Y = [self randomNumberBetweenMin:RectGetTopRight(rect).y andMax:RectGetMidRight(rect).y];
            pointForQuadrant = CGPointMake( RectGetTopRight(rect).x,Q1Y);
        }
        else
        {
            NSInteger Q1X = [self randomNumberBetweenMin:RectGetMidTop(rect).x andMax:RectGetTopRight(rect).x];
            pointForQuadrant = CGPointMake(Q1X,RectGetTopRight(rect).y);
        }
    }
    else if (quad == 2)
    {
        if (RANDOM_BOOL) {
            NSInteger Q2Y = [self randomNumberBetweenMin:RectGetMidRight(rect).y andMax:RectGetBottomRight(rect).y];
            pointForQuadrant = CGPointMake( RectGetBottomRight(rect).x, Q2Y);
        }
        else
        {
            NSInteger Q2X = [self randomNumberBetweenMin:RectGetMidBottom(rect).x andMax:RectGetBottomRight(rect).x];
            pointForQuadrant = CGPointMake(Q2X,  RectGetBottomRight(rect).y);
        }
    }
    else if (quad == 3)
    {
        if (RANDOM_BOOL) {
            NSInteger Q3Y = [self randomNumberBetweenMin:RectGetMidLeft(rect).y andMax:RectGetBottomLeft(rect).y];
            pointForQuadrant = CGPointMake(RectGetBottomLeft(rect).x, Q3Y);
        }
        else
        {
            NSInteger Q3X = [self randomNumberBetweenMin:RectGetBottomLeft(rect).x andMax:RectGetMidBottom(rect).x];
            pointForQuadrant = CGPointMake(Q3X,  RectGetBottomLeft(rect).y);
        }
        
    }
    
    CGPoint center = RectGetCenter(rect);
    
    CGFloat returnAngle = [self pointPairToBearingDegrees:center secondPoint:pointForQuadrant];
    
    NSString *hourForAngleString = [self hourForAngle:returnAngle];
    
    NSLog(@"Point:%@ Q:%li",NSStringFromCGPoint(pointForQuadrant),(long)quad);
    
    NSLog(@"Return Angle: %f",returnAngle);
    NSLog(@"Return Angle Hour:%@",hourForAngleString);
    
    return pointForQuadrant;
}

-(NSInteger)quadrantFromAngle:(CGFloat)angle
{
    NSInteger quadrant = 0;
    // Q0=10,11,12 Q1=1,2,3 Q2=4,5,6 Q3=7,8,9
    
    if (angle > 180 && angle < 270) {
        
        quadrant = 0;
    }
    else if (angle > 270 && angle < 360)
    {
        quadrant = 1;
    }
    else if (angle > 0 && angle < 90)
    {
        quadrant = 2;
    }
    else if (angle > 90 && angle < 180)
    {
        quadrant = 3;
    }
    
    NSLog(@"Quad:%li From Angle:%li",(long)quadrant,(long)angle);
    
    
    return quadrant;
}

-(NSString*)hourForAngle:(CGFloat)angle
{
    NSArray *numberArray = @[@30.0F, @60.0F, @90.0F, @120.0F, @150.0F, @180.0F, @210.F, @240.F, @270.F, @300.0F ,@330.0F,@360.0F];
    
    NSArray *hourArray = @[@"Four",@"Five",@"Six",@"Seven",@"Eight",@"Nine",@"Ten",@"Eleven",@"Twelve",@"One",@"Two",@"Three"];
    
    NSInteger numberIndex = 0;
    NSNumber *angleNumber = [NSNumber numberWithFloat:angle];
    
    for (int x=0; x<numberArray.count-1; x++)
    {
        
        NSInteger num = [[numberArray objectAtIndex:x] integerValue];
        
        if (x == 0 && [angleNumber integerValue] < num)
        {
            numberIndex = x;
        }
        
        if ([angleNumber integerValue]-15 < num && [angleNumber integerValue]+15 > num)
        {
            numberIndex = x;
        }
    }
    
    NSString *hourString = [hourArray objectAtIndex:numberIndex];
    
    NSLog(@"%@-O-Clock for Angle:%li",hourString,(long)angle);
    
    return hourString;
}

-(CGPoint)nextDirectionFrom:(CGFloat)angle
{
    NSArray *numberArray = @[@30.0F, @60.0F, @90.0F, @120.0F, @150.0F, @180.0F, @210.F, @240.F, @270.F, @300.0F ,@330.0F,@360.0F];
    
    NSArray *hourArray = @[@"Four",@"Five",@"Six",@"Seven",@"Eight",@"Nine",@"Ten",@"Eleven",@"Twelve",@"One",@"Two",@"Three"];
    
    NSInteger numberIndex = 0;
    NSNumber *angleNumber = [NSNumber numberWithFloat:angle];
    NSInteger angleNumberInt = [angleNumber integerValue];
    
    for (int x=0; x<numberArray.count-1; x++)
    {
        NSString *hourString = [hourArray objectAtIndex:x];
        NSInteger num = [[numberArray objectAtIndex:x] integerValue];
        
        if (x == 0 && [angleNumber integerValue] < num)
        {
            NSLog(@"Its Less Than 30");
            numberIndex = x;
        }
        
        if ([angleNumber integerValue]-15 < num && [angleNumber integerValue]+15 > num) {
            NSLog(@"Hour: %@ Since:%ld is Closest to:%li At index:%i",hourString,(long)angleNumberInt,(long)num,x);
            numberIndex = x;
        }
    }
    
    CGPoint nextRiverPoint = [self pointForQuadrant:[self nextQuadFromQuad:[self quadrantFromAngle:angle]]];
    
    return nextRiverPoint;
}

-(NSInteger)nextQuadFromQuad:(NSInteger)quad
{
    NSInteger nextQuad = 0;
    NSInteger randomIndex = [self randomNumberBetweenMin:0 andMax:4];
    
    if (quad == 0)
    {
        NSArray *nextQuadArray = @[@0,@1,@0,@0,@0];
        nextQuad = [[nextQuadArray objectAtIndex:randomIndex] integerValue];
    }
    else if (quad == 1)
    {
        NSArray *nextQuadArray = @[@1,@0,@1,@1,@1];
        nextQuad = [[nextQuadArray objectAtIndex:randomIndex] integerValue];
        
    }
    else if (quad == 2)
    {
        NSArray *nextQuadArray = @[@2,@1,@2,@2,@2];
        nextQuad = [[nextQuadArray objectAtIndex:randomIndex] integerValue];
    }
    else if (quad == 3)
    {
        NSArray *nextQuadArray = @[@3,@3,@2,@3,@3];
        nextQuad = [[nextQuadArray objectAtIndex:randomIndex] integerValue];
        
    }
    
    NSLog(@"Next Quadrant:%lu From Quad: %lu",(unsigned long)nextQuad,(unsigned long)quad);
    
    return nextQuad;
}



- (NSInteger) randomNumberBetweenMin:(NSInteger)min andMax:(NSInteger)max
{
    return min + arc4random() % (max - min);
}

- (UIColor*)randomColor
{
    CGFloat redValue = (arc4random() % 255) / 255.0f;
    CGFloat blueValue = (arc4random() % 255) / 255.0f;
    CGFloat greenValue = (arc4random() % 255) / 255.0f;
    UIColor *randomColor = [UIColor colorWithRed:redValue green:greenValue blue:blueValue alpha:0.5f];
    return randomColor;
}

- (UIColor*)randomColorWithLowAlpha
{
    CGFloat redValue = (arc4random() % 255) / 255.0f;
    CGFloat blueValue = (arc4random() % 255) / 255.0f;
    CGFloat greenValue = (arc4random() % 255) / 255.0f;
    UIColor *randomColor = [UIColor colorWithRed:redValue green:greenValue blue:blueValue alpha:0.85f];
    return randomColor;
}

- (CGFloat) pointPairToBearingDegrees:(CGPoint)startingPoint secondPoint:(CGPoint) endingPoint
{
    CGPoint originPoint = CGPointMake(endingPoint.x - startingPoint.x, endingPoint.y - startingPoint.y); // get origin point to origin by subtracting end from start
    float bearingRadians = atan2f(originPoint.y, originPoint.x); // get bearing in radians
    float bearingDegrees = bearingRadians * (180.0 / M_PI); // convert to degrees
    bearingDegrees = (bearingDegrees > 0.0 ? bearingDegrees : (360.0 + bearingDegrees)); // correct discontinuity
    return bearingDegrees;
}


-(void)setupColors
{
    greenColorArray = [NSMutableArray arrayWithArray:@[[UIColor emeraldColor],[UIColor grassColor],[UIColor pastelGreenColor], [UIColor seafoamColor],[UIColor paleGreenColor],[UIColor cactusGreenColor],[UIColor chartreuseColor],[UIColor cardTableColor],[UIColor limeColor],[UIColor moneyGreenColor],[UIColor hollyGreenColor],[UIColor oliveColor],[UIColor oliveDrabColor]]];
    
    
    [self setUpLandRegions];
    
    
}

-(void)setUpLandRegions
{
    NSMutableArray *numberArray = [NSMutableArray arrayWithArray:@[@0,@1,@2,@3,@4,@5,@6,@7]];
    
    NSInteger randomIndex = [self randomNumberBetweenMin:1 andMax:numberArray.count-1]-1;
    
    NSInteger nextIndex = 0;
    
    if (randomIndex == numberArray.count-1)
    {
        nextIndex = 0;
        
    }
    else
    {
        nextIndex = randomIndex+1;
    }
    
    
    NSNumber *mountain = [numberArray objectAtIndex:randomIndex];
    mountainInteger = [mountain integerValue];
    
    NSNumber *nextMountain = [numberArray objectAtIndex:nextIndex];
    NSInteger nextMountainInteger = [nextMountain integerValue];
    
    
    [numberArray removeObjectAtIndex:randomIndex];
    [numberArray removeObjectAtIndex:randomIndex];
    
    NSInteger lakeBiomeIndex = 0;
    if (mountainInteger < 3) {
        lakeBiomeIndex = numberArray.count-1;
    }
    else
    {
        lakeBiomeIndex = mountainInteger-3;
    }
    
    NSNumber *lakeBiomeNumber = [numberArray objectAtIndex:lakeBiomeIndex];
    NSInteger lakeBiomeInteger = [lakeBiomeNumber integerValue];
    [numberArray removeObjectAtIndex:lakeBiomeIndex];
    
    NSInteger rainForestIndex = [self randomNumberBetweenMin:0 andMax:numberArray.count-1];
    NSNumber *rainForrestNumber = [numberArray objectAtIndex:rainForestIndex];
    NSInteger rainForestBiome = [rainForrestNumber integerValue];
    [numberArray removeObjectAtIndex:rainForestIndex];
    
    NSInteger dessertIndex = [self randomNumberBetweenMin:0 andMax:numberArray.count-1];
    NSNumber *dessertNumber = [numberArray objectAtIndex:dessertIndex];
    NSInteger dessertBiome = [dessertNumber integerValue];
    [numberArray removeObjectAtIndex:dessertIndex];
    
    NSInteger forestIndex = [self randomNumberBetweenMin:0 andMax:numberArray.count-1];
    NSNumber *forestNumber = [numberArray objectAtIndex:forestIndex];
    NSInteger forestBiome = [forestNumber integerValue];
    [numberArray removeObjectAtIndex:forestIndex];
    
    NSInteger lakeIndex = [self randomNumberBetweenMin:0 andMax:numberArray.count-1];
    NSNumber *lakeNumber = [numberArray objectAtIndex:lakeIndex];
    NSInteger lakeBiome = [lakeNumber integerValue];
    [numberArray removeObjectAtIndex:lakeIndex];
    
    NSNumber *grasslandNumber = [numberArray firstObject];
    NSInteger grasslandBiome = [grasslandNumber integerValue];
    
    UIColor *mountainColor = [UIColor snowColor];
    UIColor *lakeColor = [UIColor waveColor];
    UIColor *rainForestColor = [UIColor emeraldColor];
    //    UIColor *dessertColor = [UIColor clearColor];
    //    UIColor *forrestColor = [UIColor hollyGreenColor];
    //    UIColor *grasslandColor = [UIColor waveColor];
    
    regionColors = [NSMutableArray arrayWithArray:@[@0,@1,@2,@3,@4,@5,@6,@7]];
    
    [regionColors replaceObjectAtIndex:mountainInteger withObject:mountainColor];
    
    [regionColors replaceObjectAtIndex:nextMountainInteger withObject:mountainColor];
    [regionColors replaceObjectAtIndex:lakeBiomeInteger withObject:lakeColor];
    [regionColors replaceObjectAtIndex:lakeBiome withObject:rainForestColor];
    [regionColors replaceObjectAtIndex:rainForestBiome withObject:rainForestColor];
    [regionColors replaceObjectAtIndex:dessertBiome withObject:rainForestColor];
    [regionColors replaceObjectAtIndex:forestBiome withObject:rainForestColor];
    [regionColors replaceObjectAtIndex:grasslandBiome withObject:lakeColor];
    
    //    NSLog(@"regionColors Array: %@",regionColors);
    //    NSLog(@"mountainBiomeA: %lu",(unsigned long)mountainInteger);
    //    NSLog(@"mountainBiomeB: %lu",(unsigned long)nextMountainInteger);
    //    NSLog(@"lakeBiome: %lu",(unsigned long)lakeBiomeInteger);
    //    NSLog(@"rainForestBiome: %lu",(unsigned long)rainForestBiome);
    //    NSLog(@"dessertBiome: %lu",(unsigned long)dessertBiome);
    //    NSLog(@"forestBiome: %lu",(unsigned long)forestBiome);
    //    NSLog(@"lakeBiome: %lu",(unsigned long)lakeBiome);
    //    NSLog(@"grasslandInteger: %lu",(unsigned long)grasslandInteger);
    
    
}

-(void)setupArrays
{
    
    outOfFrameCells = [[NSMutableArray alloc]init];
    islandCells = [[NSMutableArray alloc]init];
    outerCells = [[NSMutableArray alloc]init];
    oceanNodes = [[NSMutableArray alloc]init];
    coastWaterNodes = [[NSMutableArray alloc]init];
    coastlineCells = [[NSMutableArray alloc]init];
    sharpCells = [[NSMutableArray alloc]init];
//    lowTerrainCells = [[NSMutableArray alloc]init];
//    highTerrainCells = [[NSMutableArray alloc]init];
//    jaggedSegmentEndNodes = [[NSMutableArray alloc]init]; //
//    jaggedSegmentStartNodes = [[NSMutableArray alloc]init]; //
    segmentIDArray = [[NSMutableArray alloc]init];
    
    mapCells = [[NSMutableDictionary alloc]init];
    masterPaths =  [[NSMutableDictionary alloc]init];
    islandSegmentPaths = [[NSMutableDictionary alloc]init];
    
    _frameNodes = [[NSMutableArray alloc]init];

    
    centerP = RectGetCenter(_frame);
    
    firstMountainPointMadeYet = NO;
    
    
}

@end
