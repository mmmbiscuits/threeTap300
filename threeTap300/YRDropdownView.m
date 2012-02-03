//
//  YRDropdownView.m
//  YRDropdownViewExample
//
//  Created by Eli Perkins on 1/27/12.
//  Copyright (c) 2012 One Mighty Roar. All rights reserved.
//

#import "YRDropdownView.h"
#import <QuartzCore/QuartzCore.h>

@interface UILabel (YRDropdownView)
- (void)sizeToFitFixedWidth:(CGFloat)fixedWidth;
@end

@implementation UILabel (YRDropdownView)


- (void)sizeToFitFixedWidth:(CGFloat)fixedWidth
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, fixedWidth, 0);
    self.lineBreakMode = UILineBreakModeWordWrap;
    self.numberOfLines = 0;
    [self sizeToFit];
}
@end

@interface YRDropdownView ()
- (void)updateTitleLabel:(NSString *)newText;
- (void)updateDetailLabel:(NSString *)newText;
- (void)hideUsingAnimation:(NSNumber *)animated;
- (void)done;
@end


@implementation YRDropdownView

@synthesize titleText;
@synthesize detailText;
@synthesize minHeight;
@synthesize backgroundImage;
@synthesize accessoryImage;
@synthesize onTouch;
@synthesize shouldAnimate;

//Using this prevents two alerts to ever appear on the screen at the same time
//TODO: Queue alerts, if multiple
static YRDropdownView *currentDropdown = nil;

+ (YRDropdownView *)currentDropdownView
{
    return currentDropdown;
}

#pragma mark - Accessors

- (NSString *)titleText
{
    return titleText;
}

- (void)setTitleText:(NSString *)newText
{
    if ([NSThread isMainThread]) {
		[self updateTitleLabel:newText];
		[self setNeedsLayout];
		[self setNeedsDisplay];
	} else {
		[self performSelectorOnMainThread:@selector(updateTitleLabel:) withObject:newText waitUntilDone:NO];
		[self performSelectorOnMainThread:@selector(setNeedsLayout) withObject:nil waitUntilDone:NO];
		[self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
	}
}

- (NSString *)detailText
{
    return detailText;
}

- (void)setDetailText:(NSString *)newText
{
    if ([NSThread isMainThread]) {
        [self updateDetailLabel:newText];
        [self setNeedsLayout];
        [self setNeedsDisplay];
    } else {
        [self performSelectorOnMainThread:@selector(updateDetailLabel:) withObject:newText waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(setNeedsLayout) withObject:nil waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
    }
}

- (void)updateTitleLabel:(NSString *)newText {
    if (titleText != newText) {
    #if !__has_feature(objc_arc)
        [titleText release];
    #endif
        titleText = [newText copy];
        titleLabel.text = titleText;
    }
}

- (void)updateDetailLabel:(NSString *)newText {
    if (detailText != newText) {
    #if !__has_feature(objc_arc)
        [detailText release];
    #endif
        detailText = [newText copy];
        detailLabel.text = detailText;
    }
}



#pragma mark - Initializers
- (id)init {
    return [self initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.titleText = nil;
        self.detailText = nil;
        self.minHeight = 44.0f;
        self.backgroundImage = [UIImage imageNamed:@"bg-yellow.png"];
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        detailLabel = [[UILabel alloc] initWithFrame:self.bounds];
        backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        backgroundImageView.image = [self.backgroundImage stretchableImageWithLeftCapWidth:1 topCapHeight:self.backgroundImage.size.height/2];
        backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        accessoryImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:backgroundImageView];
        
        self.opaque = YES;
        
        onTouch = @selector(hide:);
    }
    return self;
}
- (id)initWithFrameOfColor:(CGRect)frame: (NSString*)color
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.titleText = nil;
        self.detailText = nil;
        self.minHeight = 44.0f;
        NSString * permutationString = [NSString stringWithFormat:@"bg-%@.png",color];
        NSLog(@"permutation string is:%@",permutationString);
        self.backgroundImage = [UIImage imageNamed:permutationString];
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        detailLabel = [[UILabel alloc] initWithFrame:self.bounds];
        backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        backgroundImageView.image = [self.backgroundImage stretchableImageWithLeftCapWidth:1 topCapHeight:self.backgroundImage.size.height/2];
        backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        accessoryImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:backgroundImageView];
        
        self.opaque = YES;
        
        onTouch = @selector(hide:);
    }
    return self;
}

