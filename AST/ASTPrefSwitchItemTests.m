//==============================================================================
//
//  ASTPrefSwitchItemTests.m
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
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>


//------------------------------------------------------------------------------

@interface ASTPrefSwitchItemTests : XCTestCase

@end

//------------------------------------------------------------------------------

@implementation ASTPrefSwitchItemTests

//------------------------------------------------------------------------------

- (void) testProperties
{
	ASTPrefSwitchItem* item = [ ASTPrefSwitchItem item ];
	
	NSString* testValue = @"foo";
	
	item.prefKey = testValue;
	XCTAssertEqualObjects( item.prefKey, testValue );
	
	XCTAssertEqualObjects( item.prefDefaultValue, @NO );
	item.prefDefaultValue = testValue;
	XCTAssertEqualObjects( item.prefDefaultValue, testValue );
	
	XCTAssertEqualObjects( item.prefOnValue, @YES );
	item.prefOnValue = testValue;
	XCTAssertEqualObjects( item.prefOnValue, testValue );
	
	XCTAssertEqualObjects( item.prefOffValue, @NO );
	item.prefOffValue = testValue;
	XCTAssertEqualObjects( item.prefOffValue, testValue );
}

//------------------------------------------------------------------------------

- (void) testPreferenceSetup
{
	NSUserDefaults* prefs = [ NSUserDefaults standardUserDefaults ];
	NSString* prefKey = @"samplePrefKey";
	
	// Test that the default value is NO
	{
		[ prefs removeObjectForKey: prefKey ];
		
		ASTItem* item = [ ASTItem itemWithDict: @{
			AST_itemClass : @"ASTPrefSwitchItem",
			AST_prefKey : prefKey,
		} ];
		
		UISwitch* prefSwitch = (UISwitch*)item.cell.accessoryView;
		XCTAssertEqual( prefSwitch.on, NO );
	}
	
	// Test that the pref value is the initial switch value
	{
		[ prefs setObject: @YES forKey: prefKey ];
		
		ASTItem* item = [ ASTItem itemWithDict: @{
			AST_itemClass : @"ASTPrefSwitchItem",
			AST_prefKey : prefKey,
		} ];
		
		UISwitch* prefSwitch = (UISwitch*)item.cell.accessoryView;
		XCTAssertEqual( prefSwitch.on, YES );
	}

	// Test custom on value
	{
		NSString* onValue = @"foo";
		[ prefs setObject: onValue forKey: prefKey ];
		
		ASTItem* item = [ ASTItem itemWithDict: @{
			AST_itemClass : @"ASTPrefSwitchItem",
			AST_prefKey : prefKey,
			AST_prefOnValue : onValue,
		} ];
		
		UISwitch* prefSwitch = (UISwitch*)item.cell.accessoryView;
		XCTAssertEqual( prefSwitch.on, YES );
	}
	
	// Test custom off value
	{
		NSString* offValue = @"foo";
		[ prefs setObject: offValue forKey: prefKey ];
		
		ASTItem* item = [ ASTItem itemWithDict: @{
			AST_itemClass : @"ASTPrefSwitchItem",
			AST_prefKey : prefKey,
			AST_prefOffValue : offValue,
		} ];
		
		UISwitch* prefSwitch = (UISwitch*)item.cell.accessoryView;
		XCTAssertEqual( prefSwitch.on, NO );
	}
}

//------------------------------------------------------------------------------

- (void) testSwitchChangingPrefValue
{
	NSUserDefaults* prefs = [ NSUserDefaults standardUserDefaults ];
	NSString* prefKey = @"samplePrefKey";
	NSString* onValue = @"foo";
	NSString* offValue = @"bar";
	
	[ prefs removeObjectForKey: prefKey ];
		
	ASTPrefSwitchItem* item = [ ASTPrefSwitchItem itemWithDict: @{
		AST_prefKey : prefKey,
		AST_prefOnValue : onValue,
		AST_prefOffValue : offValue,
	} ];
	UISwitch* prefSwitch = (UISwitch*)item.cell.accessoryView;
	
	// Test switch changes pref to on value
	{
		prefSwitch.on = YES;
		[ prefSwitch sendActionsForControlEvents: UIControlEventValueChanged ];
		
		XCTAssertEqualObjects( [ prefs objectForKey: prefKey ], onValue );
	}
	
	// Test switch changes pref to off value
	{
		prefSwitch.on = NO;
		[ prefSwitch sendActionsForControlEvents: UIControlEventValueChanged ];
		
		XCTAssertEqualObjects( [ prefs objectForKey: prefKey ], offValue );
	}
}

//------------------------------------------------------------------------------

- (void) testPrefsChangeSwitchValue
{
	NSUserDefaults* prefs = [ NSUserDefaults standardUserDefaults ];
	NSString* prefKey = @"samplePrefKey";
	NSString* onValue = @"foo";
	NSString* offValue = @"bar";
	
	[ prefs removeObjectForKey: prefKey ];
	[ prefs setObject: onValue forKey: prefKey ];
		
	ASTPrefSwitchItem* item = [ ASTPrefSwitchItem itemWithDict: @{
		AST_prefKey : prefKey,
		AST_prefOnValue : onValue,
		AST_prefOffValue : offValue,
	} ];
	UISwitch* prefSwitch = (UISwitch*)item.cell.accessoryView;
	
	// Test initial value
	XCTAssertEqual( prefSwitch.on, YES );

	// Test pref change is detected
	[ prefs setObject: offValue forKey: prefKey ];
	XCTAssertEqual( prefSwitch.on, NO );
	
	// Test change to pref key
	NSString* newPrefKey = @"yetAnotherPrefKey";
	[ prefs setObject: onValue forKey: newPrefKey ];
	item.prefKey = newPrefKey;
	XCTAssertEqual( prefSwitch.on, YES );
}

//------------------------------------------------------------------------------

@end
