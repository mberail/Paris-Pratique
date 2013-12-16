//
//  IconsViewController.m
//  ParisPratique
//
//  Created by Maxime Berail on 09/10/13.
//  Copyright (c) 2013 Maxime Berail. All rights reserved.
//

#import "CustomView.h"
#import "IconsViewController.h"
#import "MapViewController.h"
#import "NSString+HTML.h"

@interface IconsViewController ()
{
    NSArray *icons;
    NSArray *labels;
    NSArray *dataJSON;
    CLLocationManager *locationManager;
    //NSMutableArray *mutArray;
}

@end

@implementation IconsViewController

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
    self.navigationItem.title = @"Paris Pratique";
    labels = [NSArray arrayWithObjects:NSLocalizedString(@"Auto-écoles", nil), NSLocalizedString(@"Autolib", nil),NSLocalizedString(@"Bibliothèques", nil),/*@"Encombrants",*/NSLocalizedString(@"La Poste", nil),NSLocalizedString(@"Marchés", nil),NSLocalizedString(@"Musées", nil),NSLocalizedString(@"Parcs", nil),NSLocalizedString(@"Piscines", nil),NSLocalizedString(@"Taxis", nil),NSLocalizedString(@"Tennis", nil),NSLocalizedString(@"Velib", nil),NSLocalizedString(@"Wi-fi", nil), nil];
    icons = [NSArray arrayWithObjects:@"autoecoles-logo.png",@"autolib-logo.png",@"bibliotheques-logo.png",/*@"encombrants.png",*/@"laposte-logo.png",@"marches-logo.png",@"musees-logo.png",@"parcs-logo.png",@"piscines-logo.png",@"taxis-logo.png",@"tennis-logo.png",@"velib-logo.png",@"wifi-logo.png", nil];
    dataJSON = [NSArray arrayWithObjects:@"Auto-écoles",@"Autolib",@"Bibliothèques",@"La Poste",@"Marchés",@"Musées",@"Parcs",@"Piscines",@"Taxis",@"Tennis",@"Vélib",@"Wifi", nil];
    
    UIImage *profile = [UIImage imageNamed:@"gear_40.png"];
    UIButton *profileButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, profile.size.width, profile.size.height)];
    [profileButton setBackgroundImage:profile forState:UIControlStateNormal];
    [profileButton addTarget:self action:@selector(goParameters) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *profilItem =[[UIBarButtonItem alloc] initWithCustomView:profileButton];
    self.navigationItem.rightBarButtonItem = profilItem;
    
    //mutArray = [[NSMutableArray alloc] init];
    //[self getCoordinatesFromAddress:0];
    //[self addID:0];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    locationManager = [[CLLocationManager alloc] init];
    [locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)goParameters
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ParametersViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

/*- (void)addID:(int)index
{
    NSData *falseData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Wifi" ofType:@"json"]];
    NSArray *arrayTemp = [[NSArray alloc] init];
    arrayTemp = [NSJSONSerialization JSONObjectWithData:falseData options:NSJSONReadingAllowFragments error:nil];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[arrayTemp objectAtIndex:index] copyItems:YES];
    [dict setValue:[NSString stringWithFormat:@"%i",index+1] forKey:@"id"];
    [mutArray addObject:dict];
    if (index+1 < arrayTemp.count)
    {
        [self addID:index+1];
    }
    if (index == arrayTemp.count - 1)
    {
        NSData *newData = [NSJSONSerialization dataWithJSONObject:mutArray options:NSJSONWritingPrettyPrinted error:nil];
        NSString *stringData = [[NSString alloc] initWithData:newData encoding:NSUTF8StringEncoding];
        NSLog(@"data : %@",stringData);
    }
}*/

/*- (void)getCoordinatesFromAddress:(int)index
{
    NSData *falseData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Wifi" ofType:@"json"]];
    NSArray *arrayTemp = [[NSArray alloc] init];
    arrayTemp = [NSJSONSerialization JSONObjectWithData:falseData options:NSJSONReadingAllowFragments error:nil];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[arrayTemp objectAtIndex:index] copyItems:YES];
    NSString *stringURL = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true",[dict objectForKey:@"address"]];
    NSString *encodedURL = [stringURL stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSURL *url = [NSURL URLWithString:encodedURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // Prepare for the response back from the server
    NSHTTPURLResponse *response = nil;
    NSError *errors = nil;
    
    // Send a synchronous request to the server (i.e. sit and wait for the response)
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&errors];
    NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
    NSArray *results = [dictData objectForKey:@"results"];
    if (results.count > 0)
    {
        NSDictionary *dictCoord = [[[[dictData objectForKey:@"results"] objectAtIndex:0] objectForKey:@"geometry"] objectForKey:@"location"];
        NSArray *arrayCoord = [NSArray arrayWithObjects:[dictCoord objectForKey:@"lng"],[dictCoord objectForKey:@"lat"], nil];
        [dict setObject:arrayCoord forKey:@"coordinates"];
        [mutArray addObject:dict];
    }
    else
    {
        [self getCoordinatesFromAddress:index];
    }
    if (index+1 < arrayTemp.count)
    {
        [self getCoordinatesFromAddress:index+1];
    }
    if (index == arrayTemp.count - 1)
    {
        NSData *newData = [NSJSONSerialization dataWithJSONObject:mutArray options:NSJSONWritingPrettyPrinted error:nil];
        NSString *stringData = [[NSString alloc] initWithData:newData encoding:NSUTF8StringEncoding];
        NSLog(@"data : %@",stringData);
    }
}*/

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return labels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"customView";
    CustomView *customView = [self.collectionV dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    customView.iconView.image = [UIImage imageNamed:[icons objectAtIndex:indexPath.row]];
    customView.labelView.text = [labels objectAtIndex:indexPath.row];
    return customView;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSData *allData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[dataJSON objectAtIndex:indexPath.row] ofType:@"json"]];
    NSArray *arrayData = [NSJSONSerialization JSONObjectWithData:allData options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"count : %i",arrayData.count);
    [locationManager stopUpdatingLocation];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    MapViewController *mvc = [storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
    mvc.allData = arrayData;
    //CLLocationCoordinate2D fakeCoord = CLLocationCoordinate2DMake(48.845711, 2.328133);
    mvc.userLoc = locationManager.location.coordinate;
    //mvc.userLoc = fakeCoord;
    NSLog(@"user : %f %f",mvc.userLoc.latitude,mvc.userLoc.longitude);
    mvc.nameData = [dataJSON objectAtIndex:indexPath.row];
    mvc.navigationItem.title = [dataJSON objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:mvc animated:YES];
}

@end
