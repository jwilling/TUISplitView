#import <TwUI/TUIKit.h>

typedef void(^TUISplitViewDividerDrawRect)(CGRect);

typedef enum {
    TUISplitViewDividerStyleThick = 1,
    TUISplitViewDividerStyleThin = 2,
    TUISplitViewDividerStylePaneSplitter = 3,
}TUISplitViewDividerStyle;

@protocol TUISplitViewDelegate;

@interface TUISplitView : TUIView


/* Set or get whether the long axes of a split view's dividers are oriented up-and-down (YES) or left-and-right (NO).
 */
@property (nonatomic, assign, getter = isVertical) BOOL vertical;

@property (nonatomic, assign, getter = isHorizontal) BOOL horizontal;
@property (nonatomic, assign) TUISplitViewDividerStyle dividerStyle;
@property (nonatomic, weak) id <TUISplitViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame;
- (id)initWithFrame:(CGRect)frame andSubviews:(NSUInteger)count;

/* Draw the divider between two of the split view's subviews. The rectangle describes the entire divider rectangle in the receiver's coordinates. You can override this method to change the appearance of dividers.
 */
- (void)drawDividerInRect:(NSRect)rect;


/* Return the color of the dividers that the split view is drawing between subviews. The default implementation of this method returns [NSColor clearColor] for the thick divider style. It will also return [NSColor clearColor] for the thin divider style when the split view is in a textured window. All other thin dividers are drawn with a color that looks good between two white panes. You can override this method to change the color of dividers.
 */
- (NSColor *)colorForDividerAtIndex:(NSUInteger)index;


/* Return the thickness of the dividers that the split view is drawing between subviews. The default implementation returns a value that depends on the divider style. You can override this method to change the size of dividers.
 */
- (CGFloat)dividerThickness;

/* Set the frames of the split view's subviews so that they, plus the dividers, fill the split view. The default implementation of this method resizes all of the subviews proportionally so that the ratio of heights (in the horizontal split view case) or widths (in the vertical split view case) doesn't change, even though the absolute sizes of the subviews do change. This message should be sent to split views from which subviews have been added or removed, to reestablish the consistency of subview placement.
 */
- (void)adjustSubviews;

/* Return YES if the subview is in the collapsed state, NO otherwise.
 */
- (BOOL)isSubviewCollapsed:(TUIView *)subview;


/* Divider indices are zero-based, with the topmost (in horizontal split views) or leftmost (vertical) divider having an index of 0.
 */

/* Get the minimum or maximum possible position of a divider. The position is "possible" in that it is dictated by the bounds of this view and the current position of other dividers. ("Allowable" positions are those that result from letting the delegate apply constraints to the possible positions.) You can invoke these methods to determine the range of values that can be usefully passed to -setPosition:ofDividerAtIndex:. You can also invoke them from delegate methods like -splitView:constrainSplitPosition:ofSubviewAt: to implement relatively complex behaviors that depend on the current state of the split view. The results of invoking these methods when -adjustSubviews has not been invoked recently enough for the subview frames to be valid are undefined.
 */
- (CGFloat)minPossiblePositionOfDividerAtIndex:(NSInteger)dividerIndex;
- (CGFloat)maxPossiblePositionOfDividerAtIndex:(NSInteger)dividerIndex;

/* Set the position of a divider. The default implementation of this method behaves as if the user were attempting to drag the divider to the proposed position, so the constraints imposed by the delegate are applied and one of the views adjacent to the divider may be collapsed. This method is not invoked by TUISplitView itself, so there's probably not much point in overriding it.
 */
- (void)setPosition:(CGFloat)position ofDividerAtIndex:(NSInteger)dividerIndex;

@end

// The following methods are optionally implemented by the delegate.

@protocol TUISplitViewDelegate<NSObject>
@optional

// The delegate can override a subview's ability to collapse by implementing this method.
// Return YES to allow collapsing. If this is implemented, the subviews' built-in
// 'collapsed' flags are ignored.
- (BOOL)splitView:(TUISplitView*)sender canCollapse:(TUIView*)subview;

