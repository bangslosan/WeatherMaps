//
//  WMOverlay.h
//  WorldMap
//
//  Created by kishikawa katsumi on 2012/09/26.
//  Copyright (c) 2012 kishikawa katsumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef enum
{
    WLWeahterLayerFontColorWhite,
    WLWeahterLayerFontColorBlack
} WLWeahterLayerFontColor;

typedef enum
{
    WLWeahterLayerUnitTypeF,
    WLWeahterLayerUnitTypeC
} WLWeahterLayerUnitType;

@interface WLWeatherLayer : NSObject <MKOverlay>

@property (nonatomic) WLWeahterLayerFontColor color;
@property (nonatomic) WLWeahterLayerUnitType unitType;

- (NSURL *)imageURLWithTilePath:(NSString *)path;

@end
