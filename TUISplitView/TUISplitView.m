#import "TUISplitView.h"

#define INITIAL_DRAG_LOCATION @"initialDragLocation"
#define CURRENT_DIVIDER @"currentDivider"
#define INITIAL_DIVIDER_ORIGIN @"initialDividerOrigin"
#define FIRST_SPLITVIEW_FRAME @"firstSplitViewFrame"
#define SECOND_SPLITVEIW_FRAME @"secondSplitViewFrame"

@interface TUISplitView()
@property (nonatomic, strong) NSMutableArray *splitViews;
@property (nonatomic, strong) NSMutableArray *dividers;

@property (nonatomic, strong) NSDictionary *draggingInfo;

@end


@implementation TUISplitView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self)
        return nil;
    
    self.backgroundColor = [TUIColor grayColor];
    self.splitViews = [NSMutableArray array];
    self.dividers = [NSMutableArray array];
    self.dividerThickness = 4.f;
    self.horizontal = NO;

    return self;
}

- (void)addSplitView:(TUIView *)view {
    [self.splitViews addObject:view];
    [self addSubview:view];
    
    if (self.splitViews.count < 1)
        return;
    
    TUIView *divider = [[TUIView alloc] initWithFrame:CGRectZero];
    [self.dividers addObject:divider];
    divider.backgroundColor = [TUIColor grayColor];
    [self addSubview:divider];
    [self bringSubviewToFront:divider];
    
    [self resetSubviews];
}

- (void)setHorizontal:(BOOL)isHorizontal {
    _horizontal = isHorizontal;
    [self resetSubviews];
}

- (void)setDividerThickness:(CGFloat)dividerThickness {
    _dividerThickness = dividerThickness;
    [self resetSubviews];
}

- (void)layoutSubviews {
    for (TUIView *divider in self.dividers) {
        CGSize size = self.bounds.size;
        
        CGRect newFrame = divider.frame;
        newFrame.size.height = self.isHorizontal ? self.dividerThickness : size.height;
        newFrame.size.width = self.isHorizontal ? size.width : self.dividerThickness;
        divider.frame = newFrame;
    }
    
    for (TUIView *splitView in self.splitViews) {
        CGSize size = self.bounds.size;
        
        CGRect newFrame = splitView.frame;
        newFrame.size.height = self.isHorizontal ? splitView.frame.size.width : size.height;
        newFrame.size.width = self.isHorizontal ? size.width : splitView.frame.size.width;
        splitView.frame = newFrame;
    }
}

- (void)resetSubviews {
    CGSize size = self.bounds.size;
    CGFloat totalDividerThickness = self.dividerThickness * self.dividers.count;
    CGFloat adjustedDistance = (self.isHorizontal ? size.height : size.width) - totalDividerThickness;
    CGFloat splitViewDistance = floorf(adjustedDistance / self.splitViews.count);
    CGFloat origin = 0.f;
    
    TUIView *lastSplitView = [self.splitViews lastObject];
    
    for (TUIView *splitView in self.splitViews) {
        CGRect frame = self.bounds;
        
        if (self.isHorizontal) {
            frame.size.height = splitViewDistance;
            frame.origin.y = origin;
        }
        else {
            frame.size.width = splitViewDistance;
            frame.origin.x = origin;
        }
        
        splitView.frame = frame;
        
        if ([splitView isEqual:lastSplitView]) {
            CGRect newFrame = lastSplitView.frame;
            newFrame.size.width = self.isHorizontal ? newFrame.size.width : size.width - origin;
            newFrame.size.height = self.isHorizontal ? newFrame.size.height + origin : size.height;
            splitView.frame = newFrame;
        }
        origin += splitViewDistance + self.dividerThickness;
        
        //NSLog(@"%lu - %@",self.splitViews.count,NSStringFromRect(splitView.frame));
    }
    [self updateDividerPosition];
}

- (void)updateDividerPosition {
    [self.dividers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(TUIView *)obj setFrame:[self rectForDividerAtIndex:idx]];
    }];
}


- (CGRect)rectForDividerAtIndex:(NSUInteger)idx {
    CGRect newFrame = [(TUIView *)[self.splitViews objectAtIndex:idx] frame];
    newFrame.origin.x += self.isHorizontal ? 0.f : newFrame.size.width;
    newFrame.origin.y += self.isHorizontal ? newFrame.size.height : 0.f;
    newFrame.size.width = self.isHorizontal ? newFrame.size.width : self.dividerThickness;
    newFrame.size.height = self.isHorizontal ? self.dividerThickness : newFrame.size.height;
    return newFrame;
}



