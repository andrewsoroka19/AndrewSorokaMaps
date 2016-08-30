//
//  MapAnnotation.h
//  SorokaAndrewMaps
//
//  Created by Soroka Andrii on 7/19/16.
//  Copyright © 2016 Soroka Andrii. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>

@interface MapAnnotation : NSObject <MKAnnotation>


@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, strong) NSString *iso;

@end
