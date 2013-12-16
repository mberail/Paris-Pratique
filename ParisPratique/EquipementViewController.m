//
//  EquipementViewController.m
//  ParisPratique
//
//  Created by Maxime Berail on 16/07/13.
//  Copyright (c) 2013 Maxime Berail. All rights reserved.
//

#import "EquipementViewController.h"
#import "PinAnnotation.h"
#import "HourView.h"

@interface EquipementViewController ()
{
    CLLocationManager *locationManager;
    NSMutableDictionary *mutDict;
}
@end

@implementation EquipementViewController

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
    NSLog(@"equipement infos : %@",self.equipementInfos);
    self.nameLabel.text = [self.equipementInfos objectForKey:@"title"];
    NSString *address = [NSString stringWithFormat:@"%@",[self.equipementInfos objectForKey:@"street"]];
    if ([self.equipementInfos objectForKey:@"zipcode"] != nil)
    {
        address = [NSString stringWithFormat:@"%@, %@",address,[self.equipementInfos objectForKey:@"zipcode"]];
    }
    self.addressLabel.text = address;
    NSDictionary *calendars = [self.equipementInfos objectForKey:@"calendars"];
    mutDict = [[NSMutableDictionary alloc] init];
    if (calendars == nil || calendars.count == 2)
    {
        [self.collectionV setHidden:YES];
    }
    else if (calendars.count > 2)
    {
        NSArray *keys = [calendars allKeys];
        NSArray *allKeys = [keys sortedArrayUsingComparator:^NSComparisonResult (id obj1, id obj2)
         {NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
             [dateFormatter setDateFormat:@"yyyy-MM-dd"];
             NSDate *date1 = [dateFormatter dateFromString:obj1];
             NSDate *date2 = [dateFormatter dateFromString:obj2];
             return [date1 compare:date2];}];
        for (int i = 0; i < allKeys.count; i++)
        {
            NSArray *hours = [calendars objectForKey:[allKeys objectAtIndex:i]];
            for (NSArray *hour in hours)
            {
                if (hour.count > 2)
                {
                    [mutDict setValue:hour forKey:[allKeys objectAtIndex:i]];
                }
            }
        }
    }
    NSMutableDictionary *days = [[NSMutableDictionary alloc] initWithDictionary:[self.equipementInfos objectForKey:@"days"] copyItems:YES];
    if (days.count > 0)
    {
        [self.collectionV setHidden:NO];
        mutDict = days;
    }
    self.textView.text = [self.equipementInfos objectForKey:@"text"];
    
    self.mapView.layer.cornerRadius = 10;
    CLLocationCoordinate2D theCoordinate = self.coord;
    MKCoordinateRegion region;
    region.center = theCoordinate;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.005;
    span.longitudeDelta = 0.005;
    region.span = span;
    [self.mapView setRegion:region animated:YES];
    
    NSString *title = [self.equipementInfos objectForKey:@"title"];
    NSString *zipcode = [self.equipementInfos objectForKey:@"street"];
    if ([self.nameData isEqualToString:@"La Poste"] && ![[self.equipementInfos objectForKey:@"type"] isEqualToString:@"Bureau"])
    {
        title = [NSString stringWithFormat:@"%@ %@",[self.equipementInfos objectForKey:@"type"],[self.equipementInfos objectForKey:@"street"]];
    }
    if ([[self.equipementInfos objectForKey:@"zipcode"] length] == 5)
    {
        zipcode = [NSString stringWithFormat:@"%@ %@",zipcode,[self.equipementInfos objectForKey:@"zipcode"]];
    }
    
    PinAnnotation *pin = [[PinAnnotation alloc] initWithName:title address:zipcode id:[self.equipementInfos objectForKey:@"id"]];
    pin.coordinate = theCoordinate;
    [self.mapView addAnnotation:pin];
    [self.mapView selectAnnotation:pin animated:YES];
}

#pragma mark - Map view data source

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
//affichage du marqueur sur la carte
{
    MKPinAnnotationView *pinAnnotation = nil;
    if (annotation != mapView.userLocation)
    {
        pinAnnotation = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:nil];
        if (pinAnnotation == nil )
            pinAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
        pinAnnotation.pinColor = MKPinAnnotationColorRed;
        pinAnnotation.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        pinAnnotation.canShowCallout = YES;
        pinAnnotation.animatesDrop = YES;
    }
    return pinAnnotation;
}

