//==============================================================================
//
//  ASTViewController.m
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

#import "ASTViewController.h"

#import "ASTItem.h"
#import "ASTItemSubclass.h"
#import "ASTSection.h"
#import "ASTSectionSubclass.h"


//------------------------------------------------------------------------------

static NSIndexSet* indexSetFromArray( NSArray* indexArray )
{
	NSMutableIndexSet* indexSet = [ NSMutableIndexSet indexSet ];
	for( NSNumber* indexValue in indexArray ) {
		[ indexSet addIndex: [ indexValue unsignedIntegerValue ] ];
	}
	return indexSet;
}

//------------------------------------------------------------------------------

NSArray* sortArray( NSArray* indexArray, NSString* key, BOOL ascending )
{
	NSSortDescriptor* descriptor = [ NSSortDescriptor
			sortDescriptorWithKey: key
			ascending: ascending ];
	return [ indexArray sortedArrayUsingDescriptors: @[ descriptor ] ];
}

//------------------------------------------------------------------------------

NSArray* sortIndexesOfArray( NSArray* array, NSString* key, BOOL ascending )
{
	NSSortDescriptor* descriptor = [ NSSortDescriptor
			sortDescriptorWithKey: key
			ascending: ascending ];
	NSMutableArray* result = [ NSMutableArray arrayWithCapacity: array.count ];
	for( NSUInteger i = 0; i < array.count; ++i ) {
		[ result addObject: @(i) ];
	}
	
	[ result sortUsingComparator: ^NSComparisonResult( id index1, id index2 ) {
		id value1 = array[ [ index1 unsignedIntegerValue ] ];
		id value2 = array[ [ index2 unsignedIntegerValue ] ];
		return [ descriptor compareObject: value1 toObject: value2 ];
	} ];
	
	return [ result copy ];
}

//------------------------------------------------------------------------------

static NSArray* groupIndexesOfArray( NSArray* array, NSString* key,
		NSString* sortKey, BOOL ascending )
{
	NSMutableDictionary* groups = [ NSMutableDictionary dictionary ];
	for( NSUInteger i = 0; i < array.count; ++i ) {
		id object = array[ i ];
		id keyValue = [ object valueForKey: key ];
		NSMutableArray* group = groups[ keyValue ];
		if( group == nil ) {
			group = [ NSMutableArray array ];
			groups[ keyValue ] = group;
		}
		[ group addObject: @(i) ];
	}
	NSMutableArray* keys = [ groups.allKeys mutableCopy ];
	NSSortDescriptor* descriptor = [ NSSortDescriptor
			sortDescriptorWithKey: sortKey
			ascending: ascending ];
	[ keys sortUsingDescriptors: @[ descriptor ] ];
	NSMutableArray* result = [ NSMutableArray arrayWithCapacity: keys.count ];
	for( id key in keys ) {
		id keyValue = groups[ key ];
		[ result addObject: keyValue ];
	}
	return result;
}

//------------------------------------------------------------------------------

static NSArray* objectsAtIndexes( NSArray* sourceArray, NSArray* indexArray )
{
	NSMutableArray* result = [ NSMutableArray arrayWithCapacity: indexArray.count ];
	for( NSNumber* indexValue in indexArray ) {
		NSUInteger index = [ indexValue unsignedIntegerValue ];
		id value = sourceArray[ index ];
		[ result addObject: value ];
	}
	return result;
}

//------------------------------------------------------------------------------

static NSArray* mapIndexPathsToRows( NSArray* indexPaths )
{
	NSMutableArray* result = [ NSMutableArray arrayWithCapacity: indexPaths.count ];
	for( NSIndexPath* indexPath in indexPaths ) {
		[ result addObject: @(indexPath.row) ];
	}
	return result;
}

//------------------------------------------------------------------------------

static ASTItem* itemFromObject( id itemObject )
{
	if( [ itemObject isKindOfClass: [ ASTItem class ] ] ) {
		return itemObject;
	} else if( [ itemObject isKindOfClass: [ NSDictionary class ] ] ) {
		return [ ASTItem itemWithDict: itemObject ];
	} else if( [ itemObject isKindOfClass: [ NSNull class ] ] ) {
		return nil;
	} else {
		[ NSException raise: @"Unexpected ASTItem object"
				format: @"An unexpected type was encountered: %@",
				itemObject ];
	}
	return nil;
}

