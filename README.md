Introduction
============

Auto Layout was introduced in OS X 10.7 and iOS 6 as a way to describe the layout of views in a user interface using objects called constraints. Instead of manually setting the frame of your views, you describe their position and size relative to each other. Because Auto Layout is based on relationships between views, it is far more powerful than the springs and struts system provided by autoresizing masks. However, creating constraints in code is a nightmare. The primitive API to create a single constraint is so verbose that creating even four constraints can easily span 34 lines of code. Apple's solution to this problem is called the Visual Format Language. Essentially, instead of typing out all the constraints by hand, you draw the layout of the views in an ASCII-art like string. While using the visual format language can reduce the amount of work involved, it is very limited and unsuitable for most tasks. *Simple Format Language* is my attempt to make constraint creation easy.

Simple Format Language
----------------------

Using Simple Format Language, instead of drawing views using ASCII-art, you describe the constraints intuitively. Here are some examples of Simple Format Language constraints:

    @"view.width = 100" // View's width is 100 pts.
    @"view.height = 2 * view.width" // View's height is twice its width
    @"view.centerX = superview.centerX" // View is centered horizontally in its superview
    @"view1.right = view2.left - 10" // There is a 10 pt. horizontal space between view1 and view2
    @"view.right <= superview.right - 10" // There are at least 10 pts. between the right edge of view and its superview
    @"view.width = 200 @ 750" // View's width is 200 with a priority of 750
    
That's it. The ability to create constraints from Simple Format Language strings is implemented as a category on NSLayoutConstraint. There are two methods:

    + (NSLayoutConstraint *)constraintWithSimpleFormat:(NSString *)format metrics:(NSDictionary *)metrics views (NSDictionary *)views;

which generates a single constraint from a Simple Format Language string, and

    + (NSArray *)constraintsWithSimpleFormat:(NSArray *)formattedConstraints metrics:(NSDictionary *)metrics views:(NSDictionary *)views;
    
which generates multiple constraints from an array of Simple Format Language strings.

As an example of how easy it is to create constraints using Simple Format Language, here is a typical example of what it takes to create four constraints using the normal API:

    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:redView
                                  attribute:NSLayoutAttributeWidth
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:nil
                                  attribute:NSLayoutAttributeNotAnAttribute
                                 multiplier:1
                                   constant:100]];
    
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:redView
                                  attribute:NSLayoutAttributeHeight
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:redView
                                  attribute:NSLayoutAttributeWidth
                                 multiplier:1
                                   constant:0]];
    
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:redView
                                  attribute:NSLayoutAttributeLeft
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:redView.superview
                                  attribute:NSLayoutAttributeLeft
                                 multiplier:1
                                   constant:0]];
    
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:redView
                                  attribute:NSLayoutAttributeCenterY
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:redView.superview
                                  attribute:NSLayoutAttributeCenterY
                                 multiplier:1
                                   constant:0]];
                                   
Using Simple Format Language, these four constraints reduce to:

    [superview addConstraints:
     [NSLayoutConstraint
      constraintsWithSimpleFormat:
      @[ @"redView.width = 100",
         @"redView.height = redView.width",
         @"redView.left = superview.left",
         @"redView.centerY = superview.centerY" ]
      metrics:nil
      views:
      NSDictionaryOfVariableBindings(redView, superview)]];
      
Syntax
------
      
The syntax of a Simple Format Language constraint is as follows:

    view1.attribute relation multiplier * view2.attribute + constant @ priority
    
where *relation* is either `=`, `>=`, or `<=`, and *attribute* is one of the following:

* left
* right
* top
* bottom
* trailing
* leading
* centerX
* centerY
* baseline
* width
* height.

The priority is optional, and if it is not specified, it defaults to the highest priority (required). It is important to note that **the order of elements matters**. For example, the following constraint is not valid:

    @"2 * view.width = view.height" // Not allowed!

as will

    @"view.height = view.width * 2" // Also not allowed
    

Conclusion
----------

The inspiration for Simple Format Language came from Apple's own documentation of Auto Layout. Apple uses practically the same format in its documentation to describe constraints (e.g., `view.width = 100`). I never understood why Apple didn't just use this format. Instead, we have Visual Format Language, which is too basic for most use cases. Hopefully, Simple Format Language will provide a powerful alternative that will finally make constraint creation easy, as it should be. Cheers!