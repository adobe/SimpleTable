//==============================================================================
//
//  ASTPrefGroupItem.m
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

#import "ASTPrefGroupItem.h"

#import "ASTItemSubclass.h"
#import "ASTViewController.h"


//------------------------------------------------------------------------------

void* _Nullable ASTItemPrefGroupItem_prefObservationContext = &ASTItemPrefGroupItem_prefObservationContext;

//------------------------------------------------------------------------------

@implementation ASTPrefGroupItem

//------------------------------------------------------------------------------

+ (instancetype) prefGroupItemWithTitle: (NSString*) title
		key: (NSString*) key
		value: (id) value
{
	NSDictionary* dict = @{
		AST_cell_textLabel_text : title ?: [ NSNull null ],
		AST_prefKey : key ?: [ NSNull null ],
		AST_itemPrefValue : value ?: [ NSNull null ],
	};
	
	ASTPrefGroupItem* result = [ [ ASTPrefGroupItem alloc ]
			initWithDict: dict ];
	
	return result;
}

//------------------------------------------------------------------------------

- (instancetype) initWithDict: (NSDictionary*) dict
{
	NSMutableDictionary* newDict = [ dict mutableCopy ];
	
	if( newDict[ AST_cellStyle ] == nil ) {
		newDict[ AST_cellStyle ] = @(UITableViewCellStyleValue1);
	}
	if( newDict[ AST_selectable ] == nil ) {
		newDict[ AST_selectable ] = @YES;
	}
	
	self = [ super initWithDict: newDict ];
	
	if( self ) {
		_itemPrefValue = newDict[ AST_itemPrefValue ];
		_itemIsDefault = [ newDict[ AST_itemIsDefault ] boolValue ];
		self.prefKey = newDict[ AST_prefKey ];

		[ self syncCheckedStateWithPrefValue ];
	}
	
	return self;
}

//------------------------------------------------------------------------------

- (void) dealloc
{
	if( _prefKey ) {
		[ [ NSUserDefaults standardUserDefaults ] removeObserver: self
				forKeyPath: _prefKey context: ASTItemPrefGroupItem_prefObservationContext ];
	}
}

//------------------------------------------------------------------------------

- (id) resolvedPrefValue
{
// LCOV_EXCL_START
	if( _prefKey == nil ) {
		return nil;
	}
// LCOV_EXCL_STOP
	
	id prefValue = nil;
	if( _prefKey ) {
		prefValue = [ [ NSUserDefaults standardUserDefaults ]
				valueForKey: _prefKey ];
	}
	if( prefValue == nil && _itemIsDefault ) {
		prefValue = _itemPrefValue;
	}
	
	return prefValue;
}

//------------------------------------------------------------------------------

- (void) syncCheckedStateWithPrefValue
{
	id prefValue = [ self resolvedPrefValue ];
	UITableViewCellAccessoryType accessoryType = [ prefValue isEqual: _itemPrefValue ]
			? UITableViewCellAccessoryCheckmark
			: UITableViewCellAccessoryNone;
	[ self setValue: @(accessoryType) forKeyPath: AST_cell_accessoryType ];
}

//------------------------------------------------------------------------------

- (void) performSelectionAction
{
	id prefValue = [ self resolvedPrefValue ];
	if( [ prefValue isEqual: _itemPrefValue ] == NO ) {
		[ [ NSUserDefaults standardUserDefaults ] setObject: _itemPrefValue forKey: _prefKey ];
	}
	
	[ self deselectWithAnimation: YES ];
}

//------------------------------------------------------------------------------

- (void) setPrefKey: (NSString*) prefKey
{
	NSUserDefaults* prefs = [ NSUserDefaults standardUserDefaults ];
	
	if( _prefKey ) {
		[ prefs removeObserver: self forKeyPath: _prefKey ];
	}
	
	_prefKey = prefKey;
	
	if( _prefKey ) {
		[ prefs addObserver: self forKeyPath: _prefKey
				options: NSKeyValueObservingOptionInitial
				context: ASTItemPrefGroupItem_prefObservationContext ];
	}
	
	[ self syncCheckedStateWithPrefValue ];
}

//------------------------------------------------------------------------------

- (void) setItemIsDefault: (BOOL) itemIsDefault
{
	_itemIsDefault = itemIsDefault;
	[ self syncCheckedStateWithPrefValue ];
}

//------------------------------------------------------------------------------

- (void) setItemPrefValue: (id) itemPrefValue
{
	_itemPrefValue = itemPrefValue;
	[ self syncCheckedStateWithPrefValue ];
}

//------------------------------------------------------------------------------

- (void) observeValueForKeyPath: (NSString*) keyPath ofObject: (id) object
		change: (NSDictionary*) change context: (void*) context
{
	if( context == ASTItemPrefGroupItem_prefObservationContext ) {
		[ self syncCheckedStateWithPrefValue ];
		return;
	}
	
// LCOV_EXCL_START
	[ super observeValueForKeyPath: keyPath ofObject: object
			change: change context: context ];
// LCOV_EXCL_STOP
}

//------------------------------------------------------------------------------

@end
