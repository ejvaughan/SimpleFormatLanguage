//
//  NSLayoutConstraint+NSLayoutConstraint_SimpleFormatLanguage.m
//  AutoLayoutFun
//
//  Created by Ethan Vaughan on 11/28/13.
//  Copyright (c) 2013 Ethan James Vaughan. All rights reserved.
//

#import "NSLayoutConstraint+SimpleFormatLanguage.h"

@interface EVConstraintParser : NSObject

@property (nonatomic, strong) NSString *string;
@property (nonatomic, strong) NSDictionary *metrics;
@property (nonatomic, strong) NSDictionary *views;
@property (nonatomic, strong) NSScanner *scanner;
@property (nonatomic, strong) NSDictionary *attributes;
@property (nonatomic, strong) NSDictionary *relations;

- (instancetype)initWithString:(NSString *)string
                       metrics:(NSDictionary *)metrics
                         views:(NSDictionary *)views;

- (NSLayoutConstraint *)parseLayoutConstraint;

@end

@implementation EVConstraintParser

- (instancetype)initWithString:(NSString *)string
                       metrics:(NSDictionary *)metrics
                         views:(NSDictionary *)views
{
    self = [super init];
    
    if (self) {
        _string = string;
        _metrics = metrics;
        _views = views;
        _scanner = [[NSScanner alloc] initWithString:string];
        
        _attributes = @{ @"left" : @(NSLayoutAttributeLeft),
                         @"right" : @(NSLayoutAttributeRight),
                         @"top" : @(NSLayoutAttributeTop),
                         @"bottom" : @(NSLayoutAttributeBottom),
                         @"leading" : @(NSLayoutAttributeLeading),
                         @"trailing" : @(NSLayoutAttributeTrailing),
                         @"width" : @(NSLayoutAttributeWidth),
                         @"height" : @(NSLayoutAttributeHeight),
                         @"centerX" : @(NSLayoutAttributeCenterX),
                         @"centerY" : @(NSLayoutAttributeCenterY),
                         @"baseline" : @(NSLayoutAttributeBaseline) };
        
        _relations = @{ @"=" : @(NSLayoutRelationEqual),
                        @"<=" : @(NSLayoutRelationLessThanOrEqual),
                        @">=" : @(NSLayoutRelationGreaterThanOrEqual) };
    }
    
    return self;
}

- (NSNumber *)parseAttribute
{
    for (NSString *a in self.attributes) {
        if ([self.scanner scanString:a intoString:NULL]) {
            return [self.attributes objectForKey:a];
        }
    }
    
    return nil;
}

- (NSNumber *)parseRelation
{
    for (NSString *r in self.relations) {
        if ([self.scanner scanString:r intoString:NULL]) {
            return [self.relations objectForKey:r];
        }
    }
    
    return nil;
}

- (UIView *)parseView
{
    for (NSString *view in self.views) {
        if ([self.scanner scanString:view intoString:NULL]) {
            return [self.views objectForKey:view];
        }
    }
    
    return nil;
}

- (NSNumber *)parseNumber
{
    double number = 0;
    
    if ([self.scanner scanDouble:&number])
        return @(number);
    
    for (NSString *metric in self.metrics) {
        if ([self.scanner scanString:metric intoString:NULL])
            return [self.metrics objectForKey:metric];
    }
    
    return nil;
}

- (BOOL)parseDotSeparator
{
    return [self.scanner scanString:@"." intoString:NULL];
}

- (BOOL)parseMultiplyOperator
{
    return [self.scanner scanString:@"*" intoString:NULL];
}

- (NSNumber *)parseConstant
{
    if ([self.scanner scanString:@"+" intoString:NULL]) {
        return [self parseNumber];
    } else if ([self.scanner scanString:@"-" intoString:NULL]) {
        NSNumber *n = [self parseNumber];
        
        if (!n)
            return nil;
        
        return @(-n.doubleValue);
    }
    
    return nil;
}

- (NSNumber *)parsePriority
{
    if ([self.scanner scanString:@"@" intoString:NULL]) {
        return [self parseNumber];
    }
    
    return nil;
}

- (NSLayoutConstraint *)parseLayoutConstraint
{
    UIView *view1 = [self parseView];
    
    if (!view1)
        return nil;
    
    if (![self parseDotSeparator])
        return nil;
    
    NSNumber *attribute1 = [self parseAttribute];
    
    if (!attribute1)
        return nil;
    
    NSNumber *relation = [self parseRelation];
    
    if (!relation)
        return nil;
    
    NSNumber *multiplier = @1;
    
    NSNumber *number = [self parseNumber];
    
    if (number) {
        if ([self parseMultiplyOperator]) {
            multiplier = number;
        } else {
            NSNumber *priority = [self parsePriority];
            
            NSLayoutConstraint *c = [NSLayoutConstraint constraintWithItem:view1
                                                                 attribute:[attribute1 integerValue]
                                                                 relatedBy:[relation integerValue]
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1
                                                                  constant:[number doubleValue]];
            
            if (priority)
                c.priority = [priority integerValue];
            
            return c;
        }
    }
    
    UIView *view2 = [self parseView];
    
    if (!view2)
        return nil;
    
    if (![self parseDotSeparator])
        return nil;
    
    NSNumber *attribute2 = [self parseAttribute];
    
    if (!attribute2)
        return nil;
    
    NSNumber *constant = [self parseConstant];
    NSNumber *priority = [self parsePriority];
    
    NSLayoutConstraint *c = [NSLayoutConstraint constraintWithItem:view1
                                                         attribute:[attribute1 integerValue]
                                                         relatedBy:[relation integerValue]
                                                            toItem:view2
                                                         attribute:[attribute2 integerValue]
                                                        multiplier:[multiplier doubleValue]
                                                          constant:[constant doubleValue]];
    
    if (priority)
        c.priority = [priority integerValue];
    
    return c;
}

@end

@implementation NSLayoutConstraint (SimpleFormatLanguage)

+ (NSLayoutConstraint *)constraintWithSimpleFormat:(NSString *)format metrics:(NSDictionary *)metrics views:(NSDictionary *)views
{
    return [[[EVConstraintParser alloc] initWithString:format
                                               metrics:metrics
                                                 views:views] parseLayoutConstraint];
}

+ (NSArray *)constraintsWithSimpleFormat:(NSArray *)formattedConstraints metrics:(NSDictionary *)metrics views:(NSDictionary *)views
{
    NSMutableArray *constraints = [NSMutableArray arrayWithCapacity:[formattedConstraints count]];
    
    for (NSString *constraint in formattedConstraints) {
        NSLayoutConstraint *c =
        [NSLayoutConstraint constraintWithSimpleFormat:constraint
                                               metrics:metrics
                                                 views:views];
        
        if (c) {
            [constraints addObject:c];
        }
    }
    
    return constraints;
}

@end
