//
//  AwesomeFloatingToolbar.m
//  BlocBrowser
//
//  Created by Amanda Pi on 2015-02-05.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "AwesomeFloatingToolbar.h"

@interface AwesomeFloatingToolbar ()

@property (nonatomic, strong) NSArray *currentTitles;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSMutableArray *buttons;
//@property (nonatomic, strong) NSArray *labels;
@property (nonatomic, weak) UILabel *currentLabel;
//@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;

@end

@implementation AwesomeFloatingToolbar


- (instancetype) initWithFourTitles:(NSArray *)titles {
    // First, call the superclass (UIView)'s initializer, to make sure we do all that setup first.
    self = [super init];
    
    if (self) {
        
        // Save the titles, and set the 4 colors
        self.currentTitles = titles;
        self.colors = @[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],
                        [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1]];
        
        // Make the 4 buttons
        NSMutableArray *buttonsArray = [[NSMutableArray alloc] init];
        
        for (NSString *currentTitle in self.currentTitles) {
            UIButton *button = [[UIButton alloc] init];
            button.userInteractionEnabled = YES; // changed to YES - is that OK?
            button.alpha = 0.25; // transparency is 0.25
            
            NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle];
            // 0 through 3
            NSString *titleForThisButton = [self.currentTitles objectAtIndex:currentTitleIndex];
            UIColor *colorForThisButton = [self.colors objectAtIndex:currentTitleIndex];
            
            //label.textAlignment = NSTextAlignmentCenter;
            button.titleLabel.font = [UIFont systemFontOfSize:20];
            [button setTitle:titleForThisButton forState:UIControlStateNormal];
            button.backgroundColor = colorForThisButton;
            button.titleLabel.textColor = [UIColor whiteColor];
            
            [buttonsArray addObject:button];
        }
        
        self.buttons = buttonsArray;
        
        for (UIButton *thisButton in self.buttons) {
            [thisButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:thisButton];
        }
        //self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
        // detect the tap at view self, and when a tap is detected call tapFired:
        // [self addGestureRecognizer:self.tapGesture];
        
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
        [self addGestureRecognizer:self.panGesture];
        
        self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchFired:)];
        [self addGestureRecognizer:self.pinchGesture];
        
        self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressFired:)];
        [self addGestureRecognizer:self.longPressGesture];
    }
    
    return self;
}


- (void) layoutSubviews {
    // set the frames for the 4 labels
    
    for (UIButton *thisButton in self.buttons) {
        NSUInteger currentButtonIndex = [self.buttons indexOfObject:thisButton];
        
        CGFloat ButtonHeight = CGRectGetHeight(self.bounds) / 2;
        CGFloat ButtonWidth = CGRectGetWidth(self.bounds) / 2;
        CGFloat ButtonX = 0;
        CGFloat ButtonY = 0;
        
        // adjust buttonX and buttonY for each button
        if (currentButtonIndex < 2) {
            // 0 or 1, so on top
            ButtonY = 0;
        } else {
            // 2 or 3, so on bottom
            ButtonY = CGRectGetHeight(self.bounds) / 2;
        }
        
        if (currentButtonIndex % 2 == 0) { // is currentButtonIndex evenly divisible by 2?
            // 0 or 2, so on the left
            ButtonX = 0;
        } else {
            // 1 or 3, so on the right
            ButtonX = CGRectGetWidth(self.bounds) / 2;
        }
        
        thisButton.frame = CGRectMake(ButtonX, ButtonY, ButtonWidth, ButtonHeight);
    }
}


#pragma mark - Button Enabling


- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title {
    NSUInteger index = [self.currentTitles indexOfObject:title];
    
    if (index != NSNotFound) {
        UIButton *button = [self.buttons objectAtIndex:index];
        button.userInteractionEnabled = enabled;
        button.alpha = enabled?  1.0 : 0.25;
    }
}


#pragma mark - Touch Handling


- (UIButton *) ButtonFromTouches:(NSSet *)touches withEvent:(UIEvent *)event {
    // find out which of the 4 buttons are touched
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    UIView *subview = [self hitTest:location withEvent:event];
    return (UIButton *)subview;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // How to make buttons dim on touch?
    UIButton *button = [self ButtonFromTouches:touches withEvent:event];
    button.alpha = 0.5;
}

- (void) buttonPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
        [self.delegate floatingToolbar:self didSelectButtonWithTitle:((UIButton *)sender).titleLabel.text];
    }
}

//- (void) tapFired:(UITapGestureRecognizer *)recognizer {
    // first, check for the proper state:
//    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        // then, get xy coordinates of the tap:
//        CGPoint location = [recognizer locationInView:self];
        // Logging the tap point
//        NSLog(@"Checking location: %f, %f", location.x, location.y);
        // then, find out which view received the tap:
//        UIView *tappedView = [self hitTest:location withEvent:nil];
        // then, check if the tap was in toolbar bound:
//        if ([self.buttons containsObject:tappedView]) {
//            if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
//                [self.delegate floatingToolbar:self didSelectButtonWithTitle:((UILabel *)tappedView).text];
//            }
//        }
//    }
//}


- (void) panFired:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        // location not important, direction is important
        CGPoint Translation = [recognizer translationInView:self];
        // Logging the translation change
        NSLog(@"New translation: %@", NSStringFromCGPoint(Translation));
        // a pan = collection of many mini-pans so this method is called many times
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPanWithOffset:)])
        {
            [self.delegate floatingToolbar:self didTryToPanWithOffset:Translation];
        }
        // reset translation to 0 after each call
        [recognizer setTranslation:CGPointZero inView:self];
    }
}


// Assignment: add a pinch gesture recognizer

- (void) pinchFired:(UIPinchGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        // pinch is about scaling the toolbar to a float multiple of original scale
        CGFloat scale = [recognizer scale];
        // Logging the scale change
        NSLog(@"New scale is %f", scale);
        // a pinch = collection of many mini-pinches
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPinchWithScale:)])
        {
            [self.delegate floatingToolbar:self didTryToPinchWithScale:scale];
        }
        //reset scale to 1.0
        [recognizer setScale:1.0];
    }
}


// Assignment: add a long press gesture recognizer to rotate label colors

-(void) longPressFired:(UILongPressGestureRecognizer*)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        UIColor* returnColor = ((UIButton*)self.buttons[0]).backgroundColor;
        // iterate through buttons
        for (NSInteger i = 0; i < self.colors.count; i++) {
            UIButton* currentButton = self.buttons[i];
            currentButton.backgroundColor = ((UIButton*)self.buttons[(i + 1) % self.colors.count]).backgroundColor;
            
        // Logging colors
            NSLog(@"First color is %@", self.colors[0]);
            NSLog(@"Second color is %@", self.colors[1]);

        // When i gets to limit of count
            if (i == (self.colors.count - 1)) {
                ((UILabel*)self.buttons[i]).backgroundColor = returnColor;
            }
        }
    }
}


@end
