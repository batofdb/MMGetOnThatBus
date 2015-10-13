//
//  ViewController.m
//  GetOnThatBus
//
//  Created by Kellen Pierson on 10/13/15.
//  Copyright © 2015 Kellen Pierson. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>

@interface ViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSDictionary *results;
@property (nonatomic) NSArray *row;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
    self.mapView.showsUserLocation = YES;

    NSURL *url = [NSURL URLWithString:@"https://s3.amazonaws.com/mmios8week/bus.json"];

    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        if (data) {
            self.results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            self.row = self.results[@"row"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self populatePins];
            });
        }
    }];

    [task resume];
    
}

- (void)populatePins {

    for (NSDictionary *busStop in self.row) {
        MKPointAnnotation *annotation = [MKPointAnnotation new];
        double lat = [busStop[@"latitude"] doubleValue];
        double longitude = [busStop[@"longitude"] doubleValue];
        annotation.coordinate = CLLocationCoordinate2DMake(lat, longitude);
        annotation.title = busStop[@"cta_stop_name"];
        [self.mapView addAnnotation:annotation];
    }

}

@end



















