//
//  DetailsViewController.h
//  ParisPratique
//
//  Created by Maxime Berail on 24/10/13.
//  Copyright (c) 2013 Maxime Berail. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *dataView;
@property (nonatomic, strong) NSString *dataText;

@end
