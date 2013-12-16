//
//  MapViewController.m
//  ParisPratique
//
//  Created by Maxime Berail on 07/10/13.
//  Copyright (c) 2013 Maxime Berail. All rights reserved.
//

#import "MapViewController.h"
#import "PinAnnotation.h"
#import "Equipements.h"
#import "EquipementViewController.h"
#import "VRGeoportailMapSource.h"
#import "RMMarkerManager.h"
#import "RMMarker.h"

#define degreesToRadians( degrees ) ( ( degrees ) / 180.0 * M_PI )

@interface MapViewController ()
{
    BOOL mapOpened;
    BOOL displayPlans;
    NSMutableArray *allPins;
}
@property (nonatomic, strong) NSMutableArray *nameEquipements;
@property (nonatomic, strong) NSMutableArray *filteredArray;
@property (nonatomic, retain) RMMarkerManager *manager;
@property (nonatomic, retain) RMMapLayer *mapLayer;
@end

@implementation MapViewController
@synthesize rootMap = _rootMap;
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
    mapOpened = YES;
    [self.tabV setHidden:YES];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(getList)];
    self.navigationItem.rightBarButtonItem = buttonItem;
    
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    displayPlans = [[pref objectForKey:@"plans"] boolValue];
    NSLog(@"displayPlans : %hhd",displayPlans);
    if (displayPlans)
    {
        [_rootMap setHidden:YES];
        [self.mapV setHidden:NO];
        [self loadMap];
    }
    
    else
    {
        [_rootMap setHidden:NO];
        [self.mapV setHidden:YES];
        [self loadGeoportail];
    }
    
}

- (void)loadMap
{
    MKCoordinateRegion region;
    region.center = self.userLoc;
    MKCoordinateSpan span;
    span.latitudeDelta  = 0.02;
    span.longitudeDelta = 0.02;
    region.span = span;
    [self.mapV setRegion:region animated:YES];
    NSMutableDictionary *mutDict = [[NSMutableDictionary alloc] init];
    allPins = [[NSMutableArray alloc] init];
    self.nameEquipements = [[NSMutableArray alloc] init];
    for (NSDictionary *dictTemp in self.allData)
    {
        CLLocationCoordinate2D coord;
        if ([self.nameData isEqualToString:@"Vélib"] || ([self.nameData isEqualToString:@"La Poste"] && [[dictTemp objectForKey:@"type"] isEqualToString:@"Bureau"]))
        {
            coord = CLLocationCoordinate2DMake([[[dictTemp objectForKey:@"coordinates"] objectAtIndex:0] floatValue], [[[dictTemp objectForKey:@"coordinates"] objectAtIndex:1] floatValue]);
        }
        else
        {
            coord = CLLocationCoordinate2DMake([[[dictTemp objectForKey:@"coordinates"] objectAtIndex:1] floatValue], [[[dictTemp objectForKey:@"coordinates"] objectAtIndex:0] floatValue]);
        }
        NSNumber *dist = [NSNumber numberWithFloat:6378 * acos(cos(degreesToRadians(self.userLoc.latitude))*cos(degreesToRadians(coord.latitude))*cos(degreesToRadians(coord.longitude)-degreesToRadians(self.userLoc.longitude))+sin(degreesToRadians(self.userLoc.latitude))*sin(degreesToRadians(coord.latitude)))];
        [mutDict setValue:dist forKey:[dictTemp objectForKey:@"id"]];
    }
    self.filteredArray = [[NSMutableArray alloc] initWithCapacity:self.nameEquipements.count];
    NSArray *orderedKeys = [mutDict keysSortedByValueUsingComparator:^NSComparisonResult (id obj1, id obj2)
                            {return [obj1 compare:obj2];}];
    for (int i = 0; i < orderedKeys.count; i++)
    {
        NSString *identifiant = [orderedKeys objectAtIndex:i];
        for (NSDictionary *dict in self.allData)
        {
            if ([[dict objectForKey:@"id"] isEqualToString:identifiant])
            {
                CLLocationCoordinate2D coord;
                if ([self.nameData isEqualToString:@"Vélib"] || ([self.nameData isEqualToString:@"La Poste"] && [[dict objectForKey:@"type"] isEqualToString:@"Bureau"]))
                {
                    coord = CLLocationCoordinate2DMake([[[dict objectForKey:@"coordinates"] objectAtIndex:0] floatValue], [[[dict objectForKey:@"coordinates"] objectAtIndex:1] floatValue]);
                }
                else
                {
                    coord = CLLocationCoordinate2DMake([[[dict objectForKey:@"coordinates"] objectAtIndex:1] floatValue], [[[dict objectForKey:@"coordinates"] objectAtIndex:0] floatValue]);
                }
                NSString *title = [dict objectForKey:@"title"];
                NSString *zipcode = [dict objectForKey:@"street"];
                if ([self.nameData isEqualToString:@"La Poste"] && ![[dict objectForKey:@"type"] isEqualToString:@"Bureau"])
                {
                    title = [NSString stringWithFormat:@"%@ %@",[dict objectForKey:@"type"],[dict objectForKey:@"street"]];
                }
                if ([[dict objectForKey:@"zipcode"] length] == 5)
                {
                    zipcode = [NSString stringWithFormat:@"%@ %@",zipcode,[dict objectForKey:@"zipcode"]];
                }
                if (i < 10)
                {
                    PinAnnotation *pin = [[PinAnnotation alloc] initWithName:title address:zipcode id:[dict objectForKey:@"id"]];
                    pin.coordinate = coord;
                    pin.infos = dict;
                    pin.type = [dict objectForKey:@"type"];
                    [self.mapV addAnnotation:pin];
                }
                Equipements *thisEquipement = [Equipements nameOfElement:title atZip:zipcode withId:[dict objectForKey:@"id"]];
                thisEquipement.street = [dict objectForKey:@"street"];
                thisEquipement.type = [dict objectForKey:@"type"];
                thisEquipement.distance = [mutDict objectForKey:identifiant];
                thisEquipement.infos = dict;
                [self.nameEquipements addObject:thisEquipement];
            }
        }
    }
}

