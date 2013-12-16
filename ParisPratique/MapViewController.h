//
//  MapViewController.h
//  ParisPratique
//
//  Created by Maxime Berail on 07/10/13.
//  Copyright (c) 2013 Maxime Berail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "RMMapView.h"

@interface MapViewController : UIViewController <MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate,RMMapViewDelegate>

@property (retain, nonatomic) IBOutlet RMMapView *rootMap;
@property CLLocationCoordinate2D userLoc;
@property (weak, nonatomic) IBOutlet MKMapView *mapV;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSArray *allData;
@property (weak, nonatomic) IBOutlet UITableView *tabV;
@property (nonatomic, strong) NSString *nameData;
@end
