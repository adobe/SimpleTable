//==============================================================================
//
//  ASTSection.m
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

#import "ASTSection.h"
#import "ASTSectionSubclass.h"

#import "ASTItemSubclass.h"
#import "ASTViewController.h"


//------------------------------------------------------------------------------

@implementation ASTSection

//------------------------------------------------------------------------------

+ (instancetype) section
{
	ASTSection* result = [ [ ASTSection alloc ] init ];
	return result;
}

//------------------------------------------------------------------------------

+ (instancetype) sectionWithItems: (NSArray*) items
{
	return [ [ ASTSection alloc ] initWithItems: items ];
}

//------------------------------------------------------------------------------

+ (instancetype) sectionWithHeaderText: (NSString*) headerText
		items: (NSArray*) items
{
	return [ [ ASTSection alloc ] initWithHeaderText: headerText items: items ];
}

//------------------------------------------------------------------------------

+ (instancetype) sectionWithDict: (NSDictionary*) dict
{
	return [ [ ASTSection alloc ] initWithDict: dict ];
}

//------------------------------------------------------------------------------

- (instancetype) init
{
	self = [ self initWithDict: @{} ];
	if( self ) {
	}
	return self;
}

//------------------------------------------------------------------------------

- (instancetype) initWithItems: (NSArray*) items
{
	self = [ self initWithDict: @{} ];
	if( self ) {
		self.items = items;
	}
	return self;
}

//------------------------------------------------------------------------------

- (instancetype) initWithHeaderText: (NSString*) headerText items: (NSArray*) items
{
	self = [ self initWithDict: @{} ];
	if( self ) {
		self.items = items;
		self.headerText = headerText;
	}
	return self;
}

//------------------------------------------------------------------------------

- (instancetype) initWithDict: (NSDictionary*) dict
{
	self = [ super init ];
	if( self ) {
		_items = [ NSMutableArray array ];
		[ self setupSectionWithDict: dict ];
	}
	return self;
}

//------------------------------------------------------------------------------

- (void) setupSectionWithDict: (NSDictionary*) dict
{
	self.identifier = dict[ AST_id ];

	self.headerText = dict[ AST_headerText ];
	self.footerText = dict[ AST_footerText ];
	self.headerView = dict[ AST_headerView ];
	self.footerView = dict[ AST_footerView ];
	
	self.items = dict[ AST_items ];
}

//------------------------------------------------------------------------------

- (void) removeFromContainerWithRowAnimation: (UITableViewRowAnimation) animation;
{
	[ _tableViewController removeSectionsAtIndexes: @[ @(self.index) ]
			withRowAnimation: animation ];
}

//------------------------------------------------------------------------------

- (NSInteger) index
{
	if( _tableViewController ) {
		return [ _tableViewController indexOfSection: self ];
	}
	return NSNotFound;
}

//------------------------------------------------------------------------------

- (ASTItem*) itemAtIndex: (NSUInteger) index
{
	if( index < _items.count ) {
		return _items[ index ];
	}
	return nil;
}

//------------------------------------------------------------------------------

- (ASTItem*) itemWithIdentifier: (NSString*) identifier
{
	for( ASTItem* item in _items ) {
		if( item.identifier == identifier
				|| [ item.identifier isEqualToString: identifier ] ) {
			return item;
		}
	}
	
	return nil;
}

//------------------------------------------------------------------------------

- (ASTItem*) itemWithRepresentedObject: (id) representedObject
{
	for( ASTItem* item in _items ) {
		if( [ item.representedObject isEqual: representedObject ]
				|| (representedObject == nil && item.representedObject == nil ) ) {
			return item;
		}
	}
	
	return nil;
}

//------------------------------------------------------------------------------

- (void) insertItemReferences: (NSArray*) items atIndexes: (NSArray*) indexes
{
	NSParameterAssert( items.count == indexes.count );
	NSArray* sortedIndexes = sortIndexesOfArray( indexes,
			@"unsignedIntegerValue", SortDescending );
	
	for( NSNumber* indexValue in sortedIndexes ) {
		NSUInteger index = [ indexValue unsignedIntegerValue ];
		ASTItem* sortedItem = items[ index ];
		NSUInteger sortedIndex = [ indexes[ index ] unsignedIntegerValue ];
		[ _items insertObject: sortedItem atIndex: sortedIndex ];
		sortedItem.tableViewController = self.tableViewController;
		sortedItem.section = self;
	}
}

//------------------------------------------------------------------------------

- (void) removeItemReferencesAtIndexes: (NSArray*) indexes
{
	NSArray* sortedIndexes = sortArray( indexes, @"unsignedIntegerValue", NO );
	for( NSNumber* indexValue in sortedIndexes ) {
		NSUInteger index = [ indexValue unsignedIntegerValue ];
		ASTItem* item = _items[ index ];
		[ _items removeObjectAtIndex: index ];
		item.tableViewController = nil;
		item.section = nil;
	}
}

//------------------------------------------------------------------------------

