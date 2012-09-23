#import "TUISplitView.h"

#define INITIAL_DRAG_LOCATION @"initialDragLocation"
#define CURRENT_DIVIDER @"currentDivider"
#define INITIAL_DIVIDER_ORIGIN @"initialDividerOrigin"
#define FIRST_SPLITVIEW_FRAME @"firstSplitViewFrame"
#define SECOND_SPLITVEIW_FRAME @"secondSplitViewFrame"

@interface TUISplitView()

- (NSArray *)_orderedSubviews;

@property (nonatomic, strong) NSArray *orderedSubviews;


@property (nonatomic, strong) NSMutableArray *splitViews;
@property (nonatomic, strong) NSMutableArray *dividers;

@property (nonatomic, strong) NSDictionary *draggingInfo;

@end


@implementation TUISplitView

- (id)initWithFrame:(CGRect)aFrame {
	if (self = [super initWithFrame:aFrame]) {
		[self commonInit];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		[self commonInit];
	}
	return self;
}

-(void)commonInit {
	self.backgroundColor = [NSColor grayColor];
    self.splitViews = [NSMutableArray array];
    self.dividers = [NSMutableArray array];
    self.dividerStyle = TUISplitViewDividerStyleThick;
    self.vertical = YES;
}

-(void)viewWillStartLiveResize {
	[super viewWillStartLiveResize];
	
	NSMutableArray *nonResizingViews = [NSMutableArray array];
	NSMutableArray *resizingViews = [NSMutableArray array];
	
	//Get the views to resize and those not to
	[self._orderedSubviews enumerateObjectsUsingBlock:^(NSView *view, NSUInteger index, BOOL *stop) {
		BOOL resizeView = NO;
		if ([self.delegate respondsToSelector:@selector(splitView:shouldFrameChangeResizeSubviewAtIndex:)]) {
			resizeView = [self.delegate splitView:self shouldFrameChangeResizeSubviewAtIndex:index];
		}
		[(resizeView ? resizingViews : nonResizingViews) addObject:view];
	}];
	
	//If we only have non-resizing views, break the last one
	if (nonResizingViews.count == self._orderedSubviews.count) {
		[resizingViews addObject:nonResizingViews.lastObject];
		[nonResizingViews removeLastObject];
	}

}

- (TUIView *)subviewAtIndex:(NSInteger)aIndex {
	return self._orderedSubviews[aIndex];
}

- (NSInteger)indexOfSubview:(NSView *)aView {
	return [self._orderedSubviews indexOfObject:aView];
}


- (void)addSubview:(TUIView *)view {
    [self.splitViews addObject:view];
    [super addSubview:view];
    
    if (self.splitViews.count < 1)
        return;
    
    TUIView *divider = [[TUIView alloc] initWithFrame:CGRectZero];
    [self.dividers addObject:divider];
    divider.backgroundColor = [NSColor grayColor];
    [super addSubview:divider];
    [self bringSubviewToFront:divider];
    
    [self adjustSubviews];
}

- (CGFloat)dividerThickness {
	switch (self.dividerStyle) {
		case TUISplitViewDividerStyleThick:
			return 4.0f;
			break;
		case TUISplitViewDividerStyleThin:
			break;
			return 0.4f;
		default:
			return 1.0f;
			break;
	}
	return 0.0f;
}

- (void)setVertical:(BOOL)isVertical{
    _vertical = isVertical;
    [self adjustSubviews];
}


- (void)layoutSubviews {
    for (TUIView *divider in self.dividers) {
        CGSize size = self.bounds.size;
        
        CGRect newFrame = divider.frame;
        newFrame.size.height = self.isVertical ? size.height : self.dividerThickness;
        newFrame.size.width = self.isVertical ? self.dividerThickness : size.width ;
        divider.frame = newFrame;
    }
    
    for (TUIView *splitView in self.splitViews) {
        CGSize size = self.bounds.size;
        
        CGRect newFrame = splitView.frame;
        newFrame.size.height = self.isVertical ? size.height : splitView.frame.size.width;
        newFrame.size.width = self.isVertical ?  splitView.frame.size.width : size.width;
        splitView.frame = newFrame;
    }
}

- (void)adjustSubviews {
    CGSize size = self.bounds.size;
    CGFloat totalDividerThickness = self.dividerThickness * self.dividers.count;
    CGFloat adjustedDistance = (self.isVertical ? size.width : size.height) - totalDividerThickness;
    CGFloat splitViewDistance = floorf(adjustedDistance / self.splitViews.count);
    CGFloat origin = 0.f;
    
    TUIView *lastSplitView = [self.splitViews lastObject];
    
    for (TUIView *splitView in self.splitViews) {
        CGRect frame = self.bounds;
        
        if (self.isVertical) {
            frame.size.width = splitViewDistance;
            frame.origin.x = origin;
        }
        else {
			frame.size.height = splitViewDistance;
            frame.origin.y = origin;
        }
        
        splitView.frame = frame;
        
        if ([splitView isEqual:lastSplitView]) {
            CGRect newFrame = lastSplitView.frame;
            newFrame.size.width = self.isVertical ? size.width - origin : newFrame.size.width;
            newFrame.size.height = self.isVertical ? size.height : newFrame.size.height + origin;
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
    newFrame.origin.x += self.isVertical ? newFrame.size.width : 0.f;
    newFrame.origin.y += self.isVertical ? 0.f : newFrame.size.height;
    newFrame.size.width = self.isVertical ? self.dividerThickness : newFrame.size.width;
    newFrame.size.height = self.isVertical ? newFrame.size.height : self.dividerThickness;
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
    
    CGFloat deltaY = self.isVertical ? 0.f : ceil([theEvent locationInWindow].y - initialDragLocation.y);
    CGFloat deltaX = self.isVertical ? ceil([theEvent locationInWindow].x - initialDragLocation.x) : 0.f;
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


- (NSArray *)_orderedSubviews {
	if (!self.orderedSubviews) {
		self.orderedSubviews = [self.subviews sortedArrayUsingComparator:^NSComparisonResult(NSView *obj1, NSView *obj2) {
			CGFloat view1Value = obj1.frame.origin.y;
			CGFloat view2Value = obj2.frame.origin.y;
			
			if (self.vertical) {
				view1Value = obj1.frame.origin.x;
				view2Value = obj2.frame.origin.x;
			}
			
			if (view1Value < view2Value) {
				return NSOrderedAscending;
			}
			if (view1Value > view2Value) {
				return NSOrderedDescending;
			}
			return NSOrderedSame;
		}];
	}
	return self.orderedSubviews;
}

@end