#pragma mark - Defines

#define HORIZONTAL_PADDING 15.0f
#define VERTICAL_PADDING 19.0f
#define IMAGE_PADDING 45.0f
#define TITLE_FONT_SIZE 19.0f
#define DETAIL_FONT_SIZE 13.0f
#define ANIMATION_DURATION 0.3f

#pragma mark - Class methods
#pragma mark View Methods
+ (YRDropdownView *)showDropdownInView:(UIView *)view title:(NSString *)title
{
    return [YRDropdownView showDropdownInView:view title:title detail:nil];
}

+ (YRDropdownView *)showDropdownInView:(UIView *)view title:(NSString *)title detail:(NSString *)detail
{
    return [YRDropdownView showDropdownInView:view title:title detail:detail image:nil animated:YES];
}

+ (YRDropdownView *)showDropdownInView:(UIView *)view title:(NSString *)title detail:(NSString *)detail animated:(BOOL)animated
{
    return [YRDropdownView showDropdownInView:view title:title detail:detail image:nil animated:animated hideAfter:0.0];
}

+ (YRDropdownView *)showDropdownInView:(UIView *)view title:(NSString *)title detail:(NSString *)detail image:(UIImage *)image animated:(BOOL)animated
{
    return [YRDropdownView showDropdownInView:view title:title detail:detail image:image animated:animated hideAfter:0.0];
}

+ (YRDropdownView *)showDropdownInView:(UIView *)view 
                             title:(NSString *)title 
                            detail:(NSString *)detail 
                             image:(UIImage *)image
                          animated:(BOOL)animated
                         hideAfter:(float)delay
                     setBackground:(NSString*)colour
{
    if (currentDropdown) {
        [currentDropdown hideUsingAnimation:[NSNumber numberWithBool:animated]];
    }
    
    YRDropdownView *dropdown = [[YRDropdownView alloc] initWithFrameOfColor:CGRectMake(0, 0, view.bounds.size.width, 44):(NSString*) colour];
    currentDropdown = dropdown;
    dropdown.titleText = title;

    if (detail) {
        dropdown.detailText = detail;
    } 

    if (image) {
        dropdown.accessoryImage = image;
    }
    
    dropdown.shouldAnimate = animated;
    
    [view addSubview:dropdown];
    [dropdown show:animated];
    if (delay != 0.0) {
        [dropdown performSelector:@selector(hideUsingAnimation:) withObject:[NSNumber numberWithBool:animated] afterDelay:delay+ANIMATION_DURATION];
    }
    if (colour){
        NSLog(@"%@",colour);
        NSString * colourBackgroundToLoad = [NSString stringWithFormat:@"bg-%@.png",colour];
        dropdown.backgroundImage = [UIImage imageNamed:colourBackgroundToLoad];
    }

    return dropdown;
}

#pragma mark Window Methods

+ (YRDropdownView *)showDropdownInWindow:(UIWindow *)window title:(NSString *)title
{
    return [YRDropdownView showDropdownInWindow:window title:title detail:nil];
}

+ (YRDropdownView *)showDropdownInWindow:(UIWindow *)window title:(NSString *)title detail:(NSString *)detail
{
    return [YRDropdownView showDropdownInWindow:window title:title detail:detail image:nil animated:YES];
}

+ (YRDropdownView *)showDropdownInWindow:(UIWindow *)window title:(NSString *)title detail:(NSString *)detail animated:(BOOL)animated
{
    return [YRDropdownView showDropdownInWindow:window title:title detail:detail image:nil animated:animated hideAfter:0.0];
}

+ (YRDropdownView *)showDropdownInWindow:(UIWindow *)window title:(NSString *)title detail:(NSString *)detail image:(UIImage *)image animated:(BOOL)animated
{
    return [YRDropdownView showDropdownInWindow:window title:title detail:detail image:image animated:animated hideAfter:0.0];
}
  

