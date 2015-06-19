//
//  ViewController.h
//  biketastic
//
//  Created by Keyvan Hardani.
//  Copyright (c) 2014 iAppi.de Softwareentwicklung™. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "RegionAnnotation.h"
#import "RegionAnnotationView.h"
#import "RCLocationManager.h"

@interface ViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate>
{    
	// the map view
	MKMapView* _mapView;
	
    // routes points
    NSMutableArray* _points;
    
	// the data representing the route points. 
	MKPolyline* _routeLine;
	
	// the view we create for the line on the map
	MKPolylineView* _routeLineView;
	
	// the rect that bounds the loaded points
	MKMapRect _routeRect;
    
    // location manager
    CLLocationManager* _locationManager;    
    
    // current location
    CLLocation* _currentLocation;
    
    MKMapCamera *mapCamera;
}
- (IBAction)postToFacebook:(id)sender;
// - (IBAction)postToTwitter:(id)sender;

@property (nonatomic, retain) MKMapView* mapView;
@property (nonatomic, retain) NSMutableArray* points;
@property (nonatomic, retain) MKPolyline* routeLine;
@property (nonatomic, retain) MKPolylineView* routeLineView;
@property (nonatomic, retain) CLLocationManager* locationManager;
@property (strong, nonatomic) UILabel *postfb;

// Speed Set
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (strong, nonatomic) UIImageView *arrow;
@property (weak, nonatomic) IBOutlet UIImageView *baseImageView;
@property (weak, nonatomic) IBOutlet UILabel *reminderLabel;
@property (weak, nonatomic) IBOutlet UILabel *centralSpeedLabel;
@property (weak, nonatomic) IBOutlet UILabel *centralDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *hundredLabel;
@property (weak, nonatomic) IBOutlet UILabel *hundredDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mirrorImageView;
@property double currentSpeed;
@property double lastKnownSpeed;
@property bool animating;
@property (strong, nonatomic) NSDate *date;
@property float lastCalculatedValue;

@property (strong, nonatomic) CLLocationManager *manager;

-(void) configureRoutes;



@end
