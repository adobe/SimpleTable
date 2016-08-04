//==============================================================================
//
//  ASTSectionTests.m
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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ASTItem.h"
#import "ASTSection.h"
#import "ASTViewController.h"


//------------------------------------------------------------------------------

@interface ASTSectionTests : XCTestCase

@end

//------------------------------------------------------------------------------

@implementation ASTSectionTests

//------------------------------------------------------------------------------

- (void) testSection
{
	ASTSection* section = [ ASTSection sectionWithItems: @[
		[ ASTItem itemWithText: @"1" ],
		[ ASTItem itemWithText: @"2" ],
	] ];

	XCTAssertEqual( section.numberOfItems, 2 );
}

//------------------------------------------------------------------------------

- (void) testSectionWithDict
{
	{
		ASTSection* section = [ ASTSection sectionWithDict: @{
			AST_headerText : @"Foo",
			AST_items : @[
				[ ASTItem itemWithText: @"1" ],
				[ ASTItem itemWithText: @"2" ],
			],
			AST_footerText : @"Bar",
		} ];
		
		XCTAssertEqualObjects( section.headerText, @"Foo" );
		XCTAssertEqual( section.numberOfItems, 2 );
		XCTAssertEqualObjects( section.footerText, @"Bar" );
	}
	
	// Test that items can be plain dictionaries.
	{
		ASTSection* section = [ ASTSection sectionWithDict: @{
			AST_items : @[
				@{
					AST_cell_textLabel_text : @"1"
				},
				@{
					AST_cell_textLabel_text : @"2"
				},
			],
		} ];
		
		XCTAssertEqual( section.numberOfItems, 2 );
		XCTAssertEqual( [ section.items[0] class ], [ ASTItem class ] );
	}
	
	// Test that invalid items throw an exception.
	ASTSection* section = nil;
	NSArray* items = @[
		@{
			AST_cell_textLabel_text : @"1",
		},
		@"Not an item",
	];
	XCTAssertThrows( section = [ ASTSection sectionWithDict: @{
		AST_items : items
	} ] );
}

//------------------------------------------------------------------------------

- (void) testSectionWithHeaderTextItems
{
	ASTSection* section = [ ASTSection sectionWithHeaderText: @"Foo"
			items: @[
		[ ASTItem itemWithText: @"1" ],
		[ ASTItem itemWithText: @"2" ],
	] ];
	
	XCTAssertEqualObjects( section.headerText, @"Foo" );
	XCTAssertEqual( section.numberOfItems, 2 );
}

//------------------------------------------------------------------------------

- (void) testSectionWithDictWithNulls
{
	ASTSection* section = [ ASTSection sectionWithDict: @{
		AST_items : @[
			[ ASTItem itemWithText: @"1" ],
			[ NSNull null ],
			[ ASTItem itemWithText: @"2" ],
		],
	} ];
	
	XCTAssertEqual( section.numberOfItems, 2 );
}

//------------------------------------------------------------------------------

- (void) testItemWithIdentifier
{
	ASTItem* item = [ ASTItem itemWithDict: @{
		AST_id : @"target_item",
	} ];
	
	ASTSection* section = [ ASTSection sectionWithDict: @{
		AST_items : @[
			@{
				AST_id : @"first_item",
			},
			@{
				// No id for this item deliberately
			},
			item,
		],
	} ];
	
	XCTAssertEqualObjects( [ section itemWithIdentifier: @"target_item" ], item );
}

//------------------------------------------------------------------------------

- (void) testItemWithRepresentedObject
{
	ASTItem* item = [ ASTItem itemWithDict: @{
		AST_representedObject : @"target_item",
	} ];
	
	ASTSection* section = [ ASTSection sectionWithDict: @{
		AST_items : @[
			@{
				AST_representedObject : @"first_item",
			},
			@{
				// No representedObject for this item deliberately
			},
			item,
		],
	} ];
	
	XCTAssertEqualObjects( [ section itemWithRepresentedObject: @"target_item" ], item );
}

//------------------------------------------------------------------------------

- (void) testItemAtIndex
{
	ASTSection* section = [ ASTSection sectionWithDict: @{
		AST_items : @[
			[ ASTItem itemWithText: @"1" ],
			[ ASTItem itemWithText: @"2" ],
		],
	} ];
	
	XCTAssertEqualObjects( [ section itemAtIndex: 0 ].cell.textLabel.text, @"1" );
	XCTAssertEqualObjects( [ section itemAtIndex: 1 ].cell.textLabel.text, @"2" );
	XCTAssertNil( [ section itemAtIndex: 2 ] );
}