+ (YRDropdownView *)showDropdownInWindow:(UIWindow *)window title:(NSString *)title detail:(NSString *)detail image:(UIImage *)image animated:(BOOL)animated hideAfter:(float)delay 
{
    if (currentDropdown) {
        [currentDropdown hideUsingAnimation:[NSNumber numberWithBool:animated]];
    }
    
    YRDropdownView *dropdown = [[YRDropdownView alloc] initWithFrame:CGRectMake(0, 0, window.bounds.size.width, 44)];
    currentDropdown = dropdown;
    dropdown.titleText = title;
    
    if (detail) {
        dropdown.detailText = detail;
    }
    
    if (image) {
        dropdown.accessoryImage = image;
    }
        
    if (![UIApplication sharedApplication].statusBarHidden) {
        CGRect frame = dropdown.frame;
        frame.origin.y += [UIApplication sharedApplication].statusBarFrame.size.height;
        dropdown.frame = frame;
    }

    [window addSubview:dropdown];
    [dropdown show:animated];
    if (delay != 0.0) {
        [dropdown performSelector:@selector(hideUsingAnimation:) withObject:[NSNumber numberWithBool:animated] afterDelay:delay+ANIMATION_DURATION];
    }

    return dropdown;
}

+ (void)removeView 
{
    if (!currentDropdown) {
        return;
    }
    
    [currentDropdown removeFromSuperview];
    
    [currentDropdown release];
    currentDropdown = nil;
}

+ (BOOL)hideDropdownInView:(UIView *)view
{
    return [YRDropdownView hideDropdownInView:view animated:YES];
}

+ (BOOL)hideDropdownInView:(UIView *)view animated:(BOOL)animated
{
    if (currentDropdown) {
        [currentDropdown hideUsingAnimation:[NSNumber numberWithBool:animated]];
        return YES;
    }
    
    UIView *viewToRemove = nil;
    for (UIView *v in [view subviews]) {
        if ([v isKindOfClass:[YRDropdownView class]]) {
            viewToRemove = v;
        }
    }
    if (viewToRemove != nil) {
        YRDropdownView *dropdown = (YRDropdownView *)viewToRemove;
        [dropdown hideUsingAnimation:[NSNumber numberWithBool:animated]];
        return YES;
    }
    else {
        return NO;
    }
}

+ (BOOL)hideDropdownInWindow:(UIWindow *)window
{
    return [YRDropdownView hideDropdownInWindow:window animated:YES];
}

+ (BOOL)hideDropdownInWindow:(UIWindow *)window animated:(BOOL)animated
{
    if (currentDropdown) {
        [currentDropdown hideUsingAnimation:[NSNumber numberWithBool:animated]];
        return YES;
    }
    
    UIView *viewToRemove = nil;
    for (UIView *v in [window subviews]) {
        if ([v isKindOfClass:[YRDropdownView class]]) {
            viewToRemove = v;
        }
    }
    if (viewToRemove != nil) {
        YRDropdownView *dropdown = (YRDropdownView *)viewToRemove;
        [dropdown hideUsingAnimation:[NSNumber numberWithBool:animated]];
        return YES;
    }
    else {
        return NO;
    }
}

#pragma mark - Methods

- (void)show:(BOOL)animated
{
    if(animated)
    {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y-self.frame.size.height, self.frame.size.width, self.frame.size.height);
        self.alpha = 0.02;
        [UIView animateWithDuration:ANIMATION_DURATION
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.alpha = 1.0;
                             self.frame = CGRectMake(self.frame.origin.x, 
                                                     self.frame.origin.y+self.frame.size.height,
                                                     self.frame.size.width, self.frame.size.height);
                         }
                         completion:^(BOOL finished) {
                             if (finished)
                             {
                                 
                             }
                         }];

    }
}

- (void)hide:(BOOL)animated
{
    [self done];
}

- (void)hideUsingAnimation:(NSNumber *)animated {
    if ([animated boolValue]) {
        [UIView animateWithDuration:ANIMATION_DURATION
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.alpha = 0.02;
                             self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y-self.frame.size.height, self.frame.size.width, self.frame.size.height);
                         }
                         completion:^(BOOL finished) {
                             if (finished)
                             {
                                 [self done];
                             }
                         }];        
    }
    else {
        self.alpha = 0.0f;
        [self done];
    }
}

