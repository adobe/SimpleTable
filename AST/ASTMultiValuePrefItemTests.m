//==============================================================================
//
//  ASTMultiValuePrefItemTests.m
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

#import "ASTPrefGroupItem.h"
#import "ASTViewController.h"

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>


//------------------------------------------------------------------------------

@interface ASTMultiValuePrefItemTests : XCTestCase

@end

//------------------------------------------------------------------------------

@implementation ASTMultiValuePrefItemTests

//------------------------------------------------------------------------------

- (NSArray*) buildTestValues
{
	return @[
		@{
			AST_title : @"Foo",
			AST_value : @"foo",
		},
		@{
			AST_title : @"Bar",
			AST_value : @"bar",
		},
		@{
			AST_title : @"Baz",
			AST_value : @"baz",
		},
	];
}

//------------------------------------------------------------------------------

- (void) testProperties
{
	ASTMultiValuePrefItem* item = [ ASTMultiValuePrefItem item ];
	
	NSString* testValue = @"foo";
	NSArray* testValues = [ self buildTestValues ];
	
	item.prefKey = testValue;
	XCTAssertEqualObjects( item.prefKey, testValue );
	
	XCTAssertNil( item.prefDefaultValue );
	item.prefDefaultValue = testValue;
	XCTAssertEqualObjects( item.prefDefaultValue, testValue );
	
	XCTAssertNil( item.values );
	item.values = testValues;
	XCTAssertEqualObjects( item.values, testValues );
	
	XCTAssertEqual( item.presentation, ASTItemPresentation_default );
	item.presentation = ASTItemPresentation_modal;
	XCTAssertEqual( item.presentation, ASTItemPresentation_modal );
}

//------------------------------------------------------------------------------

- (void) testDictionaryConstruction
{
	NSString* prefKey = @"testprefkey";
	NSUserDefaults* prefs = [ NSUserDefaults standardUserDefaults ];
	[ prefs removeObjectForKey: prefKey ];
	
	NSArray* testValues = [ self buildTestValues ];
	NSString* defaultValue = @"bar";
	ASTMultiValuePrefItem* item = [ ASTMultiValuePrefItem
			itemWithDict: @{
		AST_prefKey : prefKey,
		AST_values : testValues,
		AST_defaultValue : defaultValue,
		AST_presentation : @(ASTItemPresentation_modal),
	} ];
	
	XCTAssertEqualObjects( item.cell.detailTextLabel.text, @"Bar" );
	XCTAssertEqualObjects( item.prefKey, prefKey );
	XCTAssertEqualObjects( item.values, testValues );
	XCTAssertEqualObjects( item.prefDefaultValue, defaultValue );
	XCTAssertEqual( item.presentation, ASTItemPresentation_modal );
}

//------------------------------------------------------------------------------

- (void) testSelectionControllerConstruction
{
	NSString* prefKey = @"testprefkey";
	NSUserDefaults* prefs = [ NSUserDefaults standardUserDefaults ];
	[ prefs removeObjectForKey: prefKey ];
	
	NSArray* testValues = [ self buildTestValues ];
	ASTMultiValuePrefItem* item = [ ASTMultiValuePrefItem
			itemWithDict: @{
		AST_prefKey : prefKey,
		AST_values : testValues,
		AST_presentation : @(ASTItemPresentation_modal),
	} ];
	
	ASTViewController* selectionController = [ item buildSelectionController: nil ];
	ASTSection* section = [ selectionController sectionAtIndex: 0 ];
	XCTAssertEqual( section.numberOfItems, 3 );
	ASTPrefGroupItem* secondItem = (ASTPrefGroupItem*)[ section itemAtIndex: 1 ];
	XCTAssertEqualObjects( secondItem.cell.textLabel.text, @"Bar" );
	XCTAssertEqualObjects( secondItem.representedObject, @"bar" );
}

//------------------------------------------------------------------------------

- (void) testSettingPrefKeyTwice
{
	NSString* prefKey = @"testprefkey";
	NSString* anotherPrefKey = @"anotherprefkey";
	NSUserDefaults* prefs = [ NSUserDefaults standardUserDefaults ];
	[ prefs setObject: @"bar" forKey: prefKey ];
	[ prefs setObject: @"foo" forKey: anotherPrefKey ];
	
	NSArray* testValues = [ self buildTestValues ];
	ASTMultiValuePrefItem* item = [ ASTMultiValuePrefItem
			itemWithDict: @{
		AST_prefKey : prefKey,
		AST_values : testValues,
		AST_presentation : @(ASTItemPresentation_modal),
	} ];
	
	XCTAssertEqualObjects( item.cell.detailTextLabel.text, @"Bar" );
	item.prefKey = anotherPrefKey;
	XCTAssertEqualObjects( item.cell.detailTextLabel.text, @"Foo" );
}

//------------------------------------------------------------------------------

@end
