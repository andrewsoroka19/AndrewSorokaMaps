//
//  ViewController.h
//  SorokaAndrewMaps
//
//  Created by Soroka Andrii on 7/19/16.
//  Copyright © 2016 Soroka Andrii. All rights reserved.
//

#import <UIKit/UIKit.h>


@class MKMapView;

@interface ViewController : UIViewController<UIGestureRecognizerDelegate>
@property (weak,nonatomic) IBOutlet MKMapView* mapView;
- (IBAction)setMap:(id)sender;


@end

