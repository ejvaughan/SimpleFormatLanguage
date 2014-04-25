//
//  EVSimpleFormatLanguageTests.m
//  Example
//
//  Created by Ethan Vaughan on 4/24/14.
//  Copyright (c) 2014 Ethan James Vaughan. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSLayoutConstraint+SimpleFormatLanguage.h"

@interface EVSimpleFormatLanguageTests : XCTestCase

@property (nonatomic, strong) UIView *view1;
@property (nonatomic, strong) UIView *view2;
@property (nonatomic, strong) NSDictionary *views;

@end

@implementation EVSimpleFormatLanguageTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    
    self.view1 = [[UIView alloc] initWithFrame:CGRectZero];
    self.view2 = [[UIView alloc] initWithFrame:CGRectZero];
    self.views = @{ @"view1" : self.view1, @"view2" : self.view2 };
}

- (void)testNilFormatString
{
    XCTAssertThrowsSpecificNamed([NSLayoutConstraint constraintWithSimpleFormat:nil metrics:nil views:nil], NSException, NSInvalidArgumentException, @"A nil format string should throw an invalid argument exception");
}

- (void)testInvalidViewsDictionary
{
    NSString *exampleFormatString = @"view.width = 10";
    
    XCTAssertThrowsSpecificNamed([NSLayoutConstraint constraintWithSimpleFormat:exampleFormatString metrics:nil views:nil], NSException, NSInvalidArgumentException, @"A nil views dictionary should throw an invalid argument exception");
    
    XCTAssertNil([NSLayoutConstraint constraintWithSimpleFormat:exampleFormatString metrics:nil views:@{}], @"nil should be returned when the views dictionary is empty");
    
    XCTAssertNil([NSLayoutConstraint constraintWithSimpleFormat:exampleFormatString metrics:nil views:@{ @"view" : @"Not a UIView!" }], @"nil should be returned when the views dictionary contains values that are not instances of UIView");
}

- (void)testInvalidMetricsDictionary
{
    NSString *exampleFormatStringWithMetric = @"view1.width = w";
    
    XCTAssertNil([NSLayoutConstraint constraintWithSimpleFormat:exampleFormatStringWithMetric metrics:nil views:self.views], @"nil should be returned when the format string contains metrics but the metrics dictionary is nil");
    
    XCTAssertNil([NSLayoutConstraint constraintWithSimpleFormat:exampleFormatStringWithMetric metrics:@{} views:self.views], @"nil should be returned when the format string contains metrics but the metrics dictionary is empty");
    
    XCTAssertNil([NSLayoutConstraint constraintWithSimpleFormat:exampleFormatStringWithMetric metrics:@{ @"w" : @"100" } views:self.views], @"nil should be returned when the metrics dictionary contains values that are not instances of NSNumber");
    
}

- (BOOL)constraint:(NSLayoutConstraint *)constraint1 isEqualToConstraint:(NSLayoutConstraint *)constraint2
{
    return constraint1.firstItem == constraint2.firstItem &&
    constraint1.firstAttribute == constraint2.firstAttribute &&
    constraint1.relation == constraint2.relation &&
    constraint1.secondItem == constraint2.secondItem &&
    constraint1.secondAttribute == constraint2.secondAttribute &&
    constraint1.multiplier == constraint2.multiplier &&
    constraint1.constant == constraint2.constant &&
    constraint1.priority == constraint2.priority;
}

- (void)testPositiveConstantConstraint
{
    NSLayoutConstraint *controlConstraint = [NSLayoutConstraint constraintWithItem:self.view1
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:1
                                                                    constant:100];
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithSimpleFormat:@"view1.width = 100"
                                                                             metrics:nil
                                                                               views:self.views];
    
    BOOL constraintsAreEqual = [self constraint:constraint isEqualToConstraint:controlConstraint];
    XCTAssertTrue(constraintsAreEqual, @"constraints must be equal");
}

- (void)testNegativeConstantConstraint
{
    NSLayoutConstraint *controlConstraint = [NSLayoutConstraint constraintWithItem:self.view1
                                                                         attribute:NSLayoutAttributeWidth
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:nil
                                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                                        multiplier:1
                                                                          constant:-100];
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithSimpleFormat:@"view1.width = -100"
                                                                             metrics:nil
                                                                               views:self.views];
    
    BOOL constraintsAreEqual = [self constraint:constraint isEqualToConstraint:controlConstraint];
    XCTAssertTrue(constraintsAreEqual, @"constraints must be equal");
}

