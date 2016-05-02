//
//  MapView.m
//  DelaunayView
//
//  Created by Justin Madewell on 8/11/14.
//  Copyright (c) 2014 Justin Madewell. All rights reserved.
//

#import "MapView.h"
#import "MapUtility.h"
#import "Colours.h"

#import "NSObject+GCD.h"

#import "UIImage+TTTDrawing.h"

#import "MSCachedAsyncViewDrawing.h"


typedef void(^UIImageRenderBlock)(CGContextRef context);

typedef void (^DrawBlock)(CGRect frame);
typedef void (^CompletionBlock)(UIImage *drawnImage);
typedef struct CGContext * CGContextRef;

static inline size_t aligned_size(size_t size, size_t alignment) {
    size_t r = size + --alignment + 2;
    return (r + 2 + alignment) & ~alignment;
}




CG_INLINE CGContextRef CGContextCreate(CGSize size)
{
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(nil, size.width, size.height, 8, size.width * (CGColorSpaceGetNumberOfComponents(space) + 1), space, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(space);
    
    return ctx;
}

CG_INLINE UIImage* UIGraphicsGetImageFromContext(CGContextRef ctx)
{
    CGImageRef cgImage = CGBitmapContextCreateImage(ctx);
    UIImage* image = [UIImage imageWithCGImage:cgImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    CGImageRelease(cgImage);
    
    return image;
}




@interface MapView ()
{
    UIImage *mapImage;
    UIImageView *imageView;
    MSCachedAsyncViewDrawing *asyncDrawing;
}

@end

@implementation MapView

@synthesize rect;

-(UIImage *)drawImageWithSize:(CGSize)size withBlock:(id)drawBlock
{
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 2.0);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    UIImage * createdImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    NSLog(@"Returning Image");
    
    
    return createdImage;
    


    
}



-(void)catImage
{
    [UIImage tttImageWithSize:CGSizeMake(44, 44)
                      drawing:^(CGContextRef ctx, CGSize size) {
                          
                          UIColor *blue = [UIColor blueColor];
                          CGContextSetFillColorWithColor(ctx, blue.CGColor);
                          
                          CGFloat half = size.height / 2;
                          rect = (CGRect){{0, half}, {size.width, half}};
                          CGContextFillRect(ctx, rect);
                          
                      }];
}

-(void)qq
{
    CGFloat backgroundHeight = 0;
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(NULL, 250, 250, 8, 250 * 4, colorSpaceRef,   kCGBitmapAlphaInfoMask| kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little);
        CGColorSpaceRelease(colorSpaceRef);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //[_text drawInRect:CGRectMake(0, 0, 250, backgroundHeight - 112) withFont:font];
            CGImageRef outputImage = CGBitmapContextCreateImage(context);
            // imageRef = outputImage;
            // [self performSelectorOnMainThread:@selector(finishDrawingImage) withObject:nil waitUntilDone:YES];
        });
        
        CGContextRelease(context);
        // CGImageRelease(outputImage);
    });
    
    
    
    
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        if (self.areColorsRandom) {
            self.backgroundColor = [self randomColor];
        }
        
        
        
        
        self.backgroundColor = [UIColor blueberryColor];
        [self viewDidLoad];
    }
    
    return self;
}




+(instancetype)map
{
    MapView *view = [[self alloc] init];
    
    return view;
}


+(instancetype)drawMap:(CGRect)frame
{
    NSLog(@"Initiated");
    MapView *mapView = [[self alloc] initWithFrame:frame];
    mapView.alpha = 0.1;
    
    return mapView;
}

-(void)setMapCells:(NSMutableDictionary *)mapCells
{
    
    NSLog(@"Setting Map Cells Dictionary");
    
    _mapCells = mapCells;
    
    NSLog(@"Cells Set");
    
     [self makeMapImage];
    
    UIColor *background = [UIColor whiteColor];
    
    if (self.areColorsRandom) {
        NSLog(@"Colors are random");
       background =  [self randomColor];
    }
    
    if (!self.areColorsRandom && self.showVanilla) {
        NSLog(@"Vanilla");
       background =  [UIColor whiteColor];
    }
    
    if (!self.areColorsRandom && !self.showVanilla) {
        background = [UIColor blueberryColor];
    }
    
    
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       // Update UI
                       
                       // UIColor *bg = [UIColor clearColor];
                       
                       self.backgroundColor = background;
                       
                       
                       // self.backgroundColor = [UIColor blueberryColor];
                       
                   });

    NSLog(@"Map Cells Set");
    
    
}