//------------------------------------------------------------------------------

static ASTSection* sectionFromObject( id sectionObject )
{
	if( [ sectionObject isKindOfClass: [ ASTSection class ] ] ) {
		return sectionObject;
	} else if( [ sectionObject isKindOfClass: [ NSDictionary class ] ] ) {
		return [ ASTSection sectionWithDict: sectionObject ];
	} else if( [ sectionObject isKindOfClass: [ NSNull class ] ] ) {
		return nil;
	} else {
		[ NSException raise: @"Unexpected ASTSection object"
				format: @"An unexpected type was encountered: %@",
				sectionObject ];
	}
	return nil;
}

//------------------------------------------------------------------------------

@interface ASTViewController() {
	NSMutableArray* _data;
}

@end

//------------------------------------------------------------------------------

@implementation ASTViewController

//------------------------------------------------------------------------------

- (instancetype) init
{
	// Most of the time one wants a grouped table, so lets make that the default.
	return [ self initWithStyle: UITableViewStyleGrouped ];
}

//------------------------------------------------------------------------------

// LCOV_EXCL_START

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [ super initWithNibName: nibNameOrNil bundle: nibBundleOrNil ];
	if( self ) {
		[ self initializeASTViewControllerMembers ];
	}
	return self;
}

// LCOV_EXCL_STOP

//------------------------------------------------------------------------------

- (instancetype) initWithStyle:(UITableViewStyle)style
{
	self = [ super initWithStyle: style ];
	if( self ) {
		[ self initializeASTViewControllerMembers ];
	}
	return self;
}

//------------------------------------------------------------------------------

// LCOV_EXCL_START

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
	self = [ super initWithCoder: aDecoder ];
	if( self ) {
		[ self initializeASTViewControllerMembers ];
	}
	return self;
}

// LCOV_EXCL_STOP

//------------------------------------------------------------------------------

- (void) initializeASTViewControllerMembers
{
	_data = [ NSMutableArray array ];
}

//------------------------------------------------------------------------------

- (void) loadView
{
	[ super loadView ];
	
	// Note that setting both the estimatedRowHeight and rowHeight seem to be
	// necessary to get the tableview to correctly handle autolayout.
	self.tableView.estimatedRowHeight = 44;
	self.tableView.rowHeight = UITableViewAutomaticDimension;
	self.tableView.allowsMultipleSelectionDuringEditing = NO;
	self.tableView.estimatedSectionHeaderHeight = 44;
	self.tableView.estimatedSectionFooterHeight = 44;
}

//------------------------------------------------------------------------------

- (ASTSection*) sectionWithIdentifier: (NSString*) identifier
{
	if( self.tableView.style == UITableViewStyleGrouped ) {
		for( ASTSection* section in _data ) {
			if( section.identifier == identifier
					|| [ section.identifier isEqualToString: identifier ] ) {
				return section;
			}
		}
	}
	
	return nil;
}

//------------------------------------------------------------------------------

- (ASTSection*) sectionAtIndex: (NSUInteger) index;
{
	if( self.tableView.style == UITableViewStyleGrouped ) {
		if( index < _data.count ) {
			return _data[ index ];
		}
	}
	return nil;
}

//------------------------------------------------------------------------------

- (ASTItem*) itemWithIdentifier: (NSString*) identifier
{
	if( self.tableView.style == UITableViewStyleGrouped ) {
		for( ASTSection* section in _data ) {
			ASTItem* item = [ section itemWithIdentifier: identifier ];
			if( item ) {
				return item;
			}
		}
	} else {
		for( ASTItem* item in _data ) {
			if( item.identifier == identifier
					|| [ item.identifier isEqualToString: identifier ] ) {
				return item;
			}
		}
	}
	
	return nil;
}

//------------------------------------------------------------------------------

- (ASTItem*) itemWithRepresentedObject: (id) representedObject
{
	if( self.tableView.style == UITableViewStyleGrouped ) {
		for( ASTSection* section in _data ) {
			ASTItem* item = [ section itemWithRepresentedObject: representedObject ];
			if( item ) {
				return item;
			}
		}
	} else {
		for( ASTItem* item in _data ) {
			if( item.representedObject == representedObject
					|| [ item.representedObject isEqual: representedObject ] ) {
				return item;
			}
		}
	}
	
	return nil;
}

