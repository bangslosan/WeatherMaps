//
//  TileManager.h
//  WeatherMaps
//
//  Created by Watanabe Toshinori on 11/08/28.
//  Copyright 2011年 FLCL.jp. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "Tile.h"


@interface TileManager : NSObject

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

+ (id)sharedTileManager;

- (NSArray *)tilesInMapRect:(MKMapRect)rect zoomScale:(MKZoomScale)scale;
- (void)loadTilesInMapRect:(MKMapRect)rect zoomScale:(MKZoomScale)scale completion:(void (^)(void))completion;

@end
