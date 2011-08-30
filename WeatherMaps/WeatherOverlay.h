//
//  WeatherOverlay.h
//  WeatherMaps
//
//  Created by Watanabe Toshinori on 11/08/28.
//  Copyright 2011年 FLCL.jp. All rights reserved.
//

#import <MapKit/MapKit.h>


@interface WeatherOverlay : NSObject <MKOverlay>

@property (nonatomic, assign) MKMapRect boundingMapRect;

@end
