//==============================================================================
//
//  ASTViewControllerTests.m
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

#import "ASTViewController.h"

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>


//------------------------------------------------------------------------------

@interface ASTViewControllerTests : XCTestCase

@end

//------------------------------------------------------------------------------

@implementation ASTViewControllerTests

//------------------------------------------------------------------------------

- (void) testDefaultTableStyle
{
	ASTViewController* vc =
			[ [ ASTViewController alloc ] init ];
	
	XCTAssertEqual( vc.tableView.style, UITableViewStyleGrouped );
}

//------------------------------------------------------------------------------

- (void) testDataImmutability
{
	NSArray* someData = @[
		[ ASTSection sectionWithItems: @[
			[ ASTItem itemWithText: @"1" ],
			[ ASTItem itemWithText: @"2" ],
		] ],
		[ ASTSection sectionWithItems: @[
			[ ASTItem itemWithText: @"1" ],
			[ ASTItem itemWithText: @"2" ],
		] ],
	];
	ASTViewController* vc = [ [ ASTViewController alloc ]
			initWithStyle: UITableViewStyleGrouped ];
	vc.data = someData;
	
	XCTAssert( vc.data != someData );
	XCTAssertEqualObjects( vc.data, someData );
	
}

//------------------------------------------------------------------------------

- (void) testDataProperty
{
	// Grouped
	{
		ASTItem* item = [ ASTItem itemWithDict: @{
			AST_id : @"foo",
		} ];
		NSArray* originalData = @[
			[ ASTSection sectionWithItems: @[
				item,
			] ],
		];
		ASTViewController* vc = [ [ ASTViewController alloc ]
				initWithStyle: UITableViewStyleGrouped ];
		vc.data = originalData;

		XCTAssertEqualObjects( item.tableViewController, vc );
		
		vc.data = @[
			[ ASTSection sectionWithItems: @[
				[ ASTItem itemWithText: @"1" ],
				[ ASTItem itemWithText: @"2" ],
			] ],
		];
		
		XCTAssertNil( item.tableViewController );
	}
	// Plain
	{
		ASTItem* item = [ ASTItem itemWithDict: @{
			AST_id : @"foo",
		} ];
		NSArray* originalData = @[
			item,
		];
		ASTViewController* vc = [ [ ASTViewController alloc ]
				initWithStyle: UITableViewStylePlain ];
		vc.data = originalData;

		XCTAssertEqualObjects( item.tableViewController, vc );
		
		vc.data = @[
			[ ASTItem itemWithText: @"1" ],
			[ ASTItem itemWithText: @"2" ],
		];
		
		XCTAssertNil( item.tableViewController );
	}
}

//------------------------------------------------------------------------------

- (void) testDataPropertyReusingItems
{
	ASTItem* item = [ ASTItem itemWithDict: @{
		AST_id : @"foo",
	} ];
	NSArray* originalData = @[
		[ ASTSection sectionWithItems: @[
			item,
		] ],
	];
	ASTViewController* vc = [ [ ASTViewController alloc ]
			initWithStyle: UITableViewStyleGrouped ];
	vc.tableView.bounds = CGRectMake( 0, 0, 640, 960 );

	vc.data = originalData;
	[ vc.view layoutIfNeeded ];

	XCTAssertEqualObjects( item.tableViewController, vc );
	
	vc.data = @[
		[ ASTSection sectionWithItems: @[
			[ ASTItem itemWithText: @"1" ],
			[ ASTItem itemWithText: @"2" ],
			item,
		] ],
	];
	[ vc.view layoutIfNeeded ];
	
	XCTAssertEqualObjects( item.tableViewController, vc );
}

//------------------------------------------------------------------------------

- (void) testGroupedTableData
{
	ASTViewController* vc = [ [ ASTViewController alloc ]
			initWithStyle: UITableViewStyleGrouped ];
	vc.data = @[
		[ ASTSection sectionWithItems: @[
			[ ASTItem itemWithText: @"1" ],
			[ ASTItem itemWithText: @"2" ],
		] ],
		[ ASTSection sectionWithItems: @[
			[ ASTItem itemWithText: @"1" ],
			[ ASTItem itemWithText: @"2" ],
		] ],
	];
	
	UITableView* tableView = vc.tableView;
	XCTAssertEqual( [ vc numberOfSectionsInTableView: tableView ], 2 );
	XCTAssertEqual( [ vc tableView: tableView numberOfRowsInSection: 0 ], 2 );
	XCTAssertEqual( [ vc tableView: tableView numberOfRowsInSection: 1 ], 2 );
}

//------------------------------------------------------------------------------

- (void) testGroupedTableDataViaDictionaries
{
	ASTViewController* vc = [ [ ASTViewController alloc ]
			initWithStyle: UITableViewStyleGrouped ];
	vc.data = @[
		@{
			AST_items : @[
				[ ASTItem itemWithText: @"1" ],
				[ ASTItem itemWithText: @"2" ],
			],
		},
		@{
			AST_items : @[
				[ ASTItem itemWithText: @"1" ],
				[ ASTItem itemWithText: @"2" ],
			],
		},
	];
	
	UITableView* tableView = vc.tableView;
	XCTAssertEqual( [ vc numberOfSectionsInTableView: tableView ], 2 );
	XCTAssertEqual( [ vc tableView: tableView numberOfRowsInSection: 0 ], 2 );
	XCTAssertEqual( [ vc tableView: tableView numberOfRowsInSection: 1 ], 2 );
}