- (void)loadGeoportail
{
    [RMMapView class];
    [_rootMap setDelegate:self];
    [_rootMap setContents:[[RMMapContents alloc] initWithView:_rootMap
                                                   tilesource:[[VRGeoportailMapSource alloc] initWithType:0]
                                                 centerLatLon:self.userLoc
                                                    zoomLevel:12
                                                 maxZoomLevel:[VRGeoportailMapSource zoomMaxForType:0]
                                                 minZoomLevel:[VRGeoportailMapSource zoomMinForType:0]
                                              backgroundImage:nil
                                                  screenScale:0.0]];
    self.manager = [[RMMarkerManager alloc] initWithContents:[_rootMap contents]];
    
    RMMarker *marker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"blue-pin.png"]];
    [self.manager addMarker:marker AtLatLong:self.userLoc];
    
    self.nameEquipements = [[NSMutableArray alloc] init];
    NSMutableDictionary *mutDict = [[NSMutableDictionary alloc] init];
    for (NSDictionary *dictTemp in self.allData)
    {
        CLLocationCoordinate2D coord;
        if ([self.nameData isEqualToString:@"Vélib"] || ([self.nameData isEqualToString:@"La Poste"] && [[dictTemp objectForKey:@"type"] isEqualToString:@"Bureau"]))
        {
            coord = CLLocationCoordinate2DMake([[[dictTemp objectForKey:@"coordinates"] objectAtIndex:0] floatValue], [[[dictTemp objectForKey:@"coordinates"] objectAtIndex:1] floatValue]);
        }
        else
        {
            coord = CLLocationCoordinate2DMake([[[dictTemp objectForKey:@"coordinates"] objectAtIndex:1] floatValue], [[[dictTemp objectForKey:@"coordinates"] objectAtIndex:0] floatValue]);
        }
        NSNumber *dist = [NSNumber numberWithFloat:6378 * acos(cos(degreesToRadians(self.userLoc.latitude))*cos(degreesToRadians(coord.latitude))*cos(degreesToRadians(coord.longitude)-degreesToRadians(self.userLoc.longitude))+sin(degreesToRadians(self.userLoc.latitude))*sin(degreesToRadians(coord.latitude)))];
        [mutDict setValue:dist forKey:[dictTemp objectForKey:@"id"]];
    }
    self.filteredArray = [[NSMutableArray alloc] initWithCapacity:self.nameEquipements.count];
    NSArray *orderedKeys = [mutDict keysSortedByValueUsingComparator:^NSComparisonResult (id obj1, id obj2)
                            {return [obj1 compare:obj2];}];
    for (int i = 0; i < orderedKeys.count; i++)
    {
        NSString *identifiant = [orderedKeys objectAtIndex:i];
        for (NSDictionary *dict in self.allData)
        {
            if ([[dict objectForKey:@"id"] isEqualToString:identifiant])
            {
                CLLocationCoordinate2D coord;
                if ([self.nameData isEqualToString:@"Vélib"] || ([self.nameData isEqualToString:@"La Poste"] && [[dict objectForKey:@"type"] isEqualToString:@"Bureau"]))
                {
                    coord = CLLocationCoordinate2DMake([[[dict objectForKey:@"coordinates"] objectAtIndex:0] floatValue], [[[dict objectForKey:@"coordinates"] objectAtIndex:1] floatValue]);
                }
                else
                {
                    coord = CLLocationCoordinate2DMake([[[dict objectForKey:@"coordinates"] objectAtIndex:1] floatValue], [[[dict objectForKey:@"coordinates"] objectAtIndex:0] floatValue]);
                }
                NSString *title = [dict objectForKey:@"title"];
                NSString *zipcode = [dict objectForKey:@"street"];
                if ([self.nameData isEqualToString:@"La Poste"] && ![[dict objectForKey:@"type"] isEqualToString:@"Bureau"])
                {
                    title = [NSString stringWithFormat:@"%@ %@",[dict objectForKey:@"type"],[dict objectForKey:@"street"]];
                }
                if ([[dict objectForKey:@"zipcode"] length] == 5)
                {
                    zipcode = [NSString stringWithFormat:@"%@ %@",zipcode,[dict objectForKey:@"zipcode"]];
                }
                if (i < 10)
                {
                    RMMarker *marker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"pin.png"]];
                    marker.data = dict;
                    CGSize size = [title sizeWithFont:[UIFont systemFontOfSize:15.0] constrainedToSize:CGSizeMake(10000, 40) lineBreakMode:NSLineBreakByWordWrapping];
                    [marker changeLabelUsingText:title position:CGPointMake(-(size.width/2), -20) font:[UIFont systemFontOfSize:15.0] foregroundColor:[UIColor blackColor] backgroundColor:[UIColor whiteColor]];
                    [self.manager addMarker:marker AtLatLong:coord];
                }
                Equipements *thisEquipement = [Equipements nameOfElement:title atZip:zipcode withId:[dict objectForKey:@"id"]];
                thisEquipement.street = [dict objectForKey:@"street"];
                thisEquipement.type = [dict objectForKey:@"type"];
                thisEquipement.distance = [mutDict objectForKey:identifiant];
                thisEquipement.infos = dict;
                [self.nameEquipements addObject:thisEquipement];
            }
        }
    }
}

