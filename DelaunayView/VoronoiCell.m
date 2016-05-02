//
//  VoronoiCell.m
//  DelaunayTest
//
//  Created by Mike Rotondo on 7/21/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import "VoronoiCell.h"
#import "DelaunayPoint.h"

@interface VoronoiCell ()
{
    NSMutableArray *segmentIDArray;
}

@end

@implementation VoronoiCell
@synthesize site;
@synthesize nodes;

-(instancetype)init
{
    segmentIDArray = [[NSMutableArray alloc]init];

    
    
    return self;
}

+ (VoronoiCell *)voronoiCellAtSite:(DelaunayPoint *)site withNodes:(NSArray *)nodes
{
    VoronoiCell *cell = [[self alloc] init];
    
    
        
    cell.site = site;
    cell.nodes = nodes;
    
    return cell;
}



// Change up the Drawing for noise
- (void)drawInContext:(CGContextRef)ctx
{
    
//    NSValue *prevPoint = [self.nodes lastObject];
//    CGPoint p = [prevPoint CGPointValue];
//    CGContextMoveToPoint(ctx, p.x, p.y);
//    for ( NSValue *point in self.nodes)
//    {
//        CGPoint p = [point CGPointValue];
//        CGContextAddLineToPoint(ctx, p.x, p.y);        
//    }
    
    //    [self jaggedOutLineCell:self.nodes];
    
    
}

-(void)jaggedOutLineCell:(NSArray*)nodePoints
{
    CGFloat tensity = 0.45f;
    
    for (int x=0; x<nodes.count-1; x++)
    {
        CGPoint ptA = [[nodes objectAtIndex:x] CGPointValue];
        CGPoint ptB = [[nodes objectAtIndex:x+1] CGPointValue];
        
        if (![self segmentBeenDrawn:ptA to:ptB])
        {
            //NSLog(@"I can Draw Path");
            [self randomLineNodesFrom:ptA to:ptB intensity:tensity];
        }
        
        
    }
    
    CGPoint firstObject = [[nodes firstObject] CGPointValue];
    CGPoint lastObject = [[nodes lastObject] CGPointValue];
    
    if (![self segmentBeenDrawn:firstObject to:lastObject]) {
        
        [self randomLineNodesFrom:firstObject to:lastObject intensity:tensity];
    }
    
}

-(BOOL)segmentBeenDrawn:(CGPoint)pointA to:(CGPoint)pointB
{
    BOOL hasSegmentBeenDrawn = NO;
    
    NSString *askingID = [self generateIDFrom:pointA to:pointB];
    
    for (int x=0; x<segmentIDArray.count; x++) {
        NSString *segmentID = [segmentIDArray objectAtIndex:x];
        
        if ([segmentID isEqualToString:askingID]) {
            // NSLog(@"Segment Has Been drawn");
            hasSegmentBeenDrawn = YES;
        }
    }
    
    return hasSegmentBeenDrawn;
}


-(NSString*)generateIDFrom:(CGPoint)pointA to:(CGPoint)pointB
{
    CGFloat pax =  pointA.x;
    NSNumber *paxNumber = [NSNumber numberWithFloat:pax];
    CGFloat pay =  pointA.y;
    NSNumber *payNumber = [NSNumber numberWithFloat:pay];
    
    CGFloat pbx =  pointB.x;
    NSNumber *pbxNumber = [NSNumber numberWithFloat:pbx];
    CGFloat pby =  pointB.y;
    NSNumber *pbyNumber = [NSNumber numberWithFloat:pby];
    
    
    
    NSString *segmentString = [NSString stringWithFormat:@"%lu%lu2%lu%lu",(unsigned long)[paxNumber integerValue],(unsigned long)[payNumber integerValue],(unsigned long)[pbxNumber integerValue],(unsigned long)[pbyNumber integerValue]];
    
    //NSLog(@"ID Number:%@",segmentString);
    
    return segmentString;
    
}


