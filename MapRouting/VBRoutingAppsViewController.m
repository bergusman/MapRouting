//
//  VBRoutingAppsViewController.m
//  MapRouting
//
//  Created by Vitaliy Berg on 5/3/13.
//  Copyright (c) 2013 Vitaliy Berg. All rights reserved.
//

#import "VBRoutingAppsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <MapKit/MapKit.h>

@interface VBRoutingAppsViewController () <MKMapViewDelegate>

@property (nonatomic, strong) NSArray *routingApps;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *buttonsContainerView;

@property (nonatomic, strong) MKPointAnnotation *pointFrom;
@property (nonatomic, strong) MKPointAnnotation *pointTo;

@end

@implementation VBRoutingAppsViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    
    NSMutableArray *routingApps = [NSMutableArray array];
    
    [routingApps addObject:@{
        @"icon" : @"AppleMaps",
        @"url" : @"http://maps.apple.com/maps?saddr=%f,%f&daddr=%f,%f"
     }];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
        [routingApps addObject:@{
            @"icon" : @"GoogleMaps",
            @"url" : @"comgooglemaps://?saddr=%f,%f&daddr=%f,%f"
         }];
    }
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"yandexnavi://"]]) {
        [routingApps addObject:@{
            @"icon" : @"YandexNavi",
            @"url" : @"yandexnavi://build_route_on_map?lat_from=%f&lon_from=%f&lat_to=%f&lon_to=%f"
         }];
    }
    
    self.routingApps = routingApps;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView.region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(55.751249, 37.618427), 8000, 8000);
    
    self.buttonsContainerView.layer.shadowOffset = CGSizeZero;
    self.buttonsContainerView.layer.shadowOpacity = 0.2;
    self.buttonsContainerView.layer.shadowRadius = 2;
    self.buttonsContainerView.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(-20, 0, 360, 20)].CGPath;
    
    self.pointFrom = [[MKPointAnnotation alloc] init];
    self.pointFrom.coordinate = CLLocationCoordinate2DMake(55.765855, 37.63813);
    self.pointFrom.title = @"From";
    [self.mapView addAnnotation:self.pointFrom];
    
    self.pointTo = [[MKPointAnnotation alloc] init];
    self.pointTo.coordinate = CLLocationCoordinate2DMake(55.744845, 37.602768);
    self.pointTo.title = @"To";
    [self.mapView addAnnotation:self.pointTo];
    
    [self generateButtons];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)generateButtons {
    CGSize buttonSize = CGSizeMake(64, 64);
    CGFloat step = (320 - buttonSize.width * [self.routingApps count]) / ([self.routingApps count] + 1);
    CGFloat step2 = step + buttonSize.width;
    CGPoint center = CGPointMake(step + buttonSize.width / 2, self.buttonsContainerView.bounds.size.height / 2);
    NSInteger tag = 0;
    
    for (NSDictionary *routingApp in self.routingApps) {
        UIButton *button = [[UIButton alloc] init];
        button.frame = CGRectMake(0, 0, buttonSize.width, buttonSize.height);
        button.center = center;
        [button setImage:[self roundedImage:[UIImage imageNamed:routingApp[@"icon"]] cornerRadius:10] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = tag;
        [self.buttonsContainerView addSubview:button];
        
        center.x += step2;
        tag++;
    }
}

#pragma mark - Actions

- (void)buttonTouchUpInside:(UIButton *)sender {
    NSDictionary *routingApp = self.routingApps[sender.tag];
    NSString *urlString = [NSString stringWithFormat:
                           routingApp[@"url"],
                           self.pointFrom.coordinate.latitude,
                           self.pointFrom.coordinate.longitude,
                           self.pointTo.coordinate.latitude,
                           self.pointTo.coordinate.longitude];
    
    NSURL *url = [NSURL URLWithString:urlString];
    if (![[UIApplication sharedApplication] canOpenURL:url]) {
        [[[UIAlertView alloc] initWithTitle:@"Ups"
                                    message:@"Cannot open application"
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"Ok", nil] show];
    } else {
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }

    static NSString *pinID = @"Pin";
    MKPinAnnotationView *pin = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pinID];
    if (!pin) {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:pinID];
        pin.canShowCallout = YES;
        pin.draggable = YES;
    }
    pin.annotation = annotation;
    pin.pinColor = ([annotation.title isEqualToString:@"From"]) ? MKPinAnnotationColorGreen : MKPinAnnotationColorRed;
    return pin;
}

#pragma mark - Utility

- (UIImage *)roundedImage:(UIImage *)image cornerRadius:(CGFloat)radius {
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    
    [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, image.size.width, image.size.height) cornerRadius:radius] addClip];
    [image drawAtPoint:CGPointMake(0, 0)];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

@end
