//==============================================================================
//
//  ASTViewController.h
//
//==============================================================================
//
//  Copyright (c) 2016 Adobe Systems Incorporated. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//
//==============================================================================

#import <UIKit/UIKit.h>

#import "ASTSection.h"
#import "ASTItem.h"
#import "ASTSliderItem.h"
#import "ASTTextFieldItem.h"
#import "ASTTextViewItem.h"


NS_ASSUME_NONNULL_BEGIN

typedef void (^ASTUpdateBlock)( void );

//------------------------------------------------------------------------------

@interface ASTViewController : UITableViewController

/// The items or sections to be displayed in the table view. The expected type
/// depends on the table view style. If the table view is grouped then the array
/// is expected to contain ASTSection objects. If the table view is plain then
/// the array is expected to contain ASTItem objects. The array may also contain
/// dictionaries that describe the expected type.
@property (copy,nonatomic) NSArray* data;

/// Returns the first section with the identifier. Nil is allowed.
/// @param identifier A string identifying the section to return.
/// @return The first section with an identifier matching the identifier or nil
/// if no matching section is found.
- (nullable ASTSection*) sectionWithIdentifier: (nullable NSString*) identifier;
/// Returns the section at the specified index or nil if the index is invalid.
/// @param index An index number identifying a section.
/// @return The section at the index or nil if the index is invalid.
- (nullable ASTSection*) sectionAtIndex: (NSUInteger) index;

/// Returns the first item with the identifier or nil if there is no
/// item with the identifier.
/// @param identifier A string identifying the item to return.
/// @return The first item with an identifier matching the identifier or nil
/// if no matching item is found.
- (nullable ASTItem*) itemWithIdentifier: (nullable NSString*) identifier;
/// Returns the item at the specified index path or nil if the index path is
/// invalid.
/// @param index An index path identifying an item.
/// @return The item at the index path or nil if the index is invalid.
- (nullable ASTItem*) itemAtIndexPath: (NSIndexPath*) indexPath;
/// Returns the first item with a representedObject that matches the parameter.
/// The objects are compared with isEqual:. The parameter may be nil.
/// @param representedObject An object to compare to the representedObject of
/// each of the items. May be nil.
/// @return The first item with a represented object matching the parameter or
/// nil if no matching item is found.
- (nullable ASTItem*) itemWithRepresentedObject: (nullable id) representedObject;

/// Returns the index of the section or NSNotFound if the section is not in the
/// table view. This method performs a linear search and may not be performant.
/// @param section A section to find in the table view.
/// @return The index of the section or NSNotFound.
- (NSInteger) indexOfSection: (ASTSection*) section;
/// Returns the index path of the item or nil if the item is not in the table
/// view.
/// @param item An item to find in the table view. This method performs a linear
/// search and may not be performant.
/// @return The index path of the item or nil.
- (nullable NSIndexPath*) indexPathForItem: (ASTItem*) item;

// Containment

/// The number of items in plain table view or the number of sections in a
/// grouped table view.
@property (readonly,nonatomic) NSUInteger numberOfItems;

/// Inserts sections at the locations identified by an array of
/// indexes, with an option to animate the insertion.
/// @param items An array of ASTSection objects.
/// @param indexes An array of NSNumber objects.
/// @param animation A constant that either specifies the kind of animation to
/// perform when inserting the items or requests no animation.
- (void) insertSections: (NSArray*) sections atIndexes: (NSArray*) indexes
		withRowAnimation: (UITableViewRowAnimation) animation;
/// Removes the sections specified by an array of indexes, with an option to
/// animate the removal.
/// @param indexes An array of NSNumber objects.
/// @param animation A constant that either specifies the kind of animation to
/// perform when removing the items or requests no animation.
- (void) removeSectionsAtIndexes: (NSArray*) indexes
		withRowAnimation: (UITableViewRowAnimation) animation;
/// Moves a section from one location to another.
/// @param index An index identifying the section to move.
/// @param newIndex An index identifying the section that is the destination of
/// the section at index. The existing section at that location slides up or down to
/// an adjoining index position to make room for it.
- (void) moveSectionWithAnimationAtIndex: (NSUInteger) index
		toIndex: (NSUInteger) newIndex;

/// Inserts items at the locations identified by an array of indexes, with an
/// option to animate the insertion.
/// @param items An array of ASTItem objects.
/// @param indexePaths An array of NSIndexPath objects.
/// @param animation A constant that either specifies the kind of animation to
/// perform when inserting the items or requests no animation.
- (void) insertItems: (NSArray*) items atIndexPaths: (NSArray*) indexPaths
		withRowAnimation: (UITableViewRowAnimation) animation;
/// Removes the items specified by an array of index paths, with an option to
/// animate the removal.
/// @param indexPaths An array of NSIndexPath objects.
/// @param animation A constant that either specifies the kind of animation to
/// perform when removing the items or requests no animation.
- (void) removeItemsAtIndexPaths: (NSArray*) indexPaths
		withRowAnimation: (UITableViewRowAnimation) animation;
/// Moves an item from one location to another.
/// @param indexPath An index path identifying the item to move.
/// @param newIndexPath An index path identifying the item that is the
/// destination of the item at index. The existing item at that location slides
/// up or down to an adjoining index position to make room for it.
- (void) moveItemWithAnimationAtIndexPath: (NSIndexPath*) indexPath
		toIndexPath: (NSIndexPath*) newIndexPath;

// Selection

/// Selects the item in the table view. This method performs a linear
/// search and may not be performant. If you have the index path of the item
/// then it is faster to use the selection methods on the table view.
/// @param item An item to select in the table view.
/// @param animated A flag indicating whether animation should be performed as
/// the selection changes.
- (void) selectItem: (ASTItem*) item withAnimation: (BOOL) animated
		scrollPosition: (UITableViewScrollPosition) scrollPosition;

/// Deselects the item in the table view. This method performs a linear
/// search and may not be performant. If you have the index path of the item
/// then it is faster to use the selection methods on the table view.
/// @param item An item to deselect in the table view.
/// @param animated A flag indicating whether animation should be performed as
/// the selection changes.
- (void) deselectItem: (ASTItem*) item withAnimation: (BOOL) animated;

@end

//------------------------------------------------------------------------------

@interface UITableView (ASTViewController)

/// Deselects all rows in the table view.
- (void) ast_clearSelection;

/// Performs updates to the table view while surrounding them with a
/// beginUpdates call and a endUpdates call.
- (void) performUpdates: (ASTUpdateBlock) updateBlock;

@end

//------------------------------------------------------------------------------

static BOOL SortAscending = YES;
static BOOL SortDescending = NO;

//------------------------------------------------------------------------------

NSArray* sortIndexesOfArray( NSArray* array, NSString* key, BOOL ascending );
NSArray* sortArray( NSArray* indexArray, NSString* key, BOOL ascending );

//------------------------------------------------------------------------------

NS_ASSUME_NONNULL_END
