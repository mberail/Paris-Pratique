//
//  EquipementViewController.h
//  ParisPratique
//
//  Created by Maxime Berail on 16/07/13.
//  Copyright (c) 2013 Maxime Berail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>
#import <MessageUI/MessageUI.h>

@interface EquipementViewController : UIViewController <MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, copy) NSDictionary *equipementInfos;
@property CLLocationCoordinate2D coord;
@property (nonatomic, copy) NSString *nameData;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionV;

@end
