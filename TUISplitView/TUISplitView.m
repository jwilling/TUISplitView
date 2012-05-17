#import "TUISplitView.h"
#import "NSMutableArray+Insert.h"

@interface TUISplitView()
@property (nonatomic) NSInteger numberOfSplitViews;
@property (nonatomic, strong) NSMutableArray *splitViews;
@property (nonatomic, strong) NSMutableArray *dividers;

@property (nonatomic, assign) NSPoint initialDragLocation;
@property (nonatomic, assign) NSPoint initialDividerLocation;
@property (nonatomic, weak) TUIView *currentlyDraggingDivider;


@end


@implementation TUISplitView

- (id)initWithFrame:(CGRect)frame splitViews:(NSUInteger)numSplits {
    self = [super initWithFrame:frame];
    if (!self)
        return nil;
    
    self.numberOfSplitViews = numSplits;
    self.backgroundColor = [TUIColor greenColor];
    self.splitViews = [NSMutableArray array];
    self.dividers = [NSMutableArray array];
    self.dividerWidth = 4.f;
    
    return self;
}

- (void)setView:(TUIView *)view forSplitView:(NSUInteger)splitView {
    [self.splitViews safelyInsertObject:view atIndex:splitView];
    [self addSubview:view];
    
    while ( (self.numberOfSplitViews - 1) > self.dividers.count) {
        TUIView *divider = [[TUIView alloc] initWithFrame:CGRectZero];
        divider.backgroundColor = [TUIColor grayColor];
        [self.dividers safelyInsertObject:divider atIndex:splitView];
        [self addSubview:divider];
        [self bringSubviewToFront:divider];
    }
}

- (CGRect)frameForSplitViewAtIndex:(NSUInteger)index {
    CGRect frame = self.frame;
    
    BOOL lastSplitView = (index == (self.splitViews.count - 1));
    BOOL firstSplitView = (index == 0);
    
    TUIView *nextDivider = nil;
    TUIView *previousDivider = nil;
    if (!lastSplitView)
        nextDivider = [self.dividers objectAtIndex:index];
    if (!firstSplitView)
        previousDivider = [self.dividers objectAtIndex:(index - 1)];

    CGFloat newOriginX = 0.f;
    CGFloat newWidth = 0.f;
    if (firstSplitView) {
        newWidth = nextDivider.frame.origin.x;
    }
    else if (lastSplitView) {
        newOriginX = previousDivider.frame.origin.x + self.dividerWidth;
        newWidth = self.frame.size.width - newOriginX;
    }
    else {
        newOriginX = previousDivider.frame.origin.x + self.dividerWidth;
        newWidth = nextDivider.frame.origin.x - newOriginX;
    }
    frame.origin.x = newOriginX;
    frame.size.width = newWidth;
    
    return frame;
}

- (CGRect)frameForDividerAtIndex:(NSUInteger)index {
    CGFloat viewWidth = self.frame.size.width;
    CGFloat totalDividerWidth = self.dividerWidth*self.dividers.count;
    CGFloat splitViewWidth = ceil( (viewWidth - totalDividerWidth) / self.numberOfSplitViews );
    
    TUIView *divider = (TUIView *)[self.dividers objectAtIndex:index];
    if (self.dividerWidth == divider.frame.size.width) //no need to update anything other than height
        return (CGRect){ divider.frame.origin, self.dividerWidth, self.frame.size.height };
    
    return CGRectMake(splitViewWidth*(index + 1), 0, self.dividerWidth, self.frame.size.height);
}


- (void)layoutSubviews {    
    [self.dividers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isMemberOfClass:[TUIView class]]) {
            // only set the frame if our divider isn't set up yet
            // or if properties have changed, like height, div width
            TUIView *div = (TUIView *)obj;
            CGRect f = div.frame;
            if (f.size.height != self.frame.size.height
                 || f.size.width != self.dividerWidth) {
                [div setFrame:[self frameForDividerAtIndex:idx]];
            }
            [self bringSubviewToFront:div];
        }
    }];
    
    [self.splitViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isMemberOfClass:[TUIView class]]) {
            [(TUIView *)obj setFrame:[self frameForSplitViewAtIndex:idx]];
        }
    }];
}




- (void)mouseEntered:(NSEvent *)event onSubview:(TUIView *)subview {
    if (![self.dividers containsObject:subview])
        return;
        
    [[NSCursor resizeLeftRightCursor] push];
}

- (void)mouseExited:(NSEvent *)event fromSubview:(TUIView *)subview {
    if (![self.dividers containsObject:subview])
        return;
        
    [[NSCursor currentCursor] pop];
}

- (void)mouseDown:(NSEvent *)event onSubview:(TUIView *)subview {
    if (![self.dividers containsObject:subview])
       return;
    
    self.initialDragLocation = [event locationInWindow];
    self.currentlyDraggingDivider = subview;
    self.initialDividerLocation = subview.frame.origin;
}

- (void)mouseUp:(NSEvent *)event fromSubview:(TUIView *)subview {
    self.currentlyDraggingDivider = nil;
    
    if (![self.dividers containsObject:subview])
        return;
    
    if ([event clickCount] > 1)[self collapseDivider:subview];
}

-(void)mouseDragged:(NSEvent *)theEvent onSubview:(TUIView *)subview {
    if (subview != self.currentlyDraggingDivider)
        return;
    
    CGFloat deltaY = 0;
    CGFloat deltaX = ceil([theEvent locationInWindow].x - self.initialDragLocation.x);
    CGPoint point = self.initialDividerLocation;
    
    point.y += deltaY;
    point.x += deltaX;
    
    if (point.x < 0.f)
        point.x = 0.f;
    else if (point.x > self.frame.size.width - self.dividerWidth)
        point.x = self.frame.size.width - self.dividerWidth;
    
    CGSize currentSize = self.currentlyDraggingDivider.frame.size;
    CGRect newRect = (CGRect){ point, currentSize };
    self.currentlyDraggingDivider.frame = newRect;
    
    [self layoutSubviews];
}


- (void)collapseDivider:(TUIView *)divider {
    [TUIView animateWithDuration:0.6f animations:^{
        divider.frame = (CGRect){ CGPointZero, divider.frame.size };
        [self layoutSubviews];
    }]; 
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


- (NSString *)stringForState {
    NSString *numberOfDividers = [NSString stringWithFormat:@"%ld:",self.dividers.count];
    NSString *origins = [NSString string];
    
    for (TUIView *divider in self.dividers) {
        origins = [origins stringByAppendingFormat:@"%f-",divider.frame.origin.x];
    }
    
    return [numberOfDividers stringByAppendingString:origins];
}

- (BOOL)setStateForString:(NSString *)stateString {
    NSArray *strings = [stateString componentsSeparatedByString:@":"];
    NSInteger count = strings.count;
    if (count < 2)
        return NO;
    
    NSInteger numberOfDividers = [[strings objectAtIndex:0] integerValue];
    NSString *dividerString = [strings objectAtIndex:1];
    NSArray *dividersArray = [dividerString componentsSeparatedByString:@"-"];
    
    NSInteger i;
    for (i = 0; i < numberOfDividers; i++) {
        CGFloat origin = [[dividersArray objectAtIndex:i] floatValue];
        CGRect frame = (CGRect){ origin, 0, self.dividerWidth, self.frame.size.height };
        TUIView *divider = [self.dividers objectAtIndex:i];
        divider.frame = frame;
    }
    return YES;
}

@end

