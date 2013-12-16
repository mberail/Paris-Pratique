//
//  PinAnnotation.m
//  ParisPratique
//
//  Created by Maxime Berail on 16/07/13.
//  Copyright (c) 2013 Maxime Berail. All rights reserved.
//

#import "PinAnnotation.h"

@implementation PinAnnotation

@synthesize coordinate,title,subtitle,ID;

- (id)initWithName:(NSString *)name address:(NSString *)address id:(NSString *)idAnnotation
{
    if ((self = [super init]))
    {
        self.title = name;
        self.subtitle = address;
        self.ID = idAnnotation;
    }
    return self;
}

- (NSString *)title
{
    return title;
}

- (NSString *)subtitle
{
    return subtitle;
}

@end