- (void)getList
{
    if (mapOpened)
    {
        if (displayPlans)
            [self.mapV setHidden:YES];
        else
            [self.rootMap setHidden:YES];
        [self.tabV setHidden:NO];
        mapOpened = NO;
    }
    else
    {
        if (displayPlans)
            [self.mapV setHidden:NO];
        else
            [self.rootMap setHidden:NO];
        [self.tabV setHidden:YES];
        mapOpened = YES;
    }
}

- (void)filterContentForSearchText:(NSString *)searchText scope:(NSString *)scopeText
{
    [self.filteredArray removeAllObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains[c] %@",searchText];
    NSArray *arrayTemp = [self.nameEquipements filteredArrayUsingPredicate:predicate];
    for (Equipements *equipement in arrayTemp)
    {
        [self.filteredArray addObject:equipement];
    }
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"SELF.zipCode == %@",searchText];
    NSArray *arrayTemp2 = [self.nameEquipements filteredArrayUsingPredicate:predicate2];
    for (Equipements *equipement in arrayTemp2)
    {
        [self.filteredArray addObject:equipement];
    }
}

#pragma mark - RMMapView delegate

-(void)tapOnMarker:(RMMarker *)marker onMap:(RMMapView *)map
{
    [marker toggleLabel];
}