//------------------------------------------------------------------------------

- (ASTItem*) itemAtIndexPath: (NSIndexPath*) indexPath
{
	if( indexPath == nil ) {
		return nil;
	}
	
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	
	if( self.tableView.style == UITableViewStyleGrouped ) {
		if( section < _data.count ) {
			ASTSection* section = [ self sectionAtIndex: indexPath.section ];
			if( row < section.numberOfItems ) {
				return [ section itemAtIndex: row ];
			}
		}
	} else {
		if( section == 0 && row < _data.count ) {
			return _data[ row ];
		}
	}
	
	return nil;
}

//------------------------------------------------------------------------------

- (NSInteger) indexOfSection: (ASTSection*) section
{
	if( self.tableView.style != UITableViewStyleGrouped || section == nil ) {
		return NSNotFound;
	}
	
	int sectionIndex = 0;
	
	for( ASTSection* iterSection in _data ) {
		if( iterSection == section ) {
			return sectionIndex;
		}
		++sectionIndex;
	}
	
	return NSNotFound;
}

//------------------------------------------------------------------------------

- (NSIndexPath*) indexPathForItem: (ASTItem*) item
{
	if( item == nil ) {
		return nil;
	}
	
	int section = 0;
	int row = 0;
	Class sectionClass = [ ASTSection class ];
	
	for( id sectionOrItem in _data ) {
		if( [ sectionOrItem isKindOfClass: sectionClass ] ) {
			row = 0;
			for( id sectionItem in [ sectionOrItem items ] ) {
				if( sectionItem == item ) {
					return [ NSIndexPath indexPathForItem: row inSection: section ];
				}
				++row;
			}
			++section;
		} else {
			if( sectionOrItem == item ) {
				return [ NSIndexPath indexPathForItem: row inSection: section ];
			}
		}
		++row;
	}
	
	return nil;
}

//------------------------------------------------------------------------------

- (NSUInteger) numberOfItems
{
	return _data.count;
}

//------------------------------------------------------------------------------

- (void) insertSections: (NSArray*) sections atIndexes: (NSArray*) indexes
{
	NSParameterAssert( sections.count == indexes.count );
	
	if( self.tableView.style == UITableViewStyleGrouped ) {
		NSArray* sortedIndexes = sortIndexesOfArray( indexes, @"unsignedIntegerValue", SortAscending );
		for( NSInteger i = 0; i < sortedIndexes.count; ++i ) {
			NSUInteger sortedIndex = [ sortedIndexes[ i ] unsignedIntegerValue ];
			ASTSection* section = sectionFromObject( sections[ sortedIndex ] );
			NSParameterAssert( section != nil );
			NSUInteger sectionIndex = [ indexes[ sortedIndex ] unsignedIntegerValue ];
			if( sectionIndex >= _data.count ) {
				[ _data addObject: section ];
			} else {
				[ _data insertObject: section atIndex: sectionIndex ];
			}
			section.tableViewController = self;
		}
	}
}

//------------------------------------------------------------------------------

- (void) removeSectionsAtIndexes: (NSArray*) indexes
{
	if( self.tableView.style == UITableViewStyleGrouped ) {
		NSArray* sortedIndexes = sortArray( indexes, @"unsignedIntegerValue", SortDescending );
		for( NSInteger i = 0; i < sortedIndexes.count; ++i ) {
			NSUInteger index = [ sortedIndexes[ i ] unsignedIntegerValue ];
			ASTSection* section = _data[ index ];
			[ _data removeObjectAtIndex: index ];
			section.tableViewController = nil;
		}
	}
}

//------------------------------------------------------------------------------

- (void) moveSectionAtIndex: (NSUInteger) index toIndex: (NSUInteger) newIndex
{
	if( self.tableView.style == UITableViewStyleGrouped ) {
		id section = _data[ index ];
		[ _data removeObjectAtIndex: index ];
		[ _data insertObject: section atIndex: newIndex ];
	}
}

//------------------------------------------------------------------------------

