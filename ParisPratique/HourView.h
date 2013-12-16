//
//  HourView.h
//  ParisPratique
//
//  Created by Maxime Berail on 19/10/13.
//  Copyright (c) 2013 Maxime Berail. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HourView : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstHour;
@property (weak, nonatomic) IBOutlet UILabel *lastHour;

@end
