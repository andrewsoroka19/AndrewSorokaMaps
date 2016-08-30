//
//  AnnotationView.m
//  MapTestSkut
//
//  Created by Soroka Andrii on 7/20/16.
//  Copyright © 2016 Soroka Andrii. All rights reserved.
//

#import "AnnotationView.h"

#import <MapKit/MKAnnotationView.h>

@implementation AnnotationView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (AnnotationView*) superAnnotationView {
  if ([self.superview isKindOfClass:[AnnotationView class]]) {
    return (AnnotationView*) self.superview;
  }
  
}


@end
