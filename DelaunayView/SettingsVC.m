//
//  SettingsVC.m
//  DelaunayView
//
//  Created by Justin Madewell on 8/17/14.
//  Copyright (c) 2014 Justin Madewell. All rights reserved.
//

#import "SettingsVC.h"
#import "ViewController.h"
#import "SettingsView.h"

@implementation SettingsVC

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *vc = [segue sourceViewController];
    
    SettingsView *sv = [vc view];
    
    NSLog(@"sv.randomColorSwitch.on value: %d", sv.randomColorSwitch.on);
    NSLog(@"sv.colorSwitch.on value: %d", sv.colorSwitch.on);
    
    
    CGFloat p = sv.points;
    
    
    if (p == 0)
    {
        p = 300.0f;
    }
    
    [[segue destinationViewController] setAreColorsRandom:sv.randomColorSwitch.on];
    [[segue destinationViewController] setShowVanillaMap:sv.colorSwitch.on];
    [[segue destinationViewController] setPts:p];
    [[segue destinationViewController] setAreLinesJagged:sv.jaggedSwitch.on];
     
}




@end