//------------------------------------------------------------------------------

- (void) testPlainTableData
{
	ASTViewController* vc = [ [ ASTViewController alloc ]
			initWithStyle: UITableViewStylePlain ];
	vc.data = @[
		[ ASTItem itemWithText: @"1" ],
		[ ASTItem itemWithText: @"2" ],
		[ ASTItem itemWithText: @"3" ],
		[ ASTItem itemWithText: @"4" ],
	];
	
	UITableView* tableView = vc.tableView;
	XCTAssertEqual( [ vc numberOfSectionsInTableView: tableView ], 1 );
	XCTAssertEqual( [ vc tableView: tableView numberOfRowsInSection: 0 ], 4 );
}

//------------------------------------------------------------------------------

- (void) testPlainTableDataViaDictionaries
{
	ASTViewController* vc = [ [ ASTViewController alloc ]
			initWithStyle: UITableViewStylePlain ];
	vc.data = @[
		@{
			AST_cell_textLabel_text : @"1",
		},
		@{
			AST_cell_textLabel_text : @"2",
		},
		@{
			AST_cell_textLabel_text : @"3",
		},
		@{
			AST_cell_textLabel_text : @"4",
		},
	];
	
	UITableView* tableView = vc.tableView;
	XCTAssertEqual( [ vc numberOfSectionsInTableView: tableView ], 1 );
	XCTAssertEqual( [ vc tableView: tableView numberOfRowsInSection: 0 ], 4 );
}

//------------------------------------------------------------------------------

- (void) testDataWithNulls
{
	// Group table
	{
		ASTViewController* vc = [ [ ASTViewController alloc ]
				initWithStyle: UITableViewStyleGrouped ];
		vc.data = @[
			[ ASTSection sectionWithItems: @[
				[ ASTItem itemWithText: @"1" ],
				[ ASTItem itemWithText: @"2" ],
			] ],
			[ NSNull null ],
			[ ASTSection sectionWithItems: @[
				[ ASTItem itemWithText: @"1" ],
				[ NSNull null ],
				[ ASTItem itemWithText: @"2" ],
			] ],
		];
		
		UITableView* tableView = vc.tableView;
		XCTAssertEqual( [ vc numberOfSectionsInTableView: tableView ], 2 );
		XCTAssertEqual( [ vc tableView: tableView numberOfRowsInSection: 1 ], 2 );
	}
	// Plain table
	{
		ASTViewController* vc = [ [ ASTViewController alloc ]
				initWithStyle: UITableViewStylePlain ];
		vc.data = @[
			[ ASTItem itemWithText: @"1" ],
			[ ASTItem itemWithText: @"2" ],
			[ NSNull null ],
			[ ASTItem itemWithText: @"3" ],
			[ ASTItem itemWithText: @"4" ],
		];
		XCTAssertEqual( [ vc tableView: vc.tableView numberOfRowsInSection: 0 ], 4 );
	}
}

//------------------------------------------------------------------------------

- (void) testInvalidData
{
	// Group table
	{
		ASTViewController* vc = [ [ ASTViewController alloc ]
				initWithStyle: UITableViewStylePlain ];
		NSArray* badData = @[
			@{
				AST_id : @"first_section",
				AST_items : @[
					[ ASTItem itemWithText: @"1" ],
				],
			} ,
			@{
				AST_items : @[
					[ ASTItem itemWithText: @"1" ],
				],
			},
			@30,
		];
		
		XCTAssertThrows( vc.data = badData );
	}
	// Plain table
	{
		ASTViewController* vc = [ [ ASTViewController alloc ]
				initWithStyle: UITableViewStylePlain ];
		NSArray* badData = @[
			[ ASTItem itemWithText: @"1" ],
			[ ASTItem itemWithText: @"2" ],
			@"Foo",
			[ ASTItem itemWithText: @"3" ],
			[ ASTItem itemWithText: @"4" ],
		];
		
		XCTAssertThrows( vc.data = badData );
	}
}

//------------------------------------------------------------------------------

