//
//  Navigation.h
//  SorokaAndrewMaps
//
//  Created by Soroka Andrii on 7/27/16.
//  Copyright © 2016 Soroka Andrii. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Navigation : NSObject

@property (strong, nonatomic) NSString* locationName;
@property (strong, nonatomic) NSString* locationAdress;
@property (strong, nonatomic) NSString *iso;
@property (strong, nonatomic) NSNumber* locationLatitude;
@property (strong, nonatomic) NSNumber* locationLongtitude;

@property (strong, nonatomic) NSString* locationDescription;


//Factory class method to create new locations
+(Navigation *)newLocationWithName: (NSString*) name andAdress: (NSString*) adress andDescription: (NSString*) description andLatitude: (NSNumber*) latitude andLongtitude: (NSNumber*) longtitude AndISO:(NSString *)isoCode;

@end
