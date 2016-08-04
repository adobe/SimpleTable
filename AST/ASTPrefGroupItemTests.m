//==============================================================================
//
//  ASTPrefGroupItemTests.m
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
#import "ASTSection.h"
#import "ASTViewController.h"

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>


//------------------------------------------------------------------------------

NSString* const testPrefKey = @"testGroupPrefKey";

//------------------------------------------------------------------------------

@interface ASTPrefGroupItemTests : XCTestCase

@end

//------------------------------------------------------------------------------

@implementation ASTPrefGroupItemTests

//------------------------------------------------------------------------------

- (void) testPrefGroupItemWithTitleKeyValue
{
	NSString* testValue = @"foo";

	ASTPrefGroupItem* item = [ ASTPrefGroupItem
			prefGroupItemWithTitle: testValue key: testValue value: testValue ];
	
	XCTAssertEqualObjects( item.cell.textLabel.text, testValue );
	XCTAssertEqualObjects( item.prefKey, testValue );
	XCTAssertEqualObjects( item.itemPrefValue, testValue );
}

//------------------------------------------------------------------------------

- (void) testInit
{
	ASTPrefGroupItem* item =
			[ [ ASTPrefGroupItem alloc ] init ];
	XCTAssertNotNil( item );
}

//------------------------------------------------------------------------------

- (void) testProperties
{
	ASTPrefGroupItem* item = [ ASTPrefGroupItem item ];
	NSString* testValue = @"foo";
	item.prefKey = testValue;
	XCTAssertEqualObjects( item.prefKey, testValue );

	item.itemIsDefault = YES;
	XCTAssertEqual( item.itemIsDefault, YES );

	item.itemPrefValue = testValue;
	XCTAssertEqualObjects( item.itemPrefValue, testValue );
	
	item.prefKey = nil;
	XCTAssert( item.prefKey == nil );
}

//------------------------------------------------------------------------------

- (ASTSection*) buildTestSection
{
	return [ ASTSection sectionWithItems: @[
		@{
			AST_itemClass : @"ASTPrefGroupItem",
			AST_cell_textLabel_text : @"Fee",
			AST_prefKey : testPrefKey,
			AST_itemPrefValue : @"fee",
			AST_itemIsDefault : @YES,
		},
		@{
			AST_itemClass : @"ASTPrefGroupItem",
			AST_cell_textLabel_text : @"Fi",
			AST_prefKey : testPrefKey,
			AST_itemPrefValue : @"fi",
		},
		@{
			AST_itemClass : @"ASTPrefGroupItem",
			AST_cell_textLabel_text : @"Fo",
			AST_itemPrefValue : @"fo",
			AST_prefKey : testPrefKey,
		},
		@{
			AST_itemClass : @"ASTPrefGroupItem",
			AST_cell_textLabel_text : @"Fum",
			AST_itemPrefValue : @"fum",
			AST_prefKey : testPrefKey,
		},
	] ];
	
}

//------------------------------------------------------------------------------

- (void) testPreferenceSetup
{
	NSUserDefaults* prefs = [ NSUserDefaults standardUserDefaults ];
	
	// Test that the default item is checked
	{
		[ prefs removeObjectForKey: testPrefKey ];
		
		ASTSection* section = [ self buildTestSection ];
		ASTItem* firstItem = [ section itemAtIndex: 0 ];
		
		XCTAssertEqual( firstItem.cell.accessoryType, UITableViewCellAccessoryCheckmark );
	}
	
	// Test that a preset pref value checks the right cell
	{
		[ prefs setObject: @"fo" forKey: testPrefKey ];
		
		ASTSection* section = [ self buildTestSection ];
		ASTItem* testItem = section.items[ 2 ];
		
		XCTAssertEqual( testItem.cell.accessoryType, UITableViewCellAccessoryCheckmark );
	}
}

//------------------------------------------------------------------------------

- (void) testSelection
{
	NSUserDefaults* prefs = [ NSUserDefaults standardUserDefaults ];
	[ prefs removeObjectForKey: testPrefKey ];
	
	ASTViewController* vc = [ [ ASTViewController alloc ] initWithStyle: UITableViewStyleGrouped ];
	vc.data = @[
		[ self buildTestSection ],
	];
	UITableView* tableView = vc.tableView;
	
	NSIndexPath* indexPath = [ NSIndexPath indexPathForItem: 2 inSection: 0 ];
	[ tableView selectRowAtIndexPath: indexPath animated: YES
			scrollPosition: UITableViewScrollPositionNone ];
	[ tableView.delegate tableView: tableView didSelectRowAtIndexPath: indexPath ];
	
	id prefValue = [ prefs objectForKey: testPrefKey ];
	XCTAssertEqualObjects( prefValue, @"fo" );
}

//------------------------------------------------------------------------------

@end
