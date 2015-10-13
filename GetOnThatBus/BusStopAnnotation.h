//
//  BusStopAnnotation.h
//  GetOnThatBus
//
//  Created by Kellen Pierson on 10/13/15.
//  Copyright © 2015 Kellen Pierson. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface BusStopAnnotation : MKPointAnnotation

@property (nonatomic) NSString *busStopName;
@property (nonatomic) NSString *stopAddress;
@property (nonatomic) NSString *busRoute;
@property (nonatomic) NSString *interModalTransfers;

@end