- (void) testSectionWithIdentifier
{
	// Group table
	{
		ASTSection* section = [ ASTSection sectionWithDict: @{
			AST_id : @"target_section",
			AST_items : @[
				[ ASTItem itemWithText: @"1" ],
			],
		} ];
		ASTSection* nilIDSection = [ ASTSection sectionWithDict: @{
			AST_items : @[
				[ ASTItem itemWithText: @"1" ],
			],
		} ];
		
		ASTViewController* vc = [ [ ASTViewController alloc ]
				initWithStyle: UITableViewStyleGrouped ];
		vc.data = @[
			[ ASTSection sectionWithDict: @{
				AST_id : @"first_section",
				AST_items : @[
					[ ASTItem itemWithText: @"1" ],
				],
			} ],
			nilIDSection,
			section,
		];
		XCTAssertEqualObjects( [ vc sectionWithIdentifier: @"target_section" ], section );
		XCTAssertEqualObjects( [ vc sectionWithIdentifier: nil ], nilIDSection );
		XCTAssertNotNil( [ vc sectionWithIdentifier: @"first_section" ] );
		XCTAssertNil( [ vc sectionWithIdentifier: @"does_not_exist" ] );
	}
	// Plain table
	{
		ASTViewController* vc = [ [ ASTViewController alloc ]
				initWithStyle: UITableViewStylePlain ];
		vc.data = @[
			@{},
			@{},
		];
		XCTAssertNil( [ vc sectionWithIdentifier: @"does_not_exist" ] );
	}
}

//------------------------------------------------------------------------------

- (void) testSectionAtIndex
{
	// Group table
	{
		ASTViewController* vc = [ [ ASTViewController alloc ]
				initWithStyle: UITableViewStyleGrouped ];
		vc.data = @[
			[ ASTSection sectionWithDict: @{
				AST_items : @[
					[ ASTItem itemWithText: @"1" ],
				],
			} ],
			[ ASTSection sectionWithDict: @{
				AST_items : @[
					[ ASTItem itemWithText: @"1" ],
				],
			} ],
		];
		XCTAssertNotNil( [ vc sectionAtIndex: 0 ] );
		XCTAssertNotNil( [ vc sectionAtIndex: 1 ] );
		XCTAssertNil( [ vc sectionAtIndex: 2 ] );
	}
	// Plain table
	{
		ASTViewController* vc = [ [ ASTViewController alloc ]
				initWithStyle: UITableViewStylePlain ];
		vc.data = @[
			@{},
			@{},
		];
		XCTAssertNil( [ vc sectionAtIndex: 0 ] );
	}
}

//------------------------------------------------------------------------------

- (void) testItemWithIdentifier
{
	// Group table
	{
		ASTItem* item = [ ASTItem itemWithDict: @{
			AST_id : @"target_item",
		} ];
		ASTItem* noIDItem = [ ASTItem item ];
		ASTViewController* vc = [ [ ASTViewController alloc ]
				initWithStyle: UITableViewStyleGrouped ];
		vc.data = @[
			[ ASTSection sectionWithDict: @{
				AST_items : @[
					@{
						AST_id : @"first_item",
					},
					noIDItem,
					item,
				],
			} ],
		];
		XCTAssertEqualObjects( [ vc itemWithIdentifier: @"target_item" ], item );
		XCTAssertEqualObjects( [ vc itemWithIdentifier: nil ], noIDItem );
		XCTAssertNotNil( [ vc itemWithIdentifier: @"first_item" ] );
		XCTAssertNil( [ vc itemWithIdentifier: @"does_not_exist" ] );
	}
	// Plain table
	{
		ASTItem* item = [ ASTItem itemWithDict: @{
			AST_id : @"target_item",
		} ];
		ASTItem* noIDItem = [ ASTItem item ];
		ASTViewController* vc = [ [ ASTViewController alloc ]
				initWithStyle: UITableViewStylePlain ];
		vc.data = @[
			@{
				AST_id : @"first_item",
			},
			noIDItem,
			item,
		];
		XCTAssertEqualObjects( [ vc itemWithIdentifier: @"target_item" ], item );
		XCTAssertEqualObjects( [ vc itemWithIdentifier: nil ], noIDItem );
		XCTAssertNotNil( [ vc itemWithIdentifier: @"first_item" ] );
		XCTAssertNil( [ vc itemWithIdentifier: @"does_not_exist" ] );
	}
}

//------------------------------------------------------------------------------

- (void) testItemAtIndexPath
{
	// Group table
	{
		ASTItem* item = [ ASTItem itemWithText: @"Foo" ];
		ASTViewController* vc = [ [ ASTViewController alloc ]
				initWithStyle: UITableViewStyleGrouped ];
		vc.data = @[
			[ ASTSection sectionWithDict: @{
				AST_items : @[
					[ ASTItem itemWithText: @"1" ],
					[ ASTItem itemWithText: @"2" ],
					item,
				],
			} ],
			[ ASTSection sectionWithDict: @{
				AST_items : @[
					[ ASTItem itemWithText: @"1" ],
					[ ASTItem itemWithText: @"2" ],
					[ ASTItem itemWithText: @"3" ],
				],
			} ],
		];
		XCTAssertEqualObjects( [ vc itemAtIndexPath:
				[ NSIndexPath indexPathForItem: 2 inSection: 0 ] ], item );
		XCTAssertNotNil( [ vc itemAtIndexPath:
				[ NSIndexPath indexPathForItem: 0 inSection: 1 ] ] );
		XCTAssertNil( [ vc itemAtIndexPath:
				[ NSIndexPath indexPathForItem: 5 inSection: 1 ] ] );
		XCTAssertNil( [ vc itemAtIndexPath:
				[ NSIndexPath indexPathForItem: 5 inSection: 5 ] ] );
		NSIndexPath* nilPath = nil;
		XCTAssertNil( [ vc itemAtIndexPath: nilPath ] );
	}
	// Plain table
	{
		ASTItem* item = [ ASTItem itemWithDict: @{
			AST_id : @"target_item",
		} ];
		ASTViewController* vc = [ [ ASTViewController alloc ]
				initWithStyle: UITableViewStylePlain ];
		vc.data = @[
			[ ASTItem itemWithText: @"1" ],
			[ ASTItem itemWithText: @"1" ],
			item,
		];
		XCTAssertEqualObjects( [ vc itemAtIndexPath:
				[ NSIndexPath indexPathForItem: 2 inSection: 0 ] ], item );
		XCTAssertNil( [ vc itemAtIndexPath:
				[ NSIndexPath indexPathForItem: 5 inSection: 0 ] ] );
		XCTAssertNil( [ vc itemAtIndexPath:
				[ NSIndexPath indexPathForItem: 5 inSection: 5 ] ] );
		NSIndexPath* nilPath = nil;
		XCTAssertNil( [ vc itemAtIndexPath: nilPath ] );
	}
}

