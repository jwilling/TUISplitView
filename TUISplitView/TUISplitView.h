#import <TwUI/TUIKit.h>

@protocol TUISplitViewDelegate;

enum {
	TUISplitViewDividerStyleThick = 1,
    TUISplitViewDividerStyleThin = 2
};
typedef NSInteger TUISplitViewDividerStyle;


@interface TUISplitView : TUIView

@property (nonatomic, getter = isVertical) BOOL vertical;
@property (nonatomic, assign) TUISplitViewDividerStyle dividerStyle;
@property (nonatomic, copy) NSString *autosaveName;
@property (unsafe_unretained) id<TUISplitViewDelegate> delegate;
@property (nonatomic, copy) TUIViewDrawRect dividerDrawRectBlock;

- (void)drawDividerInRect:(NSRect)rect;
- (NSColor *)dividerColor;
- (CGFloat)dividerThickness;
- (void)adjustSubviews;

@end


@protocol TUISplitViewDelegate <NSObject>

@optional

- (BOOL)splitView:(TUISplitView *)aSplitView shouldFrameChangeResizeSubviewAtIndex:(NSUInteger)aIndex;

@end