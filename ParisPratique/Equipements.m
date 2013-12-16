//
//  Equipements.m
//  ParisPratique
//
//  Created by Maxime Berail on 16/07/13.
//  Copyright (c) 2013 Maxime Berail. All rights reserved.
//

#import "Equipements.h"

@implementation Equipements

@synthesize name, idEquipement, zipCode;

+ (id)nameOfElement:(NSString *)name atZip:(NSString *)zip withId:(NSString *)ID
{
    Equipements *newEquipement = [[self alloc] init];
    newEquipement.name = name;
    newEquipement.zipCode = zip;
    newEquipement.idEquipement = ID;
    return newEquipement;
}

@end
