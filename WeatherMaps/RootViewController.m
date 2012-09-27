//
//  RootViewController.m
//  WeatherMaps
//
//  Created by Watanabe Toshinori on 11/08/28.
//  Copyright 2011年 FLCL.jp. All rights reserved.
//

#import "RootViewController.h"
#import "WLWeatherLayer.h"
#import "WLWeatherLayerView.h"

@interface RootViewController ()
@property (nonatomic, strong) WLWeatherLayer *weatherLayer;
@end

@interface RootViewController (MKMapViewDelegate) <MKMapViewDelegate>
@end


@implementation RootViewController


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Weather";
 
    self.weatherLayer = [[WLWeatherLayer alloc] init];

    [self.mapView addOverlay:self.weatherLayer];
}

#pragma mark - Actions

- (IBAction)fontColorChanged:(UISegmentedControl *)sender
{
    self.weatherLayer.color = sender.selectedSegmentIndex;
    
    [self reloadLayer];
}

- (IBAction)unitTypeChanged:(UISegmentedControl *)sender
{
    self.weatherLayer.unitType = sender.selectedSegmentIndex;

    [self reloadLayer];
}


#pragma mark - Private method

- (void)reloadLayer
{
    [self.mapView removeOverlay:self.weatherLayer];
    [self.mapView addOverlay:self.weatherLayer];
}

@end


#pragma mark -
@implementation RootViewController (MKMapViewDelegate)

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    if (overlay == self.weatherLayer) {
        WLWeatherLayerView *view = [[WLWeatherLayerView alloc] initWithOverlay:overlay];
        return view;
    }
    
    return nil;
}

@end
