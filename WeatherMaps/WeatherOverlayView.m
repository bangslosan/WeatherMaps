//
//  WeatherOverlayView.m
//  WeatherMaps
//
//  Created by Watanabe Toshinori on 11/08/28.
//  Copyright 2011年 FLCL.jp. All rights reserved.
//

#import "WeatherOverlayView.h"
#import "TileManager.h"
#import "Tile.h"


@implementation WeatherOverlayView


- (BOOL)canDrawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale
{
    float scale = zoomScale / [[UIScreen mainScreen] scale];
    NSArray *tilesInRect = [[TileManager sharedTileManager] tilesInMapRect:mapRect zoomScale:scale];

    return [tilesInRect count] > 0;
}

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context
{
    float scale = zoomScale / [[UIScreen mainScreen] scale];
    NSArray *tilesInRect = [[TileManager sharedTileManager] tilesInMapRect:mapRect zoomScale:scale];
    
    for (Tile *tile in tilesInRect) {
        MKMapRect frame = MKMapRectMake((double)([tile.x intValue] * TILE_SIZE) / [tile.scale floatValue],
                                        (double)([tile.y intValue] * TILE_SIZE) / [tile.scale floatValue],
                                        TILE_SIZE / [tile.scale floatValue],
                                        TILE_SIZE / [tile.scale floatValue]);

        CGRect rect = [self rectForMapRect:frame];
        UIImage *image = [UIImage imageWithData:tile.image];

        CGContextSaveGState(context);
        CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
        CGContextScaleCTM(context, 1 / scale, 1 / scale);
        CGContextTranslateCTM(context, 0, image.size.height);
        CGContextScaleCTM(context, 1, -1);
        CGContextDrawImage(context, CGRectMake(0, 0, image.size.width, image.size.height), [image CGImage]);
        CGContextRestoreGState(context);
    }
}

@end
