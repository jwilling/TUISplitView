#import <TwUI/TUIKit.h>

@interface TUISplitView : TUIView

//- (id)initWithFrame:(CGRect)frame splitViews:(NSUInteger)numSplits;
- (void)setView:(TUIView *)view forSplitView:(NSUInteger)splitView;
- (void)addSplitView:(TUIView *)view;
     
@property (nonatomic, readwrite) CGFloat dividerThickness;
@property (nonatomic, copy) TUIViewDrawRect dividerDrawRectBlock;
@property (nonatomic, getter = isHorizontal) BOOL horizontal;
//property for divider drawRect block (passed in mouseDown events)

- (NSString *)stringForState;
- (BOOL)setStateForString:(NSString *)stateString;

@end
