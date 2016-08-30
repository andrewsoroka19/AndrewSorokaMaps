//
//  ViewController.m
//  SorokaAndrewMaps
//
//  Created by Soroka Andrii on 7/19/16.
//  Copyright © 2016 Soroka Andrii. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "MapAnnotation.h"
#import "UIView+MKAnnotationView.h"
#import "Navigation.h"
#import "Searching.h"


@interface ViewController () <MKMapViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) CLLocationManager* locationManager;
@property (strong, nonatomic) UILongPressGestureRecognizer *longPress;
@property (strong, nonatomic) CLGeocoder* geoCoder;
@property (strong, nonatomic) MKDirections* directions;
@property (strong, nonatomic) Searching* searchingController;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;



@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  UIBarButtonItem* addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(actionAdd:)];
  
  UIBarButtonItem* zoomButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(actionShowAll:)];
  
  self.searchingController = [[Searching alloc] init];
  
  self.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(respondToLongPress:)];
  [self.mapView addGestureRecognizer:self.longPress];
  self.longPress.delegate = self;
  
  self.navigationItem.leftBarButtonItems = @[addButton];

  self.navigationItem.rightBarButtonItems = @[zoomButton];
  [self askForUserLocationUsage];
  self.geoCoder = [[CLGeocoder alloc]init];

  
  
  
  
//  Navigation
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(receiveNotification:)
                                               name:@"myNotification"
                                             object:nil];
}



- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

  if (![self.presentedViewController isKindOfClass:Searching.class]) {
  self.searchingController.modalPresentationStyle = UIModalPresentationPopover;
    self.searchingController.popoverPresentationController.sourceView = self.searchBar;
  self.searchingController.popoverPresentationController.sourceRect = self.searchBar.bounds;
  [self presentViewController:self.searchingController
                     animated:YES
                   completion:nil];
  } else {
    [self.searchingController searchForString:searchText AtLocationWithCoordinates:self.mapView.centerCoordinate];
  }
}

- (void)receiveNotification:(NSNotification *)notification
{
  if ([[notification name] isEqualToString:@"myNotification"]) {
    NSLog(@"Notification recieved");
    Navigation *locationFromNotification = [notification.userInfo objectForKey:@"NavigationLocation"];
    MapAnnotation *annotation = [[MapAnnotation alloc] init];
    annotation.title = locationFromNotification.locationName;
    annotation.subtitle = locationFromNotification.locationAdress;
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([locationFromNotification.locationLatitude doubleValue], [locationFromNotification.locationLongtitude doubleValue]);
    annotation.coordinate = coordinate;
    annotation.iso = locationFromNotification.iso;
    
    MKCoordinateRegion selectedRegion;
    selectedRegion.center.latitude = [locationFromNotification.locationLatitude doubleValue];
    selectedRegion.center.longitude = [locationFromNotification.locationLongtitude doubleValue];
    selectedRegion.span.latitudeDelta = 20;
    selectedRegion.span.longitudeDelta = 20;
    
    [self.mapView addAnnotation:annotation];
    [self.mapView setRegion:selectedRegion animated:YES];
    
   }
}


- (void) dealloc {
  if ([self.geoCoder isGeocoding]) {
    [self.geoCoder cancelGeocode];
  }
  if ([self.directions isCalculating]) {
    [self.directions cancel];
  }
}


#pragma mark - Action

- (void) actionAdd: (UIBarButtonItem*) sender{
  
  CLLocation *location =
  [[CLLocation alloc] initWithLatitude:self.mapView.centerCoordinate.latitude
                             longitude:self.mapView.centerCoordinate.longitude];
  
  CLGeocoder *geocoder = [[CLGeocoder alloc] init];
  [geocoder reverseGeocodeLocation:location
                 completionHandler:^(NSArray<CLPlacemark *> *placemarks,
                                     NSError *error) {
                   MapAnnotation *annotation =
                   [[MapAnnotation alloc] init];
                   CLPlacemark *placemark = placemarks.firstObject;
                   if ([placemark.name isEqualToString:@""]) {
                     annotation.title = placemark.thoroughfare;
                     annotation.subtitle = placemark.locality;
                     annotation.iso = placemark.ISOcountryCode;
                   } else {
                     annotation.title = placemark.subAdministrativeArea;
                     annotation.subtitle = placemark.name;
                     annotation.iso = placemark.ISOcountryCode;
                   }
                   
                   annotation.coordinate = location.coordinate;
                   [self.mapView addAnnotation:annotation];
                 }];
  
}

