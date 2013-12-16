//
//  Equipements.h
//  ParisPratique
//
//  Created by Maxime Berail on 16/07/13.
//  Copyright (c) 2013 Maxime Berail. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Equipements : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *zipCode;
@property (nonatomic, copy) NSString *idEquipement;
@property (nonatomic, copy) NSString *street;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *distance;
@property (nonatomic, copy) NSDictionary *infos;

+ (id)nameOfElement:(NSString *)name atZip:(NSString *)zip withId:(NSString *)ID;

@end
