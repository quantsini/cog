
#import <Cocoa/Cocoa.h>

extern NSString *MovedRowsType;
extern NSString *CogUrlsPboardType;
extern NSString *iTunesDropType;

@interface DNDArrayController : NSArrayController
{
    IBOutlet NSTableView *tableView;
}

// table view drag and drop support
- (BOOL)tableView:(NSTableView *)aTableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard;
- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op;
- (BOOL)tableView:(NSTableView*)tv acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)op;
    

// utility methods
-(void)moveObjectsInArrangedObjectsFromIndexes:(NSIndexSet*)indexSet toIndex:(unsigned int)insertIndex;

@end
