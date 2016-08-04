//==============================================================================
//
//  ASTMultiValuePrefItem.m
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

#import "ASTMultiValuePrefItem.h"

#import "ASTItemSubclass.h"
#import "ASTPrefGroupItem.h"
#import "ASTViewController.h"

#import <UIKit/UIKit.h>


//------------------------------------------------------------------------------

const void* ASTMultiValuePrefItem_prefObservationContext;

//------------------------------------------------------------------------------

@interface ASTMultiValuePrefItem() <UIActionSheetDelegate>

@end

//------------------------------------------------------------------------------

@implementation ASTMultiValuePrefItem

//------------------------------------------------------------------------------

- (instancetype) initWithDict: (NSDictionary*) dict
{
	self = [ super initWithDict: dict ];
	if( self ) {
		_prefDefaultValue = dict[ AST_defaultValue ];
		self.values = dict[ AST_values ];
		self.prefKey = dict[ AST_prefKey ];
		self.presentation = [ dict[ AST_presentation ] integerValue ];

		self.selectable = YES;
		
		if( dict[ AST_cellStyle ] == nil ) {
			self.cellStyle = UITableViewCellStyleValue1;
		}
		[ self setValue: @(UITableViewCellAccessoryDisclosureIndicator)
				forKeyPath: AST_cell_accessoryType ];
	}
	return self;
}

//------------------------------------------------------------------------------

- (void) dealloc
{
	if( _prefKey ) {
		[ [ NSUserDefaults standardUserDefaults ] removeObserver: self
				forKeyPath: _prefKey context: &ASTMultiValuePrefItem_prefObservationContext ];
	}
}

//------------------------------------------------------------------------------

- (id) resolvedPrefValue
{
	id prefValue = nil;
	if( _prefKey ) {
		prefValue = [ [ NSUserDefaults standardUserDefaults ]
			valueForKey: _prefKey ];
	}
	if( prefValue == nil ) {
		prefValue = _prefDefaultValue;
	}
	
	return prefValue;
}

//------------------------------------------------------------------------------

- (void) setPrefKey: (NSString*) prefKey
{
	NSUserDefaults* prefs = [ NSUserDefaults standardUserDefaults ];
	
	if( _prefKey ) {
		[ prefs removeObserver: self forKeyPath: _prefKey ];
	}
	
	_prefKey = prefKey;
	self.value = [ self resolvedPrefValue ];
	
	if( _prefKey ) {
		[ prefs addObserver: self forKeyPath: _prefKey
				options: NSKeyValueObservingOptionInitial
				context: &ASTMultiValuePrefItem_prefObservationContext ];
	}
}

//------------------------------------------------------------------------------

- (void) selectedValue: (id) value
{
	[ super selectedValue: value ];
	[ [ NSUserDefaults standardUserDefaults ] setObject: value forKey: _prefKey ];
}

//------------------------------------------------------------------------------

- (void) observeValueForKeyPath: (NSString*) keyPath ofObject: (id) object
		change: (NSDictionary*) change context: (void*) context
{
	if( context == &ASTMultiValuePrefItem_prefObservationContext ) {
		self.value = [ self resolvedPrefValue ];
		return;
	}
	
// LCOV_EXCL_START
	[ super observeValueForKeyPath: keyPath ofObject: object
			change: change context: context ];
// LCOV_EXCL_STOP
}

//------------------------------------------------------------------------------

@end
