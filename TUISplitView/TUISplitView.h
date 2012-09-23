#import <TwUI/TUIKit.h>
#import "TUISplitSubview.h"

typedef void(^TUISplitViewDividerDrawRect)(CGRect);

// These values are used to handle the various cursor types.
typedef enum {
	TUIHorizontalCursor=0,		// appears over horizontal dividers
	TUIVerticalCursor,			// appears over vertical dividers
	TUI2WayCursor,				// appears over two-way thumbs
	TUIDragCursor,				// appears while dragging
	TUICursorTypeCount
} TUICursorType;

@interface TUISplitView : TUISplitSubview {
	// Subclasses normally should use setter methods instead of changing instance variables by assignment.
	// Most getter methods simply return the corresponding instance variable, so with some care, subclasses
	// could reference them directly.
	IBOutlet id delegate;		// The delegate (may be nil).
	NSString* autosaveName;		// This name is used for storing subview proportions in user defaults.
	NSImage* divider;			// The image used for the divider "dimple".
	NSRect* dividers;			// A C array of NSRects, one for each divider.
	CGFloat dividerThickness;	// Actual divider width; should be an integer and at least 1.0.
	BOOL mustAdjust;			// Set internally if the subviews need to be adjusted.
	BOOL mustClearFractions;	// Set internally if fractions should be cleared before adjusting.
	BOOL isHorizontal;			// The divider's orientation; default is vertical.
	BOOL canSaveState;			// Set internally to allow saving subview state.
	BOOL isCoupled;				// If YES, take some parameters from the containing TUISplitView, if any.
	BOOL isAdjusting;			// Set internally while the subviews are being adjusted.
	BOOL isDragging;			// Set internally while in a drag loop.
	BOOL isInScrollView;		// Set internally if directly contained in an NSScrollView.
}

// These class methods get and set the cursor used for each type.
// Pass in nil to reset to the default cursor for that type.
+ (NSCursor*)cursor:(TUICursorType)type;
+ (void)setCursor:(TUICursorType)type toCursor:(NSCursor*)cursor;

// This class method clears the saved state for a given autosave name from the defaults.
+ (void)removeStateUsingName:(NSString*)name;

// This class method returns the actual key used to store autosave data in the defaults.
+ (NSString*)defaultsKeyForName:(NSString*)name isHorizontal:(BOOL)orientation;

// Sets and gets the autosaveName; this will be the key used to store the subviews' proportions
// in the user defaults. Default is @"", which doesn't save anything. Set flag to YES to set
// unique names for nested subviews. You are responsible for avoiding duplicates.
- (void)setAutosaveName:(NSString*)aString recursively:(BOOL)flag;
- (NSString*)autosaveName;

// Saves the current state of the subviews if there's a valid autosave name set. If the argument
// is YES, it's then also called recursively for nested TUISplitViews. Returns YES if successful.
- (BOOL)saveState:(BOOL)recurse;

// Returns a string encoding the current state of all direct subviews. Does not check for nesting.
- (NSString*)stringWithSavedState;

// Readjusts all direct subviews according to the encoded string parameter. The number of subviews
// must match. Returns YES if successful. Does not check for nesting.
- (BOOL)setStateFromString:(NSString*)aString;

// Returns an array with complete state information for the receiver and all subviews, taking
// nesting into account. Don't store this array in a file, as its format might change in the
// future; this is for taking a state snapshot and later restoring it with setStatesFromArray.
- (NSArray*)arrayWithStates;

// Restores the state of the receiver and all subviews. The array must have been produced by a
// previous call to arrayWithStates. Returns YES if successful. This will fail if you have
// added or removed subviews in the meantime!
// You need to call adjustSubviews after calling this.
- (BOOL)setStatesFromArray:(NSArray*)array;

// This is the designated initializer for creating TUISplitViews programmatically.
- (id)initWithFrame:(NSRect)frame;

// This convenience initializer adds any number of subviews and adjusts them proportionally.
- (id)initWithFrame:(NSRect)frame andSubviews:(NSUInteger)count;

// Sets and gets the delegate. (Delegates aren't retained.) See further down for delegate methods.
- (void)setDelegate:(id)anObject;
- (id)delegate;

// Returns a subview which has a certain identifier string, or nil if there's none
- (TUISplitSubview*)subviewWithIdentifier:(NSString*)anIdentifier;

// Returns the subview at a certain position. Returns nil if the position is invalid.
- (TUISplitSubview*)subviewAtPosition:(NSUInteger)position;

// Adds a subview at a certain position.
- (void)addSubview:(TUIView*)aView atPosition:(NSUInteger)position;

// Sets and gets the divider thickness, which should be a positive integer or zero.
// Setting the divider image also resets this automatically, so you would call this
// only if you want the divider to be larger or smaller than the image. Zero means that
// the image dimensions will be used.
- (void)setDividerThickness:(CGFloat)thickness;
- (CGFloat)dividerThickness;

@property (nonatomic, copy) TUISplitViewDividerDrawRect dividerDrawRectBlock;


// Sets and gets the orientation. This uses the same convention as NSSplitView: vertical means the
// dividers are vertical, but the subviews are in a horizontal row. Sort of counter-intuitive, yes.
- (void)setVertical:(BOOL)flag;
- (BOOL)isVertical;
- (void)setHorizontal:(BOOL)flag;
- (BOOL)isHorizontal;

// Call this to force adjusting the subviews before display. Called automatically if anything
// relevant is changed.
- (void)setMustAdjust;

// Returns YES if there's a pending adjustment.
- (BOOL)mustAdjust;
- (BOOL)isAdjusting;

