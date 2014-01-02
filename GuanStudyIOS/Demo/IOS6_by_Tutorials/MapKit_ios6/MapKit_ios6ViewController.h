//
//  MapKit_ios6ViewController.h
//  GuanStudyIOS
//
//  Created by macmini on 13-12-30.
//  Copyright (c) 2013 城云 官. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface MapKit_ios6ViewController :BaseViewController

- (void)routeFrom:(CLLocationCoordinate2D)from to:(CLLocationCoordinate2D)to;
- (void)routeFromCurrentLocationTo:(CLLocationCoordinate2D)to;
- (void)routeToCurrentLocationFrom:(CLLocationCoordinate2D)from;

@end