- (void)tapOnLabelForMarker:(RMMarker*) marker onMap:(RMMapView*) map
{
    NSLog(@"infos : %@",marker.data);
    NSString *displayText = @"";
    NSDictionary *temp = [[NSDictionary alloc] init];
    if ([self.nameData isEqualToString:@"Auto-écoles"])
    {
        temp = (NSDictionary *)marker.data;
        displayText = [NSString stringWithFormat:@"Candidats au permis B : %@\n\nTaux de réussite au permis B : %i%%\n\nCandidats au code : %@\n\nTaux de réussite au code : %i%%\n\nPowered by www.VroomVroom.fr",[temp objectForKey:@"b_2012_first_total_candidates"],[[temp objectForKey:@"b_2012_first_success_rate"] intValue],[temp objectForKey:@"etg_2012_first_total_candidates"],[[temp objectForKey:@"etg_2012_first_success_rate"] intValue]];
    }
    else if ([self.nameData isEqualToString:@"Autolib"])
    {
        temp = (NSDictionary *)marker.data;
        displayText = [NSString stringWithFormat:@"Total bornes : %@\n\nBornes Autolib : %@\n\nBornes véhicule tiers : %@",[temp objectForKey:@"nombre_total_de_bornes_de_charge"],[temp objectForKey:@"bornes_de_charge_autolib"],[temp objectForKey:@"bornes_de_charge_pour_vehicule_tiers"]];
    }
    else if ([self.nameData isEqualToString:@"La Poste"])
    {
        NSMutableDictionary *mut = [[NSMutableDictionary alloc] initWithDictionary:(NSDictionary *)marker.data copyItems:YES];
        NSDictionary *data = [self getPoste:[mut objectForKey:@"id"]];
        [mut setValue:data forKey:@"days"];
        temp = mut;
    }
    else if ([self.nameData isEqualToString:@"Vélib"])
    {
        NSMutableDictionary *mut = [[NSMutableDictionary alloc] initWithDictionary:(NSDictionary *)marker.data copyItems:YES];
        NSDictionary *data = [self getVelib:[mut objectForKey:@"id"]];
        [mut setValue:[data objectForKey:@"available_bike_stands"] forKey:@"available_bike_stands"];
        [mut setValue:[data objectForKey:@"available_bikes"] forKey:@"available_bikes"];
        [mut setValue:[data objectForKey:@"status"] forKey:@"status"];
        temp = mut;
        displayText = [NSString stringWithFormat:@"Bornes libres : %@\n\nVelib disponibles : %@\n\nStatus : %@",[temp objectForKey:@"available_bike_stands"],[temp objectForKey:@"available_bikes"],[temp objectForKey:@"status"]];
    }
    else if ([self.nameData isEqualToString:@"Taxis"])
    {
        temp = (NSDictionary *)marker.data;
        displayText = [NSString stringWithFormat:@"Tél : %@\n\nIndication : %@",[temp objectForKey:@"phone"],[temp objectForKey:@"indication"]];
    }
    else if ([self.nameData isEqualToString:@"Wifi"])
    {
        temp = (NSDictionary *)marker.data;
    }
    else
    {
        NSMutableDictionary *mut = [[NSMutableDictionary alloc] initWithDictionary:(NSDictionary *)marker.data copyItems:YES];
        NSDictionary *data = [self getEquipement:[mut objectForKey:@"id"]];
        [mut setValue:[data objectForKey:@"calendars"] forKey:@"calendars"];
        [mut setValue:[data objectForKey:@"phone"] forKey:@"phone"];
        [mut setValue:[data objectForKey:@"email"] forKey:@"email"];
        temp = mut;
        if ([temp objectForKey:@"phone"] != nil)
        {
            displayText = [NSString stringWithFormat:@"Tél : %@\n\n",[temp objectForKey:@"phone"]];
        }
        if ([temp objectForKey:@"email"] != nil)
        {
            displayText = [NSString stringWithFormat:@"%@Email : %@",displayText,[temp objectForKey:@"email"]];
        }
    }
    NSMutableDictionary *mutDict = [[NSMutableDictionary alloc] initWithDictionary:temp copyItems:YES];
    [mutDict setValue:displayText forKey:@"text"];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    EquipementViewController *evc = [storyboard instantiateViewControllerWithIdentifier:@"EquipementViewController"];
    evc.equipementInfos = mutDict;
    NSLog(@"infos : %@",mutDict);
    CLLocationCoordinate2D coord;
    if ([self.nameData isEqualToString:@"Vélib"] || ([self.nameData isEqualToString:@"La Poste"] && [[mutDict objectForKey:@"type"] isEqualToString:@"Bureau"]))
    {
        coord = CLLocationCoordinate2DMake([[[mutDict objectForKey:@"coordinates"] objectAtIndex:0] floatValue], [[[mutDict objectForKey:@"coordinates"] objectAtIndex:1] floatValue]);
    }
    else
    {
        coord = CLLocationCoordinate2DMake([[[mutDict objectForKey:@"coordinates"] objectAtIndex:1] floatValue], [[[mutDict objectForKey:@"coordinates"] objectAtIndex:0] floatValue]);
    }
    evc.coord = coord;
    evc.nameData = self.nameData;
    evc.navigationItem.title = @"Details";
    [self.navigationController pushViewController:evc animated:YES];
}