// Returns YES if we're in a dragging loop.
- (BOOL)isDragging;

// Returns YES if the view is directly contained in an NSScrollView.
- (BOOL)isInScrollView;

// Call this to recalculate all subview dimensions. Normally this is done automatically whenever
// something relevant is changed, so you rarely will need to call this explicitly.
- (void)adjustSubviews;

// This method should be called only from within the splitView:wasResizedFrom:to: delegate method
// to keep some specific subview the same size.
- (void)adjustSubviewsExcepting:(TUISplitSubview*)excepting;

// This method draws dividers. You should never call it directly but you can override it when
// subclassing, if you need custom dividers.
- (void)drawDivider:(NSImage*)anImage inRect:(NSRect)rect betweenView:(TUISplitSubview*)leading andView:(TUISplitSubview*)trailing;

@end

// The following methods are optionally implemented by the delegate.

@protocol TUISplitViewDelegate<NSObject>
@optional

// The delegate can override a subview's ability to collapse by implementing this method.
// Return YES to allow collapsing. If this is implemented, the subviews' built-in
// 'collapsed' flags are ignored.
- (BOOL)splitView:(TUISplitView*)sender canCollapse:(TUISplitSubview*)subview;

// The delegate can alter the divider's appearance by implementing this method.
// Before calling this, the divider is filled with the background, and afterwards
// the divider image is drawn into the returned rect. If imageRect is empty, no
// divider image will be drawn, because there are nested TUISplitViews. Return
// NSZeroRect to suppress the divider image. Return imageRect to use the default
// location for the image, or change its origin to place the image elsewhere.
// You could also draw the divider yourself at this point and return NSZeroRect.
- (NSRect)splitView:(TUISplitView*)sender willDrawDividerInRect:(NSRect)dividerRect betweenView:(TUISplitSubview*)leading andView:(TUISplitSubview*)trailing withProposedRect:(NSRect)imageRect;

// These methods are called after a subview is completely collapsed or expanded. adjustSubviews may or may not
// have been called, however.
- (void)splitView:(TUISplitView*)sender didCollapse:(TUISplitSubview*)subview;
- (void)splitView:(TUISplitView*)sender didExpand:(TUISplitSubview*)subview;

// These methods are called just before and after adjusting subviews.
- (void)willAdjustSubviews:(TUISplitView*)sender;
- (void)didAdjustSubviews:(TUISplitView*)sender;

// This method will be called after a TUISplitView is resized with setFrameSize: but before
// adjustSubviews is called on it.
- (void)splitView:(TUISplitView*)sender wasResizedFrom:(CGFloat)oldDimension to:(CGFloat)newDimension;

// This method will be called when a divider is double-clicked and both leading and trailing
// subviews can be collapsed. Return either of the parameters to collapse that subview, or nil
// to collapse neither. If not implemented, the smaller subview will be collapsed.
- (TUISplitSubview*)splitView:(TUISplitView*)sender collapseLeading:(TUISplitSubview*)leading orTrailing:(TUISplitSubview*)trailing;

// This method will be called when a cursor rect is being set (inside resetCursorRects). The
// proposed rect is passed in. Return the actual rect, or NSZeroRect to suppress cursor setting
// for this divider. This won't be called for two-axis thumbs, however. The rects are in
// sender's local coordinates.
- (NSRect)splitView:(TUISplitView*)sender cursorRect:(NSRect)rect forDivider:(NSUInteger)divider;

// This method will be called whenever a mouse-down event is received in a divider. Return YES to have
// the event handled by the split view, NO if you wish to ignore it or handle it in the delegate.
- (BOOL)splitView:(TUISplitView*)sender shouldHandleEvent:(NSEvent*)theEvent inDivider:(NSUInteger)divider betweenView:(TUISplitSubview*)leading andView:(TUISplitSubview*)trailing;

// This method will be called just before a subview will be collapsed or expanded with animation.
// Return the approximate time the animation should take, or 0.0 to disallow animation.
// If not implemented, it will use the default of 0.2 seconds per 150 pixels.
- (NSTimeInterval)splitView:(TUISplitView*)sender willAnimateSubview:(TUISplitSubview*)subview withDimension:(CGFloat)dimension;

// This method will be called whenever a subview's frame is changed, usually from inside adjustSubviews' final loop.
// You'd normally use this to move some auxiliary view to keep it aligned with the subview.
- (void)splitView:(TUISplitView*)sender changedFrameOfSubview:(TUISplitSubview*)subview from:(NSRect)fromRect to:(NSRect)toRect;

// This method is called whenever the event handlers want to check if some point within the RBSplitSubview
// should act as an alternate drag view. Usually, the delegate will check the point (which is in sender's
// local coordinates) against the frame of one or several auxiliary views, and return a valid divider number.
// Returning NSNotFound means the point is not valid.
- (NSUInteger)splitView:(TUISplitView*)sender dividerForPoint:(NSPoint)point inSubview:(TUISplitSubview*)subview;

// This method is called continuously while a divider is dragged, just before the leading subview is resized.
// Return NO to resize the trailing view by the same amount, YES to resize the containing window by the same amount.
- (BOOL)splitView:(TUISplitView*)sender shouldResizeWindowForDivider:(NSUInteger)divider betweenView:(TUISplitSubview*)leading andView:(TUISplitSubview*)trailing willGrow:(BOOL)grow;

// This method is called by each subview's drawRect: method, just after filling it with the background color but
// before the contained subviews are drawn. Usually you would use this to draw a frame inside the subview.
- (void)splitView:(TUISplitView*)sender willDrawSubview:(TUISplitSubview*)subview inRect:(NSRect)rect;

@end