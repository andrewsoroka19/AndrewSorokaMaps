//
//  TableViewController.m
//  SorokaAndrewMaps
//
//  Created by Soroka Andrii on 7/26/16.
//  Copyright © 2016 Soroka Andrii. All rights reserved.
//

#import "TableViewController.h"
#import "Navigation.h"

@interface TableViewController ()

@property (strong, nonatomic) __block NSMutableArray *data;

@property (nonatomic) NSInteger selectedLocationIndex;


@end

@implementation TableViewController

- (void)viewDidLoad {
  
  
  [super viewDidLoad];
  
  if ([[UIDevice currentDevice].model isEqualToString:@"iPad"]) {
    [self.view setNeedsLayout];
    UIView* backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
      backgroundView.backgroundColor = [UIColor clearColor];
      
      UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
      UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
      blurEffectView.frame = backgroundView.bounds;
      blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
      
      [backgroundView addSubview:blurEffectView];
    } else {
      backgroundView.backgroundColor = [UIColor clearColor];
    }
  
    
    [self.view addSubview:backgroundView];
    [self.view sendSubviewToBack:backgroundView];
    
    
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.view setBackgroundColor:[UIColor clearColor]];
  }

  
  self.data = [[NSMutableArray alloc] init];
  
  Navigation* lviv = [Navigation newLocationWithName:@"Ukraine"
                                               andAdress:@"Lviv"
                                          andDescription:@"Test location description1"
                                             andLatitude:@49.833247
                                           andLongtitude:@23.99974
                                              AndISO:@"UA"];
  [self.data addObject:lviv];
  
  Navigation* kiev = [Navigation newLocationWithName:@"Ukraine"
                                               andAdress:@"Kiev"
                                          andDescription:@"Test location description2"
                                             andLatitude:@50.4501
                                           andLongtitude:@30.5234
                                              AndISO:@"UA"];
  [self.data addObject:kiev];
  
  Navigation* rome = [Navigation newLocationWithName:@"Italy"
                                               andAdress:@"Rome"
                                          andDescription:@"Test location description3"
                                             andLatitude:@41.8905
                                           andLongtitude:@12.4942
                                              AndISO:@"IT"];
  [self.data addObject:rome];
  
  Navigation* newyork = [Navigation newLocationWithName:@"USA"
                                                andAdress:@"New York"
                                           andDescription:@"Test location description3"
                                              andLatitude:@40.7144
                                            andLongtitude:@-74.006
                                                 AndISO:@"US"];
  [self.data addObject:newyork];

  
   
  
  
}

- (void)sendNotification {
  [[NSNotificationCenter defaultCenter] postNotificationName:@"myNotification" object:nil userInfo:@{ @"NavigationLocation": [self.data objectAtIndex:self.selectedLocationIndex]}];
  
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

  
  
  static NSString *cellIdentifier = @"TableCell";
  
  UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  cell.textLabel.text = [self.data[indexPath.row] locationAdress];
  [cell setBackgroundColor:[UIColor clearColor]];
  return cell;
  
  
  
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  
  self.selectedLocationIndex = indexPath.row;
  
  [self sendNotification];
  
}

@end
