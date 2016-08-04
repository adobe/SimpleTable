//==============================================================================
//
//  ASTSwitchItem.m
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

#import "ASTSwitchItem.h"

#import "ASTItemSubclass.h"


//------------------------------------------------------------------------------

@implementation ASTSwitchItem

//------------------------------------------------------------------------------

- (instancetype) initWithDict: (NSDictionary*) dict
{
	self = [ super initWithDict: dict ];
	if( self ) {
		self.cellClass = [ ASTSwitchItemCell class ];
		
		[ self setValue: dict[ AST_switchActionKey ] forKey: AST_switchActionKey ];
		self.switchTarget = dict[ AST_switchTargetKey ];
	}
	return self;
}

//------------------------------------------------------------------------------

- (void) loadCell
{
	[ super loadCell ];
	
	if( self.cellLoaded ) {
		ASTSwitchItemCell* switchCell = (ASTSwitchItemCell*)self.cell;
		[ switchCell.itemSwitch addTarget: self
				action: @selector(switchValueChangedAction:)
				forControlEvents: UIControlEventValueChanged ];
		// Note that we never remove the target/action for the slider. Since we
		// own the slider and the control holds the target weakly and controls
		// auto release and/or don't care if the target/action is removed it
		// would seem to be unnecessary.
	}
}

//------------------------------------------------------------------------------

- (void) switchValueChangedAction: (id) sender
{
	ASTSwitchItemCell* switchCell = (ASTSwitchItemCell*)self.cell;
	[ self setCellPropertiesValue: @(switchCell.itemSwitch.on) forKeyPath: AST_cell_switch_on ];
	
	if( _switchAction ) {
		[ self sendAction: _switchAction to: _switchTarget ];
	}
}

//------------------------------------------------------------------------------

- (void) setValue: (id) value forKey: (NSString*) key
{
	if( [ key isEqualToString: AST_switchActionKey ] ) {
		NSParameterAssert( value == nil || [ value isKindOfClass: [ NSString class ] ] );
		if( value ) {
			_switchAction = NSSelectorFromString( value );
		} else {
			_switchAction = nil;
		}
	} else {
// LCOV_EXCL_START
		[ super setValue: value forKey: key ];
// LCOV_EXCL_STOP
	}
}

//------------------------------------------------------------------------------

@end

//------------------------------------------------------------------------------

@interface ASTSwitchItemCell() {
	UISwitch* _itemSwitch;
}

@end

//------------------------------------------------------------------------------

@implementation ASTSwitchItemCell

//------------------------------------------------------------------------------

- (instancetype) initWithStyle: (UITableViewCellStyle) style
		reuseIdentifier: (NSString*) reuseIdentifier
{
	self = [ super initWithStyle: style reuseIdentifier: reuseIdentifier ];
	if( self ) {
		// Force the slider to be created.
		[ self itemSwitch ];
	}
	return self;
}

//------------------------------------------------------------------------------

- (UISwitch*) itemSwitch
{
	if( _itemSwitch == nil ) {
		_itemSwitch = [ [ UISwitch alloc ] init ];
		self.accessoryView = _itemSwitch;
	}
	
	return _itemSwitch;
}

//------------------------------------------------------------------------------

@end

//------------------------------------------------------------------------------
