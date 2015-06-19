//
//  ViewController.m
//  biketastic
//
//  Created by Keyvan Hardani.
//  Copyright (c) 2014 iAppi.de Softwareentwicklung™. All rights reserved.
//

#import "ViewController.h"
#import <Social/Social.h>
#import <QuartzCore/QuartzCore.h>
#import "PRTween.h"
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)


#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@interface ViewController () <RCLocationManagerDelegate, MKMapViewDelegate>
{
    RCLocationManager *llocationManager;
}

- (IBAction)addRegion:(id)sender;

@end

@implementation ViewController

@synthesize points = _points;
@synthesize mapView = _mapView;
@synthesize routeLine = _routeLine;
@synthesize routeLineView = _routeLineView;
@synthesize locationManager = _locationManager;




- (void)viewDidLoad
{
    [super viewDidLoad];

    // MapView option
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];    
    self.mapView.delegate = self;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
#ifdef __IPHONE_8_0
    if(IS_OS_8_OR_LATER) {
        // Use one or the other, not both. Depending on what you put in info.plist
      //  [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager requestAlwaysAuthorization];
    }
#endif
    [self.locationManager startUpdatingLocation];
    
    self.mapView.showsUserLocation = YES;
    self.mapView.userInteractionEnabled = YES;
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    [self.view addSubview:self.mapView];

    // Map Location
 CLLocationCoordinate2D breckenridgeLocation = CLLocationCoordinate2DMake(39.4864, -106.0436);
    
  self.mapView.centerCoordinate = breckenridgeLocation;
    
    //self.mapView.region = MKCoordinateRegionMakeWithDistance(breckenridgeLocation, 10000, 10000);
    
    // 3D Set
    
    //Set a few MKMapView Properties to allow pitch, building view, points of interest, and zooming.
    
    self.mapView.pitchEnabled = YES;
    
    self.mapView.showsBuildings = YES;
    
    self.mapView.showsPointsOfInterest = YES;
    
    self.mapView.zoomEnabled = YES;
    
    self.mapView.scrollEnabled = YES;
    
    self.mapView.zoomEnabled = YES;
    
    
    
    //Set MKmapView camera property
    
    self.mapView.pitchEnabled = YES;
    
    self.mapView.showsBuildings = YES;
    
    self.mapView.showsPointsOfInterest = YES;
    
    self.mapView.zoomEnabled = YES;
    
    self.mapView.scrollEnabled = YES;
    
    self.mapView.zoomEnabled = YES;
    
    // Create location manager with filters set for battery efficiency.
    llocationManager = [[RCLocationManager alloc] initWithUserDistanceFilter:kCLLocationAccuracyHundredMeters userDesiredAccuracy:kCLLocationAccuracyBest purpose:@"My custom purpose message" delegate:self];

    
    
    // Start updating location changes.
    [llocationManager startUpdatingLocation];
    
    
    //set up initial location
    
    CLLocationCoordinate2D ground = CLLocationCoordinate2DMake(40.6892, -74.0444);
    
    CLLocationCoordinate2D eye = CLLocationCoordinate2DMake(40.6892, -74.0500);
    
    MKMapCamera *_mapCamera = [MKMapCamera cameraLookingAtCenterCoordinate:ground
                              
                                                        fromEyeCoordinate:eye
                              
                                                              eyeAltitude:700];
    
   //[UIView animateWithDuration:25.0 animations:^{
    
    self.mapView.camera = _mapCamera;

    
  //   }];
    
    
    
    // active Route
    [self configureRoutes];
    
    // Set Speed
    
    [self setupViews];
    [self setupCoreLocationStack];
    self.currentSpeed = 0;
    self.animating = NO;
    self.lastCalculatedValue = 0;
    
    [NSTimer scheduledTimerWithTimeInterval:0.3
                                     target:self
                                   selector:@selector(updateSpeedometer)
                                   userInfo:nil
                                    repeats:YES];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    
    self.mapView = nil;
	self.routeLine = nil;
	self.routeLineView = nil;
    
    [llocationManager stopUpdatingLocation];
    [llocationManager stopMonitoringAllRegions];
    llocationManager.delegate = nil;
    llocationManager = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}
/*
 
 // if you want to post into twitter
 // please active .h IBAction and import Socialframwork.
 
- (IBAction)postToTwitter:(id)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:@"I am Here!"];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }
}
*/

// Start Share Option

- (IBAction)postToFacebook:(id)sender {
    NSArray*postfb;
    postfb = @[_postfb.text = @"Your Text Here"];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:postfb applicationActivities:nil];
    
    [self presentViewController:activityController animated:YES completion:NULL];
}

// Mapview Tracking Pointer

#pragma mark
#pragma mark Map View