-(void)setMapImage
{
    NSLog(@"Setting Map Image");
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       // Update UI
                      
                       [imageView setImage:mapImage];
                       [self addSubview:imageView];
                   });
}

-(UIImage*)catI
{
     return [UIImage tttImageWithSize:CGSizeMake(300, 300)
                      drawing:^(CGContextRef ctx, CGSize size) {
                          
                          dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                          
                          
                          dispatch_apply([_mapCells allKeys].count, queue, ^(size_t i)
                          {
                              UIGraphicsPushContext(ctx);
                              
                              NSDictionary *cellDict = [_mapCells objectForKey:[[_mapCells allKeys] objectAtIndex:i]];
                              UIBezierPath *cellPath = [cellDict objectForKey:@"PATH"];
                              UIColor *cellColor = [cellDict objectForKey:@"COLOR"];
                              NSNumber *outlineNumber = [cellDict objectForKey:@"OUTLINE"];
                              BOOL colorMode = [outlineNumber boolValue];
                              
                              UIColor *outlineColor = [UIColor colorWithWhite:0.75 alpha:0.8];
                              
                              if (!colorMode) {
                                  outlineColor = cellColor;
                              }
                              
                              [outlineColor setStroke];
                              [cellPath stroke];
                              [cellColor setFill];
                              [cellPath fill];
                              
                          });
                      }];
}


-(void)makeMapImage
{
     UIImage *map = [self mapImage];
    

    mapImage = map;
    
    [self setMapImage];
    
}

-(UIImage*)newBlockImage
{
    CGSize sz =  CGSizeMake(300, 300);

    UIImage *newBlock = [self imageWithSize:sz block:^(CGContextRef context) {
        //Code
        
        NSLog(@"context:%@",context);
        
        
        
        
        //        UIBezierPath *path = [UIBezierPath bezierPath];
        //        [path moveToPoint:CGPointMake(20, 20)];
        //        [path addLineToPoint:CGPointMake(50, 75)];
        //
        //        [[UIColor blackColor] setStroke];
        //        [path stroke];
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        
        
        
        dispatch_apply([_mapCells allKeys].count, queue, ^(size_t i) {
            
        
            
                    UIBezierPath *path = [UIBezierPath bezierPath];
                    [path moveToPoint:CGPointMake(20, 20)];
                    [path addLineToPoint:CGPointMake(50, 75)];
            
                    [[UIColor blackColor] setStroke];
                    [path stroke];

            
//            NSDictionary *cellDict = [_mapCells objectForKey:[[_mapCells allKeys] objectAtIndex:i]];
//            UIBezierPath *cellPath = [cellDict objectForKey:@"PATH"];
//            UIColor *cellColor = [cellDict objectForKey:@"COLOR"];
//            NSNumber *outlineNumber = [cellDict objectForKey:@"OUTLINE"];
//            BOOL colorMode = [outlineNumber boolValue];
//            
//            UIColor *outlineColor = [UIColor colorWithWhite:0.75 alpha:0.8];
//            
//            if (!colorMode) {
//                outlineColor = cellColor;
//            }
//            
//            [outlineColor setStroke];
//            [cellPath stroke];
//            [cellColor setFill];
//            [cellPath fill];
            
        });
        
        
    }];

    return newBlock;
}


