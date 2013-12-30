//
//  MapKit_ios6ViewController.m
//  GuanStudyIOS
//
//  Created by macmini on 13-12-30.
//  Copyright (c) 2013 城云 官. All rights reserved.
//

#import "MapKit_ios6ViewController.h"
#import <MapKit/MapKit.h>
#import "RWStation.h"

@interface MapKit_ios6ViewController ()<MKMapViewDelegate> {
    NSMutableArray *_stations;
    MKPolyline *_mapPolyline;
}

typedef NS_ENUM(NSInteger, RWMapMode) {
    RWMapModeNormal = 0,
    RWMapModeLoading,
    RWMapModeDirections,
};

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, assign) RWMapMode mapMode;

@end


@implementation MapKit_ios6ViewController

- (void)setMapMode:(RWMapMode)mapMode {
    _mapMode = mapMode;
    
    switch (mapMode) {
        case RWMapModeNormal: {
            self.title = @"Maps";
        }
            break;
        case RWMapModeLoading: {
            self.title = @"Loading...";
        }
            break;
        case RWMapModeDirections: {
            self.title = @"Directions";
        }
            break;
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadData{
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"victoria_line" ofType:@"json"]];
    NSArray *stationData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    NSUInteger stationCount = stationData.count;
    
    NSInteger i = 0;
    CLLocationCoordinate2D *polylineCoords = malloc(sizeof(CLLocationCoordinate2D)* stationCount);
    _stations = [[NSMutableArray alloc]initWithCapacity:stationCount];
    
    for (NSDictionary *stationDictionary in stationData) {
        CLLocationDegrees latitude = [[stationDictionary objectForKey:@"latitude"] doubleValue];
        CLLocationDegrees longitude = [[stationDictionary objectForKey:@"longitude"]doubleValue];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    }
}

@end