- (void)done
{
    [self removeFromSuperview];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self hideUsingAnimation:[NSNumber numberWithBool:self.shouldAnimate]];
}

#pragma mark - Layout

- (void)layoutSubviews {    
    // Set label properties
    titleLabel.font = [UIFont boldSystemFontOfSize:TITLE_FONT_SIZE];
    titleLabel.adjustsFontSizeToFitWidth = NO;
    titleLabel.opaque = NO;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor colorWithWhite:0.225 alpha:1.0];
    titleLabel.shadowOffset = CGSizeMake(0, 1/[[UIScreen mainScreen] scale]);
    titleLabel.shadowColor = [UIColor colorWithWhite:1 alpha:0.25];
    titleLabel.text = self.titleText;
    [titleLabel sizeToFitFixedWidth:self.bounds.size.width - (2 * HORIZONTAL_PADDING)];
    
    titleLabel.frame = CGRectMake(self.bounds.origin.x + HORIZONTAL_PADDING, 
                                  self.bounds.origin.y + VERTICAL_PADDING - 8, 
                                  self.bounds.size.width - (2 * HORIZONTAL_PADDING), 
                                  titleLabel.frame.size.height);
    
    [self addSubview:titleLabel];
    
    if (self.detailText) {
        detailLabel.font = [UIFont systemFontOfSize:DETAIL_FONT_SIZE];
        detailLabel.numberOfLines = 0;
        detailLabel.adjustsFontSizeToFitWidth = NO;
        detailLabel.opaque = NO;
        detailLabel.backgroundColor = [UIColor clearColor];
        detailLabel.textColor = [UIColor colorWithWhite:0.225 alpha:1.0];
        detailLabel.shadowOffset = CGSizeMake(0, 1/[[UIScreen mainScreen] scale]);
        detailLabel.shadowColor = [UIColor colorWithWhite:1 alpha:0.25];
        detailLabel.text = self.detailText;
        [detailLabel sizeToFitFixedWidth:self.bounds.size.width - (2 * HORIZONTAL_PADDING)];
        
        detailLabel.frame = CGRectMake(self.bounds.origin.x + HORIZONTAL_PADDING, 
                                       titleLabel.frame.origin.y + titleLabel.frame.size.height + 2, 
                                       self.bounds.size.width - (2 * HORIZONTAL_PADDING), 
                                       detailLabel.frame.size.height);

        [self addSubview:detailLabel];
    } else {
        titleLabel.frame = CGRectMake(titleLabel.frame.origin.x,
                                      9,
                                      titleLabel.frame.size.width, 
                                      titleLabel.frame.size.height);
    }
    
    if (self.accessoryImage) {
        accessoryImageView.image = self.accessoryImage;
        accessoryImageView.frame = CGRectMake(self.bounds.origin.x + HORIZONTAL_PADDING, 
                                              self.bounds.origin.y + VERTICAL_PADDING,
                                              self.accessoryImage.size.width,
                                              self.accessoryImage.size.height);
        
        [titleLabel sizeToFitFixedWidth:self.bounds.size.width - IMAGE_PADDING - (HORIZONTAL_PADDING * 2)];
        titleLabel.frame = CGRectMake(titleLabel.frame.origin.x + IMAGE_PADDING, 
                                      titleLabel.frame.origin.y, 
                                      titleLabel.frame.size.width, 
                                      titleLabel.frame.size.height);
        
        if (self.detailText) {
            [detailLabel sizeToFitFixedWidth:self.bounds.size.width - IMAGE_PADDING - (HORIZONTAL_PADDING * 2)];
            detailLabel.frame = CGRectMake(detailLabel.frame.origin.x + IMAGE_PADDING, 
                                           detailLabel.frame.origin.y, 
                                           detailLabel.frame.size.width, 
                                           detailLabel.frame.size.height);
        }
        
        [self addSubview:accessoryImageView];
    }
    
    CGFloat dropdownHeight = 44.0f;
    if (self.detailText) {
        dropdownHeight = MAX(CGRectGetMaxY(self.bounds), CGRectGetMaxY(detailLabel.frame));
        dropdownHeight += VERTICAL_PADDING;
    } 
            
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, dropdownHeight)];
    
    [backgroundImageView setFrame:self.bounds];
        
}

@end


