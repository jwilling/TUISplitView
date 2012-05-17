#import <TwUI/TUIKit.h>

@interface TUISplitView : TUIView

- (id)initWithFrame:(CGRect)frame splitViews:(NSUInteger)numSplits;
- (void)setView:(TUIView *)view forSplitView:(NSUInteger)splitView;
     
@property (nonatomic, readwrite) CGFloat dividerWidth;
@property (nonatomic, copy) TUIViewDrawRect dividerDrawRectBlock;
//property for divider drawRect block (passed in mouseDown events)

- (NSString *)stringForState;
- (BOOL)setStateForString:(NSString *)stateString;

@end
