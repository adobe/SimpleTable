//==============================================================================
//
//  ASTSwitchItemTests.m
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

#import <XCTest/XCTest.h>


//------------------------------------------------------------------------------

@interface SwitchItemTestTarget : NSObject

@property (nonatomic) BOOL actionSent;

- (void) switchTestAction: (id) sender;

@end

//------------------------------------------------------------------------------

@interface ASTSwitchItemTests : XCTestCase

@end

//------------------------------------------------------------------------------

@implementation ASTSwitchItemTests

//------------------------------------------------------------------------------

- (void) testDictionarySwitchActionAndTargetKeys
{
	ASTSwitchItem* item = [ ASTSwitchItem itemWithDict: @{
		AST_switchActionKey : @"testDictionarySwitchActionKey",
		AST_switchTargetKey : self,
	} ];
	
	XCTAssertEqualObjects( NSStringFromSelector( item.switchAction ), @"testDictionarySwitchActionKey" );
	XCTAssertEqual( item.switchTarget, self );
}

//------------------------------------------------------------------------------

- (void) testDictionaryOnKey
{
	ASTSwitchItem* item = [ ASTSwitchItem itemWithDict: @{
		AST_cell_switch_on : @YES,
	} ];
	
	ASTSwitchItemCell* cell = (ASTSwitchItemCell*)item.cell;
	XCTAssertTrue( cell.itemSwitch.on );
}

//------------------------------------------------------------------------------

- (void) testDictionaryOnTintColorKey
{
	UIColor* testColor = [ UIColor redColor ];
	ASTSwitchItem* item = [ ASTSwitchItem itemWithDict: @{
		AST_cell_switch_onTintColor : testColor,
	} ];
	
	ASTSwitchItemCell* cell = (ASTSwitchItemCell*)item.cell;
	XCTAssertEqual( cell.itemSwitch.onTintColor, testColor );
}

//------------------------------------------------------------------------------

- (void) testDictionaryTintColorKey
{
	UIColor* testColor = [ UIColor redColor ];
	ASTSwitchItem* item = [ ASTSwitchItem itemWithDict: @{
		AST_cell_switch_tintColor : testColor,
	} ];
	
	ASTSwitchItemCell* cell = (ASTSwitchItemCell*)item.cell;
	XCTAssertEqual( cell.itemSwitch.tintColor, testColor );
}

//------------------------------------------------------------------------------

- (void) testDictionaryThumbTintColorKey
{
	UIColor* testColor = [ UIColor redColor ];
	ASTSwitchItem* item = [ ASTSwitchItem itemWithDict: @{
		AST_cell_switch_thumbTintColor : testColor,
	} ];
	
	ASTSwitchItemCell* cell = (ASTSwitchItemCell*)item.cell;
	XCTAssertEqual( cell.itemSwitch.thumbTintColor, testColor );
}

//------------------------------------------------------------------------------

- (void) testSwitchItemActionAndTargetProperties
{
	SwitchItemTestTarget* target = [ [ SwitchItemTestTarget alloc ] init ];
	ASTSwitchItem* item = [ ASTSwitchItem item ];
	item.switchAction = @selector(switchTestAction:);
	item.switchTarget = target;
	
	XCTAssertEqualObjects( NSStringFromSelector( item.switchAction ), @"switchTestAction:" );
	XCTAssertEqual( item.switchTarget, target );
	
	ASTSwitchItemCell* cell = (ASTSwitchItemCell*)item.cell;
	
	cell.itemSwitch.on = YES;
	[ cell.itemSwitch sendActionsForControlEvents: UIControlEventValueChanged ];
	
	XCTAssertTrue( target.actionSent );
	XCTAssertTrue( [ [ item valueForKeyPath: AST_cell_switch_on ] boolValue ] );
	
	target.actionSent = NO;
	item.switchAction = nil;
	
	[ cell.itemSwitch sendActionsForControlEvents: UIControlEventValueChanged ];
	
	XCTAssertFalse( target.actionSent );
}

//------------------------------------------------------------------------------

- (void) testSwitchItemActionPropertiesViaKey
{
	ASTSwitchItem* item = [ ASTSwitchItem item ];
	
	[ item setValue: @"switchTestAction:" forKey: @"switchAction" ];
	XCTAssertEqualObjects( NSStringFromSelector( item.switchAction ), @"switchTestAction:" );

	[ item setValue: nil forKey: @"switchAction" ];
	XCTAssertEqual( item.switchAction, nil );
}

//------------------------------------------------------------------------------

@end

//------------------------------------------------------------------------------

@implementation SwitchItemTestTarget

//------------------------------------------------------------------------------

- (void) switchTestAction: (id) sender
{
	self.actionSent = YES;
}

//------------------------------------------------------------------------------

@end
