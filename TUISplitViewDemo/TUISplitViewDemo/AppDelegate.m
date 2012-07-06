#import "AppDelegate.h"
#import <TwUI/TUIKit.h>
#import "TUISplitView.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    TUINSView *view = self.window.contentView;
    view.autoresizingMask = TUIViewAutoresizingFlexibleSize;
    
    //TUISplitView *splitView = [[TUISplitView alloc] initWithFrame:view.frame splitViews:2];
    TUISplitView *splitView = [[TUISplitView alloc] initWithFrame:view.frame];
    splitView.horizontal = NO;
    view.rootView = splitView;
    
    TUIView *view1 = [[TUIView alloc] initWithFrame:CGRectZero];
    view1.backgroundColor = [TUIColor redColor];
#warning horizontal resizing might be off
    
    TUIView *view2 = [[TUIView alloc] initWithFrame:CGRectZero];
    view2.backgroundColor = [TUIColor blueColor];
    
    TUIView *view3 = [[TUIView alloc] initWithFrame:CGRectZero];
    view3.backgroundColor = [TUIColor magentaColor];
    
    [splitView addSplitView:view1];
    [splitView addSplitView:view2];
    [splitView addSplitView:view3];
    
    splitView.dividerThickness = 4.f;
    splitView.dividerDrawRectBlock = ^(TUIView *divider, CGRect rect) {
        CGRect bounds = divider.bounds;
        CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
        CGFloat locations[2] = {0, 1};
        CGFloat components[8] = {	0.988, 0.988, 0.988, 1.0,  // light
            0.875, 0.875, 0.875, 1.0 };// dark
        CGGradientRef gradient = CGGradientCreateWithColorComponents (rgb, components, locations, 2);
        CGContextRef context = TUIGraphicsGetCurrentContext();
        CGPoint start, end;
        // Light left to dark right.
        start = CGPointMake(CGRectGetMinX(bounds), CGRectGetMidY(bounds));
        end = CGPointMake(CGRectGetMaxX(bounds), CGRectGetMidY(bounds));
        CGContextDrawLinearGradient(context, gradient, start, end, 0);
        CGColorSpaceRelease(rgb);
        CGGradientRelease(gradient);
        
        // Draw borders.
        float borderThickness = 1.0;
        [[TUIColor colorWithWhite:0.7 alpha:1.0] set];
        CGRect borderRect = bounds;
        borderRect.size.width = borderThickness;
        CGContextFillRect(context, borderRect);
        borderRect.origin.x = CGRectGetMaxX(bounds) - borderThickness;
        CGContextFillRect(context, borderRect);
        
        // Draw grip.
        
        
        
        float width = 9.0;
        float height;
        height = 30.0;
        
        // Draw grip in centred in rect.
        CGRect gripRect = CGRectMake(0, 0, width, height);
        gripRect.origin.x = ((rect.size.width - gripRect.size.width) / 2.0);
        gripRect.origin.y = ((rect.size.height - gripRect.size.height) / 2.0);
        
        float stripThickness = 1.0;
        TUIColor *stripColor = [TUIColor colorWithWhite:0.35 alpha:1.0];
        TUIColor *lightColor = [TUIColor colorWithWhite:1.0 alpha:1.0];
        float space = 3.0;
        gripRect.size.width = stripThickness;
        [stripColor set];
        CGContextFillRect(context, gripRect);
        
        gripRect.origin.x += stripThickness;
        gripRect.origin.y += 1;
        [lightColor set];
        CGContextFillRect(context, gripRect);
        gripRect.origin.x -= stripThickness;
        gripRect.origin.y -= 1;
        
        gripRect.origin.x += space + stripThickness;
        [stripColor set];
        CGContextFillRect(context, gripRect);
        
        gripRect.origin.x += stripThickness;
        gripRect.origin.y += 1;
        [lightColor set];
        CGContextFillRect(context, gripRect);
        gripRect.origin.x -= stripThickness;
        gripRect.origin.y -= 1;
        
        gripRect.origin.x += space + stripThickness;
        [stripColor set];
        CGContextFillRect(context, gripRect);
        
        gripRect.origin.x += stripThickness;
        gripRect.origin.y += 1;
        [lightColor set];
        CGContextFillRect(context, gripRect);
    };
    //[self restoreState];
}

- (TUISplitView *)splitView {
    return (TUISplitView *)[(TUINSView *)self.window.contentView rootView];
}

- (void)restoreState {
    [[self splitView] setStateForString:[[NSUserDefaults standardUserDefaults] valueForKey:@"splitView"]];
}

- (void)saveState {
    [[NSUserDefaults standardUserDefaults] setValue:[[self splitView] stringForState] forKey:@"splitView"];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    //[self saveState];
}


@end