// The delegate can alter the divider's appearance by implementing this method.
// Before calling this, the divider is filled with the background, and afterwards
// the divider image is drawn into the returned rect. If imageRect is empty, no
// divider image will be drawn, because there are nested TUISplitViews. Return
// NSZeroRect to suppress the divider image. Return imageRect to use the default
// location for the image, or change its origin to place the image elsewhere.
// You could also draw the divider yourself at this point and return NSZeroRect.
- (CGRect)splitView:(TUISplitView*)sender willDrawDividerInRect:(CGRect)dividerRect betweenView:(TUIView*)leading andView:(TUIView*)trailing withProposedRect:(CGRect)imageRect;

// These methods are called after a subview is completely collapsed or expanded. adjustSubviews may or may not
// have been called, however.
- (void)splitView:(TUISplitView*)sender didCollapse:(TUIView*)subview;
- (void)splitView:(TUISplitView*)sender didExpand:(TUIView*)subview;

// These methods are called just before and after adjusting subviews.
- (void)willAdjustSubviews:(TUISplitView*)sender;
- (void)didAdjustSubviews:(TUISplitView*)sender;

// This method will be called after a TUISplitView is resized with setFrameSize: but before
// adjustSubviews is called on it.
- (void)splitView:(TUISplitView*)sender wasResizedFrom:(CGFloat)oldDimension to:(CGFloat)newDimension;

// This method will be called when a divider is double-clicked and both leading and trailing
// subviews can be collapsed. Return either of the parameters to collapse that subview, or nil
// to collapse neither. If not implemented, the smaller subview will be collapsed.
- (TUIView*)splitView:(TUISplitView*)sender collapseLeading:(TUIView*)leading orTrailing:(TUIView*)trailing;

// This method will be called when a cursor rect is being set (inside resetCursorRects). The
// proposed rect is passed in. Return the actual rect, or NSZeroRect to suppress cursor setting
// for this divider. This won't be called for two-axis thumbs, however. The rects are in
// sender's local coordinates.
- (CGRect)splitView:(TUISplitView*)sender cursorRect:(CGRect)rect forDivider:(NSUInteger)divider;

// This method will be called whenever a mouse-down event is received in a divider. Return YES to have
// the event handled by the split view, NO if you wish to ignore it or handle it in the delegate.
- (BOOL)splitView:(TUISplitView*)sender shouldHandleEvent:(NSEvent*)theEvent inDivider:(NSUInteger)divider betweenView:(TUIView*)leading andView:(TUIView*)trailing;

// This method will be called just before a subview will be collapsed or expanded with animation.
// Return the approximate time the animation should take, or 0.0 to disallow animation.
// If not implemented, it will use the default of 0.2 seconds per 150 pixels.
- (NSTimeInterval)splitView:(TUISplitView*)sender willAnimateSubview:(TUIView*)subview withDimension:(CGFloat)dimension;

// This method will be called whenever a subview's frame is changed, usually from inside adjustSubviews' final loop.
// You'd normally use this to move some auxiliary view to keep it aligned with the subview.
- (void)splitView:(TUISplitView*)sender changedFrameOfSubview:(TUIView*)subview from:(CGRect)fromRect to:(CGRect)toRect;

// This method is called whenever the event handlers want to check if some point within the RBSplitSubview
// should act as an alternate drag view. Usually, the delegate will check the point (which is in sender's
// local coordinates) against the frame of one or several auxiliary views, and return a valid divider number.
// Returning NSNotFound means the point is not valid.
- (NSUInteger)splitView:(TUISplitView*)sender dividerForPoint:(NSPoint)point inSubview:(TUIView*)subview;

// This method is called continuously while a divider is dragged, just before the leading subview is resized.
// Return NO to resize the trailing view by the same amount, YES to resize the containing window by the same amount.
- (BOOL)splitView:(TUISplitView*)sender shouldResizeWindowForDivider:(NSUInteger)divider betweenView:(TUIView*)leading andView:(TUIView*)trailing willGrow:(BOOL)grow;

// This method is called by each subview's drawRect: method, just after filling it with the background color but
// before the contained subviews are drawn. Usually you would use this to draw a frame inside the subview.
- (void)splitView:(TUISplitView*)sender willDrawSubview:(TUIView*)subview inRect:(CGRect)rect;

@end