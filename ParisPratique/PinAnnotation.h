//
//  PinAnnotation.h
//  ParisPratique
//
//  Created by Maxime Berail on 16/07/13.
//  Copyright (c) 2013 Maxime Berail. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PinAnnotation : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, strong) NSDictionary *infos;

- (id)initWithName:(NSString *)name address:(NSString *)address id:(NSString *)idAnnotation;

@end