- (void) actionShowAll:(UIBarButtonItem*) sender {
  MKMapRect zoomRect = MKMapRectNull;
  for (id <MKAnnotation> annotation in self.mapView.annotations) {
    CLLocationCoordinate2D location = annotation.coordinate;
    MKMapPoint center = MKMapPointForCoordinate(location);
    static double delta = 20000;
    MKMapRect rect = MKMapRectMake(center.x - delta, center.y - delta, delta * 2  , delta * 2);
    zoomRect = MKMapRectUnion(zoomRect, rect);
    }
  zoomRect = [self.mapView mapRectThatFits:zoomRect];
  [self.mapView setVisibleMapRect:zoomRect
                      edgePadding:UIEdgeInsetsMake(50, 50, 50, 50)
                         animated:YES];
}


// long pressed
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
  CGPoint touchLocation = [touch locationInView:self.mapView];
  UIView *view = [self.mapView hitTest:touchLocation withEvent:nil];
  if ([view isKindOfClass:[MKPinAnnotationView class]] && gestureRecognizer == self.longPress) {
    return NO;
  }
  return YES;
}


- (void)respondToLongPress:(UILongPressGestureRecognizer *)recognizer {
  if (recognizer.state == UIGestureRecognizerStateBegan) {
    MapAnnotation *annotation = [[MapAnnotation alloc] init];
    CGPoint touchLocation = [recognizer locationInView:self.mapView];
    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:touchLocation  toCoordinateFromView:self.mapView];
    annotation.coordinate = coordinate;
    
    CLLocation *location =
        [[CLLocation alloc] initWithLatitude:coordinate.latitude
                                   longitude:coordinate.longitude];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location
                   completionHandler:^(NSArray<CLPlacemark *> *placemarks,
                                       NSError *error) {
                     MapAnnotation *annotation =
                     [[MapAnnotation alloc] init];
                     CLPlacemark *placemark = placemarks.firstObject;
                     if ([placemark.name isEqualToString:@""]) {
                       annotation.title = placemark.thoroughfare;
                       annotation.subtitle = placemark.locality;
                       annotation.iso = placemark.ISOcountryCode;
                     } else {
                       annotation.title = placemark.subAdministrativeArea;
                       annotation.subtitle = placemark.name;
                       annotation.iso = placemark.ISOcountryCode;
                     }
                   
                     annotation.coordinate = location.coordinate;
                     [self.mapView addAnnotation:annotation];
                     
                   }];
  }
}





- (void) askForUserLocationUsage {
  
  //asking for user location
  self.locationManager = [[CLLocationManager alloc]init];
  
  if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
    
    NSLog(@"\n\nAccess to location services not determined asking for permission\n\n");
    if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"] && [self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
      [self.locationManager requestWhenInUseAuthorization];
    }
    
  } else if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
    
    NSLog(@"\n\nAccess to location services denied\n\n");
    
  } else if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
    
    NSLog(@"\n\nAccess to location services restricted\n\n");
  }
  
  if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
    
    NSLog(@"\n\nAccess to location services always allowed\n\n");
  } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
    
    NSLog(@"\n\nAccess to location services when in use allowed\n\n");
  }
  
}


#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(MapAnnotation *)annotation {
  if ([annotation isKindOfClass:[MKUserLocation class]]) {
    return nil;
  }
  
  NSString *URLString = [NSString
                         stringWithFormat:@"http://www.crwflags.com/fotw/images/%c/%@.gif",
                         [annotation.iso characterAtIndex:0], annotation.iso];
  NSLog(@"URL string: %@", URLString);
  NSURL *url = [NSURL URLWithString:URLString];
  UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
  
  
  static NSString *identifier = @"Annotation";
  MKPinAnnotationView *pin = (MKPinAnnotationView *)[mapView
      dequeueReusableAnnotationViewWithIdentifier:identifier];
  if (!pin) {
    pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                          reuseIdentifier:identifier];
    pin.pinTintColor = [UIColor purpleColor];
    pin.canShowCallout = YES;
    pin.draggable = YES;

    UIButton *descriptionButton =
        [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [descriptionButton addTarget:self
                          action:@selector(actionDescription:)
                forControlEvents:UIControlEventTouchUpInside];
    pin.rightCalloutAccessoryView = descriptionButton;

    UIButton *directionButton =
        [UIButton buttonWithType:UIButtonTypeContactAdd];
    [directionButton addTarget:self
                        action:@selector(actionDirection:)
              forControlEvents:UIControlEventTouchUpInside];
    UIImageView *flagView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    UIStackView *stackView = [[UIStackView alloc] initWithFrame:CGRectMake(0, 0, 90, 35)];
    stackView.spacing = 10;
    [stackView addArrangedSubview:flagView];
    [stackView addArrangedSubview:directionButton];
    pin.leftCalloutAccessoryView = stackView;
  } else {
    pin.annotation = annotation;
  }
  
  UIImageView *pinFlagView = pin.leftCalloutAccessoryView.subviews[0];
  pinFlagView.image = image;
  return pin;
}


- (void)mapView:(MKMapView *)mapView
 annotationView:(MKAnnotationView *)annotationView
didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState {
  if (oldState == MKAnnotationViewDragStateEnding &&
      newState == MKAnnotationViewDragStateNone) {
    CLLocationDegrees latitude = annotationView.annotation.coordinate.latitude;
    CLLocationDegrees longtitude =
        annotationView.annotation.coordinate.longitude;
    CLLocation *location =
    [[CLLocation alloc] initWithLatitude:latitude longitude:longtitude];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location
                   completionHandler:^(NSArray<CLPlacemark *> *placemarks,
                                       NSError *error) {
                     MapAnnotation*annotation =
                     [[MapAnnotation alloc] init];
                     CLPlacemark *placemark = placemarks.firstObject;
                     annotation.title = placemark.name;
                     annotation.subtitle = placemark.thoroughfare;
                     annotation.coordinate = location.coordinate;
                     annotation.iso = placemark.ISOcountryCode;
                      [self.mapView addAnnotation:annotation];
                     [self.mapView removeAnnotation:annotationView.annotation];
                     
                  }];
    }
}


// drawing routes
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay {
  if ([overlay isKindOfClass:[MKPolyline class]]) {
    
    MKPolylineRenderer* renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.lineWidth = 4.f;
    renderer.strokeColor = [UIColor colorWithRed:0.f green:0.5f blue:1.f alpha:0.9f];
    return renderer;
  }
  return nil;
}



#pragma mark - Actions

- (void) showAlertWithTitle:(NSString*) title andMessage:(NSString*) message {
  [[
    [UIAlertView alloc]
    initWithTitle:title
    message:message
    delegate:nil
    cancelButtonTitle:@"OK"
    otherButtonTitles: nil] show];
}

- (void) geocodeAddress:(NSString *)address {
  [[[CLGeocoder alloc] init] geocodeAddressString:address completionHandler:^(NSArray<CLPlacemark *> *placemarks, NSError *error) {
    NSLog(@"%@", placemarks.firstObject.name);
  }];
}

- (void) actionDescription:(UIButton*) sender {
  MKAnnotationView* annotationView = [sender superAnnotationView];
  if (!annotationView) {
    return;
  }
  CLLocationCoordinate2D coordinate = annotationView.annotation.coordinate;
  CLLocation* location = [[CLLocation alloc]initWithLatitude:coordinate.latitude
                                                   longitude:coordinate.longitude];
  [self geocodeAddress:@"Lviv"];
  [self.geoCoder reverseGeocodeLocation:location
                 completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                  
                   NSString* message = nil;
                   if (error) {
                     message = [error localizedDescription];
                   } else {
                     if ([placemarks count] > 0) {
                       CLPlacemark* placeMark = [placemarks firstObject];
                       message = [placeMark.addressDictionary description];
                     } else {
                       message = @"No Placemarks Found";
                     }
                   }
                   [self showAlertWithTitle:@"Location" andMessage:message];
               }];
  
}

//routes
- (void) actionDirection:(UIButton*) sender {
  MKAnnotationView* annotationView = [sender superAnnotationView];
  if (!annotationView) {
    return;
  }
  
  if ([self.directions isCalculating]) {
    [self.directions cancel];
  }
  
  CLLocationCoordinate2D coordinate = annotationView.annotation.coordinate;
  
  MKDirectionsRequest* request = [[MKDirectionsRequest alloc] init];
  request.source = [MKMapItem mapItemForCurrentLocation];
  MKPlacemark* placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
                                                 addressDictionary:nil];
  MKMapItem* destination = [[MKMapItem alloc]initWithPlacemark:placemark];
  request.destination = destination;
  request.transportType = MKDirectionsTransportTypeAutomobile;
  
  request.requestsAlternateRoutes = YES;
  
  self.directions = [[MKDirections alloc] initWithRequest:request];
  
  [self.directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * response, NSError * error) {
  
    if (error) {
      [self showAlertWithTitle:@"Error" andMessage:[error localizedDescription]];
    } else if ([response.routes count] == 0) {
      [self showAlertWithTitle:@"Error" andMessage:@"No routes found"];
    } else {
      
      [self.mapView removeOverlays:[self.mapView overlays]];
      
      NSMutableArray* array = [NSMutableArray array];
      for (MKRoute* route in response.routes) {
        [array addObject:route.polyline];
      }
      
      [self.mapView addOverlays:array level:MKOverlayLevelAboveRoads];
    }

  }];
  
  
}

- (IBAction)setMap:(id)sender {
  switch (((UISegmentedControl*)sender).selectedSegmentIndex) {
    case 0:
      _mapView.mapType = MKMapTypeStandard;
      break;
    case 1:
      _mapView.mapType = MKMapTypeSatellite;
      break;
    case 2:
      _mapView.mapType = MKMapTypeHybrid;
      break;
    case 3:
      _mapView.mapType = MKMapTypeSatelliteFlyover;
      break;
      
    default:
      break;
  }
}



@end