-(NSArray*)randomLineNodesFrom:(CGPoint)pointA to:(CGPoint)pointB intensity:(CGFloat)intensity
{
    NSMutableArray *randomLineNodes = [[NSMutableArray alloc]init];
    
    BOOL debugMode = NO;
    
    CGFloat segmentDistance = PointDistanceFromPointV(pointA, pointB);
    CGFloat segmentLength = segmentDistance/8;
    CGFloat segmentMultiplyer = segmentLength * 2;
    CGFloat sizeW = intensity * segmentMultiplyer;
    CGFloat sizeH = intensity * segmentMultiplyer;
    CGSize rectSize = CGSizeMake(sizeW, sizeH);
    
    CGRect wholeLineRect = PointsMakeRectV(pointA, pointB);
    CGPoint lineCenter = RectGetCenterV(wholeLineRect);
    
    // Divde Segment into 4ths, 8th
    // Draw Rects find the center Points, draw rects agian with those center points and segment points
    // Draw rect around the center points with the size being the segment length
    
    //
    CGRect firstHalfRect = PointsMakeRectV(pointA, lineCenter);
    CGPoint firstHalfCenter = RectGetCenterV(firstHalfRect);
    //
    CGRect secondHalfRect = PointsMakeRectV(lineCenter, pointB);
    CGPoint secondHalfCenter = RectGetCenterV(secondHalfRect);
    //
    //
    CGRect firstQtrRect = PointsMakeRectV(pointA, firstHalfCenter);
    CGPoint firstQtrCenter = RectGetCenterV(firstQtrRect);
    //CGRect firstCenteredQtrRect = RectAroundCenter(firstQtrCenter, rectSize);
    //
    CGRect secondQtrRect = PointsMakeRectV(firstHalfCenter, lineCenter);
    CGPoint secondQtrCenter = RectGetCenterV(secondQtrRect);
    //CGRect secondCenteredQtrRect = RectAroundCenter(secondQtrCenter, rectSize);
    //
    CGRect thirdQtrRect = PointsMakeRectV(lineCenter, secondHalfCenter);
    CGPoint thirdQtrCenter = RectGetCenterV(thirdQtrRect);
    // CGRect thirdCenteredQtrRect = RectAroundCenter(thirdQtrCenter, rectSize);
    //
    CGRect fourthQtrRect = PointsMakeRectV(secondHalfCenter, pointB);
    CGPoint fourthQtrCenter = RectGetCenterV(fourthQtrRect);
    //CGRect fourthCenteredQtrRect = RectAroundCenter(fourthQtrCenter, rectSize);
    
    // Chop 8 Times
    //
    CGRect firstEightRect = PointsMakeRectV(pointA, firstQtrCenter);
    CGPoint pc1 = RectGetCenterV(firstEightRect);
    CGRect r1 = RectAroundCenterV(pc1, rectSize);  //CGRect ri1 = CGRectInset(r1, ww, 0);
    CGPoint rpt1 = [self randomPointInRectV:r1];
    
    
    
    CGRect secondEightRect = PointsMakeRectV(firstQtrCenter, firstHalfCenter);
    CGPoint pc2 = RectGetCenterV(secondEightRect);
    CGRect r2 = RectAroundCenterV(pc2, rectSize);
    CGPoint rpt2 = [self randomPointInRectV:r2];
    
    CGRect thirdEightRect = PointsMakeRectV(firstHalfCenter, secondQtrCenter);
    CGPoint pc3 = RectGetCenterV(thirdEightRect);
    CGRect r3 = RectAroundCenterV(pc3, rectSize);
    CGPoint rpt3 = [self randomPointInRectV:r3];
    
    CGRect fourthEightRect = PointsMakeRectV(secondQtrCenter, lineCenter);
    CGPoint pc4 = RectGetCenterV(fourthEightRect);
    CGRect r4 = RectAroundCenterV(pc4, rectSize);
    CGPoint rpt4 = [self randomPointInRectV:r4];
    
    CGRect fifthEightRect = PointsMakeRectV(lineCenter, thirdQtrCenter);
    CGPoint pc5 = RectGetCenterV(fifthEightRect);
    CGRect r5 = RectAroundCenterV(pc5, rectSize);
    CGPoint rpt5 = [self randomPointInRectV:r5];
    
    CGRect sixthEightRect = PointsMakeRectV(thirdQtrCenter, secondHalfCenter);
    CGPoint pc6 = RectGetCenterV(sixthEightRect);
    CGRect r6 = RectAroundCenterV(pc6, rectSize);
    CGPoint rpt6 = [self randomPointInRectV:r6];
    
    CGRect seventhEightRect = PointsMakeRectV(secondHalfCenter, fourthQtrCenter);
    CGPoint pc7 = RectGetCenterV(seventhEightRect);
    CGRect r7 = RectAroundCenterV(pc7, rectSize);
    CGPoint rpt7 = [self randomPointInRectV:r7];
    
    CGRect eightEightRect = PointsMakeRectV(fourthQtrCenter, pointB);
    CGPoint pc8 = RectGetCenterV(eightEightRect);
    CGRect r8 = RectAroundCenterV(pc8, rectSize);
    CGPoint rpt8 = [self randomPointInRectV:r8];
    
    // Draw First Segment
    UIBezierPath *segmentPath = [UIBezierPath bezierPath];
    [segmentPath moveToPoint:pointA];
    [randomLineNodes insertObject:[NSValue valueWithCGPoint:pointA] atIndex:0];
    
    [segmentPath addLineToPoint:rpt1];
    [randomLineNodes insertObject:[NSValue valueWithCGPoint:rpt1] atIndex:0];
    [segmentPath addLineToPoint:firstQtrCenter];
    [randomLineNodes insertObject:[NSValue valueWithCGPoint:firstQtrCenter] atIndex:0];
    [segmentPath addLineToPoint:rpt2];
    [randomLineNodes insertObject:[NSValue valueWithCGPoint:rpt2] atIndex:0];
    [segmentPath addLineToPoint:firstHalfCenter];
    [randomLineNodes insertObject:[NSValue valueWithCGPoint:firstHalfCenter] atIndex:0];
    [segmentPath addLineToPoint:rpt3];
    [randomLineNodes insertObject:[NSValue valueWithCGPoint:rpt3] atIndex:0];
    [segmentPath addLineToPoint:secondQtrCenter];
    [randomLineNodes insertObject:[NSValue valueWithCGPoint:secondQtrCenter] atIndex:0];
    [segmentPath addLineToPoint:rpt4];
    [randomLineNodes insertObject:[NSValue valueWithCGPoint:rpt4] atIndex:0];
    [segmentPath addLineToPoint:lineCenter];
    [randomLineNodes insertObject:[NSValue valueWithCGPoint:lineCenter] atIndex:0];
    [segmentPath addLineToPoint:rpt5];
    [randomLineNodes insertObject:[NSValue valueWithCGPoint:rpt5] atIndex:0];
    [segmentPath addLineToPoint:thirdQtrCenter];
    [randomLineNodes insertObject:[NSValue valueWithCGPoint:thirdQtrCenter] atIndex:0];
    [segmentPath addLineToPoint:rpt6];
    [randomLineNodes insertObject:[NSValue valueWithCGPoint:rpt6] atIndex:0];
    [segmentPath addLineToPoint:secondHalfCenter];
    [randomLineNodes insertObject:[NSValue valueWithCGPoint:secondHalfCenter] atIndex:0];
    [segmentPath addLineToPoint:rpt7];
    [randomLineNodes insertObject:[NSValue valueWithCGPoint:rpt7] atIndex:0];
    [segmentPath addLineToPoint:fourthQtrCenter];
    [randomLineNodes insertObject:[NSValue valueWithCGPoint:fourthQtrCenter] atIndex:0];
    [segmentPath addLineToPoint:rpt8];
    [randomLineNodes insertObject:[NSValue valueWithCGPoint:rpt8] atIndex:0];
    [segmentPath addLineToPoint:pointB];
    [randomLineNodes insertObject:[NSValue valueWithCGPoint:pointB] atIndex:0];
    
    
    [[UIColor whiteColor] setStroke];
    segmentPath.lineWidth = 0.50;
    [segmentPath stroke];
    
    NSString *segmentIDString = [self generateIDFrom:pointA to:pointB];
    NSString *reversedSegmentIDString = [self generateIDFrom:pointB to:pointA];
    
    [segmentIDArray addObject:reversedSegmentIDString];
    [segmentIDArray addObject:segmentIDString];

    
    
    if (debugMode)
    {
        
        NSLog(@"segmentLength: %f",segmentLength);
        NSLog(@"segmentMultiplyer: %f",segmentMultiplyer);
        NSLog(@"Rectangle Side: %f",sizeW);
        
        // Draw Rectangles
        UIBezierPath *rectPath = [UIBezierPath bezierPathWithRect:r1];
        rectPath.lineWidth = 0.25;
        [[UIColor whiteColor] setStroke];
        [rectPath stroke];
        
        
        
        // Show Segments
        [self paintNodes:@[[NSValue valueWithCGPoint:pointA],
                           [NSValue valueWithCGPoint:firstQtrCenter],
                           [NSValue valueWithCGPoint:firstHalfCenter],
                           [NSValue valueWithCGPoint:secondQtrCenter],
                           [NSValue valueWithCGPoint:lineCenter],
                           [NSValue valueWithCGPoint:thirdQtrCenter],
                           [NSValue valueWithCGPoint:secondHalfCenter],
                           [NSValue valueWithCGPoint:fourthQtrCenter],
                           [NSValue valueWithCGPoint:pointB]] with:[UIColor greenColor] dotSize:0.25];
        
        
        
        //  Show Random Points
        [self paintNodes:@[[NSValue valueWithCGPoint:rpt1],
                           [NSValue valueWithCGPoint:rpt2],
                           [NSValue valueWithCGPoint:rpt3],
                           [NSValue valueWithCGPoint:rpt4],
                           [NSValue valueWithCGPoint:rpt5],
                           [NSValue valueWithCGPoint:rpt6],
                           [NSValue valueWithCGPoint:rpt7],
                           [NSValue valueWithCGPoint:rpt8]] with:[UIColor blueColor] dotSize:0.15];
        
    }
    
    return randomLineNodes;
}


