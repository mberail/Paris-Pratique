//
//  ParametersViewController.m
//  ParisPratique
//
//  Created by Maxime Berail on 24/10/13.
//  Copyright (c) 2013 Maxime Berail. All rights reserved.
//

#import "ParametersViewController.h"
#import "DetailsViewController.h"

@interface ParametersViewController ()
@property BOOL displayPlans;
@end

@implementation ParametersViewController

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
    self.navigationItem.title = @"Réglages";
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    self.displayPlans = [[preferences objectForKey:@"plans"] boolValue];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tableview datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
    //return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return @"Sélectionnez votre fond de carte :";
            break;
        default:
            return nil;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"paraCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSString *text = @"";
    switch (indexPath.section)
    {
        case 0:
            switch (indexPath.row)
            {
                case 0:
                {
                    if (self.displayPlans)
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    else
                        cell.accessoryType = UITableViewCellAccessoryNone;
                    text = @"Plans";
                }
                    break;
                case 1:
                {
                    if (!self.displayPlans)
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    else
                        cell.accessoryType = UITableViewCellAccessoryNone;
                    text = @"Geoportail";
                }
                    break;
                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row)
            {
                case 0:
                    text = @"Informations";
                    break;
                case 1:
                    text = @"Contact";
                    break;
                default:
                    break;
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        default:
            break;
    }
    cell.textLabel.text = text;
    return cell;
}

#pragma mark - Tableview delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 0:
        {
            NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
            switch (indexPath.row)
            {
                case 0:
                    if ([[pref objectForKey:@"plans"] boolValue] == NO)
                    {
                        [pref setObject:@"1" forKey:@"plans"];
                        self.displayPlans = YES;
                    }
                    break;
                case 1:
                    if ([[pref objectForKey:@"plans"] boolValue] == YES)
                    {
                        [pref setObject:@"0" forKey:@"plans"];
                        self.displayPlans = NO;
                    }
                    break;
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            DetailsViewController *dvc = [storyboard instantiateViewControllerWithIdentifier:@"DetailsViewController"];
            NSString *text = @"";
            NSString *title = @"";
            switch (indexPath.row)
            {
                case 0:
                    title = @"Informations";
                    text = @"Toutes les données au sein de l'application sont des données publiques.\n\nMairie de Paris : http://api.paris.fr/ \n\nVélib : http://developer.jcdecaux.com/ \n\nAutolib : http://opendata.paris.fr/ \n\nAuto-écoles : http://www.vroomvroom.fr/ \n\nLa Poste : http://data.gouv.fr/\n\nUtilisation du fond de carte Geoportail fourni par l'IGN (Institut Géographique National)";
                    break;
                case 1:
                    title = @"Contact";
                    text = @"Vous avez des idées d'améliorations ?\n\nVous souhaitez ajouter des données dans l'application ?\n\nContactez-nous : max.berail@gmail.com";
                default:
                    break;
            }
            dvc.dataText = text;
            dvc.navigationItem.title = title;
            [self.navigationController pushViewController:dvc animated:YES];
        }
            break;
        default:
            break;
    }
    [self.tableV reloadData];
}

@end
