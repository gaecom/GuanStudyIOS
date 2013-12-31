//
//  RWRoute.h
//  GuanStudyIOS
//
//  Created by macmini on 13-12-31.
//  Copyright (c) 2013 城云 官. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@class RWStation;
@interface RWRoute : NSObject

@property (nonatomic, strong)RWStation *fromStation;
@property (nonatomic, strong)RWStation *toStation;
@property (nonatomic, strong)MKPolyline *mapPolyline;

@end
