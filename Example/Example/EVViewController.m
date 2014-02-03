//
//  EVViewController.m
//  AutoLayoutFun
//
//  Created by Ethan Vaughan on 11/28/13.
//  Copyright (c) 2013 Ethan James Vaughan. All rights reserved.
//

#import "EVViewController.h"
#import "NSLayoutConstraint+SimpleFormatLanguage.h"

@interface EVViewController ()

@end

@implementation EVViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UIView *redView = [[UIView alloc] initWithFrame:CGRectZero];
    redView.backgroundColor = [UIColor redColor];
    redView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIView *blueView = [[UIView alloc] initWithFrame:CGRectZero];
    blueView.backgroundColor = [UIColor blueColor];
    blueView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:redView];
    [self.view addSubview:blueView];
    
    UIView *superview = self.view;
    
    [superview addConstraints:
     [NSLayoutConstraint
      constraintsWithSimpleFormat:
      @[ @"redView.width = 100",
         @"redView.height = redView.width",
         @"redView.left = superview.left",
         @"redView.centerY = superview.centerY",
         @"blueView.height = 100",
         @"blueView.centerY = superview.centerY",
         @"blueView.left = redView.right + spacer",
         @"blueView.right <= superview.right - 50",
         @"blueView.width = 3 * redView.width @ 750" ]
      metrics:@{ @"spacer" : @20 }
      views:
      NSDictionaryOfVariableBindings(redView, blueView, superview)]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