- (void)setDividerDrawRectBlock:(TUIViewDrawRect)dividerDrawRectBlock {
    if (_dividerDrawRectBlock == dividerDrawRectBlock)
        return;
    _dividerDrawRectBlock = [dividerDrawRectBlock copy];
    
    for (TUIView *divider in self.dividers) {
        divider.drawRect = _dividerDrawRectBlock;
        [divider setNeedsDisplay];
    }
}




- (void)mouseEntered:(NSEvent *)event onSubview:(TUIView *)subview {
    if ([self.dividers containsObject:subview])
        [[NSCursor resizeLeftRightCursor] push];
}

- (void)mouseExited:(NSEvent *)event fromSubview:(TUIView *)subview {
    if ([self.dividers containsObject:subview])
        [[NSCursor currentCursor] pop]; 
}

- (void)mouseDown:(NSEvent *)event onSubview:(TUIView *)subview {
    if (![self.dividers containsObject:subview])
        return;
    
    NSUInteger dividerIndex = [self.dividers indexOfObject:subview];
    TUIView *splitViewOne = [self.splitViews objectAtIndex:dividerIndex];
    TUIView *splitViewTwo = [self.splitViews objectAtIndex:dividerIndex + 1];
    
    self.draggingInfo = [NSDictionary dictionaryWithObjectsAndKeys:subview, CURRENT_DIVIDER,
                         [NSValue valueWithPoint:[event locationInWindow]], INITIAL_DRAG_LOCATION,
                         [NSValue valueWithPoint:subview.frame.origin], INITIAL_DIVIDER_ORIGIN,
                         [NSValue valueWithRect:splitViewOne.frame], FIRST_SPLITVIEW_FRAME,
                         [NSValue valueWithRect:splitViewTwo.frame], SECOND_SPLITVEIW_FRAME, nil];
    NSLog(@"Set the dragging info");
}

- (void)mouseUp:(NSEvent *)event fromSubview:(TUIView *)subview {
    self.draggingInfo = nil;
    
    if (![self.dividers containsObject:subview])
        return;
    
    //if ([event clickCount] > 1)[self collapseDivider:subview];
}

-(void)mouseDragged:(NSEvent *)theEvent onSubview:(TUIView *)subview {
    if (![subview isEqual:[self.draggingInfo valueForKey:CURRENT_DIVIDER]])
        return;
    
    CGPoint initialDragLocation = NSPointToCGPoint([(NSValue *)[self.draggingInfo valueForKey:INITIAL_DRAG_LOCATION] pointValue]);
    CGPoint initialDividerOrigin = NSPointToCGPoint([(NSValue *)[self.draggingInfo valueForKey:INITIAL_DIVIDER_ORIGIN] pointValue]);
    TUIView *currentlyDraggingDivider = [self.draggingInfo valueForKey:CURRENT_DIVIDER];
    NSUInteger dividerIndex = [self.dividers indexOfObject:subview];
    TUIView *splitViewOne = [self.splitViews objectAtIndex:dividerIndex];
    TUIView *splitViewTwo = [self.splitViews objectAtIndex:dividerIndex + 1];
    
    CGFloat deltaY = self.isHorizontal ? ceil([theEvent locationInWindow].y - initialDragLocation.y) : 0.f;
    CGFloat deltaX = self.isHorizontal ? 0.f : ceil([theEvent locationInWindow].x - initialDragLocation.x);
    CGPoint point = initialDividerOrigin;
    
    point.y += deltaY;
    point.x += deltaX;
    
    if (point.x < 0.f)
        point.x = 0.f;
    
    else if (point.y < 0.f)
        point.y = 0.f;
    
    else if (point.x > self.frame.size.width - self.dividerThickness)
        point.x = self.frame.size.width - self.dividerThickness;
    
    else if (point.y > self.frame.size.height - self.dividerThickness)
        point.y = self.frame.size.height - self.dividerThickness;
    
    CGSize currentSize = currentlyDraggingDivider.frame.size;
    CGRect newRect = (CGRect){ point, currentSize };    
    currentlyDraggingDivider.frame = newRect;
            
    CGRect splitViewOneFrame = NSRectToCGRect([(NSValue *)[self.draggingInfo valueForKey:FIRST_SPLITVIEW_FRAME] rectValue]);
    CGRect splitViewTwoFrame = NSRectToCGRect([(NSValue *)[self.draggingInfo valueForKey:SECOND_SPLITVEIW_FRAME] rectValue]);
    
    splitViewOneFrame.size.width += deltaX;
    splitViewOneFrame.size.height += deltaY;
    
    splitViewTwoFrame.size.width -= deltaX;
    splitViewTwoFrame.size.height -= deltaY;
    splitViewTwoFrame.origin.x += deltaX;
    splitViewTwoFrame.origin.y += deltaY;

    splitViewOne.frame = splitViewOneFrame;
    splitViewTwo.frame = splitViewTwoFrame;
}


@end

