#import <Foundation/Foundation.h>

@interface NSMutableArray (Insert)

- (void)safelyInsertObject:(id)obj atIndex:(NSUInteger)idx;

@end
