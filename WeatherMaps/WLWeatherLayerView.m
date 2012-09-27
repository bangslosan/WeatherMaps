//
//  WMOverlayView.m
//  WorldMap
//
//  Created by kishikawa katsumi on 2012/09/26.
//  Copyright (c) 2012 kishikawa katsumi. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "WLWeatherLayerView.h"
#import "WLWeatherLayer.h"

@implementation WLWeatherLayerView

/**
 * Given a MKMapRect, this reprojects the center of the mapRect
 * into the Mercator projection and calculates the rect's top-left point
 * (so that we can later figure out the tile coordinate).
 *
 * See http://wiki.openstreetmap.org/wiki/Slippy_map_tilenames#Derivation_of_tile_names
 */
- (CGPoint)mercatorTileOriginForMapRect:(MKMapRect)mapRect {
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(mapRect);
    
    // Convert lat/lon to radians
    CGFloat x = (region.center.longitude) * (M_PI / 180.0f); // Convert lon to radians
    CGFloat y = (region.center.latitude) * (M_PI / 180.0f); // Convert lat to radians
    y = log(tan(y) + 1.0f / cos(y));
    
    // X and Y should actually be the top-left of the rect (the values above represent
    // the center of the rect)
    x = (1.0f + (x / M_PI)) / 2.0f;
    y = (1.0f - (y / M_PI)) / 2.0f;
    
    return CGPointMake(x, y);
}

- (NSUInteger)zoomLevelForZoomScale:(MKZoomScale)zoomScale
{
    CGFloat realScale = zoomScale / [[UIScreen mainScreen] scale];
    NSUInteger zoomLevel = (NSUInteger)(log(realScale) / log(2.0) + 20.0);
    
    return zoomLevel;
}

- (NSUInteger)worldTileWidthForZoomLevel:(NSUInteger)zoomLevel
{
    return (NSUInteger)(pow(2, zoomLevel));
}

- (CGFloat)tileWidthForZoomLevel:(NSUInteger)zoomLevel
{
    CGFloat scale = [[UIScreen mainScreen] scale];
    return 1.0f / (pow(2, zoomLevel) * scale);
}

- (CGRect)contentsRectForImage:(UIImage *)image mercatorPoint:(CGPoint)mercatorPoint tileX:(NSInteger)tilex tileY:(NSInteger)tiley zoomLevel:(NSUInteger)zoomLevel
{
    NSInteger scale = [[UIScreen mainScreen] scale];
    CGFloat tileWidth = [self tileWidthForZoomLevel:zoomLevel];
    CGSize imageSize = image.size;
    
    for (NSInteger x = 0; x < scale; x++) {
        for (NSInteger y = 0; y < scale; y++) {
            CGRect rect = CGRectMake(tileWidth * (tilex * scale) + tileWidth * x,
                                     tileWidth * (tiley * scale) + tileWidth * y,
                                     tileWidth,
                                     tileWidth);
            if (CGRectContainsPoint(rect, mercatorPoint)) {
                return CGRectMake((imageSize.width / scale) * x, (imageSize.height / scale) * y, imageSize.width / scale, imageSize.height / scale);
            }
        }
    }
    
    return CGRectZero;
}

- (BOOL)canDrawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale
{
    return YES;
}

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context
{
    NSUInteger zoomLevel = [self zoomLevelForZoomScale:zoomScale];
    CGPoint mercatorPoint = [self mercatorTileOriginForMapRect:mapRect];
    
    NSUInteger tilex = floor(mercatorPoint.x * [self worldTileWidthForZoomLevel:zoomLevel]);
    NSUInteger tiley = floor(mercatorPoint.y * [self worldTileWidthForZoomLevel:zoomLevel]);
    NSInteger scale = [[UIScreen mainScreen] scale];
    
    NSString *path = [NSString stringWithFormat:@"x=%d&y=%d&z=%d&scale=%d", tilex, tiley, zoomLevel, scale];
    NSURL *url = [(WLWeatherLayer *)self.overlay imageURLWithTilePath:path];
    UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:url]];
    
    if (image) {
        CGRect contentsRect = [self contentsRectForImage:image mercatorPoint:mercatorPoint tileX:tilex tileY:tiley zoomLevel:zoomLevel];
        CGImageRef croppedImage = CGImageCreateWithImageInRect(image.CGImage, contentsRect);
        
        CGRect rect = [self rectForMapRect:mapRect];
        CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
        CGContextScaleCTM(context, 1.0f / zoomScale, 1.0f / zoomScale);
        CGContextTranslateCTM(context, 0.0f, image.size.height / scale);
        CGContextScaleCTM(context, 1.0f, -1.0f);
        CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, image.size.width / scale, image.size.height / scale), croppedImage);
    }
}

@end