#pragma mark - Search display delegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    return YES;
}

#pragma mark - Tableview datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arrayTemp = [[NSArray alloc] init];
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        arrayTemp = self.filteredArray;
    }
    else
    {
        arrayTemp = self.nameEquipements;
    }
    return arrayTemp.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    NSArray *arrayTemp = [[NSArray alloc] init];
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        arrayTemp = self.filteredArray;
    }
    else {
        arrayTemp = self.nameEquipements;
    }
    Equipements *equipement = nil;
    equipement = [arrayTemp objectAtIndex:indexPath.row];
    NSString *title = equipement.name;
    NSString *zipcode = equipement.street;
    if ([self.nameData isEqualToString:@"La Poste"] && ![equipement.type isEqualToString:@"Bureau"])
    {
        title = [NSString stringWithFormat:@"%@ %@",equipement.type,zipcode];
    }
    if ([equipement.zipCode length] == 5)
    {
        zipcode = [NSString stringWithFormat:@"%@ %@",zipcode,equipement.zipCode];
    }
    cell.textLabel.text = title;
    cell.detailTextLabel.text = zipcode;
    return cell;
}

#pragma mark - Tableview delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arrayTemp = [[NSArray alloc] init];
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        arrayTemp = self.filteredArray;
    }
    else {
        arrayTemp = self.nameEquipements;
    }
    Equipements *equipement = nil;
    equipement = [arrayTemp objectAtIndex:indexPath.row];
    NSString *displayText = @"";
    NSDictionary *temp = [[NSDictionary alloc] init];
    if ([self.nameData isEqualToString:@"Auto-écoles"])
    {
        temp = equipement.infos;
        displayText = [NSString stringWithFormat:@"Candidats au permis B : %@\n\nTaux de réussite au permis B : %i%%\n\nCandidats au code : %@\n\nTaux de réussite au code : %i%%\n\nPowered by www.VroomVroom.fr",[temp objectForKey:@"b_2012_first_total_candidates"],[[temp objectForKey:@"b_2012_first_success_rate"] intValue],[temp objectForKey:@"etg_2012_first_total_candidates"],[[temp objectForKey:@"etg_2012_first_success_rate"] intValue]];
    }
    else if ([self.nameData isEqualToString:@"Autolib"])
    {
        temp = equipement.infos;
        displayText = [NSString stringWithFormat:@"Total bornes : %@\n\nBornes Autolib : %@\n\nBornes véhicule tiers : %@",[temp objectForKey:@"nombre_total_de_bornes_de_charge"],[temp objectForKey:@"bornes_de_charge_autolib"],[temp objectForKey:@"bornes_de_charge_pour_vehicule_tiers"]];
    }
    else if ([self.nameData isEqualToString:@"La Poste"])
    {
        NSMutableDictionary *mut = [[NSMutableDictionary alloc] initWithDictionary:equipement.infos copyItems:YES];
        NSDictionary *data = [self getPoste:equipement.idEquipement];
        [mut setValue:data forKey:@"days"];
        temp = mut;
    }
    else if ([self.nameData isEqualToString:@"Vélib"])
    {
        NSMutableDictionary *mut = [[NSMutableDictionary alloc] initWithDictionary:equipement.infos copyItems:YES];
        NSDictionary *data = [self getVelib:equipement.idEquipement];
        [mut setValue:[data objectForKey:@"available_bike_stands"] forKey:@"available_bike_stands"];
        [mut setValue:[data objectForKey:@"available_bikes"] forKey:@"available_bikes"];
        [mut setValue:[data objectForKey:@"status"] forKey:@"status"];
        temp = mut;
        displayText = [NSString stringWithFormat:@"Bornes libres : %@\n\nVelib disponibles : %@\n\nStatus : %@",[temp objectForKey:@"available_bike_stands"],[temp objectForKey:@"available_bikes"],[temp objectForKey:@"status"]];
    }
    else if ([self.nameData isEqualToString:@"Taxis"])
    {
        temp = equipement.infos;
        displayText = [NSString stringWithFormat:@"Tél : %@\n\nIndication : %@",[temp objectForKey:@"phone"],[temp objectForKey:@"indication"]];
    }
    else if ([self.nameData isEqualToString:@"Wifi"])
    {
        temp = equipement.infos;
    }
    else
    {
        NSMutableDictionary *mut = [[NSMutableDictionary alloc] initWithDictionary:equipement.infos copyItems:YES];
        NSDictionary *data = [self getEquipement:equipement.idEquipement];
        [mut setValue:[data objectForKey:@"calendars"] forKey:@"calendars"];
        [mut setValue:[data objectForKey:@"phone"] forKey:@"phone"];
        [mut setValue:[data objectForKey:@"email"] forKey:@"email"];
        temp = mut;
        if ([temp objectForKey:@"phone"] != nil)
        {
            displayText = [NSString stringWithFormat:@"Tél : %@\n\n",[temp objectForKey:@"phone"]];
        }
        if ([temp objectForKey:@"email"] != nil)
        {
            displayText = [NSString stringWithFormat:@"%@Email : %@",displayText,[temp objectForKey:@"email"]];
        }
    }
    NSMutableDictionary *mutDict = [[NSMutableDictionary alloc] initWithDictionary:temp copyItems:YES];
    [mutDict setValue:displayText forKey:@"text"];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    EquipementViewController *evc = [storyboard instantiateViewControllerWithIdentifier:@"EquipementViewController"];
    NSLog(@"infos : %@",mutDict);
    evc.equipementInfos = mutDict;
    NSDictionary *dictTemp = equipement.infos;
    CLLocationCoordinate2D coord;
    if ([self.nameData isEqualToString:@"Vélib"] || ([self.nameData isEqualToString:@"La Poste"] && [[dictTemp objectForKey:@"type"] isEqualToString:@"Bureau"]))
    {
        coord = CLLocationCoordinate2DMake([[[dictTemp objectForKey:@"coordinates"] objectAtIndex:0] floatValue], [[[dictTemp objectForKey:@"coordinates"] objectAtIndex:1] floatValue]);
    }
    else
    {
        coord = CLLocationCoordinate2DMake([[[dictTemp objectForKey:@"coordinates"] objectAtIndex:1] floatValue], [[[dictTemp objectForKey:@"coordinates"] objectAtIndex:0] floatValue]);
    }
    evc.coord = coord;
    evc.nameData = self.nameData;
    evc.navigationItem.title = @"Details";
    [self.navigationController pushViewController:evc animated:YES];
}

