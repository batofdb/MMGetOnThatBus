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

@interface ViewController () <MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSDictionary *results;
@property (nonatomic) NSArray *row;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *mapButton;
@property (weak, nonatomic) IBOutlet UIButton *listButton;
@property NSMutableArray *annotationArray;
@property BOOL isTableViewActive;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.annotationArray = [[NSMutableArray alloc] init];

    self.mapView.delegate = self;
    self.isTableViewActive = NO;
    [self showChitown];

    NSURL *url = [NSURL URLWithString:@"https://s3.amazonaws.com/mmios8week/bus.json"];

    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        if (data) {
            self.results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            self.row = self.results[@"row"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self populatePins];
                [self.tableView reloadData];
            });

        }
    }];

    [task resume];
    [self toggleTableView];
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

        [self.annotationArray addObject:annotation];
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
            pin.image = [UIImage imageNamed:@"metra"];
        } else {
            pin.image = [UIImage imageNamed:@"pace"];
        }
    } else {
        pin.image = [UIImage imageNamed:@"pin"];
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

    if ([segue.identifier isEqualToString:@"TableSegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        BusStopAnnotation *busStop = [self.annotationArray objectAtIndex:indexPath.row];
        DetailViewController *vc = segue.destinationViewController;
        vc.annotation = busStop;

    } else {
        DetailViewController *vc = segue.destinationViewController;
        vc.annotation = sender;
    }

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  [self.annotationArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    BusStopAnnotation *busStop = [self.annotationArray objectAtIndex:indexPath.row];

    cell.textLabel.text = busStop.busStopName;

    if (busStop.interModalTransfers) {
        if ([busStop.interModalTransfers isEqualToString:@"Metra"]) {
            cell.imageView.image = [UIImage imageNamed:@"metra"];
        } else {
            cell.imageView.image = [UIImage imageNamed:@"pace"];
        }
    } else {
        cell.imageView.image = [UIImage imageNamed:@"pin"];
    }

    return cell;
}
- (IBAction)onMapButtonPressed:(UIButton *)sender {
    self.isTableViewActive = NO;
    [self toggleTableView];

    UIColor *buttonColor = self.mapButton.backgroundColor;
    self.mapButton.backgroundColor = self.listButton.backgroundColor;
    self.listButton.backgroundColor = buttonColor;
}
- (IBAction)onListButtonPressed:(UIButton *)sender {
    self.isTableViewActive = YES;
    [self toggleTableView];

    UIColor *buttonColor = self.mapButton.backgroundColor;
    self.mapButton.backgroundColor = self.listButton.backgroundColor;
    self.listButton.backgroundColor = buttonColor;

}

- (void)toggleTableView {
    if(self.isTableViewActive)
        self.tableView.hidden = NO;
    else
        self.tableView.hidden = YES;
}

@end



















