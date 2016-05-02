#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^TTTDrawingBlock)(CGContextRef ctx, CGSize size);

@interface UIImage (TTTDrawing)

+ (UIImage *)tttImageWithSize:(CGSize)size drawing:(TTTDrawingBlock)drawing;

@end