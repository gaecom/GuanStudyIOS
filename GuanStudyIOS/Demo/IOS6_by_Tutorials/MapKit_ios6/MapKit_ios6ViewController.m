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
#import "RWRoute.h"

typedef void (^RWLocationCallback)(CLLocationCoordinate2D);

@interface MapKit_ios6ViewController ()<MKMapViewDelegate,UIActionSheetDelegate> {
    NSMutableArray *_stations;
    MKPolyline *_mapPolyline;
    RWStation *_droppedPin;
    RWLocationCallback _foundLocationCallback;
    RWRoute *_currentRoute;
    RWStation *_selectedStation;
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
//            self.navigationItem.leftBarButtonItem = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Show in Maps" style:UIBarButtonItemStyleBordered target:self action:@selector(showInMaps:)];
            
            if (_currentRoute) {
                [self.mapView removeAnnotation:_currentRoute.fromStation];
                [self.mapView removeAnnotation:_currentRoute.toStation];
                [self.mapView removeOverlay:_currentRoute.mapPolyline];
                _currentRoute = nil;
            }
            
            [self.mapView addAnnotations:_stations];
            [self.mapView addOverlay:_mapPolyline];
            if (_droppedPin) {
                [self.mapView addAnnotation:_droppedPin];
            }
        }
            break;
        case RWMapModeLoading: {
            self.title = @"Loading...";
            self.navigationItem.leftBarButtonItem = nil;
            self.navigationItem.rightBarButtonItem = nil;
            
            if (_currentRoute) {
                [self.mapView removeAnnotation:_currentRoute.fromStation];
                [self.mapView removeAnnotation:_currentRoute.toStation];
                [self.mapView removeOverlay:_currentRoute.mapPolyline];
                _currentRoute = nil;
            }
            
            [self.mapView removeAnnotations:_stations];
            [self.mapView removeOverlay:_mapPolyline];
            if (_droppedPin) {
                [self.mapView removeAnnotation:_droppedPin];
            }
        }
            break;
        case RWMapModeDirections: {
            self.title = @"Directions";
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStyleBordered target:self action:@selector(clearDirections:)];
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Route in Maps" style:UIBarButtonItemStyleBordered target:self action:@selector(routeInMaps:)];
            
            [self.mapView removeAnnotations:_stations];
            [self.mapView removeOverlay:_mapPolyline];
            if (_droppedPin) {
                [self.mapView removeAnnotation:_droppedPin];
            }
            
            [self.mapView addAnnotation:_currentRoute.fromStation];
            [self.mapView addAnnotation:_currentRoute.toStation];
            [self.mapView addOverlay:_currentRoute.mapPolyline];
        }
            break;
    }
}

-(void)routeInMaps:(id)sender{
    NSArray *mapItems = @[[_currentRoute.fromStation mapItem],[_currentRoute.toStation mapItem]];
    NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving};
    [MKMapItem openMapsWithItems:mapItems launchOptions:launchOptions];
}

-(void)clearDirections:(id)sender{
    self.mapMode = RWMapModeNormal;
}

-(void)showInMaps:(id)sender{
    // 1
    NSMutableArray *mapItems = [[NSMutableArray alloc] init];
    for (RWStation *station in _stations) {
        [mapItems addObject:[station mapItem]];
    }
    [mapItems addObject:[MKMapItem mapItemForCurrentLocation]];
    
    // 2
    MKMapRect boundingBox = [_mapPolyline boundingMapRect];
    MKCoordinateRegion boundingBoxRegion = MKCoordinateRegionForMapRect(boundingBox);
    
    // 3
    NSValue *centerAsValue = [NSValue valueWithMKCoordinate:boundingBoxRegion.center];
    NSValue *spanAsValue = [NSValue valueWithMKCoordinateSpan:boundingBoxRegion.span];
    
    // 4
    NSDictionary *launchOptions = @{MKLaunchOptionsMapTypeKey : @(MKMapTypeHybrid), MKLaunchOptionsMapCenterKey : centerAsValue, MKLaunchOptionsMapSpanKey : spanAsValue};
    
    // 5
    [MKMapItem openMapsWithItems:mapItems launchOptions:launchOptions];
}

