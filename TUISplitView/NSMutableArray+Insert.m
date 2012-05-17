#import "NSMutableArray+Insert.h"

@implementation NSMutableArray (Insert)

- (void)safelyInsertObject:(id)obj atIndex:(NSUInteger)idx {
    while (idx >= self.count) {
        [self addObject:[NSNull null]];
    }
    [self replaceObjectAtIndex:idx withObject:obj];
}

@end