- (void)configureRoutes
{
    // define minimum, maximum points
	MKMapPoint northEastPoint = MKMapPointMake(0.f, 0.f); 
	MKMapPoint southWestPoint = MKMapPointMake(0.f, 0.f); 
	
	// create a c array of points. 
	MKMapPoint* pointArray = malloc(sizeof(CLLocationCoordinate2D) * _points.count);
    
	// for(int idx = 0; idx < pointStrings.count; idx++)
    for(int idx = 0; idx < _points.count; idx++)
	{        
        CLLocation *location = [_points objectAtIndex:idx];  
        CLLocationDegrees latitude  = location.coordinate.latitude;
		CLLocationDegrees longitude = location.coordinate.longitude;		 
        
		// create our coordinate and add it to the correct spot in the array 
		CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
		MKMapPoint point = MKMapPointForCoordinate(coordinate);
		
		// if it is the first point, just use them, since we have nothing to compare to yet. 
		if (idx == 0) {
			northEastPoint = point;
			southWestPoint = point;
		} else {
			if (point.x > northEastPoint.x) 
				northEastPoint.x = point.x;
			if(point.y > northEastPoint.y)
				northEastPoint.y = point.y;
			if (point.x < southWestPoint.x) 
				southWestPoint.x = point.x;
			if (point.y < southWestPoint.y) 
				southWestPoint.y = point.y;
		}
        
		pointArray[idx] = point;        
	}
	
    if (self.routeLine) {
        [self.mapView removeOverlay:self.routeLine];
    }
    
    self.routeLine = [MKPolyline polylineWithPoints:pointArray count:_points.count];
    
    // add the overlay to the map
	if (nil != self.routeLine) {
		[self.mapView addOverlay:self.routeLine];
	}
    
    // clear the memory allocated earlier for the points
	free(pointArray);	
    
    
    // Zooming Option ( if you want to zoom in on the route, Active this )!
   
    
     
     double width = northEastPoint.x - southWestPoint.x;
     double height = northEastPoint.y - southWestPoint.y;
     
     _routeRect = MKMapRectMake(southWestPoint.x, southWestPoint.y, width, height);    	
     
     // zoom in on the route. 
     [self.mapView setVisibleMapRect:_routeRect];
    
    
}

// Location Option with NSLog to see Tracking log!

 #pragma mark
 #pragma mark Location Manager
 
 - (void)configureLocationManager
 {
 
 if (nil == _locationManager)
     
        _locationManager = [[CLLocationManager alloc] init];
     [_locationManager requestAlwaysAuthorization];
     _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        _locationManager.distanceFilter = 1;
    [_locationManager startUpdatingLocation];
    [_locationManager startMonitoringSignificantLocationChanges];
 }
 
 #pragma mark
 #pragma mark CLLocationManager delegate methods
 - (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
 {
 NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
 
 // If it's a relatively recent event, turn off updates to save power
 NSDate* eventDate = newLocation.timestamp;
 NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];    
 
 if (abs(howRecent) < 2.0)
 {
 NSLog(@"recent: %d", abs(howRecent));
 NSLog(@"latitude %+.6f, longitude %+.6f\n", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
 }
 
 // else skip the event and process the next one
 }
 
 - (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
 {
 NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
 NSLog(@"error: %@",error);
 }


#pragma mark
#pragma mark MKMapViewDelegate
- (void)mapView:(MKMapView *)mapView didAddOverlayViews:(NSArray *)overlayViews
{
    NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
    NSLog(@"overlayViews: %@", overlayViews);
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));

	MKOverlayView* overlayView = nil;
	
	if(overlay == self.routeLine)
	{
        if (self.routeLineView) {
            [self.routeLineView removeFromSuperview];
        }
        
        self.routeLineView = [[MKPolylineView alloc] initWithPolyline:self.routeLine];
        self.routeLineView.fillColor = [UIColor greenColor];
        self.routeLineView.strokeColor = [UIColor greenColor];
        self.routeLineView.lineWidth = 5;
        
		overlayView = self.routeLineView;		
	}
	
	return overlayView;
}


- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
   NSLog(@"views: %@", views);
}


 - (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
 {
 NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
 }
 
 - (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated
 {
 NSLog(@"");
 }
 
 - (void)mapViewWillStartLocatingUser:(MKMapView *)mapView
 {
 NSLog(@"");
 }
 
 - (void)mapViewDidStopLocatingUser:(MKMapView *)mapView
 {
 NSLog(@"");
 }


- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:userLocation.coordinate.latitude 
                                                      longitude:userLocation.coordinate.longitude];
    

    // Check and Line Option
    
    if  (userLocation.coordinate.latitude == 0.0f ||
         userLocation.coordinate.longitude == 0.0f)
        return;
    
    if (_points.count > 0) {        
        CLLocationDistance distance = [location distanceFromLocation:_currentLocation];        
        if (distance < 5) 
            return;        
    }        
    
    if (nil == _points) {
        _points = [[NSMutableArray alloc] init];
    }
    
    [_points addObject:location];	
    _currentLocation = location;

    
    [self configureRoutes];
    
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);
    [self.mapView setCenterCoordinate:coordinate animated:YES];
}

    // Pin Design

- (MKAnnotationView *) mapView:(MKMapView *)mapView
             viewForAnnotation:(id <MKAnnotation>) annotation {
    MKPinAnnotationView *annView=[[MKPinAnnotationView alloc]
                                  initWithAnnotation:annotation reuseIdentifier:@"pin"];
    annView.image=[UIImage imageNamed:@"pin.png"];
    
    
    return annView;
}