#pragma mark - Mapview datasource

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    PinAnnotation *equipement = annotation;
    if (annotation != mapView.userLocation && ![equipement.type isEqualToString:@"Bureau"])
    {
        MKPinAnnotationView *pinAnnotation = nil;
        pinAnnotation = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:nil];
        if (pinAnnotation == nil )
            pinAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
        pinAnnotation.pinColor = MKPinAnnotationColorRed;
        pinAnnotation.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        pinAnnotation.canShowCallout = YES;
        pinAnnotation.animatesDrop = YES;
        annotationView = pinAnnotation;
    }
    else if (annotation != mapView.userLocation && [equipement.type isEqualToString:@"Bureau"])
    {
        UIImage *pinImage = [[UIImage alloc] init];
        pinImage = [UIImage imageNamed:@"ICO laposte.png"];
        [annotationView setImage:pinImage];
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        annotationView.canShowCallout = YES;
    }
    else
    {
        annotationView = nil;
    }
    return annotationView;
}

#pragma mark - Mapview delegate

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    PinAnnotation *pin = view.annotation;
    NSLog(@"infos : %@",pin.infos);
    NSString *displayText = @"";
    NSDictionary *temp = [[NSDictionary alloc] init];
    if ([self.nameData isEqualToString:@"Auto-écoles"])
    {
        temp = pin.infos;
        displayText = [NSString stringWithFormat:@"Candidats au permis B : %@\n\nTaux de réussite au permis B : %i%%\n\nCandidats au code : %@\n\nTaux de réussite au code : %i%%\n\nPowered by www.VroomVroom.fr",[temp objectForKey:@"b_2012_first_total_candidates"],[[temp objectForKey:@"b_2012_first_success_rate"] intValue],[temp objectForKey:@"etg_2012_first_total_candidates"],[[temp objectForKey:@"etg_2012_first_success_rate"] intValue]];
    }
    else if ([self.nameData isEqualToString:@"Autolib"])
    {
        temp = pin.infos;
        displayText = [NSString stringWithFormat:@"Total bornes : %@\n\nBornes Autolib : %@\n\nBornes véhicule tiers : %@",[temp objectForKey:@"nombre_total_de_bornes_de_charge"],[temp objectForKey:@"bornes_de_charge_autolib"],[temp objectForKey:@"bornes_de_charge_pour_vehicule_tiers"]];
    }
    else if ([self.nameData isEqualToString:@"La Poste"])
    {
        NSMutableDictionary *mut = [[NSMutableDictionary alloc] initWithDictionary:pin.infos copyItems:YES];
        NSDictionary *data = [self getPoste:pin.ID];;
        [mut setValue:data forKey:@"days"];
        temp = mut;
    }
    else if ([self.nameData isEqualToString:@"Vélib"])
    {
        NSMutableDictionary *mut = [[NSMutableDictionary alloc] initWithDictionary:pin.infos copyItems:YES];
        NSDictionary *data = [self getVelib:pin.ID];
        [mut setValue:[data objectForKey:@"available_bike_stands"] forKey:@"available_bike_stands"];
        [mut setValue:[data objectForKey:@"available_bikes"] forKey:@"available_bikes"];
        [mut setValue:[data objectForKey:@"status"] forKey:@"status"];
        temp = mut;
        displayText = [NSString stringWithFormat:@"Bornes libres : %@\n\nVelib disponibles : %@\n\nStatus : %@",[temp objectForKey:@"available_bike_stands"],[temp objectForKey:@"available_bikes"],[temp objectForKey:@"status"]];
    }
    else if ([self.nameData isEqualToString:@"Taxis"])
    {
        temp = pin.infos;
        displayText = [NSString stringWithFormat:@"Tél : %@\n\nIndication : %@",[temp objectForKey:@"phone"],[temp objectForKey:@"indication"]];
    }
    else if ([self.nameData isEqualToString:@"Wifi"])
    {
        temp = pin.infos;
    }
    else
    {
        NSMutableDictionary *mut = [[NSMutableDictionary alloc] initWithDictionary:pin.infos copyItems:YES];
        NSDictionary *data = [self getEquipement:pin.ID];
        [mut setValue:[data objectForKey:@"calendars"] forKey:@"calendars"];
        [mut setValue:[data objectForKey:@"phone"] forKey:@"phone"];
        [mut setValue:[data objectForKey:@"email"] forKey:@"email"];
        temp = mut;
        if ([temp objectForKey:@"phone"] != nil)
        {
            displayText = [NSString stringWithFormat:@"Tél : %@\n\n",[temp objectForKey:@"phone"]];
        }
        if ([temp objectForKey:@"email"] != nil)
        {
            displayText = [NSString stringWithFormat:@"%@Email : %@",displayText,[temp objectForKey:@"email"]];
        }
    }
    NSMutableDictionary *mutDict = [[NSMutableDictionary alloc] initWithDictionary:temp copyItems:YES];
    [mutDict setValue:displayText forKey:@"text"];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    EquipementViewController *evc = [storyboard instantiateViewControllerWithIdentifier:@"EquipementViewController"];
    evc.equipementInfos = mutDict;
    NSLog(@"infos : %@",mutDict);
    evc.coord = pin.coordinate;
    evc.nameData = self.nameData;
    evc.navigationItem.title = @"Details";
    [self.navigationController pushViewController:evc animated:YES];
}

