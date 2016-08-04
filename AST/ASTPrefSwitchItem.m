//==============================================================================
//
//  ASTPrefSwitchItem.m
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

#import "ASTPrefSwitchItem.h"

#import "ASTItemSubclass.h"

#import <Foundation/NSException.h>


//------------------------------------------------------------------------------

void* ASTItemPrefSwitch_prefObservationContext = &ASTItemPrefSwitch_prefObservationContext;

//------------------------------------------------------------------------------

@interface ASTPrefSwitchItem()

@end

//------------------------------------------------------------------------------

@implementation ASTPrefSwitchItem

//------------------------------------------------------------------------------

- (void) dealloc
{
	if( _prefKey ) {
		[ [ NSUserDefaults standardUserDefaults ] removeObserver: self
				forKeyPath: _prefKey context: ASTItemPrefSwitch_prefObservationContext ];
	}
}

//------------------------------------------------------------------------------

- (instancetype) initWithDict: (NSDictionary*) initialDict
{
	NSMutableDictionary* dict = [ initialDict mutableCopy ];
	dict[ AST_switchActionKey ] = NSStringFromSelector( @selector(prefSwitchValueChanged:) );
	dict[ AST_switchTargetKey ] = self;
	
	self = [ super initWithDict: dict ];
	if( self ) {
		_prefOnValue = dict[ AST_prefOnValue ] ?: @YES;
		_prefOffValue = dict[ AST_prefOffValue ] ?: @NO;
		_prefDefaultValue = dict[ AST_prefDefaultValue ] ?: _prefOffValue;
		// Using the setter for the prefKey has the side effect of updating the
		// switch state.
		self.prefKey = dict[ AST_prefKey ];
	}
	return self;
}

//------------------------------------------------------------------------------

- (void) updateSwitchState
{
	id prefValue = nil;
	if( _prefKey ) {
		prefValue = [ [ NSUserDefaults standardUserDefaults ]
				valueForKey: _prefKey ] ?: _prefDefaultValue;
	}
	BOOL newSwitchState = [ _prefOnValue isEqual: prefValue ];
	[ self setValue: @(newSwitchState) forKeyPath: AST_cell_switch_on ];
}

//------------------------------------------------------------------------------

- (void) prefSwitchValueChanged: (id) sender
{
	ASTSwitchItemCell* switchCell = (ASTSwitchItemCell*)self.cell;
	id newPrefValue = switchCell.itemSwitch.on ? _prefOnValue : _prefOffValue;
	[ [ NSUserDefaults standardUserDefaults ] setValue: newPrefValue
			forKey: _prefKey ];
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
				context: ASTItemPrefSwitch_prefObservationContext ];
	}
	
	[ self updateSwitchState ];
}

//------------------------------------------------------------------------------

- (void) setPrefOnValue: (id) prefOnValue
{
	_prefOnValue = prefOnValue;
	[ self updateSwitchState ];
}

//------------------------------------------------------------------------------

- (void) setPrefOffValue: (id) prefOffValue
{
	_prefOffValue = prefOffValue;
	[ self updateSwitchState ];
}

//------------------------------------------------------------------------------

- (void) observeValueForKeyPath: (NSString*) keyPath ofObject: (id) object
		change: (NSDictionary*) change context: (void*) context
{
	if( context == ASTItemPrefSwitch_prefObservationContext ) {
		[ self updateSwitchState ];
		return;
	}
	
// LCOV_EXCL_START
	[ super observeValueForKeyPath: keyPath ofObject: object
			change: change context: context ];
// LCOV_EXCL_STOP
}

//------------------------------------------------------------------------------

@end
