#import "UIImage+TTTDrawing.h"

@implementation UIImage (TTTDrawing)

+ (UIImage *)tttImageWithSize:(CGSize)size drawing:(TTTDrawingBlock)drawing
{
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();

    drawing(context, size);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end