-(NSArray*)segments
{
    NSMutableArray *segments = [[NSMutableArray alloc]init];
    
    
    
    return segments;
}

- (CGPoint)centroid
{
    // CGPoint centroid = CGPointZero;
    
    CGFloat xCentroid = 0;
    CGFloat yCentroid = 0;

    
    for (NSValue *pointValue in self.nodes)
    {
        CGPoint pointFromValue = [pointValue CGPointValue];
        xCentroid = xCentroid + pointFromValue.x;
        yCentroid = yCentroid + pointFromValue.y;

    }
    
    xCentroid = xCentroid/self.nodes.count;
    yCentroid = yCentroid/self.nodes.count;
    
    return CGPointMake(xCentroid, yCentroid);;
}

-(CGPoint)lowestNodePoint
{
        
    NSMutableArray *numberArray = [[NSMutableArray alloc]init];
    
    for (NSValue *value in self.nodes) {
        CGPoint point = [value CGPointValue];
        CGFloat yPoint = point.y;
        NSNumber *number = [NSNumber numberWithFloat:yPoint];
        [numberArray addObject:number];
    }
    
    NSInteger highestNumber = 0;
    NSInteger numberIndex = 0;
    
    for (NSNumber *theNumber in numberArray)
    {
        if ([theNumber integerValue] > highestNumber) {
            highestNumber = [theNumber integerValue];
            numberIndex = [numberArray indexOfObject:theNumber];
        }
    }
    
    NSValue *lowestNodeValue =  [self.nodes objectAtIndex:numberIndex];
    CGPoint lowestPoint = [lowestNodeValue CGPointValue];
    
    return lowestPoint;
}





