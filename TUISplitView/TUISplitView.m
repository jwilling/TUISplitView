#import "TUISplitView.h"

@interface TUISplitView ()


@end

@implementation TUISplitView {
	BOOL mustAdjust;
}


// This is the designated initializer for creating TUISplitViews programmatically. You can set the
// divider image and other parameters afterwards.
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		[self setVertical:YES];
		[self setBackgroundColor:[NSColor lightGrayColor]];
	}
	return self;
}

// This convenience initializer adds any number of subviews and adjusts them proportionally.
- (id)initWithFrame:(CGRect)frame andSubviews:(NSUInteger)count {
	self = [self initWithFrame:frame];
	if (self) {
		while (count-->0) {
			[self addSubview:[[TUIView alloc] initWithFrame:frame]];
		}
		[self setMustAdjust];
	}
	return self;
}

-(void)adjustSubviews {
	mustAdjust = NO;
	if (self.subviews.count == 0) return;
	for (NSValue *dividerFrame in [self _dividerFrames]) {
		[self setNeedsDisplayInRect:[dividerFrame rectValue]];
	}
	if (self.bounds.size.width < 1.0 || self.bounds.size.height < 1.0) {
		return;
	}
}

//An array of NSValues for the divider frames.
-(NSArray*)_dividerFrames {
	
}

@end