-(UIImage*)new
{
    
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 2.0);
    UIImage * createdImage = UIGraphicsGetImageFromCurrentImageContext();
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
                       
    
    dispatch_apply([_mapCells allKeys].count, queue, ^(size_t i) {
        
        //UIGraphicsPushContext(ctx);
        [createdImage drawInRect:self.frame];
        
        printf("Painting Call Block.\n");
        NSDictionary *cellDict = [_mapCells objectForKey:[[_mapCells allKeys] objectAtIndex:i]];
        UIBezierPath *cellPath = [cellDict objectForKey:@"PATH"];
        UIColor *cellColor = [cellDict objectForKey:@"COLOR"];
        NSNumber *outlineNumber = [cellDict objectForKey:@"OUTLINE"];
        BOOL colorMode = [outlineNumber boolValue];
        
        UIColor *outlineColor = [UIColor colorWithWhite:0.75 alpha:0.8];
        
        if (!colorMode) {
            outlineColor = cellColor;
        }
        
        [outlineColor setStroke];
        [cellPath stroke];
        [cellColor setFill];
        [cellPath fill];
        
        
        
    });
    
    
    printf("Both blocks have completed.\n");
    
    //UIImage * createdImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    NSLog(@"Returning Image");
    
    
    return createdImage;
                       
                  
    

}





-(UIImage*)fast
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       // UI CODE HERE
                       UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 2.0);
                       
                   });

    
    
    
    dispatch_apply([_mapCells allKeys].count, queue, ^(size_t i) {
        
        
        printf("Painting Call Block.\n");
        NSDictionary *cellDict = [_mapCells objectForKey:[[_mapCells allKeys] objectAtIndex:i]];
        UIBezierPath *cellPath = [cellDict objectForKey:@"PATH"];
        UIColor *cellColor = [cellDict objectForKey:@"COLOR"];
        NSNumber *outlineNumber = [cellDict objectForKey:@"OUTLINE"];
        BOOL colorMode = [outlineNumber boolValue];
        
        UIColor *outlineColor = [UIColor colorWithWhite:0.75 alpha:0.8];
        
        if (!colorMode) {
            outlineColor = cellColor;
        }
        
        [outlineColor setStroke];
        [cellPath stroke];
        [cellColor setFill];
        [cellPath fill];
        
        
        
    });

    
    printf("Both blocks have completed.\n");

    UIImage * createdImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    NSLog(@"Returning Image");
    
    return createdImage;
    
    
    
    
}



-(UIImage*)fastMapImage
{
    NSLog(@"[UIScreen mainScreen].scale: %f",[UIScreen mainScreen].scale);
    
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 2.0);
    
    
    /* TEST */
    
 
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_apply([_mapCells allKeys].count, queue, ^(size_t i) {
        NSDictionary *cellDict = [_mapCells objectForKey:[[_mapCells allKeys] objectAtIndex:i]];
        UIBezierPath *cellPath = [cellDict objectForKey:@"PATH"];
        UIColor *cellColor = [cellDict objectForKey:@"COLOR"];
        NSNumber *outlineNumber = [cellDict objectForKey:@"OUTLINE"];
        BOOL colorMode = [outlineNumber boolValue];
        
        UIColor *outlineColor = [UIColor colorWithWhite:0.75 alpha:0.8];
        
        if (!colorMode) {
            outlineColor = cellColor;
        }
        
        [outlineColor setStroke];
        [cellPath stroke];
        [cellColor setFill];
        [cellPath fill];
        
    });
    
    /* END TEST */
    
    
    UIImage * createdImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    NSLog(@"Returning Image");
    
    return createdImage;



    
}

-(UIImage*)mapImage
{
    
    // NSLog(@"[UIScreen mainScreen].scale: %f",[UIScreen mainScreen].scale);
    
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 2.0);
    
//    CGContextRef ctx = CGContextCreate(self.frame.size);
    
    
           
    for (id key in [_mapCells allKeys]) {
        NSDictionary *cellDict = [_mapCells objectForKey:key];
        UIBezierPath *cellPath = [cellDict objectForKey:@"PATH"];
        UIColor *cellColor = [cellDict objectForKey:@"COLOR"];
        NSNumber *outlineNumber = [cellDict objectForKey:@"OUTLINE"];
        BOOL outline = [outlineNumber boolValue];
        [self paintPath:cellPath cellColor:cellColor outline:outline];
    }
    
    UIImage * createdImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    NSLog(@"Returning Image");
    
    return createdImage;

}