#pragma mark - Map view delegate

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
//click sur le détail du marqueur
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) //si iOS >= 6.0
    {
        CLLocationCoordinate2D theCoordinate = self.coord;
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:theCoordinate addressDictionary:nil];
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        mapItem.name = self.title;
        NSLog(@"title : %@",self.title);
        NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
        [mapItem openInMapsWithLaunchOptions:launchOptions]; //ouvre la carte pour l'itinéraire dans Plans
    }
    else if (SYSTEM_VERSION_LESS_THAN(@"6.0")) //si iOS < 6
    {
        locationManager = [[CLLocationManager alloc] init];
        [locationManager startUpdatingLocation];
        [locationManager stopUpdatingLocation];
        CLLocationCoordinate2D theCoordinate = self.coord;
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f&dirflg=w",locationManager.location.coordinate.latitude,locationManager.location.coordinate.longitude,theCoordinate.latitude,theCoordinate.longitude]]]; //ouvre la carte pour l'itinéraire dans Google Maps
    }
}

#pragma mark - Collection view datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return MIN(6, mutDict.count);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"HourView";
    HourView *hourView = [self.collectionV dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    NSArray *keys = [mutDict allKeys];
    if ([[self.equipementInfos objectForKey:@"days"] count] > 0)
    {
        hourView.dateLabel.text = [keys objectAtIndex:indexPath.row];
        hourView.firstHour.text = [[mutDict objectForKey:[keys objectAtIndex:indexPath.row]] objectAtIndex:0];
        hourView.lastHour.text = [[mutDict objectForKey:[keys objectAtIndex:indexPath.row]] objectAtIndex:1];
    }
    else
    {
        NSArray *allKeys = [keys sortedArrayUsingComparator:^NSComparisonResult (id obj1, id obj2)
                            {NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                                NSDate *date1 = [dateFormatter dateFromString:obj1];
                                NSDate *date2 = [dateFormatter dateFromString:obj2];
                                return [date1 compare:date2];}];
        NSDateFormatter *dateBefore = [[NSDateFormatter alloc] init];
        [dateBefore setDateFormat:@"yyyy-MM-dd"];
        NSDate *date = [dateBefore dateFromString:[allKeys objectAtIndex:indexPath.row]];
        [dateBefore setDateFormat:@"dd/MM"];
        hourView.dateLabel.text = [dateBefore stringFromDate:date];
        NSArray *temp = [mutDict objectForKey:[allKeys objectAtIndex:indexPath.row]];
        NSRange range = NSMakeRange(0, 5);
        hourView.firstHour.text = [[temp objectAtIndex:0] substringWithRange:range];
        hourView.lastHour.text = [[temp objectAtIndex:1] substringWithRange:range];
    }
    return hourView;
}

/*- (IBAction)mail:(id)sender
{
    if ([[self.equipementInfos objectForKey:@"email"] length] != 0)
    {
        Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
        if (mailClass != nil)
        {
            // We must always check whether the current device is configured for sending emails
            if ([mailClass canSendMail])
            {
                [self displayComposerSheet];
            }
            else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@",[self.equipementInfos objectForKey:@"email"]]]];
            }
        }
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Aucune adresse mail n'est indiquée." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

- (void)displayComposerSheet
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	NSArray *toRecipients = [NSArray arrayWithObject:[self.equipementInfos objectForKey:@"email"]];
	[picker setToRecipients:toRecipients];
	[self presentModalViewController:picker animated:YES];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	NSString *message;
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			message = @"";
			break;
		case MFMailComposeResultSaved:
			message = @"Brouillon sauvegardé";
			break;
		case MFMailComposeResultSent:
			message = @"Mail envoyé";
			break;
		case MFMailComposeResultFailed:
			message = @"Échec de l'envoi du mail";
			break;
		default:
			message = @"Mail non-envoyé";
			break;
	}
    if (![message isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)web:(id)sender
{
    if ([[self.equipementInfos objectForKey:@"websiteUrl"] length] != 0)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        WebViewController *wvc = [storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
        wvc.urlString = [self.equipementInfos objectForKey:@"websiteUrl"];
        [self.navigationController presentModalViewController:wvc animated:YES];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Aucun site web n'est indiqué." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

- (IBAction)phone:(id)sender
{
    if ([[self.equipementInfos objectForKey:@"phone"] length] != 0)
    {
        NSString *phoneString = [self.equipementInfos objectForKey:@"phone"];
        NSString *realPhone = @"";
        for (int i = 0; i < phoneString.length; i++)
        {
            NSRange range = NSMakeRange(i, 1);
            if ([[phoneString substringWithRange:range] intValue] || [[phoneString substringWithRange:range] isEqualToString:@"0"])
            {
                realPhone = [NSString stringWithFormat:@"%@%@",realPhone,[phoneString substringWithRange:range]];
            }
        }
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",realPhone]]];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Aucun numéro de téléphone n'est indiqué." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [self setTextView:nil];
    [self setNameLabel:nil];
    [self setAddressLabel:nil];
    [self setMapView:nil];
    [super viewDidUnload];
}

@end