#pragma mark - Private methods

- (NSDictionary *)getVelib:(NSString *)idVelib
{
    NSString *stringURL = [NSString stringWithFormat:@"https://api.jcdecaux.com/vls/v1/stations/%@?contract=Paris&apiKey=%@",idVelib,kVelib];
    NSString *encodedURL = [stringURL stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSURL *url = [NSURL URLWithString:encodedURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // Prepare for the response back from the server
    NSHTTPURLResponse *response = nil;
    NSError *errors = nil;
    
    // Send a synchronous request to the server (i.e. sit and wait for the response)
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&errors];
    NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
    if (dictData == nil)
    {
        dictData = [self getVelib:idVelib];
    }
    return dictData;
}

- (NSDictionary *)getEquipement:(NSString *)idEquipement
{
    NSString *stringURL = [NSString stringWithFormat:@"https://api.paris.fr:3000/data/1.0/Equipements/get_equipement/?token=%@&id=%@",kToken,idEquipement];
    NSString *encodedURL = [stringURL stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSLog(@"url : %@",encodedURL);
    NSURL *url = [NSURL URLWithString:encodedURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // Prepare for the response back from the server
    NSHTTPURLResponse *response = nil;
    NSError *errors = nil;
    
    // Send a synchronous request to the server (i.e. sit and wait for the response)
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&errors];
    NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
    NSDictionary *fakeEquipement = [[dictData objectForKey:@"data"] objectAtIndex:0];
    if (dictData == nil)
    {
        fakeEquipement = [self getEquipement:idEquipement];
    }
    return fakeEquipement;
}

- (NSDictionary *)getPoste:(NSString *)idPoste
{
    NSData *allData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Horaires La Poste" ofType:@"json"]];
    NSArray *arrayData = [NSJSONSerialization JSONObjectWithData:allData options:NSJSONReadingMutableContainers error:nil];
    //arrayData correspond à un tableau de dictionnaires
    NSDate *today = [NSDate date]; //récupère la date d'aujourd'hui
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM"]; //va servir pour convertir la string "12-08" par exemple en vrai date afin de la comparer après
    NSMutableDictionary *mutDict = [[NSMutableDictionary alloc] init]; //initialisation du dictionnaire
    for (NSDictionary *dict in arrayData) //parcours chaque dictionnaire du tableau
    {
        NSDate *dateBefore = [dateFormatter dateFromString:[dict objectForKey:@"Début_période"]];
        NSDate *dateAfter = [dateFormatter dateFromString:[dict objectForKey:@"Fin_période"]];
        if ([[dict objectForKey:@"id"] isEqualToString:idPoste] && [today laterDate:dateBefore] && [today earlierDate:dateAfter])
            // si l'id du bureau parcouru correspond à celui qu'on cherche et si la date est comprise entre début_période et fin_période
        {
            NSString *hourBefore = [dict objectForKey:@"Heure_début_de_plage_horaire"];
            NSString *hourAfter = [dict objectForKey:@"Heure_fin_de_plage_horaire"];
            NSString *day = [dict objectForKey:@"Jour"];
            NSArray *hours = [NSArray arrayWithObjects:hourBefore,hourAfter,nil]; //tableau contenant les horaires d'un jour de la semaine
            [mutDict setValue:hours forKey:day]; //dictionnaire ayant pour clé le jour et pour valeur le tableau d'horaires
        }
    }
    return mutDict;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