//------------------------------------------------------------------------------

- (void) testItemWithRepresentedObject
{
	// Group table
	{
		ASTItem* item = [ ASTItem itemWithDict: @{
			AST_representedObject : @"target_item",
		} ];
		ASTItem* noIDItem = [ ASTItem item ];
		ASTViewController* vc = [ [ ASTViewController alloc ]
				initWithStyle: UITableViewStyleGrouped ];
		vc.data = @[
			[ ASTSection sectionWithDict: @{
				AST_items : @[
					@{
						AST_representedObject : @"first_item",
					},
					noIDItem,
					item,
				],
			} ],
		];
		XCTAssertEqualObjects( [ vc itemWithRepresentedObject: @"target_item" ], item );
		XCTAssertEqualObjects( [ vc itemWithRepresentedObject: nil ], noIDItem );
		XCTAssertNotNil( [ vc itemWithRepresentedObject: @"first_item" ] );
		XCTAssertNil( [ vc itemWithRepresentedObject: @"does_not_exist" ] );
	}
	// Plain table
	{
		ASTItem* item = [ ASTItem itemWithDict: @{
			AST_representedObject : @"target_item",
		} ];
		ASTItem* noIDItem = [ ASTItem item ];
		ASTViewController* vc = [ [ ASTViewController alloc ]
				initWithStyle: UITableViewStylePlain ];
		vc.data = @[
			@{
				AST_representedObject : @"first_item",
			},
			noIDItem,
			item,
		];
		XCTAssertEqualObjects( [ vc itemWithRepresentedObject: @"target_item" ], item );
		XCTAssertEqualObjects( [ vc itemWithRepresentedObject: nil ], noIDItem );
		XCTAssertNotNil( [ vc itemWithRepresentedObject: @"first_item" ] );
		XCTAssertNil( [ vc itemWithRepresentedObject: @"does_not_exist" ] );
	}
}

//------------------------------------------------------------------------------

- (void) testIndexOfSection
{
	// Group table
	{
		ASTViewController* vc = [ [ ASTViewController alloc ]
				initWithStyle: UITableViewStyleGrouped ];
		ASTSection* section0 = [ ASTSection sectionWithDict: @{
			AST_items : @[
				[ ASTItem itemWithText: @"1" ],
			],
		} ];
		ASTSection* section1 = [ ASTSection sectionWithDict: @{
			AST_items : @[
				[ ASTItem itemWithText: @"1" ],
			],
		} ];
		ASTSection* section2 = [ ASTSection sectionWithDict: @{
			AST_items : @[
				[ ASTItem itemWithText: @"1" ],
			],
		} ];
		ASTSection* nilSection = nil;
		
		vc.data = @[
			section0,
			section1,
		];
		XCTAssertEqual( [ vc indexOfSection: section0 ], 0 );
		XCTAssertEqual( [ vc indexOfSection: section1 ], 1 );
		XCTAssertEqual( [ vc indexOfSection: section2 ], NSNotFound );
		XCTAssertEqual( [ vc indexOfSection: nilSection ], NSNotFound );
	}
	// Plain table
	{
		ASTViewController* vc = [ [ ASTViewController alloc ]
				initWithStyle: UITableViewStylePlain ];
		ASTSection* section0 = [ ASTSection sectionWithDict: @{
			AST_items : @[
				[ ASTItem itemWithText: @"1" ],
			],
		} ];
		ASTSection* nilSection = nil;

		vc.data = @[
			@{},
			@{},
		];
		XCTAssertEqual( [ vc indexOfSection: section0 ], NSNotFound );
		XCTAssertEqual( [ vc indexOfSection: nilSection ], NSNotFound );
	}
}

//------------------------------------------------------------------------------