- (void) insertItems: (NSArray*) items atIndexPaths: (NSArray*) indexPaths
{
	NSParameterAssert( items.count == indexPaths.count );
	
	if( self.tableView.style == UITableViewStyleGrouped ) {
		NSArray* indexGroups = groupIndexesOfArray( indexPaths, @"section",
				@"unsignedIntegerValue", SortDescending );
		for( NSArray* indexGroup in indexGroups ) {
			NSArray* groupItems = objectsAtIndexes( items, indexGroup );
			NSArray* groupPaths = objectsAtIndexes( indexPaths, indexGroup );
			NSUInteger sectionIndex = ((NSIndexPath*)(groupPaths.firstObject)).section;
			ASTSection* section = [ self sectionAtIndex: sectionIndex ];
			[ section insertItemReferences: groupItems atIndexes: mapIndexPathsToRows( groupPaths ) ];
		}
	} else {
		NSArray* sortedIndexes = sortIndexesOfArray( indexPaths, @"row", SortAscending );
		for( NSInteger i = 0; i < items.count; ++i ) {
			NSUInteger sortedIndex = [ sortedIndexes[ i ] unsignedIntegerValue ];
			ASTItem* item = itemFromObject( items[ sortedIndex ] );
			NSParameterAssert( item != nil );
			NSIndexPath* path = indexPaths[ sortedIndex ];
			NSUInteger dataIndex = path.row;
			if( dataIndex >= _data.count ) {
				[ _data addObject: item ];
			} else {
				[ _data insertObject: item atIndex: dataIndex ];
			}
			item.tableViewController = self;
		}
	}
}

//------------------------------------------------------------------------------

- (void) removeItemsAtIndexPaths: (NSArray*) indexPaths
{
	if( self.tableView.style == UITableViewStyleGrouped ) {
		NSArray* sortedIndexes = sortIndexesOfArray( indexPaths, @"row", SortDescending );
		for( NSInteger i = 0; i < indexPaths.count; ++i ) {
			NSUInteger sortedIndex = [ sortedIndexes[ i ] unsignedIntegerValue ];
			NSIndexPath* path = indexPaths[ sortedIndex ];
			ASTSection* section = [ self sectionAtIndex: path.section ];
			[ section removeItemReferencesAtIndexes: @[ @(path.row) ] ];
		}
	} else {
		NSArray* sortedIndexPaths = sortArray( indexPaths, @"row", SortDescending );
		for( NSInteger i = 0; i < sortedIndexPaths.count; ++i ) {
			NSIndexPath* path = sortedIndexPaths[ i ];
			ASTItem* item = [ self itemAtIndexPath: path ];
			[ _data removeObjectAtIndex: path.row ];
			item.tableViewController = nil;
		}
	}
}

//------------------------------------------------------------------------------

- (void) moveItemAtIndexPath: (NSIndexPath*) indexPath
		toIndexPath: (NSIndexPath*) newIndexPath
{
	NSParameterAssert( (indexPath != nil) == (newIndexPath != nil) );
	
	ASTItem* item = [ self itemAtIndexPath: indexPath ];
	NSAssert( item != nil, @"indexPath is not valid %@", indexPath );
	
	UITableView* tableView = self.tableView;
	
	if( tableView.style == UITableViewStyleGrouped ) {
		ASTSection* section = [ self sectionAtIndex: indexPath.section ];
		[ section removeItemReferencesAtIndexes: @[ @(indexPath.row) ] ];
		
		section = [ self sectionAtIndex: newIndexPath.section ];
		[ section insertItemReferences: @[ item ] atIndexes: @[ @(newIndexPath.row) ] ];
	} else {
		[ _data removeObjectAtIndex: indexPath.row ];
		[ _data insertObject: item atIndex: newIndexPath.row ];
	}
}

//------------------------------------------------------------------------------

- (void) insertSections: (NSArray*) sections atIndexes: (NSArray*) indexes
		withRowAnimation: (UITableViewRowAnimation) animation
{
	NSParameterAssert( sections.count == indexes.count );
	
	UITableView* tableView = self.tableView;
	if( tableView.style == UITableViewStyleGrouped ) {
		[ self insertSections: sections atIndexes: indexes ];
		[ tableView insertSections: indexSetFromArray( indexes )
				withRowAnimation: animation ];
	}
}

//------------------------------------------------------------------------------