//------------------------------------------------------------------------------

- (void) testRemoveFromContainerWithRowAnimation
{
	ASTSection* section = [ ASTSection sectionWithDict: @{
	} ];
	ASTViewController* vc = [ [ ASTViewController alloc ]
			initWithStyle: UITableViewStyleGrouped ];
	vc.data = @[ section ];
	
	XCTAssertEqualObjects( section.tableViewController, vc );
	
	[ section removeFromContainerWithRowAnimation: UITableViewRowAnimationNone ];
	
	XCTAssertNil( section.tableViewController );
}

//------------------------------------------------------------------------------

- (void) testInsertItemsAtIndexesWithRowAnimation
{
	ASTSection* section = [ ASTSection section ];
	
	[ section insertItems: @[ [ ASTItem itemWithText: @"1" ] ] atIndexes: @[ @0 ]
			withRowAnimation: UITableViewRowAnimationAutomatic ];
	XCTAssertEqualObjects( [ section itemAtIndex: 0 ].cell.textLabel.text, @"1" );
	
	[ section insertItems: @[ [ ASTItem itemWithText: @"2" ] ] atIndexes: @[ @1 ]
			withRowAnimation: UITableViewRowAnimationAutomatic ];
	XCTAssertEqualObjects( [ section itemAtIndex: 1 ].cell.textLabel.text, @"2" );
}

//------------------------------------------------------------------------------

- (void) testDeleteItemsAtIndexesWithRowAnimation
{
	ASTSection* section = [ ASTSection sectionWithDict: @{
		AST_items : @[
			[ ASTItem itemWithText: @"1" ],
			[ ASTItem itemWithText: @"2" ],
		],
	} ];
	
	[ section removeItemsAtIndexes: @[ @0 ]
			withRowAnimation: UITableViewRowAnimationAutomatic ];
	
	XCTAssertEqualObjects( [ section itemAtIndex: 0 ].cell.textLabel.text, @"2" );
}

//------------------------------------------------------------------------------

- (void) testMoveItemAtIndexWithRowAnimation
{
	ASTSection* section = [ ASTSection sectionWithDict: @{
		AST_items : @[
			[ ASTItem itemWithText: @"1" ],
			[ ASTItem itemWithText: @"2" ],
		],
	} ];
	
	[ section moveItemAtIndex: 0 toIndex: 1 ];
	
	XCTAssertEqualObjects( [ section itemAtIndex: 1 ].cell.textLabel.text, @"1" );
}

//------------------------------------------------------------------------------

- (void) testItemsProperty
{
	ASTSection* section = [ ASTSection sectionWithDict: @{
		AST_items : @[
			[ ASTItem itemWithText: @"2" ],
		],
	} ];
	
	XCTAssertEqual( section.numberOfItems, 1 );
	
	section.items = @[
		[ ASTItem itemWithText: @"Foo" ],
		[ ASTItem itemWithText: @"Bar" ],
	];

	XCTAssertEqual( section.numberOfItems, 2 );
}

//------------------------------------------------------------------------------

- (void) testIdentifierProperty
{
	ASTSection* section = [ ASTSection sectionWithDict: @{
		AST_id : @"foo",
	} ];
	XCTAssertEqualObjects( section.identifier, @"foo" );
}

//------------------------------------------------------------------------------

- (void) testTableViewControllerProperty
{
	ASTSection* section = [ ASTSection sectionWithDict: @{
	} ];
	ASTViewController* vc = [ [ ASTViewController alloc ]
			initWithStyle: UITableViewStyleGrouped ];
	vc.data = @[ section ];
	
	XCTAssertEqualObjects( section.tableViewController, vc );
}

//------------------------------------------------------------------------------

- (void) testIndexProperty
{
	ASTSection* section = [ ASTSection sectionWithDict: @{
		AST_id : @"foo",
	} ];

	XCTAssertEqual( section.index, NSNotFound );

	ASTViewController* vc = [ [ ASTViewController alloc ]
			initWithStyle: UITableViewStyleGrouped ];
	vc.data = @[ section ];
	
	XCTAssertEqual( section.index, 0 );
}

//------------------------------------------------------------------------------

@end
