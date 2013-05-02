//
//  VBMapAppsViewController.m
//  MapRouting
//
//  Created by Vitaliy Berg on 5/3/13.
//  Copyright (c) 2013 Vitaliy Berg. All rights reserved.
//

#import "VBMapAppsViewController.h"
#import <StoreKit/StoreKit.h>

@interface VBMapAppsViewController () <SKStoreProductViewControllerDelegate>

@property (nonatomic, strong) NSArray *mapApps;

@end

@implementation VBMapAppsViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    NSMutableArray *mapApps = [NSMutableArray array];
    
    UIApplication *app = [UIApplication sharedApplication];
    
    [mapApps addObject:@{
        @"icon" : @"AppleMaps",
        @"name": @"Apple Maps",
        @"installed": @YES,
        @"open_url": @"http://maps.apple.com/maps?q",
        @"app_id": @(0)
     }];
    
    [mapApps addObject:@{
        @"icon" : @"GoogleMaps",
        @"name": @"Google Maps",
        @"installed": @([app canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]),
        @"open_url": @"comgooglemaps://",
        @"app_id": @(585027354)
     }];
    
    [mapApps addObject:@{
        @"icon" : @"YandexMaps",
        @"name": @"Yandex Maps",
        @"installed": @([app canOpenURL:[NSURL URLWithString:@"yandexmaps://"]]),
        @"open_url": @"yandexmaps://",
        @"app_id": @(313877526)
     }];
    
    [mapApps addObject:@{
        @"icon" : @"YandexNavi",
        @"name": @"Yandex Navigator",
        @"installed": @([app canOpenURL:[NSURL URLWithString:@"yandexnavi://"]]),
        @"open_url": @"yandexnavi://",
        @"app_id": @(474500851)
     }];
    
    self.mapApps = mapApps;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.mapApps count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"AppCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    NSDictionary *mapApp = self.mapApps[indexPath.row];
    
    cell.textLabel.text = mapApp[@"name"];
    
    if ([mapApp[@"installed"] boolValue]) {
        cell.detailTextLabel.text = @"Installed";
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0 green:0.7 blue:0 alpha:0.5];
    } else {
        cell.detailTextLabel.text = @"Not installed";
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.7 green:0 blue:0 alpha:0.5];
    }
    
    cell.imageView.image = [self roundedImage:[UIImage imageNamed:mapApp[@"icon"]] cornerRadius:10];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *mapApp = self.mapApps[indexPath.row];
    if ([mapApp[@"installed"] boolValue]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mapApp[@"open_url"]]];
    } else {
        [self presentStoreProductWithAppID:mapApp[@"app_id"]];
    }
}

#pragma mark - SKStoreProductViewControllerDelegate

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
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

- (void)presentStoreProductWithAppID:(NSNumber *)appID {
    SKStoreProductViewController *storeViewController = [[SKStoreProductViewController alloc] init];
    storeViewController.delegate = self;
    [storeViewController loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier: appID} completionBlock:nil];
    [self presentViewController:storeViewController animated:YES completion:^{
    }];
}

@end
