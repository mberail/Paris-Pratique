//
//  VRGeoportailMapSource.m
//  ParisPratique
//
//  Created by Maxime Berail on 24/10/13.
//  Copyright (c) 2013 Maxime Berail. All rights reserved.
//

#import "VRGeoportailMapSource.h"

@interface VRGeoportailMapSource()

@property (readwrite) int type;

@end

@implementation VRGeoportailMapSource

-(id)initWithType:(int)type
{
	if(self = [super init])
	{
		self.type = type;
		[self setMaxZoom:20];
		[self setMinZoom:1];
	}
	return self;
}

-(NSString*)tileURL:(RMTile)tile
{
	NSAssert4(((tile.zoom >= self.minZoom) && (tile.zoom <= self.maxZoom)),
			  @"%@ tried to retrieve tile with zoomLevel %d, outside source's defined range %f to %f",
			  self, tile.zoom, self.minZoom, self.maxZoom);
    if (self.type == Geoportail_cadastre)
    {
        return [NSString stringWithFormat:@"http://gpp3-wxs.ign.fr/%@/geoportail/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=CADASTRALPARCELS.PARCELS&STYLE=bdparcellaire&TILEMATRIXSET=PM&TILEMATRIX=%d&TILEROW=%d&TILECOL=%d&FORMAT=image/png",[self cleDeConnexion], tile.zoom,tile.y,tile.x];
    }
    else if (self.type == Geoportail_carte)
    {
        return [NSString stringWithFormat:@"http://gpp3-wxs.ign.fr/%@/geoportail/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=GEOGRAPHICALGRIDSYSTEMS.MAPS&STYLE=normal&TILEMATRIXSET=PM&TILEMATRIX=%d&TILEROW=%d&TILECOL=%d&FORMAT=image/jpeg",[self cleDeConnexion], tile.zoom,tile.y,tile.x];
        //return [NSString stringWithFormat:@"http://wxs.ign.fr/%@/geoportail/wmts/?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=GEOGRAPHICALGRIDSYSTEM.MAPS&STYLE=normal&TILEMATRIXSET=PM&TILEMATRIX=%d&TILEROW=%d&TILECOL=%d&FORMAT=image%@jpeg",[self cleDeConnexion], tile.zoom, tile.y, tile.x,@"%2F"];
    }
    else
    {
        return [NSString stringWithFormat:@"http://gpp3-wxs.ign.fr/%@/geoportail/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=ORTHOIMAGERY.ORTHOPHOTOS&STYLE=normal&TILEMATRIXSET=PM&TILEMATRIX=%d&TILEROW=%d&TILECOL=%d&FORMAT=image/jpeg",[self cleDeConnexion], tile.zoom,tile.y,tile.x];
        //return [NSString stringWithFormat:@"http://wxs.ign.fr/%@/geoportail/wmts/?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=ORTHOIMAGERY.ORTHOPHOTOS&STYLE=normal&TILEMATRIXSET=PM&TILEMATRIX=%d&TILEROW=%d&TILECOL=%d&FORMAT=image%@jpeg",[self cleDeConnexion], tile.zoom, tile.y, tile.x,@"%2F"];
        
    }
}

-(NSString*)uniqueTilecacheKey
{
    if (self.type == Geoportail_cadastre)
        return @"Geoportail_cadastre";
    else if (self.type == Geoportail_carte)
        return @"Geoportail_carte";
    else
        return @"Geoportail_photo";
}

-(NSString *)cleDeConnexion {
    //return @"vyq9fycketywyr0rm40ofm1z";
    return @"r2hdd2fs9l1bbfjeqiv8cz1o";
}

+(int)zoomMaxForType:(int)choix {
    switch (choix) {
        case Geoportail_carte:
            return 18;
            break;
        case Geoportail_photos:
            return 19;
            break;
        case Geoportail_cadastre:
            return 21;
            break;
        case 4: //Open Street Maps
            return 18;
            break;
        default:
            return 21;
            break;
    }
}

+(int)zoomMinForType:(int)choix {
    switch (choix) {
        case Geoportail_carte:
            return 1;
            break;
        case Geoportail_photos:
            return 1;
            break;
        case Geoportail_cadastre:
            return 6;
            break;
        case 4: // Open Street Maps
            return 1;
            break;
        default:
            return 0;
            break;
    }
}

-(NSString *)shortName
{
	return @"Open Street Map";
}
-(NSString *)longDescription
{
	return @"Open Street Map, the free wiki world map, provides freely usable map data for all parts of the world, under the Creative Commons Attribution-Share Alike 2.0 license.";
}
-(NSString *)shortAttribution
{
	return @"© OpenStreetMap CC-BY-SA";
}
-(NSString *)longAttribution
{
	return @"Map data © OpenStreetMap, licensed under Creative Commons Share Alike By Attribution.";
}

@end