- (void)routeFrom:(CLLocationCoordinate2D)from to:(CLLocationCoordinate2D)to {
    // 1
    RWStation *fromStation = [self nearestStationToCoordinate:from];
    RWStation *toStation = [self nearestStationToCoordinate:to];
    
    // 2
    NSUInteger fromStationIdx = [_stations indexOfObject:fromStation];
    NSUInteger toStationIdx = [_stations indexOfObject:toStation];
    
    // 3
    BOOL forwards = (toStationIdx > fromStationIdx);
    
    // 4
    NSUInteger stationCount = 0;
    if (forwards) {
        stationCount = toStationIdx - fromStationIdx + 1;
    } else {
        stationCount = fromStationIdx - toStationIdx + 1;
    }
    
    // 5
    CLLocationCoordinate2D *polylineCoords = malloc(sizeof(CLLocationCoordinate2D) * stationCount);
    for (NSUInteger i = 0; i < stationCount; i++) {
        // 6
        NSUInteger stationIndex = 0;
        if (forwards) {
            stationIndex = fromStationIdx + i;
        } else {
            stationIndex = fromStationIdx - i;
        }
        
        // 7
        RWStation *thisStation = _stations[stationIndex];
        polylineCoords[i] = thisStation.coordinate;
    }
    
    // 8
    RWRoute *newRoute = [[RWRoute alloc] init];
    newRoute.fromStation = fromStation;
    newRoute.toStation = toStation;
    newRoute.mapPolyline = [MKPolyline polylineWithCoordinates:polylineCoords count:stationCount];
    _currentRoute = newRoute;
    
    // 9
    free(polylineCoords);
    
    // 10
    self.mapMode = RWMapModeDirections;
}

- (void)routeFromCurrentLocationTo:(CLLocationCoordinate2D)to {
    self.mapMode = RWMapModeLoading;
    [self performAfterFindingLocation:^(CLLocationCoordinate2D coordinate) {
        [self routeFrom:coordinate to:to];
    }];
}

- (void)routeToCurrentLocationFrom:(CLLocationCoordinate2D)from {
    self.mapMode = RWMapModeLoading;
    [self performAfterFindingLocation:^(CLLocationCoordinate2D coordinate) {
        [self routeFrom:from to:coordinate];
    }];
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
    
    [self loadData];
    self.mapMode = RWMapModeNormal;
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(51.525635, -0.081985);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.12649, 0.12405);
    MKCoordinateRegion regionToDisplay = MKCoordinateRegionMake(center, span);
    [self.mapView setRegion:regionToDisplay animated:NO];
    
    UILongPressGestureRecognizer *longPressRecogniser = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPressRecogniser.minimumPressDuration = 1.0;
    [self.mapView addGestureRecognizer:longPressRecogniser];
}

- (void)performAfterFindingLocation:(RWLocationCallback)callback{
    if (self.mapView.userLocation != nil) {
        if (callback) {
            callback(self.mapView.userLocation.coordinate);
            
        }
    } else {
        _foundLocationCallback = [callback copy];
    }
}

-(void)handleLongPress:(UIGestureRecognizer *)recogniser{
    // 1
    if (recogniser.state == UIGestureRecognizerStateBegan) {
        // 2
        if (_droppedPin) {
            [self.mapView removeAnnotation:_droppedPin];
            _droppedPin = nil;
        }
        
        // 3
        CGPoint touchPoint = [recogniser locationInView:self.mapView];
        CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
        
        // 4
        _droppedPin = [[RWStation alloc] init];
        _droppedPin.coordinate = touchMapCoordinate;
        _droppedPin.title = @"Dropped Pin";
        
        // 5
        [self.mapView addAnnotation:_droppedPin];
    }
}