- (void) removeSectionsAtIndexes: (NSArray*) indexes
		withRowAnimation: (UITableViewRowAnimation) animation
{
	UITableView* tableView = self.tableView;
	if( tableView.style == UITableViewStyleGrouped ) {
		[ self removeSectionsAtIndexes: indexes ];
		[ tableView deleteSections: indexSetFromArray( indexes )
				withRowAnimation: animation ];
	}
}

//------------------------------------------------------------------------------

- (void) moveSectionWithAnimationAtIndex: (NSUInteger) index
		toIndex: (NSUInteger) newIndex
{
	UITableView* tableView = self.tableView;
	if( tableView.style == UITableViewStyleGrouped ) {
		[ self moveSectionAtIndex: index toIndex: newIndex ];
		[ tableView moveSection: index toSection: newIndex ];
	}
}

//------------------------------------------------------------------------------

- (void) insertItems: (NSArray*) items atIndexPaths: (NSArray*) indexPaths
		withRowAnimation: (UITableViewRowAnimation) animation
{
	NSParameterAssert( items.count == indexPaths.count );
	
	[ self insertItems: items atIndexPaths: indexPaths ];
	[ self.tableView insertRowsAtIndexPaths: indexPaths withRowAnimation: animation ];
}

//------------------------------------------------------------------------------

- (void) removeItemsAtIndexPaths: (NSArray*) indexPaths
		withRowAnimation: (UITableViewRowAnimation) animation
{
	[ self removeItemsAtIndexPaths: indexPaths ];
	[ self.tableView deleteRowsAtIndexPaths: indexPaths withRowAnimation: animation ];
}

//------------------------------------------------------------------------------

- (void) moveItemWithAnimationAtIndexPath: (NSIndexPath*) indexPath
		toIndexPath: (NSIndexPath*) newIndexPath
{
	NSAssert( [ self itemAtIndexPath: indexPath ] != nil, @"indexPath is not valid %@", indexPath );
	
	[ self moveItemAtIndexPath: indexPath toIndexPath: newIndexPath ];
	[ self.tableView moveRowAtIndexPath: indexPath toIndexPath: newIndexPath ];
}

//------------------------------------------------------------------------------

- (void) deselectItem: (ASTItem*) item withAnimation: (BOOL) animated
{
	NSIndexPath* indexPath = [ self indexPathForItem: item ];
	[ self.tableView deselectRowAtIndexPath: indexPath animated: animated ];
}

//------------------------------------------------------------------------------

#pragma mark - Accessors

//------------------------------------------------------------------------------

- (void) setData: (NSArray*) data
{
	BOOL isGrouped = self.tableView.style == UITableViewStyleGrouped;
	
	// Remove all of the existing items or sections
	if( isGrouped ) {
		for( ASTSection* section in _data ) {
			section.tableViewController = nil;
		}
	} else {
		for( ASTItem* item in _data ) {
			item.tableViewController = nil;
		}
	}
	[ _data removeAllObjects ];
	
	for( id object in data ) {
		if( isGrouped ) {
			ASTSection* section = sectionFromObject( object );
			if( section ) {
				section.tableViewController = self;
				[ _data addObject: section ];
			}
		} else {
			ASTItem* item = itemFromObject( object );
			if( item ) {
				item.tableViewController = self;
				[ _data addObject: item ];
			}
		}
	}
	
	[ self.tableView reloadData ];
}

//------------------------------------------------------------------------------

- (NSArray*) data
{
	return [ _data copy ];
}

//------------------------------------------------------------------------------

#pragma mark - UITableViewDataSource

//------------------------------------------------------------------------------

- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView
{
	if( self.tableView.style == UITableViewStyleGrouped ) {
		return _data.count;
	}
	return 1;
}

//------------------------------------------------------------------------------

- (NSInteger) tableView: (UITableView*) tableView
		numberOfRowsInSection: (NSInteger) section
{
	if( self.tableView.style == UITableViewStyleGrouped ) {
		ASTSection* sectionData = _data[ section ];
		return sectionData.numberOfItems;
	}
	return _data.count;
}

//------------------------------------------------------------------------------

- (UITableViewCell*) tableView: (UITableView*) tableView
		cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
	ASTItem* item = [ self itemAtIndexPath: indexPath ];
	return item.cell;
}

