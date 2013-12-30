//
//  RWStation.m
//  GuanStudyIOS
//
//  Created by macmini on 13-12-30.
//  Copyright (c) 2013 城云 官. All rights reserved.
//

#import "RWStation.h"
#import <AddressBook/AddressBook.h>

@implementation RWStation

- (MKMapItem*)mapItem {
    // 1
    NSDictionary *addressDict = @{
                                  (NSString*)kABPersonAddressCountryKey : @"UK",
                                  (NSString*)kABPersonAddressCityKey : @"London",
                                  (NSString*)kABPersonAddressStreetKey : @"10 Downing Street",
                                  (NSString*)kABPersonAddressZIPKey : @"SW1A 2AA"};
    
    // 2
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:self.coordinate addressDictionary:addressDict];
    
    // 3
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    mapItem.name = self.title;
    mapItem.phoneNumber = @"+44-20-8123-4567";
    mapItem.url = [NSURL URLWithString:@"http://www.raywenderlich.com/"];
    
    return mapItem;
}
@end