- (RWStation*)nearestStationToCoordinate:(CLLocationCoordinate2D)coordinate{
    __block RWStation *nearestStation = nil;
    __block CLLocationDistance nearestDistance = DBL_MAX;
    CLLocation *coordinateLocation = [[CLLocation alloc]initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    [_stations enumerateObjectsUsingBlock:^(RWStation *station, NSUInteger idx, BOOL *stop) {
        CLLocation *thisLocation = [[CLLocation alloc]initWithLatitude:station.coordinate.latitude longitude:station.coordinate.longitude];
        CLLocationDistance thisDistance =
        [coordinateLocation distanceFromLocation:thisLocation];//测量距离
        if (thisDistance < nearestDistance) {
            nearestDistance = thisDistance;
            nearestStation = station;
        }
    }];
    //返回最短距离
    return nearestStation;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadData{
    // 1
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"victoria_line" ofType:@"json"]];
    NSArray *stationData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSUInteger stationCount = stationData.count;
    
    // 2
    NSInteger i = 0;
    CLLocationCoordinate2D *polylineCoords = malloc(sizeof(CLLocationCoordinate2D) * stationCount);
    _stations = [[NSMutableArray alloc] initWithCapacity:stationCount];
    
    // 3
    for (NSDictionary *stationDictionary in stationData) {
        // 4
        CLLocationDegrees latitude = [[stationDictionary objectForKey:@"latitude"] doubleValue];
        CLLocationDegrees longitude = [[stationDictionary objectForKey:@"longitude"] doubleValue];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        polylineCoords[i] = coordinate;
        
        // 5
        RWStation *station = [[RWStation alloc] init];
        station.title = [stationDictionary objectForKey:@"name"];
        station.coordinate = coordinate;
        [_stations addObject:station];
        
        i++;
    }
    
    // 6
    _mapPolyline = [MKPolyline polylineWithCoordinates:polylineCoords count:stationCount];
    
    // 7
    free(polylineCoords);
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    
    if ([annotation isKindOfClass:[RWStation class]]) {
        static NSString *const kPinIdentifier = @"RWStation";
        MKPinAnnotationView *view = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:kPinIdentifier];
        if (!view) {
            view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kPinIdentifier];
            view.canShowCallout = YES;
            view.calloutOffset = CGPointMake(-5, 5);
            view.animatesDrop = NO;
        }
        
        if ((RWStation *)annotation == _droppedPin) {
            view.pinColor = MKPinAnnotationColorPurple;
            view.draggable = YES;
        }else{
            view.pinColor = MKPinAnnotationColorRed;
            view.draggable = NO;
        }
        if (self.mapMode == RWMapModeNormal) {
            view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        }else{
            view.rightCalloutAccessoryView = nil;
        }
        return view;//返回大头针
    }
    return nil;
}

-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay{
    MKPolylineView *overlayView = [[MKPolylineView alloc]initWithPolyline:overlay];
    overlayView.lineWidth = 10.0f;
    if (overlay == _mapPolyline) {
        overlayView.strokeColor = [UIColor blueColor];
    }else if (overlay == _currentRoute.mapPolyline){
        overlayView.strokeColor = [UIColor greenColor];
    }
   
    return overlayView;//返回线
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    if (_foundLocationCallback) {
        _foundLocationCallback(userLocation.coordinate);
    }
    _foundLocationCallback = nil;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    _selectedStation = (RWStation*)view.annotation;
    
    // 1
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@""
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Show in Maps", @"Route from current location", nil];
    
    // 2
    if (_droppedPin && view.annotation != _droppedPin) {
        [sheet addButtonWithTitle:@"Route from dropped pin"];
    }
    
    // 3
    [sheet addButtonWithTitle:@"Cancel"];
    sheet.cancelButtonIndex = sheet.numberOfButtons - 1;
    
    // 4
    [sheet showInView:self.view];
}
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        if (buttonIndex == 0) {
            MKMapItem *mapItem = [_selectedStation mapItem];
            NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking};
            [mapItem openInMapsWithLaunchOptions:launchOptions];
        }else if (buttonIndex == 1){
            [self routeFromCurrentLocationTo:_selectedStation.coordinate];//当前站到选中站的路线
        }else if (buttonIndex == 2){
            [self routeFrom:_droppedPin.coordinate to:_selectedStation.coordinate];
        }
    }
    
    _selectedStation = nil;
}

@end