- (void) testIndexPathForItem
{
	// Group table
	{
		ASTItem* item = [ ASTItem itemWithText: @"Foo" ];
		ASTItem* itemNotInTable = [ ASTItem itemWithText: @"Foo" ];
		ASTItem* nilItem = nil;
		
		ASTViewController* vc = [ [ ASTViewController alloc ]
				initWithStyle: UITableViewStyleGrouped ];
		vc.data = @[
			[ ASTSection sectionWithDict: @{
				AST_items : @[
					[ ASTItem itemWithText: @"1" ],
					[ ASTItem itemWithText: @"2" ],
				],
			} ],
			[ ASTSection sectionWithDict: @{
				AST_items : @[
					[ ASTItem itemWithText: @"1" ],
					[ ASTItem itemWithText: @"2" ],
					[ ASTItem itemWithText: @"3" ],
					item,
				],
			} ],
		];
		
		XCTAssertEqualObjects( [ vc indexPathForItem: item ],
				[ NSIndexPath indexPathForItem: 3 inSection: 1 ] );
		XCTAssertNil( [ vc indexPathForItem: itemNotInTable ] );
		XCTAssertNil( [ vc indexPathForItem: nilItem ] );
	}
	// Plain table
	{
		ASTItem* item = [ ASTItem itemWithText: @"Foo" ];
		ASTItem* itemNotInTable = [ ASTItem itemWithText: @"Foo" ];
		ASTItem* nilItem = nil;
		
		ASTViewController* vc = [ [ ASTViewController alloc ]
				initWithStyle: UITableViewStylePlain ];

		vc.data = @[
			@{},
			@{},
			item,
		];
		
		XCTAssertEqualObjects( [ vc indexPathForItem: item ],
				[ NSIndexPath indexPathForItem: 2 inSection: 0 ] );
		XCTAssertNil( [ vc indexPathForItem: itemNotInTable ] );
		XCTAssertNil( [ vc indexPathForItem: nilItem ] );
	}
}

//------------------------------------------------------------------------------

- (void) testSectionForItem
{
	// Group table
	{
		ASTItem* item = [ ASTItem itemWithText: @"Foo" ];
		ASTItem* itemNotInTable = [ ASTItem itemWithText: @"Foo" ];
		ASTItem* nilItem = nil;
		ASTSection* section = [ ASTSection sectionWithDict: @{
			AST_items : @[
				[ ASTItem itemWithText: @"1" ],
				[ ASTItem itemWithText: @"2" ],
				[ ASTItem itemWithText: @"3" ],
				item,
			],
		} ];
		ASTViewController* vc = [ [ ASTViewController alloc ]
				initWithStyle: UITableViewStyleGrouped ];
		vc.data = @[
			[ ASTSection sectionWithDict: @{
				AST_items : @[
					[ ASTItem itemWithText: @"1" ],
					[ ASTItem itemWithText: @"2" ],
				],
			} ],
			section,
		];
		
		XCTAssertEqualObjects( item.section, section );
		XCTAssertNil( itemNotInTable.section );
		XCTAssertNil( nilItem.section );
	}
	// Plain table
	{
		ASTItem* item = [ ASTItem itemWithText: @"Foo" ];
		ASTItem* itemNotInTable = [ ASTItem itemWithText: @"Foo" ];
		ASTItem* nilItem = nil;
		ASTViewController* vc = [ [ ASTViewController alloc ]
				initWithStyle: UITableViewStylePlain ];

		vc.data = @[
			@{},
			@{},
			item,
		];
		
		XCTAssertNil( item.section );
		XCTAssertNil( itemNotInTable.section );
		XCTAssertNil( nilItem.section );
	}
}

//------------------------------------------------------------------------------

- (void) testInsertSectionsAtIndexesWithRowAnimation
{
	// Group table
	{
		ASTViewController* vc = [ [ ASTViewController alloc ]
				initWithStyle: UITableViewStyleGrouped ];
		vc.data = @[
			[ ASTSection sectionWithDict: @{} ],
			[ ASTSection sectionWithDict: @{} ],
		];
		
		XCTAssertEqual( vc.numberOfItems, 2 );

		ASTSection* section = [ ASTSection sectionWithDict: @{} ];
		[ vc insertSections: @[ section ] atIndexes: @[ @(1) ]
				withRowAnimation: UITableViewRowAnimationNone ];

		XCTAssertEqual( vc.numberOfItems, 3 );
		XCTAssertEqualObjects( [ vc sectionAtIndex: 1 ], section );
		
		XCTAssertThrows( [ vc insertSections: @[] atIndexes: @[ @1 ]
				withRowAnimation: UITableViewRowAnimationAutomatic ] );
		NSArray* nilArray = nil;
		XCTAssertNoThrow( [ vc insertSections: nilArray atIndexes: nilArray
				withRowAnimation: UITableViewRowAnimationAutomatic ] );
	}
}

//------------------------------------------------------------------------------

