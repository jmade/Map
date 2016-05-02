//
//  SettingsView.m
//  DelaunayView
//
//  Created by Justin Madewell on 8/17/14.
//  Copyright (c) 2014 Justin Madewell. All rights reserved.
//

#import "SettingsView.h"
#import "ViewController.h"

@implementation SettingsView

- (IBAction)plusButtonPressed:(id)sender {
    
    NSNumberFormatter *numberFormater = [[NSNumberFormatter alloc] init];
    NSNumber *pointNumber = [numberFormater numberFromString:self.pointLabel.text];
    CGFloat labelFloat = [pointNumber floatValue];
    CGFloat resultFloat = labelFloat + 100;
    NSNumber *resultNumber = [NSNumber numberWithFloat:resultFloat];
    NSString *resultString = [NSNumberFormatter localizedStringFromNumber:resultNumber numberStyle:NSNumberFormatterNoStyle];
    [self.pointLabel setText:resultString];
    self.points = [resultNumber floatValue];
 }

  
- (IBAction)sliderValueChanged:(UISlider *)sender forEvent:(UIEvent *)event {
    
    [self.pointLabel setText:[self getStringFromFloat:sender.value]];
    
    self.points = sender.value;
    
    CGFloat roundedSlider =  round(sender.value);
    NSLog(@"roundedSlider: %f",roundedSlider);
    
    
    
  
    
    NSLog(@"self.colorSwitch.enabled value: %d", self.colorSwitch.on);
    
  
    
    
    
    


}

- (IBAction)colorModeSwitched:(UISwitch *)sender {
    if (!sender.on) {
        NSLog(@"Color Switch Value: %d", sender.on);
        self.randomColorSwitch.on = NO;
        self.randomColorSwitch.enabled = NO;
        self.islandColorLabel.text = @"Island";
    }
    if (sender.on) {
        NSLog(@"Color Switch Value: %d", sender.on);
        self.randomColorSwitch.on = YES;
        self.randomColorSwitch.enabled = YES;
        self.islandColorLabel.text = @"White";
    }
}

- (IBAction)minusButtonPressed:(id)sender {
    
    NSNumberFormatter *numberFormater = [[NSNumberFormatter alloc] init];
    NSNumber *pointNumber = [numberFormater numberFromString:self.pointLabel.text];
    CGFloat labelFloat = [pointNumber floatValue];
    CGFloat resultFloat = labelFloat - 100;
    NSNumber *resultNumber = [NSNumber numberWithFloat:resultFloat];
    NSString *resultString = [NSNumberFormatter localizedStringFromNumber:resultNumber numberStyle:NSNumberFormatterNoStyle];
    [self.pointLabel setText:resultString];
    self.points = [resultNumber floatValue];
   
}

-(NSString*)getStringFromFloat:(CGFloat)sentFloat
{
    NSNumber *number = [NSNumber numberWithFloat:sentFloat];
    NSNumberFormatter *numberFormater = [[NSNumberFormatter alloc] init];
    numberFormater.maximumIntegerDigits = 3;
    NSString *string = [numberFormater stringFromNumber:number];
    NSLog(@"string:%@",string);
    
    return string;
}




@end
