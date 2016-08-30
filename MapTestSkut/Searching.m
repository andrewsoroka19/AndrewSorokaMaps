//
//  Searching.m
//  SorokaAndrewMaps
//
//  Created by Soroka Andrii on 7/28/16.
//  Copyright © 2016 Soroka Andrii. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "Searching.h"
#import "Navigation.h"

@interface Searching ()


@property(nonatomic, assign) MKCoordinateRegion boundingRegion;
@property(nonatomic, strong) NSArray<MKMapItem *> *places;
@property(nonatomic, strong) MKLocalSearch *localSearch;

@end



@implementation Searching


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.places.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellIdentifier = @"SearchCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:cellIdentifier];
  }
 
  
  NSMutableString *cellText = [[NSMutableString alloc] init];
  if (self.places[indexPath.row].placemark.name) {
    [cellText appendFormat:@"%@, ", self.places[indexPath.row].placemark.name];
  }
  if (self.places[indexPath.row].placemark.thoroughfare) {
    [cellText appendFormat:@"%@, ", self.places[indexPath.row].placemark.thoroughfare];
  }
  if (self.places[indexPath.row].placemark.subThoroughfare) {
    [cellText appendFormat:@"%@, ", self.places[indexPath.row].placemark.subThoroughfare];
  }
  if (self.places[indexPath.row].placemark.locality) {
    [cellText appendFormat:@"%@, ", self.places[indexPath.row].placemark.locality];
  }
  if (self.places[indexPath.row].placemark.country) {
    [cellText appendFormat:@"%@ ", self.places[indexPath.row].placemark.country];
  }
  cell.textLabel.text = cellText;
  return cell;
}

- (void)searchForString:(NSString *)searchText
    AtLocationWithCoordinates:(CLLocationCoordinate2D)coordinates {
  MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
  MKCoordinateRegion newRegion;
  newRegion.center.longitude = coordinates.latitude;
  newRegion.center.longitude = coordinates.longitude;
  newRegion.span.latitudeDelta = 1;
  newRegion.span.longitudeDelta = 1;

  request.naturalLanguageQuery = searchText;
  request.region = newRegion;

  if (self.localSearch != nil) {
    self.localSearch = nil;
  }
  self.localSearch = [[MKLocalSearch alloc] initWithRequest:request];

  [self.localSearch startWithCompletionHandler:^(
                        MKLocalSearchResponse *response, NSError *error) {
    if (error != nil) {

    } else {
      self.places = [response mapItems];
      self.boundingRegion = response.boundingRegion;
      NSLog(@"%lu", self.places.count);
      [self.tableView reloadData];
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
  }];
  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  CLPlacemark *placemark = self.places[indexPath.row].placemark;
  Navigation* location = [Navigation newLocationWithName:placemark.name
                                               andAdress:placemark.country
                                          andDescription:placemark.locality
                                             andLatitude:@(placemark.location.coordinate.latitude)
                                           andLongtitude:@(placemark.location.coordinate.longitude)
                                                  AndISO:placemark.ISOcountryCode];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"myNotification" object:nil userInfo:@{ @"NavigationLocation":location}];
 
  [self dismissViewControllerAnimated:YES completion:nil];
}


@end
