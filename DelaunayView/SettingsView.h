//
//  SettingsView.h
//  DelaunayView
//
//  Created by Justin Madewell on 8/17/14.
//  Copyright (c) 2014 Justin Madewell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsView : UIView

@property (weak, nonatomic) IBOutlet UILabel *pointLabel;

@property (weak, nonatomic) IBOutlet UIButton *plusButton;
@property (weak, nonatomic) IBOutlet UIButton *minusButton;

@property (nonatomic, assign) CGFloat points;

@property (weak, nonatomic) IBOutlet UISlider *PointCountSlider;

@property (weak, nonatomic) IBOutlet UISwitch *colorSwitch;

@property (weak, nonatomic) IBOutlet UISwitch *jaggedSwitch;

@property (weak, nonatomic) IBOutlet UISwitch *randomColorSwitch;
@property (weak, nonatomic) IBOutlet UILabel *islandColorLabel;

@end