- (void) updateSpeedometer
{
    if (self.lastKnownSpeed == 0 && self.currentSpeed > 0)
    {
        self.date = [NSDate date];
    }
    
    
    PRTweenPeriod *period = [PRTweenPeriod periodWithStartValue:self.lastCalculatedValue endValue:self.currentSpeed duration:0.9];
    
    PRTweenOperation *operation = [PRTweenOperation new];
    operation.period = period;
    operation.target = self;
    operation.timingFunction = &PRTweenTimingFunctionLinear;
    operation.updateSelector = @selector(update:);
    [[PRTween sharedInstance] addTweenOperation:operation];
    
    
    if (self.currentSpeed < 100) {
        [self updateTimeLabel];
    }
}

- (void)update:(PRTweenPeriod*)period {
    
    self.centralSpeedLabel.text = [NSString stringWithFormat:@"%d", (int) period.tweenedValue];
    self.lastCalculatedValue = period.tweenedValue;
}


- (void) updateTimeLabel
{
    NSTimeInterval interval = [self.date timeIntervalSinceNow];
    double interval2 = fabs(interval);
    if (interval2 > 60) {
        interval2 = 0;
    }
    self.hundredLabel.text = [NSString stringWithFormat:@"%.1f", interval2];
}

- (void) setupCoreLocationStack
{
    
    
    self.manager.delegate = self;
    self.manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    [self.manager startUpdatingLocation];
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *loc = [locations lastObject];
    self.lastKnownSpeed = self.currentSpeed;
    self.currentSpeed = loc.speed * 3.6;
    
    if (self.currentSpeed < 0) {
        self.currentSpeed = 0;
    }
}


- (void) setupViews
{
    
    for (UILabel *label in self.view.subviews) {
        
        if ([label class] == [UILabel class])
        {
            label.textAlignment = NSTextAlignmentCenter;
        }
    }
    
    UIImageView *circleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"km.png"]];
    circleView.frame = CGRectMake(200, 200, 120, 120);
    circleView.center = self.baseImageView.center;
    circleView.center = CGPointMake(self.baseImageView.center.x, self.baseImageView.center.y + 23 );
    [self.view addSubview:circleView];
    
    self.centralSpeedLabel.textColor = [UIColor whiteColor];
    self.centralSpeedLabel.font = [UIFont fontWithName:@"EurostileLT-Oblique" size:45];
    
    self.centralDescriptionLabel.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
    self.centralDescriptionLabel.text = @"km/h";
    self.centralDescriptionLabel.font = [UIFont fontWithName:@"EurostileLT-Oblique" size:18];
    
    self.hundredLabel.textColor = [UIColor whiteColor];
    self.hundredLabel.font = [UIFont fontWithName:@"EurostileLT-Oblique" size:30];
    self.hundredLabel.text = @"7,6";
    
    self.hundredDescriptionLabel.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
    self.hundredDescriptionLabel.font = [UIFont fontWithName:@"EurostileLT-Oblique" size:15];
    self.hundredDescriptionLabel.text = @"0-100";
    
    [self.view bringSubviewToFront:self.centralSpeedLabel];
    [self.view bringSubviewToFront:self.centralDescriptionLabel];
    
    if (IS_IPHONE_5) {
        self.baseImageView.frame = CGRectMake(self.baseImageView.frame.origin.x, self.baseImageView.frame.origin.y + 100, self.baseImageView.frame.size.width, self.baseImageView.frame.size.height);
        NSLog(@"speed?");
    }
}


#pragma mark - RCLocationManagerDelegate

- (void)llocationManager:(RCLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    // Work around a bug in MapKit where user location is not initially zoomed to.
    if (oldLocation == nil) {
        MKCoordinateRegion userLocation = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 1500.0, 1500.0);
        [self.mapView setRegion:userLocation animated:YES];
    }
}

#pragma mark - IBAction's

- (IBAction)addRegion:(id)sender
{
    if ([RCLocationManager regionMonitoringAvailable]) {
		// Create a new region based on the center of the map view.
		CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(self.mapView.centerCoordinate.latitude, self.mapView.centerCoordinate.longitude);
		CLRegion *newRegion = [[CLRegion alloc] initCircularRegionWithCenter:coord
																	  radius:1000.0
																  identifier:[NSString stringWithFormat:@"%f, %f", self.mapView.centerCoordinate.latitude, self.mapView.centerCoordinate.longitude]];
		
        
		// Create an annotation to show where the region is located on the map.
		RegionAnnotation *myRegionAnnotation = [[RegionAnnotation alloc] initWithCLRegion:newRegion];
		myRegionAnnotation.coordinate = newRegion.center;
		myRegionAnnotation.radius = newRegion.radius;
		
		[self.mapView addAnnotation:myRegionAnnotation];
		
		
		// Start monitoring the newly created region.
        [llocationManager addRegionForMonitoring:newRegion desiredAccuracy:kCLLocationAccuracyBest];
	}
	else {
		NSLog(@"Region monitoring is not available.");
	}}


@end