- (float)area
{
    float xys = 0.0;
    float yxs = 0.0;
    
    NSValue *prevPoint = [self.nodes objectAtIndex:0];
    CGPoint prevP = [prevPoint CGPointValue];
    for ( NSValue *point in [self.nodes reverseObjectEnumerator])
    {
        CGPoint p = [point CGPointValue];
        xys += prevP.x * p.y;
        yxs += prevP.y * p.x;
        prevP = p;
    }
    
    return (xys - yxs) * 0.5;
}

-(void)paintNodes:(NSArray*)nodePoints with:(UIColor*)color dotSize:(CGFloat)percent
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat dotSize = 1.5 * percent;
    
    for (NSValue *nodeValue in nodePoints)
    {
        CGPoint point = [nodeValue CGPointValue];
        [color set];
        CGContextMoveToPoint(ctx, point.x + dotSize, point.y);
        CGContextAddArc(ctx, point.x, point.y, dotSize, 0, 2 * M_PI, 0);
        CGContextFillPath(ctx);
    }
    
}

CGFloat PointDistanceFromPointV(CGPoint p1, CGPoint p2)
{
    CGFloat dx = p2.x - p1.x;
    CGFloat dy = p2.y - p1.y;
    
    return sqrt(dx*dx + dy*dy);
}




-(CGPoint)randomPointInRectV:(CGRect)rect
{
    CGPoint p = rect.origin;
    
    p.x += rect.size.width * (arc4random() / (float)0x100000000);
    p.y += rect.size.height * (arc4random() / (float)0x100000000);
    
    return p;
}

CGRect PointsMakeRectV(CGPoint p1, CGPoint p2)
{
    CGRect rect = CGRectMake(p1.x, p1.y, p2.x - p1.x, p2.y - p1.y);
    return CGRectStandardize(rect);
}

CGRect RectAroundCenterV(CGPoint center, CGSize size)
{
    CGFloat halfWidth = size.width / 2.0f;
    CGFloat halfHeight = size.height / 2.0f;
    
    return CGRectMake(center.x - halfWidth, center.y - halfHeight, size.width, size.height);
}

CGPoint RectGetCenterV(CGRect rect)
{
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}








@end