- (void) moveItemReferenceAtIndex: (NSUInteger) index toIndex: (NSUInteger) newIndex
{
	ASTItem* item = _items[ index ];
	[ _items removeObjectAtIndex: index ];
	[ _items insertObject: item atIndex: newIndex ];
}

//------------------------------------------------------------------------------

- (void) insertItems: (NSArray*) items atIndexes: (NSArray*) indexes
		withRowAnimation: (UITableViewRowAnimation) animation
{
	UITableView* tableView = self.tableViewController.tableView;
	
	[ self insertItemReferences: items atIndexes: indexes ];
	
	[ tableView insertRowsAtIndexPaths: [ self indexPathsWithIndexes: indexes ]
			withRowAnimation: animation ];
}

//------------------------------------------------------------------------------

- (void) removeItemsAtIndexes: (NSArray*) indexes
		withRowAnimation: (UITableViewRowAnimation) animation
{
	UITableView* tableView = self.tableViewController.tableView;
	
	[ self removeItemReferencesAtIndexes: indexes ];
	
	[ tableView deleteRowsAtIndexPaths: [ self indexPathsWithIndexes: indexes ]
			withRowAnimation: animation ];
}

//------------------------------------------------------------------------------

- (void) moveItemAtIndex: (NSUInteger) index toIndex: (NSUInteger) newIndex
{
	UITableView* tableView = self.tableViewController.tableView;
	
	NSIndexPath* indexPath = [ NSIndexPath indexPathForRow: index inSection: self.index ];
	
	[ self moveItemReferenceAtIndex: index toIndex: newIndex ];
	
	NSIndexPath* newIndexPath = [ NSIndexPath indexPathForRow: newIndex inSection: self.index ];
	[ tableView moveRowAtIndexPath: indexPath toIndexPath: newIndexPath ];
}

//------------------------------------------------------------------------------

- (void) setItems: (NSArray*) items
{
	// Remove existing items
	for( ASTItem* item in _items ) {
		item.tableViewController = nil;
		item.section = nil;
	}
	[ _items removeAllObjects ];
	
	for( id itemValue in items ) {
		ASTItem* item = nil;
		
		if( [ itemValue isKindOfClass: [ ASTItem class ] ] ) {
			item = itemValue;
		} else if( [ itemValue isKindOfClass: [ NSDictionary class ] ] ) {
			item = [ ASTItem itemWithDict: itemValue ];
		} else if( [ itemValue isKindOfClass: [ NSNull class ] ] ) {
			// It's null, skip it.
		} else {
			[ NSException raise: @"ASTSection unexpected item"
					format: @"An item with an unexpected type was encountered: %@",
					itemValue ];
		}
		
		if( item ) {
			[ _items addObject: item ];
			item.tableViewController = self.tableViewController;
			item.section = self;
		}
	}

	UITableView* tableView = self.tableViewController.tableView;
	[ tableView reloadData ];
}

//------------------------------------------------------------------------------

- (NSArray*) items
{
	return [ _items copy ];
}

//------------------------------------------------------------------------------

- (void) setTableViewController: (ASTViewController*) tableViewController
{
	_tableViewController = tableViewController;
	
	for( ASTItem* item in _items ) {
		item.tableViewController = tableViewController;
	}
}

//------------------------------------------------------------------------------

- (NSUInteger) numberOfItems
{
	return _items.count;
}

//------------------------------------------------------------------------------

- (NSArray*) indexPathsWithIndexes: (NSArray*) indexes
{
	NSUInteger index = self.index;
	NSMutableArray* result = [ NSMutableArray arrayWithCapacity: indexes.count ];
	for( NSNumber* indexValue in indexes ) {
		[ result addObject: [ NSIndexPath
				indexPathForItem: [ indexValue unsignedIntegerValue ]
				inSection: index ] ];
	}
	return result;
}

//------------------------------------------------------------------------------

- (void) setFooterText: (NSString*) footerText
{
	NSString* originalFooterText = _footerText;
	
	_footerText = footerText;
	
	UITableView* tableView = self.tableViewController.tableView;
	NSInteger index = self.index;
	if( tableView && index >= 0 ) {
		UITableViewHeaderFooterView* footerView = [ tableView footerViewForSection: index ];
		if( footerView != nil && originalFooterText.length > 0 && footerText.length > 0 ) {
			// This is an optimization that allows us to avoid reloading the
			// section if there was already footer text showing. This lets us
			// avoid the negative effects of a reload like killing focus in a
			// text field cell.
			footerView.textLabel.text = footerText;
			[ footerView setNeedsLayout ];
		} else {
			[ tableView reloadSections: [ NSIndexSet indexSetWithIndex: index ]
					withRowAnimation: UITableViewRowAnimationNone ];
			// Note that we are using UITableViewRowAnimationNone. Using
			// UITableViewRowAnimationAutomatic seems to cause the sections items
			// to not redraw properly.
		}
	}
}

//------------------------------------------------------------------------------

@end