- (void)testMetricConstantConstraint
{
    NSLayoutConstraint *controlConstraint = [NSLayoutConstraint constraintWithItem:self.view1
                                                                         attribute:NSLayoutAttributeWidth
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:nil
                                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                                        multiplier:1
                                                                          constant:100];
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithSimpleFormat:@"view1.width = constant" metrics:@{ @"constant" : @100 } views:self.views];
    
    BOOL constraintsAreEqual = [self constraint:constraint isEqualToConstraint:controlConstraint];
    XCTAssertTrue(constraintsAreEqual, @"constraints must be equal");
}

- (void)testConstantConstraintWithPriority
{
    NSLayoutConstraint *controlConstraint = [NSLayoutConstraint constraintWithItem:self.view1
                                                                         attribute:NSLayoutAttributeWidth
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:nil
                                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                                        multiplier:1
                                                                          constant:100];
    
    controlConstraint.priority = 500;
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithSimpleFormat:@"view1.width = 100 @ 500"
                                                                            metrics:nil
                                                                              views:self.views];
    
    BOOL constraintsAreEqual = [self constraint:constraint isEqualToConstraint:controlConstraint];
    XCTAssertTrue(constraintsAreEqual, @"constraints must be equal");
}

- (void)testVariableConstraint
{
    NSLayoutConstraint *controlConstraint = [NSLayoutConstraint constraintWithItem:self.view1
                                                                         attribute:NSLayoutAttributeWidth
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.view2
                                                                         attribute:NSLayoutAttributeWidth
                                                                        multiplier:1
                                                                          constant:0];
    
    NSLayoutConstraint *constraint1 = [NSLayoutConstraint constraintWithSimpleFormat:@"view1.width = view2.width" metrics:nil views:self.views];
    
    BOOL constraintsAreEqual = [self constraint:controlConstraint isEqualToConstraint:constraint1];
    XCTAssertTrue(constraintsAreEqual, @"constraints must be equal");
}

- (void)testVariableConstraintWithPriority
{
    NSLayoutConstraint *controlConstraint = [NSLayoutConstraint constraintWithItem:self.view1
                                                                         attribute:NSLayoutAttributeWidth
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.view2
                                                                         attribute:NSLayoutAttributeWidth
                                                                        multiplier:1
                                                                          constant:0];
    controlConstraint.priority = 500;
    
    NSLayoutConstraint *constraint1 = [NSLayoutConstraint constraintWithSimpleFormat:@"view1.width = view2.width @ 500" metrics:nil views:self.views];
    
    BOOL constraintsAreEqual = [self constraint:controlConstraint isEqualToConstraint:constraint1];
    XCTAssertTrue(constraintsAreEqual, @"constraints must be equal");
}

- (void)testVariableConstraintWithPositiveMultiplier
{
    NSLayoutConstraint *controlConstraint = [NSLayoutConstraint constraintWithItem:self.view1
                                                                         attribute:NSLayoutAttributeWidth
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.view2
                                                                         attribute:NSLayoutAttributeWidth
                                                                        multiplier:10
                                                                          constant:0];
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithSimpleFormat:@"view1.width = 10 * view2.width" metrics:nil views:self.views];
    
    BOOL constraintsAreEqual = [self constraint:constraint isEqualToConstraint:controlConstraint];
    XCTAssertTrue(constraintsAreEqual, @"constraints must be equal");
}

- (void)testVariableConstraintWithNegativeMultiplier
{
    NSLayoutConstraint *controlConstraint = [NSLayoutConstraint constraintWithItem:self.view1
                                                                         attribute:NSLayoutAttributeWidth
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.view2
                                                                         attribute:NSLayoutAttributeWidth
                                                                        multiplier:-10
                                                                          constant:0];
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithSimpleFormat:@"view1.width = -10 * view2.width" metrics:nil views:self.views];
    
    BOOL constraintsAreEqual = [self constraint:constraint isEqualToConstraint:controlConstraint];
    XCTAssertTrue(constraintsAreEqual, @"constraints must be equal");
}

- (void)testVariableConstraintWithMetricMultiplier
{
    NSLayoutConstraint *controlConstraint = [NSLayoutConstraint constraintWithItem:self.view1
                                                                         attribute:NSLayoutAttributeWidth
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.view2
                                                                         attribute:NSLayoutAttributeWidth
                                                                        multiplier:10
                                                                          constant:0];
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithSimpleFormat:@"view1.width = m * view2.width" metrics:@{ @"m" : @10 } views:self.views];
    
    BOOL constraintsAreEqual = [self constraint:constraint isEqualToConstraint:controlConstraint];
    XCTAssertTrue(constraintsAreEqual, @"constraints must be equal");
}

