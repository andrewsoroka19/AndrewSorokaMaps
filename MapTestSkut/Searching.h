//
//  Searching.h
//  SorokaAndrewMaps
//
//  Created by Soroka Andrii on 7/28/16.
//  Copyright © 2016 Soroka Andrii. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface Searching : UITableViewController

- (void)searchForString:(NSString *)searchText AtLocationWithCoordinates: (CLLocationCoordinate2D) coordinates;


@end