- (void) testRemoveSectionsAtIndexesWithRowAnimation
{
	// Group table
	{
		ASTViewController* vc = [ [ ASTViewController alloc ]
				initWithStyle: UITableViewStyleGrouped ];
		vc.data = @[
			[ ASTSection sectionWithDict: @{
				AST_headerText : @"1",
			} ],
			[ ASTSection sectionWithDict: @{
				AST_headerText : @"2",
			} ],
			[ ASTSection sectionWithDict: @{
				AST_headerText : @"3",
			} ],
			[ ASTSection sectionWithDict: @{
				AST_headerText : @"4",
			} ],
			[ ASTSection sectionWithDict: @{
				AST_headerText : @"5",
			} ],
		];

		XCTAssertEqual( vc.numberOfItems, 5 );

		[ vc removeSectionsAtIndexes: @[]
				withRowAnimation: UITableViewRowAnimationAutomatic ];
		
		XCTAssertEqual( vc.numberOfItems, 5 );
		
		NSArray* nilArray = nil;
		[ vc removeSectionsAtIndexes: nilArray
				withRowAnimation: UITableViewRowAnimationAutomatic ];
		
		XCTAssertEqual( vc.numberOfItems, 5 );

		[ vc removeSectionsAtIndexes: @[ @(1), @(3) ]
				withRowAnimation: UITableViewRowAnimationAutomatic ];

		XCTAssertEqual( vc.numberOfItems, 3 );
		XCTAssertEqualObjects( [ vc sectionAtIndex: 0 ].headerText, @"1" );
		XCTAssertEqualObjects( [ vc sectionAtIndex: 1 ].headerText, @"3" );
		XCTAssertEqualObjects( [ vc sectionAtIndex: 2 ].headerText, @"5" );
	}
}

//------------------------------------------------------------------------------

- (void) testMoveSectionWithAnimationAtIndexToIndex
{
	// Group table
	{
		ASTViewController* vc = [ [ ASTViewController alloc ]
				initWithStyle: UITableViewStyleGrouped ];
		vc.data = @[
			[ ASTSection sectionWithDict: @{
				AST_headerText : @"1",
			} ],
			[ ASTSection sectionWithDict: @{
				AST_headerText : @"2",
			} ],
			[ ASTSection sectionWithDict: @{
				AST_headerText : @"3",
			} ],
			[ ASTSection sectionWithDict: @{
				AST_headerText : @"4",
			} ],
			[ ASTSection sectionWithDict: @{
				AST_headerText : @"5",
			} ],
		];

		XCTAssertEqual( vc.numberOfItems, 5 );
		
		[ vc moveSectionWithAnimationAtIndex: 1 toIndex: 3 ];

		XCTAssertEqualObjects( [ vc sectionAtIndex: 3 ].headerText, @"2" );
		XCTAssertEqualObjects( [ vc sectionAtIndex: 1 ].headerText, @"3" );
	}
}

//------------------------------------------------------------------------------

- (void) testInsertItemsAtIndexPathsWithRowAnimation
{
	// Group table
	{
		ASTItem* item = [ ASTItem itemWithText: @"Foo" ];
		ASTSection* section = [ ASTSection sectionWithDict: @{
			AST_items : @[
				[ ASTItem itemWithText: @"1" ],
				[ ASTItem itemWithText: @"2" ],
				[ ASTItem itemWithText: @"3" ],
			],
		} ];
		ASTViewController* vc = [ [ ASTViewController alloc ]
				initWithStyle: UITableViewStyleGrouped ];
		vc.data = @[
			section,
		];
		
		XCTAssertNil( item.section );
		XCTAssertNil( [ vc indexPathForItem: item ] );
		XCTAssertEqual( section.numberOfItems, 3 );
		NSIndexPath* indexPath = [ NSIndexPath indexPathForItem: 2 inSection: 0 ];
		[ vc insertItems: @[ item ] atIndexPaths: @[ indexPath ]
				withRowAnimation: UITableViewRowAnimationAutomatic ];
		XCTAssertEqual( section.numberOfItems, 4 );
		XCTAssertEqualObjects( [ section itemAtIndex: 2 ], item );
		
		XCTAssertThrows( [ vc insertItems: @[]
				atIndexPaths: @[ [ NSIndexPath indexPathForRow: 0 inSection:1 ] ]
				withRowAnimation: UITableViewRowAnimationAutomatic ] );
		NSArray* nilArray = nil;
		XCTAssertNoThrow( [ vc insertItems: nilArray atIndexPaths: nilArray
				withRowAnimation: UITableViewRowAnimationAutomatic ] );
	}
	// Plain table
	{
		ASTItem* item = [ ASTItem itemWithText: @"Foo" ];
		ASTItem* itemNotInTable = [ ASTItem itemWithText: @"Foo" ];
		ASTViewController* vc = [ [ ASTViewController alloc ]
				initWithStyle: UITableViewStylePlain ];

		vc.data = @[
			@{},
			@{},
		];
		
		XCTAssertNil( [ vc indexPathForItem: item ] );
		XCTAssertEqual( vc.data.count, 2 );

		NSIndexPath* indexPath = [ NSIndexPath indexPathForItem: 2 inSection: 0 ];
		[ vc insertItems: @[ item ] atIndexPaths: @[ indexPath ]
				withRowAnimation: UITableViewRowAnimationAutomatic ];

		XCTAssertNil( itemNotInTable.section );
		XCTAssertEqualObjects( [ vc itemAtIndexPath: indexPath ], item );
		
		XCTAssertThrows( [ vc insertItems: @[]
				atIndexPaths: @[ [ NSIndexPath indexPathForRow: 0 inSection:1 ] ]
				withRowAnimation: UITableViewRowAnimationAutomatic ] );
		NSArray* nilArray = nil;
		XCTAssertNoThrow( [ vc insertItems: nilArray atIndexPaths: nilArray
				withRowAnimation: UITableViewRowAnimationAutomatic ] );
	}
}