//------------------------------------------------------------------------------

- (NSString*) tableView: (UITableView*) tableView
		titleForHeaderInSection: (NSInteger) section
{
	if( self.tableView.style == UITableViewStyleGrouped ) {
		ASTSection* sectionData = _data[ section ];
		return sectionData.headerText;
	}
	return nil;
}

//------------------------------------------------------------------------------

- (NSString*) tableView: (UITableView*) tableView
		titleForFooterInSection: (NSInteger) section
{
	if( self.tableView.style == UITableViewStyleGrouped ) {
		ASTSection* sectionData = _data[ section ];
		return sectionData.footerText;
	}
	return nil;
}

//------------------------------------------------------------------------------

- (UIView*) tableView: (UITableView*) tableView viewForHeaderInSection: (NSInteger) section
{
	if( self.tableView.style == UITableViewStyleGrouped ) {
		ASTSection* sectionData = _data[ section ];
		return sectionData.headerView;
	}
	return nil;
}

//------------------------------------------------------------------------------

- (UIView*) tableView: (UITableView*) tableView viewForFooterInSection: (NSInteger) section
{
	if( self.tableView.style == UITableViewStyleGrouped ) {
		ASTSection* sectionData = _data[ section ];
		return sectionData.footerView;
	}
	return nil;
}

//------------------------------------------------------------------------------

- (BOOL) tableView: (UITableView*) tableView canEditRowAtIndexPath: (NSIndexPath*) indexPath
{
	ASTItem* item = [ self itemAtIndexPath: indexPath ];
	return item.editable;
}

//------------------------------------------------------------------------------

- (void) tableView: (UITableView*) tableView
		commitEditingStyle: (UITableViewCellEditingStyle) editingStyle
		forRowAtIndexPath: (NSIndexPath*) indexPath
{
	ASTItem* item = [ self itemAtIndexPath: indexPath ];
	if( item.deleteBlock ) {
		item.deleteBlock( item );
	}
}

//------------------------------------------------------------------------------

- (CGFloat) tableView: (UITableView*) tableView heightForHeaderInSection: (NSInteger) section
{
	return UITableViewAutomaticDimension;
}

//------------------------------------------------------------------------------

- (CGFloat) tableView: (UITableView*) tableView heightForFooterInSection: (NSInteger) section
{
	return UITableViewAutomaticDimension;
}

//------------------------------------------------------------------------------

#pragma mark - UITableViewDelegate

//------------------------------------------------------------------------------

- (void) tableView: (UITableView*) tableView
		didEndDisplayingCell: (UITableViewCell*) cell
		forRowAtIndexPath: (NSIndexPath*) indexPath
{
	ASTItem* item = [ self itemAtIndexPath: indexPath ];
	[ item didEndDisplayingCell ];
}

//------------------------------------------------------------------------------

- (BOOL) tableView: (UITableView*) tableView
		shouldHighlightRowAtIndexPath: (NSIndexPath*) indexPath
{
	ASTItem* item = [ self itemAtIndexPath: indexPath ];
	return item.selectable;
}

//------------------------------------------------------------------------------

- (void) tableView:(UITableView*) tableView
		didSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
	ASTItem* item = [ self itemAtIndexPath: indexPath ];
	[ item performSelectionAction ];
}

//------------------------------------------------------------------------------

- (UITableViewCellEditingStyle) tableView: (UITableView*) tableView
		editingStyleForRowAtIndexPath: (NSIndexPath*) indexPath
{
	ASTItem* item = [ self itemAtIndexPath: indexPath ];
	return item.editable ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
}

//------------------------------------------------------------------------------

@end

//------------------------------------------------------------------------------

@implementation UITableView (ASTViewController)

//------------------------------------------------------------------------------

- (void) ast_clearSelection
{
	for( NSIndexPath* indexPath in self.indexPathsForSelectedRows ) {
		[ self deselectRowAtIndexPath: indexPath animated: YES ];
	}
}

//------------------------------------------------------------------------------

// LCOV_EXCL_START

- (void) performUpdates: (ASTUpdateBlock) updateBlock
{
	[ self beginUpdates ];
	
	updateBlock();
	
	[ self endUpdates ];
}

// LCOV_EXCL_STOP

//------------------------------------------------------------------------------

@end
