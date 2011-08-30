//
//  WeatherOverlay.m
//  WeatherMaps
//
//  Created by Watanabe Toshinori on 11/08/28.
//  Copyright 2011年 FLCL.jp. All rights reserved.
//

#import "WeatherOverlay.h"


@implementation WeatherOverlay

@synthesize boundingMapRect;


#pragma mark - Intance

- (id)init {
    self = [super init];
    if (self) {
        self.boundingMapRect = MKMapRectMake(0, 0, MKMapSizeWorld.width, MKMapSizeWorld.height);
    }
    return self;
}


#pragma mark - MKOverlay methods

- (CLLocationCoordinate2D)coordinate
{
    return MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMidX(boundingMapRect), MKMapRectGetMidY(boundingMapRect)));
}

@end