//------------------------------------------------------------------------------

- (void) testRemoveItemsAtIndexPathsWithRowAnimation
{
	// Group table
	{
		ASTItem* item = [ ASTItem itemWithText: @"Foo" ];
		ASTSection* section = [ ASTSection sectionWithDict: @{
			AST_items : @[
				[ ASTItem itemWithText: @"1" ],
				[ ASTItem itemWithText: @"2" ],
				item,
				[ ASTItem itemWithText: @"3" ],
			],
		} ];
		ASTViewController* vc = [ [ ASTViewController alloc ]
				initWithStyle: UITableViewStyleGrouped ];
		vc.data = @[
			[ ASTSection sectionWithDict: @{
				AST_items : @[
					[ ASTItem itemWithText: @"1" ],
					[ ASTItem itemWithText: @"2" ],
				],
			} ],
			section,
		];
		
		NSArray* nilArray = nil;
		XCTAssertNoThrow( [ vc removeItemsAtIndexPaths: nilArray
				withRowAnimation: UITableViewRowAnimationAutomatic ] );

		NSIndexPath* indexPath = [ NSIndexPath indexPathForItem: 2 inSection: 1 ];
		[ vc removeItemsAtIndexPaths: @[ indexPath ]
				withRowAnimation: UITableViewRowAnimationAutomatic ];
		XCTAssertEqual( section.numberOfItems, 3 );
		XCTAssertNil( [ vc indexPathForItem: item ] );
	}
	// Plain table
	{
		ASTItem* item = [ ASTItem itemWithText: @"Foo" ];
		ASTViewController* vc = [ [ ASTViewController alloc ]
				initWithStyle: UITableViewStylePlain ];

		vc.data = @[
			@{},
			item,
			@{},
		];
		
		NSArray* nilArray = nil;
		XCTAssertNoThrow( [ vc removeItemsAtIndexPaths: nilArray
				withRowAnimation: UITableViewRowAnimationAutomatic ] );

		NSIndexPath* indexPath = [ NSIndexPath indexPathForItem: 1 inSection: 0 ];
		[ vc removeItemsAtIndexPaths: @[ indexPath ]
				withRowAnimation: UITableViewRowAnimationAutomatic ];

		XCTAssertEqual( vc.data.count, 2 );
		XCTAssertNil( [ vc indexPathForItem: item ] );
	}
}

//------------------------------------------------------------------------------

- (void) testMoveItemWithAnimationAtIndexPathToIndexPath
{
	// Group table
	{
		ASTItem* item = [ ASTItem itemWithText: @"Foo" ];
		ASTSection* section = [ ASTSection sectionWithDict: @{
			AST_items : @[
				[ ASTItem itemWithText: @"1" ],
				[ ASTItem itemWithText: @"2" ],
				item,
				[ ASTItem itemWithText: @"3" ],
			],
		} ];
		ASTViewController* vc = [ [ ASTViewController alloc ]
				initWithStyle: UITableViewStyleGrouped ];
		vc.data = @[
			[ ASTSection sectionWithDict: @{
				AST_items : @[
					[ ASTItem itemWithText: @"1" ],
					[ ASTItem itemWithText: @"2" ],
				],
			} ],
			section,
		];
		
		NSIndexPath* startIndexPath = [ NSIndexPath indexPathForItem: 2 inSection: 1 ];
		NSIndexPath* endIndexPath = [ NSIndexPath indexPathForItem: 0 inSection: 0 ];
		NSIndexPath* badIndexPath = [ NSIndexPath indexPathForRow: 0 inSection: 10 ];
		
		XCTAssertThrows( [ vc moveItemWithAnimationAtIndexPath: badIndexPath toIndexPath: endIndexPath ] );
		
		[ vc moveItemWithAnimationAtIndexPath: startIndexPath
				toIndexPath: endIndexPath ];
		ASTSection* firstSection = [ vc sectionAtIndex: 0 ];
		XCTAssertEqual( section.numberOfItems, 3 );
		XCTAssertEqual( firstSection.numberOfItems, 3 );
		XCTAssertEqualObjects( [ vc indexPathForItem: item ], endIndexPath );
	}
	// Plain table
	{
		ASTItem* item = [ ASTItem itemWithText: @"Foo" ];
		ASTViewController* vc = [ [ ASTViewController alloc ]
				initWithStyle: UITableViewStylePlain ];

		vc.data = @[
			@{},
			item,
			@{},
		];
		
		NSIndexPath* startIndexPath = [ NSIndexPath indexPathForItem: 1 inSection: 0 ];
		NSIndexPath* endIndexPath = [ NSIndexPath indexPathForItem: 2 inSection: 0 ];
		NSIndexPath* badIndexPath = [ NSIndexPath indexPathForRow: 0 inSection: 10 ];

		XCTAssertThrows( [ vc moveItemWithAnimationAtIndexPath: badIndexPath toIndexPath: endIndexPath ] );
		
		[ vc moveItemWithAnimationAtIndexPath: startIndexPath
				toIndexPath: endIndexPath ];

		XCTAssertEqual( vc.data.count, 3 );
		XCTAssertEqualObjects( [ vc indexPathForItem: item ], endIndexPath );
	}
}

