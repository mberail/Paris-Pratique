//
//  VRGeoportailMapSource.h
//  ParisPratique
//
//  Created by Maxime Berail on 24/10/13.
//  Copyright (c) 2013 Maxime Berail. All rights reserved.
//

#import "RMAbstractMercatorWebSource.h"

@interface VRGeoportailMapSource : RMAbstractMercatorWebSource <RMAbstractMercatorWebSource>

enum VRTypeCarte {
    Geoportail_carte,
    Geoportail_photos,
    Geoportail_cadastre
};

+(int)zoomMaxForType:(int)choix;
+(int)zoomMinForType:(int)choix;

@property (readonly) int type;

-(id)initWithType:(int)type;

@end