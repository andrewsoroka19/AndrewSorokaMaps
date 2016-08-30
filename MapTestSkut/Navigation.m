//
//  Navigation.m
//  SorokaAndrewMaps
//
//  Created by Soroka Andrii on 7/27/16.
//  Copyright © 2016 Soroka Andrii. All rights reserved.
//

#import "Navigation.h"

@interface Navigation () <NSCoding>

@end

@implementation Navigation

+(Navigation *)newLocationWithName: (NSString*) name andAdress: (NSString*) adress andDescription: (NSString*) description andLatitude: (NSNumber*) latitude andLongtitude: (NSNumber*) longtitude AndISO:(NSString *)isoCode {
  
  Navigation *location = [[Navigation alloc] init];
  
  location.locationName = name;
  location.locationAdress = adress;
  location.locationDescription = description;
  location.iso = isoCode;
  location.locationLatitude = latitude;
  location.locationLongtitude = longtitude;
  
  
  return location;
  
}

- (void)encodeWithCoder:(NSCoder *)encoder {
  
  
  //Encode properties
  [encoder encodeObject:self.locationName forKey:@"locationName"];
  [encoder encodeObject:self.locationAdress forKey:@"locationAdress"];
  [encoder encodeObject:self.locationLatitude forKey:@"locationLatitude"];
  [encoder encodeObject:self.locationLongtitude forKey:@"locationLongtitude"];
  [encoder encodeObject:self.locationDescription forKey:@"locationDescription"];
  [encoder encodeObject:self.iso forKey:@"iso"];
}

- (id)initWithCoder:(NSCoder *)decoder {
  
  if((self = [super init])) {
    
    //decode properties
    self.locationName = [decoder decodeObjectForKey:@"locationName"];
    self.locationAdress = [decoder decodeObjectForKey:@"locationAdress"];
    self.locationLatitude = [decoder decodeObjectForKey:@"locationLatitude"];
    self.locationLongtitude = [decoder decodeObjectForKey:@"locationLongtitude"];
    self.locationDescription = [decoder decodeObjectForKey:@"locationDescription"];
    self.iso = [decoder decodeObjectForKey:@"iso"];
    
  }
  return self;
}


@end