//------------------------------------------------------------------------------

- (void) testShouldHighlightRowAtIndexPath
{
	// Group table
	{
		ASTViewController* vc = [ [ ASTViewController alloc ]
				initWithStyle: UITableViewStyleGrouped ];
		vc.data = @[
			@{
				AST_items : @[
					[ ASTItem itemWithText: @"1" ],
					@{
						AST_selectable : @YES,
					},
				],
			},
		];
		
		NSIndexPath* indexPath = [ NSIndexPath indexPathForItem: 0 inSection: 0 ];
		XCTAssertEqual( [ vc tableView: vc.tableView shouldHighlightRowAtIndexPath: indexPath ], NO );
		
		indexPath = [ NSIndexPath indexPathForItem: 1 inSection: 0 ];
		XCTAssertEqual( [ vc tableView: vc.tableView shouldHighlightRowAtIndexPath: indexPath ], YES );
	}
	// Plain table
	{
		ASTViewController* vc = [ [ ASTViewController alloc ]
				initWithStyle: UITableViewStylePlain ];

		vc.data = @[
			[ ASTItem itemWithText: @"1" ],
			@{
				AST_selectable : @YES,
			},
		];
		
		NSIndexPath* indexPath = [ NSIndexPath indexPathForItem: 0 inSection: 0 ];
		XCTAssertEqual( [ vc tableView: vc.tableView shouldHighlightRowAtIndexPath: indexPath ], NO );
		
		indexPath = [ NSIndexPath indexPathForItem: 1 inSection: 0 ];
		XCTAssertEqual( [ vc tableView: vc.tableView shouldHighlightRowAtIndexPath: indexPath ], YES );
	}
}

//------------------------------------------------------------------------------

- (void) testTableViewClearSelection
{
	ASTViewController* vc = [ [ ASTViewController alloc ]
			initWithStyle: UITableViewStylePlain ];
	vc.data = @[
		[ ASTItem itemWithText: @"1" ],
		@{
			AST_selectable : @YES,
		},
		@{
			AST_selectable : @YES,
		},
	];
	UITableView* tableView = vc.tableView;
	tableView.allowsMultipleSelection = YES;
	
	NSIndexPath* secondIndexPath = [ NSIndexPath indexPathForItem: 1 inSection: 0 ];
	NSIndexPath* thirdIndexPath = [ NSIndexPath indexPathForItem: 2 inSection: 0 ];
	[ tableView selectRowAtIndexPath: secondIndexPath animated: NO
			scrollPosition: UITableViewScrollPositionNone ];
	[ tableView selectRowAtIndexPath: thirdIndexPath animated: NO
			scrollPosition: UITableViewScrollPositionNone ];
	
	NSArray* selectedRows = tableView.indexPathsForSelectedRows;
	XCTAssertEqual( selectedRows.count, 2 );
	XCTAssertEqualObjects( selectedRows[ 0 ], secondIndexPath );
	XCTAssertEqualObjects( selectedRows[ 1 ], thirdIndexPath );

	[ tableView ast_clearSelection ];
	
	XCTAssertNil( tableView.indexPathsForSelectedRows );
}

//------------------------------------------------------------------------------

- (void) testTableViewCellRecycling
{
	ASTViewController* vc = [ [ ASTViewController alloc ]
			initWithStyle: UITableViewStylePlain ];
	
	NSMutableArray* lotsOfCells = [ NSMutableArray array ];
	for( int i = 0; i < 100; ++i ) {
		[ lotsOfCells addObject: [ ASTItem itemWithText: @"1" ] ];
	}
	
	vc.data = lotsOfCells;
	
	vc.tableView.bounds = CGRectMake( 0, 0, 640, 960 );
	[ vc.view layoutIfNeeded ];
	
	ASTItem* item = [ vc itemAtIndexPath: [ NSIndexPath indexPathForRow: 0 inSection: 0 ] ];
	
	XCTAssert( item.cellLoaded );

	UITableViewCell* __weak cell = item.cell;
	
	vc.tableView.contentOffset = CGPointMake( 0, 400 );
	[ vc.view layoutIfNeeded ];

	XCTAssert( item.cellLoaded == NO );
	XCTAssertNil( cell );
}

//------------------------------------------------------------------------------

@end