-(void)dis
{
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_SERIAL, 0);
    
    
    
    
    
   }

-(void)paintMapCellFast
{

    
    NSLog(@"Painting has begun");
    
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, [UIScreen mainScreen].scale);
    
    //CGContextRef context = UIGraphicsGetCurrentContext();
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_apply([_mapCells allKeys].count, queue, ^(size_t i) {
        NSDictionary *cellDict = [_mapCells objectForKey:[[_mapCells allKeys] objectAtIndex:i]];
        UIBezierPath *cellPath = [cellDict objectForKey:@"PATH"];
        UIColor *cellColor = [cellDict objectForKey:@"COLOR"];
        NSNumber *outlineNumber = [cellDict objectForKey:@"OUTLINE"];
        BOOL colorMode = [outlineNumber boolValue];
        
        UIColor *outlineColor = [UIColor colorWithWhite:0.75 alpha:0.8];
        
        if (!colorMode) {
            outlineColor = cellColor;
        }
        
        [outlineColor setStroke];
        [cellPath stroke];
        [cellColor setFill];
        [cellPath fill];
    
    });
    
    UIImage * createdImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       // Update UI
                       [imageView setImage:createdImage];
                   });


    
}


#pragma mark - PAINTING



-(void)multiThreadProcess
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //code here
        
    });
}

-(UIImage*)blockMapImage
{
    UIImage *createdImage = UIImageCreateUsingBlock(CGSizeMake(300, 300), NO, ^{
        //
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        dispatch_apply([_mapCells allKeys].count, queue, ^(size_t i) {
            NSDictionary *cellDict = [_mapCells objectForKey:[[_mapCells allKeys] objectAtIndex:i]];
            UIBezierPath *cellPath = [cellDict objectForKey:@"PATH"];
            UIColor *cellColor = [cellDict objectForKey:@"COLOR"];
            NSNumber *outlineNumber = [cellDict objectForKey:@"OUTLINE"];
            BOOL colorMode = [outlineNumber boolValue];
            
            UIColor *outlineColor = [UIColor colorWithWhite:0.75 alpha:0.8];
            
            if (!colorMode) {
                outlineColor = cellColor;
            }
            
            [outlineColor setStroke];
            [cellPath stroke];
            [cellColor setFill];
            [cellPath fill];
            
        });
        
    });
    
     NSLog(@"createdImage:%@",createdImage);
    
    return createdImage;

}


-(UIImage *)imageWithSize:(CGSize) canvasSize block:(UIImageRenderBlock) aBlock {
    
    CGContextRef		context;
    void				*bitmapData;
    CGColorSpaceRef		colorSpace;
    int					bitmapByteCount;
    int					bitmapBytesPerRow;
    CGImageRef  resultImage;
    UIImage     *image;
    
    //
    bitmapBytesPerRow	= canvasSize.width * 4;
    bitmapByteCount		= (bitmapBytesPerRow * canvasSize.height);
    
    //Create the color space
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    bitmapData = malloc( bitmapByteCount );
    
    //Check the the buffer is alloc'd
    if( bitmapData == NULL ){
        NSLog(@"Buffer could not be alloc'd");
    }
    
    //Create the context
    context = CGBitmapContextCreate(bitmapData, canvasSize.width, canvasSize.height, 8, bitmapBytesPerRow, colorSpace, kCGBitmapAlphaInfoMask &kCGImageAlphaPremultipliedLast);
    
    if( context == NULL ){
        NSLog(@"Context could not be created");
    }
    
    //Render user data
    aBlock(context);
    
    //The contents of the context could be saved out as follows
    //Get the result image
    resultImage = CGBitmapContextCreateImage(context);
    
    //Save the image
    image =  [UIImage imageWithCGImage:resultImage];
    
    //Cleanup
    CGImageRelease(resultImage);
    free(bitmapData);
    CGColorSpaceRelease(colorSpace);
    
    return image;
    
}






