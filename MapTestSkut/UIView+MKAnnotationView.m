//
//  MKAnnotationView.m
//  SorokaAndrewMaps
//
//  Created by Soroka Andrii on 7/21/16.
//  Copyright © 2016 Soroka Andrii. All rights reserved.
//

#import "UIView+MKAnnotationView.h"
#import <MapKit/MKAnnotationView.h>


@implementation UIView (MKAnnotationView)

- (MKAnnotationView*) superAnnotationView {
  if ([self isKindOfClass:[MKAnnotationView class]]) {
    return (MKAnnotationView*) self;
  }
  if (!self.superview) {
    return nil;
  }
    
  return [self.superview superAnnotationView];
}

@end
