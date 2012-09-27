//
//  WMOverlay.m
//  WorldMap
//
//  Created by kishikawa katsumi on 2012/09/26.
//  Copyright (c) 2012 kishikawa katsumi. All rights reserved.
//

#import "WLWeatherLayer.h"

@implementation WLWeatherLayer

- (CLLocationCoordinate2D)coordinate
{
    return MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMidX(MKMapRectWorld), MKMapRectGetMidY(MKMapRectWorld)));
}

- (MKMapRect)boundingMapRect
{
    return MKMapRectWorld;
}

- (NSURL *)imageURLWithTilePath:(NSString *)path
{
    u_int32_t random = arc4random_uniform(2);

    NSString *s =
    [NSString stringWithFormat:@"http://mt%d.google.com/mapslt?lyrs=%@%%7Cinvert:%d&%@&w=256&h=256",
     random,
     self.unitType == WLWeahterLayerUnitTypeF ? @"weather_f_kph" : @"weather_c_kph",
     self.color == WLWeahterLayerFontColorWhite ? 0 : 1,
     path];

    return [NSURL URLWithString:s];
}

@end
