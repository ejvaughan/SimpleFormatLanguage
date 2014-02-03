//
//  NSLayoutConstraint+NSLayoutConstraint_SimpleFormatLanguage.h
//  AutoLayoutFun
//
//  Created by Ethan Vaughan on 11/28/13.
//  Copyright (c) 2013 Ethan James Vaughan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSLayoutConstraint (SimpleFormatLanguage)

/**
 An intuitive and powerful replacement for Apple's Visual Format Language. A constraint is specified using the following syntax: view1.attribute relation multiplier * view2.attribute + constant @ priority.
 
 @code
 UIView *superview = ...;
 
 UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
 v.translatesAutoresizingMaskIntoConstraints = NO;
 
 [superview addSubview:v];
 
 [superview addConstraint:
 [NSLayoutConstraint 
  constraintWithSimpleFormat:
   @"v.centerX = superview.centerX"
                     metrics:nil
                       views:
   NSDictionaryOfVariableBindings(v, superview)]];
 @endcode
 
 @see https://github.com/ejvaughan/SimpleFormatLanguage for more information.
 
 @param format The simple format string containing the constraint description
 @param metrics A dictionary of constants that replace named values in @c format. The keys are the placeholder names, and the values are NSNumber objects.
 @param views A dictionary of views that appear in @c format. The keys are the names of the views in the format string, and the values are the views themselves.
 
 @return A constraint
 
 */

+ (NSLayoutConstraint *)constraintWithSimpleFormat:(NSString *)format metrics:(NSDictionary *)metrics views:(NSDictionary *)views;

/**
 Create multiple constraints from an array of simple format language constraints. A constraint is specified using the following syntax: view1.attribute relation multiplier * view2.attribute + constant @ priority.
 
 @code
 UIView *superview = ...;
 
 UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
 v.translatesAutoresizingMaskIntoConstraints = NO;
 
 [superview addSubview:v];
 
 [superview addConstraints:
 [NSLayoutConstraint
  constraintsWithSimpleFormat:
   @[ @"v.width = 100",
      @"v.height = v.width",
      @"v.centerX = superview.centerX",
      @"v.centerY = superview.centerY" ]
                      metrics:nil
                        views:
   NSDictionaryOfVariableBindings(v, superview)]];
 @endcode
 
 @see https://github.com/ejvaughan/SimpleFormatLanguage for more information.
 
 @param formattedConstraints An array of simple format language constraints.
 @param metrics A dictionary of constants that replace named values in the format strings. The keys are the placeholder names, and the values are NSNumber objects.
 @param views A dictionary of views that appear in the format strings. The keys are the names of the views in the format strings, and the values are the views themselves.
 
 @return An array of constraints
 
 */

+ (NSArray *)constraintsWithSimpleFormat:(NSArray *)formattedConstraints metrics:(NSDictionary *)metrics views:(NSDictionary *)views;

@end
