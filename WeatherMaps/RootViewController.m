//
//  RootViewController.m
//  WeatherMaps
//
//  Created by Watanabe Toshinori on 11/08/28.
//  Copyright 2011年 FLCL.jp. All rights reserved.
//

#import "RootViewController.h"
#import "WeatherOverlay.h"
#import "WeatherOverlayView.h"
#import "TileManager.h"


@interface RootViewController ()
@property (nonatomic, retain) WeatherOverlayView *overlayView_;
@end

@interface RootViewController (MKMapViewDelegate) <MKMapViewDelegate>
@end



@implementation RootViewController

@synthesize mapView_;
@synthesize overlayView_;


#pragma mark - Instance

- (void)dealloc
{
    [self viewDidUnload];
    
    self.overlayView_ = nil;
    
    [super dealloc];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Weather";

    WeatherOverlay *overlay = [[WeatherOverlay new] autorelease];
    [mapView_ addOverlay:overlay];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    self.mapView_ = nil;
}

@end


#pragma mark -
@implementation RootViewController (MKMapViewDelegate)

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    if (!overlayView_) {
        self.overlayView_ = [[[WeatherOverlayView alloc] initWithOverlay:overlay] autorelease];
    }
    return overlayView_;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    MKMapRect mapRect = mapView_.visibleMapRect;
    MKZoomScale zoomScale = mapView.bounds.size.width / mapView.visibleMapRect.size.width;
    
    [[TileManager sharedTileManager] loadTilesInMapRect:mapRect zoomScale:zoomScale completion:^{
        [overlayView_ setNeedsDisplayInMapRect:mapView_.visibleMapRect];
    }];
}

@end