-(void)viewDidLoad
{
    NSLog(@"self.frame: %@",NSStringFromCGRect(self.frame));
    
    CGRect imageViewRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    
    imageView = [[UIImageView alloc] initWithFrame:imageViewRect];
    [self addSubview:imageView];
    
    
   
    
    
    self.activityIndicatorView = [[UIActivityIndicatorView alloc]initWithFrame:self.frame];
    [self addSubview:self.activityIndicatorView];

    
 
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       //do something expensive
                       
                       //dispatch back to the main (UI) thread to stop the activity indicator
                       dispatch_async(dispatch_get_main_queue(), ^
                                      {
                                          // Update UI
                                          
                                      });
                   });
}


-(void)paintPath:(UIBezierPath*)path color:(UIColor*)pathColor
{
    [pathColor setStroke];
    [path stroke];
}



-(void)paintPath:(UIBezierPath*)path cellColor:(UIColor*)cellColor outline:(BOOL)colorMode
{
    
    UIColor *outlineColor = [UIColor colorWithWhite:1.0 alpha:0.75];
    
    if (!colorMode) {
        outlineColor = cellColor;
    }
    
    if (self.areColorsRandom) {
        cellColor = [self randomColor];
        outlineColor = [UIColor blackColor];
    }
    
    if (self.showVanilla) {
        
        outlineColor = [UIColor blackColor];
    }
    
    [outlineColor setStroke];
    [path stroke];
    [cellColor setFill];
    [path fill];
}
- (UIColor*)randomColor
{
    CGFloat redValue = (arc4random() % 255) / 255.0f;
    CGFloat blueValue = (arc4random() % 255) / 255.0f;
    CGFloat greenValue = (arc4random() % 255) / 255.0f;
    UIColor *randomColor = [UIColor colorWithRed:redValue green:greenValue blue:blueValue alpha:1.0f];
    return randomColor;
}

-(void)backImage
{



}

UIImage *UIImageCreateUsingBlock(CGSize size, BOOL opaque, void(^drawingBlock)(void)) {
    
    BOOL isMain = [NSThread isMainThread];
    CGContextRef context = NULL;
    CGFloat scale;
    
    if (isMain) {
        UIGraphicsBeginImageContextWithOptions(size, opaque, 0.0);
        context = UIGraphicsGetCurrentContext();
    } else {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        scale = [UIScreen mainScreen].scale;
        CGImageAlphaInfo alphaInfo;
        if (opaque) {
            alphaInfo = kCGBitmapAlphaInfoMask & kCGImageAlphaNoneSkipFirst;
        } else {
            alphaInfo = kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedFirst;
        }
        
        // RGB - 32 bpp - 8 bpc - available on both OS X and iOS
        const size_t bitsPerPixel = 32;
        const size_t bitsPerComponent = 8;
        size_t widthPixels = (size_t)ceil(size.width * scale);
        size_t heightPixels = (size_t)ceil(size.height * scale);
        
        // Quartz 2D Programming Guide
        // "When you create a bitmap graphics context, you’ll get the best
        // performance if you make sure the data and bytesPerRow are 16-byte aligned."
        size_t bytesPerRow = widthPixels * bitsPerPixel;
        size_t alignedBytesPerRow = aligned_size(bytesPerRow, 16);
        
        context = CGBitmapContextCreate(NULL, widthPixels, heightPixels, bitsPerComponent, alignedBytesPerRow, colorSpace, kCGBitmapAlphaInfoMask & alphaInfo);
        CGColorSpaceRelease(colorSpace);
        CGContextScaleCTM(context, scale, -1 * scale);
        CGContextTranslateCTM(context, 0, -1 * size.height);
        CGContextClipToRect(context, (CGRect){ CGPointZero, size });
        UIGraphicsPushContext(context);
    }
    
    if (drawingBlock) drawingBlock();
    
    UIImage *retImage = nil;
    
    if (isMain) {
        retImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    } else {
        UIGraphicsPopContext();
        CGImageRef cgImage = CGBitmapContextCreateImage(context);
        retImage = [UIImage imageWithCGImage:cgImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
        CGImageRelease(cgImage);
        CGContextRelease(context);
    }
    
    return retImage;
}


-(void)drawRect:(CGRect)rect
{
    // [self fast];
}





@end
