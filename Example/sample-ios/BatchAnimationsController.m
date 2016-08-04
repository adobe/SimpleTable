//==============================================================================
//
//  GroupAnimationsController.m
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

#import "BatchAnimationsController.h"


//------------------------------------------------------------------------------
// Modified version of https://en.wikipedia.org/wiki/Fisher–Yates_shuffle

static NSArray* randomIndexes( u_int32_t count, u_int32_t range)
{
	assert( count <= range );
	
	NSMutableDictionary* swapped = [ NSMutableDictionary dictionary ];
	
	for( u_int32_t i = 0; i < count; ++i ) {
		u_int32_t r = arc4random_uniform( (u_int32_t)(range - i) ) + i;
		NSNumber* swap1 = swapped[ @(i) ] ?: @(i);
		NSNumber* swap2 = swapped[ @(r) ] ?: @(r);
		swapped[ @(i) ] = swap2;
		swapped[ @(r) ] = swap1;
	}
	
	NSMutableArray* result = [ NSMutableArray arrayWithCapacity: count ];
	for( u_int32_t i = 0; i < count; ++i ) {
		[ result addObject: swapped[ @(i) ] ];
	}
	
	return [ result copy ];
}

//------------------------------------------------------------------------------

@interface BatchAnimationsController () {
	NSUInteger _counter;
}

@end

//------------------------------------------------------------------------------

@implementation BatchAnimationsController

//------------------------------------------------------------------------------

- (instancetype) init
{
	self = [ super initWithStyle: UITableViewStylePlain ];
	if( self ) {
		self.title = @"Batch Animation";
		[ self resetData ];
		[ self setupToolbar ];
	}
	return self;
}

//------------------------------------------------------------------------------

- (void) resetData
{
	NSMutableArray* data = [ NSMutableArray array ];
	NSUInteger count = 100;
	
	for( NSUInteger i = 0; i < count; ++i ) {
		[ data addObject: @{
			AST_cell_textLabel_text : [ NSString stringWithFormat: @"%ld", i ],
		} ];
	}
	
	_counter = count;
	self.data = data;
}

//------------------------------------------------------------------------------

- (void) setupToolbar
{
	self.toolbarItems = @[
		[ [ UIBarButtonItem alloc ]
				initWithBarButtonSystemItem: UIBarButtonSystemItemTrash
				target: self
				action: @selector(randomDeleteAction:) ],
		[ [ UIBarButtonItem alloc ]
				initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace
				target: nil action: nil ],
		[ [ UIBarButtonItem alloc ]
				initWithBarButtonSystemItem: UIBarButtonSystemItemAdd
				target: self
				action: @selector(randomAddAction:) ],
		[ [ UIBarButtonItem alloc ]
				initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace
				target: nil action: nil ],
		[ [ UIBarButtonItem alloc ]
				initWithTitle: @"Move"
				style: UIBarButtonItemStylePlain
				target: self
				action: @selector(randomMoveAction:) ],
		[ [ UIBarButtonItem alloc ]
				initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace
				target: nil action: nil ],
		[ [ UIBarButtonItem alloc ]
				initWithBarButtonSystemItem: UIBarButtonSystemItemRefresh
				target: self
				action: @selector(resetAction:) ],
	];
}

//------------------------------------------------------------------------------

- (void) randomDeleteAction: (id) sender
{
	u_int32_t count = (u_int32_t)self.data.count;
	NSArray* indexesToDelete = randomIndexes( MIN( 10, count ), count );
	
	NSMutableArray* pathsToDelete = [ NSMutableArray arrayWithCapacity: indexesToDelete.count ];
	for( NSUInteger i = 0; i < indexesToDelete.count; ++i ) {
		NSUInteger row = [ indexesToDelete[ i ] unsignedIntegerValue ];
		[ pathsToDelete addObject: [ NSIndexPath indexPathForRow: row inSection: 0 ] ];
	}
	
	[ self.tableView performUpdates: ^{
		[ self removeItemsAtIndexPaths: pathsToDelete
				withRowAnimation: UITableViewRowAnimationAutomatic ];
	} ];
}

//------------------------------------------------------------------------------

- (void) randomAddAction: (id) sender
{
	u_int32_t howMany = 10;
	u_int32_t count = (u_int32_t)self.data.count;
	NSArray* indexesToAdd = randomIndexes( howMany, count + howMany );
	if( count < howMany ) {
		NSMutableArray* extraToAdd = [ NSMutableArray arrayWithCapacity: howMany - count ];
		for( NSUInteger i = count; i < howMany; ++i ) {
			[ extraToAdd addObject: @(i) ];
		}
		indexesToAdd = [ indexesToAdd arrayByAddingObjectsFromArray: extraToAdd ];
	}
	
	NSMutableArray* pathsToAdd = [ NSMutableArray arrayWithCapacity: howMany ];
	for( NSNumber* indexValue in indexesToAdd ) {
		NSUInteger row = [ indexValue unsignedIntegerValue ];
		[ pathsToAdd addObject: [ NSIndexPath indexPathForRow: row inSection: 0 ] ];
	}
	
	NSMutableArray* itemsToAdd = [ NSMutableArray arrayWithCapacity: howMany ];
	for( NSUInteger i = 0; i < howMany; ++i ) {
		[ itemsToAdd addObject: @{
			AST_cell_textLabel_text : [ NSString stringWithFormat: @"%ld", i + _counter ],
		} ];
	}
	
	[ self.tableView performUpdates: ^{
		[ self insertItems: itemsToAdd atIndexPaths: pathsToAdd
				withRowAnimation: UITableViewRowAnimationAutomatic ];
	} ];
	
	_counter += howMany;
}

//------------------------------------------------------------------------------

- (void) resetAction: (id) sender
{
	[ self resetData ];
}

//------------------------------------------------------------------------------

- (void) randomMoveAction: (id) sender
{
	u_int32_t count = (u_int32_t)self.data.count;
	if( count < 2 ) {
		return;
	}
	NSArray* indexesToMove = randomIndexes( 2, count );
	NSUInteger sourceRow = [ indexesToMove[ 0 ] unsignedIntegerValue ];
	NSUInteger destRow = [ indexesToMove[ 1 ] unsignedIntegerValue ];
	NSIndexPath* sourcePath = [ NSIndexPath indexPathForRow: sourceRow inSection: 0 ];
	NSIndexPath* destPath = [ NSIndexPath indexPathForRow: destRow inSection: 0 ];
	
	[ self.tableView performUpdates: ^{
		[ self moveItemWithAnimationAtIndexPath: sourcePath toIndexPath: destPath ];
	} ];
}

//------------------------------------------------------------------------------

@end