- (void)testVariableConstraintWithMultiplierAndPriority
{
    NSLayoutConstraint *controlConstraint = [NSLayoutConstraint constraintWithItem:self.view1
                                                                         attribute:NSLayoutAttributeWidth
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.view2
                                                                         attribute:NSLayoutAttributeWidth
                                                                        multiplier:10
                                                                          constant:0];
    controlConstraint.priority = 500;
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithSimpleFormat:@"view1.width = 10 * view2.width @ 500" metrics:nil views:self.views];
    
    BOOL constraintsAreEqual = [self constraint:constraint isEqualToConstraint:controlConstraint];
    XCTAssertTrue(constraintsAreEqual, @"constraints must be equal");
}

- (void)testVariableConstraintWithMultiplierAndPositiveConstant
{
    NSLayoutConstraint *controlConstraint = [NSLayoutConstraint constraintWithItem:self.view1
                                                                         attribute:NSLayoutAttributeWidth
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.view2
                                                                         attribute:NSLayoutAttributeWidth
                                                                        multiplier:10
                                                                          constant:1];
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithSimpleFormat:@"view1.width = 10 * view2.width + 1" metrics:nil views:self.views];
    
    BOOL constraintsAreEqual = [self constraint:constraint isEqualToConstraint:controlConstraint];
    XCTAssertTrue(constraintsAreEqual, @"constraints must be equal");
}

- (void)testVariableConstraintWithMultiplierAndNegativeConstant
{
    NSLayoutConstraint *controlConstraint = [NSLayoutConstraint constraintWithItem:self.view1
                                                                         attribute:NSLayoutAttributeWidth
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.view2
                                                                         attribute:NSLayoutAttributeWidth
                                                                        multiplier:10
                                                                          constant:-1];
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithSimpleFormat:@"view1.width = 10 * view2.width - 1" metrics:nil views:self.views];
    
    BOOL constraintsAreEqual = [self constraint:constraint isEqualToConstraint:controlConstraint];
    XCTAssertTrue(constraintsAreEqual, @"constraints must be equal");
}

- (void)testVariableConstraintWithMultiplierAndMetricConstant
{
    NSLayoutConstraint *controlConstraint = [NSLayoutConstraint constraintWithItem:self.view1
                                                                         attribute:NSLayoutAttributeWidth
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.view2
                                                                         attribute:NSLayoutAttributeWidth
                                                                        multiplier:10
                                                                          constant:1];
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithSimpleFormat:@"view1.width = 10 * view2.width + constant" metrics:@{ @"constant" : @1 } views:self.views];
    
    BOOL constraintsAreEqual = [self constraint:constraint isEqualToConstraint:controlConstraint];
    XCTAssertTrue(constraintsAreEqual, @"constraints must be equal");
}

- (void)testVariableConstraintWithMultiplierAndSubtractedMetricConstant
{
    NSLayoutConstraint *controlConstraint = [NSLayoutConstraint constraintWithItem:self.view1
                                                                         attribute:NSLayoutAttributeWidth
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.view2
                                                                         attribute:NSLayoutAttributeWidth
                                                                        multiplier:10
                                                                          constant:-1];
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithSimpleFormat:@"view1.width = 10 * view2.width - constant" metrics:@{ @"constant" : @1 } views:self.views];
    
    BOOL constraintsAreEqual = [self constraint:constraint isEqualToConstraint:controlConstraint];
    XCTAssertTrue(constraintsAreEqual, @"constraints must be equal");
}

- (void)testVariableConstraintWithMultiplierAndConstantAndPriority
{
    NSLayoutConstraint *controlConstraint = [NSLayoutConstraint constraintWithItem:self.view1
                                                                         attribute:NSLayoutAttributeWidth
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.view2
                                                                         attribute:NSLayoutAttributeWidth
                                                                        multiplier:10
                                                                          constant:1];
    controlConstraint.priority = 500;
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithSimpleFormat:@"view1.width = 10 * view2.width + 1 @ 500" metrics:nil views:self.views];
    
    BOOL constraintsAreEqual = [self constraint:constraint isEqualToConstraint:controlConstraint];
    XCTAssertTrue(constraintsAreEqual, @"constraints must be equal");
}

@end
