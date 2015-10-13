//
//  ViewController.m
//  GetOnThatBus
//
//  Created by Kellen Pierson on 10/13/15.
//  Copyright © 2015 Kellen Pierson. All rights reserved.
//

#import "ViewController.h"
#import "DetailViewController.h"
#import "BusStopAnnotation.h"
#import <MapKit/MapKit.h>

@interface ViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSDictionary *results;
@property (nonatomic) NSArray *row;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.mapView.delegate = self;

    [self showChitown];

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

        BusStopAnnotation *annotation = [BusStopAnnotation new];
        double lat = [busStop[@"latitude"] doubleValue];
        double longitude = [busStop[@"longitude"] doubleValue];

        annotation.coordinate = CLLocationCoordinate2DMake(lat, longitude);
        annotation.title = busStop[@"cta_stop_name"];
        annotation.subtitle = [NSString stringWithFormat:@"Routes: %@",busStop[@"routes"]];
        annotation.busRoute = busStop[@"routes"];
        annotation.busStopName = busStop[@"cta_stop_name"];
        annotation.stopAddress = busStop[@"_address"];

        if (busStop[@"inter_modal"]) {
            annotation.interModalTransfers = busStop[@"inter_modal"];
        }

        [self.mapView addAnnotation:annotation];
    }

}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {

    BusStopAnnotation *annotation = view.annotation;
    
    [self performSegueWithIdentifier:@"DetailSegue" sender:annotation];
    
}

//- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
//    [self performSegueWithIdentifier:@"DetailSegue" sender:self];
//}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(BusStopAnnotation<MKAnnotation> *)annotation {
    MKAnnotationView *pin = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];

    if (annotation.interModalTransfers) {
        if ([annotation.interModalTransfers isEqualToString:@"Metra"]) {
            pin.image = [UIImage imageNamed:@"monster-one"];
        } else {
            pin.image = [UIImage imageNamed:@"monster-three"];
        }
    } else {
        pin.image = [UIImage imageNamed:@"mobilemakers"];
    }

    pin.canShowCallout = YES;
    pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];

    return pin;
}


- (void)showChitown {

    MKCoordinateRegion region;
    region.center.latitude = 41.8369;
    region.center.longitude = -87.6847;

    region.span.latitudeDelta = 0.1;
    region.span.longitudeDelta = 0.1;

    [self.mapView setRegion:region animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    DetailViewController *vc = segue.destinationViewController;
    vc.annotation = sender;
}


@end



















