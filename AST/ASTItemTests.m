//==============================================================================
//
//  ASTItemTests.m
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
#import "ASTViewController.h"


//------------------------------------------------------------------------------

@interface ActionTestItem : ASTItem

@property (readonly) BOOL actionWasCalled;
@end

@implementation ActionTestItem

- (void) testAction: (ASTItem*) item
{
	_actionWasCalled = YES;
}

@end

//------------------------------------------------------------------------------

@interface ActionTestViewController : ASTViewController

@property (readonly) BOOL actionWasCalled;
@end

@implementation ActionTestViewController

- (void) testAction: (ASTItem*) item
{
	_actionWasCalled = YES;
}

@end

//------------------------------------------------------------------------------

@interface TestCell : UITableViewCell

@property (nonatomic) const char* constCharStarProperty;
@property (nonatomic) char* charStarProperty;
@property (nonatomic) char charProperty;
@property (nonatomic) int intProperty;
@property (nonatomic) short shortProperty;
@property (nonatomic) int32_t longProperty;
@property (nonatomic) long long longLongProperty;
@property (nonatomic) unsigned char unsignedCharProperty;
@property (nonatomic) unsigned int unsignedIntProperty;
@property (nonatomic) unsigned short unsignedShortProperty;
@property (nonatomic) unsigned long unsignedLongProperty;
@property (nonatomic) unsigned long long unsignedLongLongProperty;
@property (nonatomic) float floatProperty;
@property (nonatomic) double doubleProperty;
@property (nonatomic) BOOL boolProperty;
@property (nonatomic) SEL selProperty;
@property (nonatomic) Class classProperty;
@property (nonatomic) void* voidStarProperty;

@end

@implementation TestCell

@end

//------------------------------------------------------------------------------

@interface ASTItemTests : XCTestCase {
	id _actionItem;
}

@end

//------------------------------------------------------------------------------

@implementation ASTItemTests

//------------------------------------------------------------------------------

- (void) testItemInit
{
	ASTItem* item = [ [ ASTItem alloc ] init ];
	
	// This is mostly here to get more coverage. Not sure what else to test.
	XCTAssertNotNil( item.cell );
}

//------------------------------------------------------------------------------

- (void) testItemWithStyleTextDetailText
{
	// Note that we cannot directly test the style of cell that was created
	// because there is no accessor.
	
	// Test the default style
	{
		ASTItem* item = [ ASTItem itemWithStyle: UITableViewCellStyleDefault
				text: @"1" detailText: nil ];
		UITableViewCell* cell = item.cell;
		
		XCTAssertEqualObjects( cell.textLabel.text, @"1" );
		XCTAssertNil( cell.detailTextLabel );
	}
	
	// Test the value1 style
	{
		ASTItem* item = [ ASTItem itemWithStyle: UITableViewCellStyleValue1
				text: @"1" detailText: @"2" ];
		UITableViewCell* cell = item.cell;
		
		XCTAssertEqualObjects( cell.textLabel.text, @"1" );
		XCTAssertEqualObjects( cell.detailTextLabel.text, @"2" );
	}

	// Test the value1 style
	{
		ASTItem* item = [ ASTItem itemWithStyle: UITableViewCellStyleValue2
				text: @"1" detailText: @"2" ];
		UITableViewCell* cell = item.cell;
		
		XCTAssertEqualObjects( cell.textLabel.text, @"1" );
		XCTAssertEqualObjects( cell.detailTextLabel.text, @"2" );
	}

	// Test the UITableViewCellStyleSubtitle style
	{
		ASTItem* item = [ ASTItem itemWithStyle: UITableViewCellStyleSubtitle
				text: @"1" detailText: @"2" ];
		UITableViewCell* cell = item.cell;
		
		XCTAssertEqualObjects( cell.textLabel.text, @"1" );
		XCTAssertEqualObjects( cell.detailTextLabel.text, @"2" );
	}
}

//------------------------------------------------------------------------------

- (void) testCellReuseIdentifier
{
	ASTViewController* vc = [ [ ASTViewController alloc ] initWithStyle: UITableViewStylePlain ];
	[ vc.tableView registerClass: [ TestCell class ] forCellReuseIdentifier: @"testcell" ];
	vc.data = @[
		[ ASTItem itemWithDict: @{
			AST_cellReuseIdentifier : @"testcell",
		 } ],
	];
	vc.tableView.bounds = CGRectMake( 0, 0, 640, 960 );
	XCTAssertNoThrow( [ vc.view layoutIfNeeded ] );
	ASTItem* item = [ vc itemAtIndexPath: [ NSIndexPath indexPathForRow: 0 inSection: 0 ] ];
	XCTAssertEqualObjects( item.cellReuseIdentifier, @"testcell" );
	XCTAssertTrue( [ item.cell isKindOfClass: [ TestCell class ] ] );
}

//------------------------------------------------------------------------------

- (void) testIdentifierProperty
{
	ASTItem* item = [ ASTItem itemWithText: @"foo" ];
	item.identifier = @"bar";
	XCTAssertEqualObjects( item.identifier, @"bar" );
}

//------------------------------------------------------------------------------

- (void) testSelectableProperty
{
	ASTItem* item = [ ASTItem itemWithText: @"foo" ];
	item.selectable = YES;
	XCTAssertEqual( item.selectable, YES );
}

//------------------------------------------------------------------------------

- (void) testRepresentedObjectProperty
{
	ASTItem* item = [ ASTItem itemWithText: @"foo" ];
	NSString* testObject = @"bar";
	item.representedObject = testObject;
	XCTAssertEqualObjects( item.representedObject, testObject );
}

//------------------------------------------------------------------------------

- (void) testCellPropertiesProperty
{
	ASTItem* item = [ ASTItem itemWithDict: @{
		AST_cell_textLabel_text : @"1",
		AST_cell_detailTextLabel_text : @"2",
	} ];
	
	NSDictionary* cellProperties = item.cellProperties;
	
	XCTAssertEqual( cellProperties.count, 2 );
	XCTAssertEqualObjects( cellProperties[ AST_cell_textLabel_text ], @"1" );
	XCTAssertEqualObjects( cellProperties[ AST_cell_detailTextLabel_text ], @"2" );
}

//------------------------------------------------------------------------------

- (void) testCellPropertiesNullHandling
{
	ASTItem* item = [ ASTItem itemWithDict: @{
		@"cellProperties.textLabel.shadowColor" : [ NSNull null ],
	} ];
	
	XCTAssertNil( item.cell.textLabel.shadowColor );
	
}

//------------------------------------------------------------------------------

- (void) testSelectActionProperty
{
	ASTItem* item = [ ASTItem itemWithText: @"foo" ];
	SEL action = @selector(testSelectActionProperty);
	item.selectAction = action;
	XCTAssertEqual( item.selectAction, action );
}

//------------------------------------------------------------------------------

- (void) testSelectActionTargetProperty
{
	ASTItem* item = [ ASTItem itemWithText: @"foo" ];
	item.selectActionTarget = self;
	XCTAssertEqualObjects( item.selectActionTarget, self );
}

//------------------------------------------------------------------------------

- (void) testSelectBlockProperty
{
	ASTItem* item = [ ASTItem itemWithText: @"foo" ];
	ASTItemActionBlock blocky = ^( ASTItem* item ) {
	};
	item.selectBlock = blocky;
	XCTAssertEqualObjects( item.selectBlock, blocky );
}

//------------------------------------------------------------------------------

- (void) testTableViewControllerProperty
{
	ASTItem* item = [ ASTItem itemWithText: @"foo" ];
	ASTViewController* vc = [ [ ASTViewController alloc ]
			initWithStyle: UITableViewStylePlain ];
	vc.data = @[ item ];
	
	XCTAssertEqualObjects( item.tableViewController, vc );
}

//------------------------------------------------------------------------------

- (void) testSectionProperty
{
	ASTItem* item = [ ASTItem itemWithText: @"foo" ];
	ASTSection* section = [ ASTSection sectionWithItems: @[ item ] ];
	
	XCTAssertEqualObjects( item.section, section );
}

//------------------------------------------------------------------------------

- (void) testIndexPathProperty
{
	ASTItem* item = [ ASTItem itemWithText: @"foo" ];
	ASTViewController* vc = [ [ ASTViewController alloc ]
			initWithStyle: UITableViewStylePlain ];
	vc.data = @[ item ];
	
	XCTAssertEqualObjects( item.indexPath, [ NSIndexPath indexPathForRow: 0 inSection: 0 ] );
}

//------------------------------------------------------------------------------

- (void) testRemoveFromContainerWithAnimation
{
	ASTItem* item = [ ASTItem itemWithText: @"foo" ];
	ASTViewController* vc = [ [ ASTViewController alloc ]
			initWithStyle: UITableViewStylePlain ];
	vc.data = @[ item ];
	
	XCTAssertEqualObjects( item.tableViewController, vc );
	[ item removeFromContainerWithAnimation: UITableViewRowAnimationNone ];
	XCTAssertNil( item.tableViewController );
}

//------------------------------------------------------------------------------

- (void) testDeselectWithAnimation
{
	ASTItem* item = [ ASTItem itemWithDict: @{
		AST_selectable : @YES,
	} ];
	ASTViewController* vc = [ [ ASTViewController alloc ]
			initWithStyle: UITableViewStylePlain ];
	vc.data = @[ item ];
	
	[ vc.tableView selectRowAtIndexPath: item.indexPath animated: NO
			scrollPosition: UITableViewScrollPositionNone ];
	XCTAssertEqualObjects( vc.tableView.indexPathForSelectedRow, item.indexPath );
	[ item deselectWithAnimation: NO ];
	XCTAssertNil( vc.tableView.indexPathForSelectedRow );
}

//------------------------------------------------------------------------------

- (void) testFancyKeypaths
{
	// Test that specifying a non-existent setter method fails.
	{
		ASTItem* item = [ ASTItem itemWithDict: @{
			@"cellProperties.textLabel.-setSlartibartfast:" : @"foo",
		} ];
		XCTAssertThrows( item.cell );
	}
	
	// Test that specifying a method that takes too many parameters fails.
	{
		ASTItem* item = [ ASTItem itemWithDict: @{
			@"cellProperties.textLabel.-textRectForBounds:limitedToNumberOfLines:" : @"foo",
		} ];
		XCTAssertThrows( item.cell );
	}
	
	// Test that specifying a method that takes too few parameters fails.
	{
		ASTItem* item = [ ASTItem itemWithDict: @{
			@"cellProperties.textLabel.-preferredMaxLayoutWidth" : @"foo",
		} ];
		XCTAssertThrows( item.cell );
	}
	
	// Test that using a setter method works.
	{
		ASTItem* item = [ ASTItem itemWithDict: @{
			@"cellProperties.textLabel.-setText:" : @"foo",
		} ];
		XCTAssertEqualObjects( item.cell.textLabel.text, @"foo" );
	}
	
	// Test that using a getter method works.
	{
		ASTItem* item = [ ASTItem itemWithDict: @{
			@"cellProperties.-textLabel.text" : @"foo",
		} ];
		XCTAssertEqualObjects( item.cell.textLabel.text, @"foo" );
	}
	
	// Test that using a getter and setter works.
	{
		ASTItem* item = [ ASTItem itemWithDict: @{
			@"cellProperties.-textLabel.-setText:" : @"foo",
		} ];
		XCTAssertEqualObjects( item.cell.textLabel.text, @"foo" );
	}
	
	// Test that a setter taking a const char* works.
	{
		ASTItem* item = [ ASTItem itemWithDict: @{
			AST_cellClass : [ TestCell class ],
			@"cellProperties.-setConstCharStarProperty:" : @"foo",
		} ];
		TestCell* testCell = (TestCell*) item.cell;
		XCTAssertEqualObjects( [ NSString stringWithUTF8String: testCell.constCharStarProperty ], @"foo" );
	}
	
	// Test that a setter taking a char* works.
	{
		ASTItem* item = [ ASTItem itemWithDict: @{
			AST_cellClass : [ TestCell class ],
			@"cellProperties.-setCharStarProperty:" : @"foo",
		} ];
		TestCell* testCell = (TestCell*) item.cell;
		XCTAssertEqualObjects( [ NSString stringWithUTF8String: testCell.charStarProperty ], @"foo" );
	}
	
	// Test that a setter taking a char works.
	{
		ASTItem* item = [ ASTItem itemWithDict: @{
			AST_cellClass : [ TestCell class ],
			@"cellProperties.-setCharProperty:" : [ NSNumber numberWithChar: 'a' ],
		} ];
		TestCell* testCell = (TestCell*) item.cell;
		XCTAssertEqual( testCell.charProperty, 'a' );
	}
	
	// Test that a setter taking a int works.
	{
		ASTItem* item = [ ASTItem itemWithDict: @{
			AST_cellClass : [ TestCell class ],
			@"cellProperties.-setIntProperty:" : [ NSNumber numberWithInt: 23 ],
		} ];
		TestCell* testCell = (TestCell*) item.cell;
		XCTAssertEqual( testCell.intProperty, 23 );
	}
	
	// Test that a setter taking a short works.
	{
		ASTItem* item = [ ASTItem itemWithDict: @{
			AST_cellClass : [ TestCell class ],
			@"cellProperties.-setShortProperty:" : [ NSNumber numberWithShort: 23 ],
		} ];
		TestCell* testCell = (TestCell*) item.cell;
		XCTAssertEqual( testCell.shortProperty, 23 );
	}
	
	// Test that a setter taking a long works.
	{
		ASTItem* item = [ ASTItem itemWithDict: @{
			AST_cellClass : [ TestCell class ],
			@"cellProperties.-setLongProperty:" : [ NSNumber numberWithLong: 23 ],
		} ];
		TestCell* testCell = (TestCell*) item.cell;
		XCTAssertEqual( testCell.longProperty, 23 );
	}
	
	// Test that a setter taking a long long works.
	{
		ASTItem* item = [ ASTItem itemWithDict: @{
			AST_cellClass : [ TestCell class ],
			@"cellProperties.-setLongLongProperty:" : [ NSNumber numberWithLongLong: 23 ],
		} ];
		TestCell* testCell = (TestCell*) item.cell;
		XCTAssertEqual( testCell.longLongProperty, 23 );
	}
	
	// Test that a setter taking a unsigned char works.
	{
		ASTItem* item = [ ASTItem itemWithDict: @{
			AST_cellClass : [ TestCell class ],
			@"cellProperties.-setUnsignedCharProperty:" : [ NSNumber numberWithUnsignedChar: 23 ],
		} ];
		TestCell* testCell = (TestCell*) item.cell;
		XCTAssertEqual( testCell.unsignedCharProperty, 23 );
	}
	
	// Test that a setter taking a unsigned int works.
	{
		ASTItem* item = [ ASTItem itemWithDict: @{
			AST_cellClass : [ TestCell class ],
			@"cellProperties.-setUnsignedIntProperty:" : [ NSNumber numberWithUnsignedInt: 23 ],
		} ];
		TestCell* testCell = (TestCell*) item.cell;
		XCTAssertEqual( testCell.unsignedIntProperty, 23 );
	}
	
	// Test that a setter taking a unsigned short works.
	{
		ASTItem* item = [ ASTItem itemWithDict: @{
			AST_cellClass : [ TestCell class ],
			@"cellProperties.-setUnsignedShortProperty:" : [ NSNumber numberWithUnsignedShort: 23 ],
		} ];
		TestCell* testCell = (TestCell*) item.cell;
		XCTAssertEqual( testCell.unsignedShortProperty, 23 );
	}
	
	// Test that a setter taking a unsigned long works.
	{
		ASTItem* item = [ ASTItem itemWithDict: @{
			AST_cellClass : [ TestCell class ],
			@"cellProperties.-setUnsignedLongProperty:" : [ NSNumber numberWithUnsignedLong: 23 ],
		} ];
		TestCell* testCell = (TestCell*) item.cell;
		XCTAssertEqual( testCell.unsignedLongProperty, 23 );
	}
	
	// Test that a setter taking a unsigned long long works.
	{
		ASTItem* item = [ ASTItem itemWithDict: @{
			AST_cellClass : [ TestCell class ],
			@"cellProperties.-setUnsignedLongLongProperty:" : [ NSNumber numberWithUnsignedLongLong: 23 ],
		} ];
		TestCell* testCell = (TestCell*) item.cell;
		XCTAssertEqual( testCell.unsignedLongLongProperty, 23 );
	}
	
	// Test that a setter taking a float works.
	{
		ASTItem* item = [ ASTItem itemWithDict: @{
			AST_cellClass : [ TestCell class ],
			@"cellProperties.-setFloatProperty:" : [ NSNumber numberWithFloat: 23 ],
		} ];
		TestCell* testCell = (TestCell*) item.cell;
		XCTAssertEqual( testCell.floatProperty, 23 );
	}
	
	// Test that a setter taking a double works.
	{
		ASTItem* item = [ ASTItem itemWithDict: @{
			AST_cellClass : [ TestCell class ],
			@"cellProperties.-setDoubleProperty:" : [ NSNumber numberWithDouble: 23 ],
		} ];
		TestCell* testCell = (TestCell*) item.cell;
		XCTAssertEqual( testCell.doubleProperty, 23 );
	}
	
	// Test that a setter taking a BOOL works.
	{
		ASTItem* item = [ ASTItem itemWithDict: @{
			AST_cellClass : [ TestCell class ],
			@"cellProperties.-setBoolProperty:" : @YES,
		} ];
		TestCell* testCell = (TestCell*) item.cell;
		XCTAssertEqual( testCell.boolProperty, YES );
	}
	
	// Test that a setter taking a SEL works.
	{
		ASTItem* item = [ ASTItem itemWithDict: @{
			AST_cellClass : [ TestCell class ],
			@"cellProperties.-setSelProperty:" : @"setBoolProperty:",
		} ];
		TestCell* testCell = (TestCell*) item.cell;
		XCTAssertEqual( testCell.selProperty, @selector(setBoolProperty:) );
	}
	
	// Test that a setter taking a Class works.
	{
		ASTItem* item = [ ASTItem itemWithDict: @{
			AST_cellClass : [ TestCell class ],
			@"cellProperties.-setClassProperty:" : [ TestCell class ],
		} ];
		TestCell* testCell = (TestCell*) item.cell;
		XCTAssertEqual( testCell.classProperty, [ TestCell class ] );
	}
	
	// Test that a setter taking an unknown type fails.
	{
		ASTItem* item = [ ASTItem itemWithDict: @{
			AST_cellClass : [ TestCell class ],
			@"cellProperties.-setVoidStarProperty:" : [ TestCell class ],
		} ];
		XCTAssertThrows( item.cell );
	}
	
	// Test that using a setter method after the item and cell already exist works.
	{
		ASTItem* item = [ ASTItem item ];
		UITableViewCell* cell = item.cell;
		[ item setValue: @"bar" forKeyPath: @"cellProperties.textLabel.-setText:" ];
		XCTAssertEqualObjects( cell.textLabel.text, @"bar" );
	}
	
	// Test that using a setter method after the item and cell already exist
	// works when using a full key path.
	{
		ASTItem* item = [ ASTItem item ];
		UITableViewCell* cell = item.cell;
		[ item setValue: @"bar" forKeyPath: @"cellProperties.textLabel.-setText:" ];
		XCTAssertEqualObjects( cell.textLabel.text, @"bar" );
	}
	
	// Test getting a value set using a fancy key path works.
	{
		ASTItem* item = [ ASTItem item ];
		[ item setValue: @"bar" forKeyPath: @"cellProperties.textLabel.-setText:" ];
		XCTAssertEqualObjects( [ item valueForKeyPath: @"cellProperties.textLabel.-setText:" ], @"bar" );
		XCTAssertEqualObjects( [ item valueForKeyPath: @"cellProperties.textLabel.-setText:" ], @"bar" );
		[ item setValue: @"foo" forKeyPath: @"cellProperties.textLabel.-setText:" ];
		XCTAssertEqualObjects( [ item valueForKeyPath: @"cellProperties.textLabel.-setText:" ], @"foo" );
		XCTAssertEqualObjects( [ item valueForKeyPath: @"cellProperties.textLabel.-setText:" ], @"foo" );
	}
}

//------------------------------------------------------------------------------

- (void) testDictionaryCellClassKey
{
	{
		ASTItem* item = [ ASTItem itemWithDict: @{
			AST_cellClass : @"TestCell",
		} ];

		XCTAssertEqual( item.cellClass, [ TestCell class ] );
		
		XCTAssertTrue( [ item.cell isKindOfClass: [ TestCell class ] ] );
	}
	
	{
		ASTItem* item = [ ASTItem itemWithDict: @{
			AST_cellClass : [ TestCell class ],
		} ];

		XCTAssertEqual( item.cellClass, [ TestCell class ] );
		
		XCTAssertTrue( [ item.cell isKindOfClass: [ TestCell class ] ] );
	}
	
	ASTItem* item = nil;
	
	{
		XCTAssertThrows( item = [ ASTItem itemWithDict: @{
			AST_cellClass : @"This is not a class name"
		} ] );
	}
	
	{
		XCTAssertThrows( item = [ ASTItem itemWithDict: @{
			AST_cellClass : @[]
		} ] );
	}
}

//------------------------------------------------------------------------------

- (void) testDictionaryCellStyleKey
{
	// Test the default style
	{
		ASTItem* item = [ ASTItem itemWithDict: @{
			AST_cellStyle : @(UITableViewCellStyleDefault),
		} ];
		
		XCTAssertEqual( item.cellStyle, UITableViewCellStyleDefault );
		
		UITableViewCell* cell = item.cell;
		
		XCTAssertNotNil( cell.textLabel );
		XCTAssertNil( cell.detailTextLabel );
	}

	// Test the value1 style
	{
		ASTItem* item = [ ASTItem itemWithDict: @{
			AST_cellStyle : @(UITableViewCellStyleValue1),
		} ];
		
		XCTAssertEqual( item.cellStyle, UITableViewCellStyleValue1 );
		
		UITableViewCell* cell = item.cell;
		
		XCTAssertNotNil( cell.textLabel );
		XCTAssertNotNil( cell.detailTextLabel );
	}

	// Test the value2 style
	{
		ASTItem* item = [ ASTItem itemWithDict: @{
			AST_cellStyle : @(UITableViewCellStyleValue2),
		} ];
		UITableViewCell* cell = item.cell;
		
		XCTAssertNotNil( cell.textLabel );
		XCTAssertNotNil( cell.detailTextLabel );
	}

	// Test the UITableViewCellStyleSubtitle style
	{
		ASTItem* item = [ ASTItem itemWithDict: @{
			AST_cellStyle : @(UITableViewCellStyleSubtitle),
		} ];
		
		XCTAssertEqual( item.cellStyle, UITableViewCellStyleSubtitle );
		
		UITableViewCell* cell = item.cell;
		
		XCTAssertNotNil( cell.textLabel );
		XCTAssertNotNil( cell.detailTextLabel );
	}

	// Test that the default style is UITableViewCellStyleDefault
	{
		ASTItem* item = [ ASTItem itemWithDict: @{
			AST_cell_textLabel_text : @"1",
		} ];
		
		XCTAssertEqual( item.cellStyle, UITableViewCellStyleDefault );
		
		UITableViewCell* cell = item.cell;
		
		XCTAssertNotNil( cell.textLabel );
		XCTAssertNil( cell.detailTextLabel );
	}
}

//------------------------------------------------------------------------------

- (void) testDictionaryTextKey
{
	ASTItem* item = [ ASTItem itemWithDict: @{
		AST_cell_textLabel_text : @"1",
	} ];
	
	XCTAssertEqualObjects( item.cell.textLabel.text, @"1" );
}

//------------------------------------------------------------------------------

- (void) testDictionaryTextAlignmentKey
{
	ASTItem* item = [ ASTItem itemWithDict: @{
		AST_cell_textLabel_text : @"1",
		AST_cell_textLabel_textAlignment : @(NSTextAlignmentCenter),
	} ];
	
	XCTAssertEqual( item.cell.textLabel.textAlignment, NSTextAlignmentCenter );
}

//------------------------------------------------------------------------------

- (void) testDictionaryTextColorKey
{
	UIColor* textColor = [ UIColor redColor ];
	ASTItem* item = [ ASTItem itemWithDict: @{
		AST_cell_textLabel_textColor : textColor,
	} ];
	
	XCTAssertEqualObjects( item.cell.textLabel.textColor, textColor );
}

//------------------------------------------------------------------------------

- (void) testDictionarySelectedTextColorKey
{
	UIColor* textColor = [ UIColor redColor ];
	ASTItem* item = [ ASTItem itemWithDict: @{
		AST_cell_textLabel_highlightedTextColor : textColor,
	} ];
	
	XCTAssertEqualObjects( item.cell.textLabel.highlightedTextColor, textColor );
}

//------------------------------------------------------------------------------

- (void) testDictionaryDetailTextKey
{
	ASTItem* item = [ ASTItem itemWithDict: @{
		AST_cellStyle : @(UITableViewCellStyleValue1),
		AST_cell_detailTextLabel_text : @"1",
	} ];
	
	XCTAssertEqualObjects( item.cell.detailTextLabel.text, @"1" );
}

//------------------------------------------------------------------------------

- (void) testDictionaryDetailTextColorKey
{
	UIColor* textColor = [ UIColor redColor ];
	ASTItem* item = [ ASTItem itemWithDict: @{
		AST_cellStyle : @(UITableViewCellStyleSubtitle),
		AST_cell_detailTextLabel_textColor : textColor,
	} ];
	
	XCTAssertEqualObjects( item.cell.detailTextLabel.textColor, textColor );
}

//------------------------------------------------------------------------------

- (void) testDictionarySelectedDetailTextColorKey
{
	UIColor* textColor = [ UIColor redColor ];
	ASTItem* item = [ ASTItem itemWithDict: @{
		AST_cellStyle : @(UITableViewCellStyleSubtitle),
		AST_cell_detailTextLabel_highlightedTextColor : textColor,
	} ];
	
	XCTAssertEqualObjects( item.cell.detailTextLabel.highlightedTextColor, textColor );
}

//------------------------------------------------------------------------------

- (void) testDictionaryIndentationKeys
{
	ASTItem* item = [ ASTItem itemWithDict: @{
		AST_cell_indentationLevel : @2,
		AST_cell_indentationWidth : @20,
	} ];
	
	XCTAssertEqual( item.cell.indentationLevel, 2 );
	XCTAssertEqual( item.cell.indentationWidth, 20 );
}

//------------------------------------------------------------------------------

- (void) testDictionaryImageKey
{
	UIImage* image = [ [ UIImage alloc ] init ];
	
	ASTItem* item = [ ASTItem itemWithDict: @{
		AST_cell_imageView_image : image,
	} ];
	
	XCTAssertEqualObjects( item.cell.imageView.image, image );
}

//------------------------------------------------------------------------------

- (void) testDictionaryImageNameKey
{
	ASTItem* item = [ ASTItem itemWithDict: @{
		AST_cell_imageView_imageName : @"ren",
	} ];
	
	XCTAssertNotNil( item.cell.imageView.image );
}

//------------------------------------------------------------------------------

- (void) testDictionaryHighlightedImageKey
{
	UIImage* image = [ [ UIImage alloc ] init ];
	
	ASTItem* item = [ ASTItem itemWithDict: @{
		AST_cell_imageView_highlightedImage : image,
	} ];
	
	XCTAssertEqualObjects( item.cell.imageView.highlightedImage, image );
}

//------------------------------------------------------------------------------

- (void) testDictionaryHighlightedImageNameKey
{
	ASTItem* item = [ ASTItem itemWithDict: @{
		AST_cell_imageView_highlightedImageName : @"ren",
	} ];
	
	XCTAssertNotNil( item.cell.imageView.highlightedImage );
}

//------------------------------------------------------------------------------

- (void) testDictionaryAccessoryTypeKey
{
	Class class = NSClassFromString( @"ASTPrefSwitchItem" );
	NSAssert( [ class isSubclassOfClass: [ ASTItem class ] ], @"type must be a subclass of ASTItem" );
	
	NSLog( @"AST_cell = \"%@\"", AST_cell_accessoryType );
	NSLog( @"AST_cell_accessoryType = \"%@\"", AST_cell_accessoryType );
	ASTItem* item = [ ASTItem itemWithDict: @{
		AST_cell_accessoryType : @(UITableViewCellAccessoryDetailButton),
	} ];
	
	XCTAssertEqual( item.cell.accessoryType, UITableViewCellAccessoryDetailButton );
}

//------------------------------------------------------------------------------

- (void) testDictionaryAccessoryViewKey
{
	UIView* view = [ [ UIView alloc ] init ];
	
	ASTItem* item = [ ASTItem itemWithDict: @{
		AST_cell_accessoryView : view,
	} ];
	
	XCTAssertEqualObjects( item.cell.accessoryView, view );
}

//------------------------------------------------------------------------------

- (void) testDictionaryBackgroundColorKey
{
	UIColor* color = [ UIColor redColor ];
	
	ASTItem* item = [ ASTItem itemWithDict: @{
		AST_cell_backgroundColor : color,
	} ];
	
	XCTAssertEqualObjects( item.cell.backgroundColor, color );
}

//------------------------------------------------------------------------------

- (void) testDictionarySelectedBackgroundColorKey
{
	UIColor* color = [ UIColor redColor ];
	
	ASTItem* item = [ ASTItem itemWithDict: @{
		AST_cell_selectedBackgroundColor : color,
	} ];
	
	XCTAssertEqualObjects( item.cell.selectedBackgroundView.backgroundColor, color );
}

//------------------------------------------------------------------------------

- (void) testDictionaryIdentifierKey
{
	ASTItem* item = [ ASTItem itemWithDict: @{
		AST_id : @"foo",
	} ];
	
	XCTAssertEqual( item.identifier, @"foo" );
}

//------------------------------------------------------------------------------

- (void) testDictionarySelectableKey
{
	ASTItem* item = [ ASTItem itemWithDict: @{
		AST_selectable : @YES,
	} ];
	
	XCTAssertEqual( item.selectable, YES );
}

//------------------------------------------------------------------------------

- (void) testDictionarySelectActionKey
{
	ASTItem* item = [ ASTItem itemWithDict: @{
		AST_selectAction : @"foo",
	} ];
	
	XCTAssertEqualObjects( NSStringFromSelector( item.selectAction ), @"foo" );
	// Having an action implies that the cell is selectable.
	XCTAssertEqual( item.selectable, YES );
}

//------------------------------------------------------------------------------

- (void) testDictionarySelectActionTargetKey
{
	// Test that the key is being passed through.
	{
		ASTItem* item = [ ASTItem itemWithDict: @{
			AST_selectActionTarget : AST_targetSelf,
		} ];
		
		XCTAssertEqualObjects( item.selectActionTarget, AST_targetSelf );
	}
	// Test that the AST_targetSelf value is being properly resolved to the item.
	{
		ActionTestItem* item = [ ActionTestItem itemWithDict: @{
			AST_selectActionTarget : AST_targetSelf,
			AST_selectAction : @"testAction:",
		} ];
		[ item performSelectionAction ];
		XCTAssertTrue( item.actionWasCalled );
	}
	// Test that the AST_targetTableViewDelegate value is being properly resolved to the view controller.
	{
		ActionTestViewController* viewController = [ [ ActionTestViewController alloc ] initWithStyle: UITableViewStylePlain ];
		ASTItem* item = [ ASTItem itemWithDict: @{
			AST_selectActionTarget : AST_targetTableViewController,
			AST_selectAction : @"testAction:",
		} ];
		viewController.data = @[ item ];
		[ item performSelectionAction ];
		XCTAssertTrue( viewController.actionWasCalled );
	}
}

//------------------------------------------------------------------------------

- (void) testDictionarySelectActionBlockKey
{
	ASTItemActionBlock blocky = ^( ASTItem* item ) {
	};
	ASTItem* item = [ ASTItem itemWithDict: @{
		AST_selectActionBlock : blocky,
	} ];
	
	XCTAssertEqualObjects( item.selectBlock, blocky );
}

//------------------------------------------------------------------------------

- (void) testDictionaryRepresentedObjectKey
{
	ASTItem* item = [ ASTItem itemWithDict: @{
		AST_representedObject : @"foo",
	} ];
	
	XCTAssertEqualObjects( item.representedObject, @"foo" );
}

//------------------------------------------------------------------------------

- (void) testSelectActionPerform
{
	_actionItem = nil;
	
	ASTItem* item = [ ASTItem itemWithDict: @{
		AST_selectAction : @"actionThatRecordsSender:",
		AST_selectActionTarget : self,
	} ];
	
	[ item performSelectionAction ];
	
	XCTAssertEqualObjects( item, _actionItem );
}

//------------------------------------------------------------------------------

- (void) testSelectActionBlockPerform
{
	id __block blockSender = nil;
	
	ASTItem* item = [ ASTItem itemWithDict: @{
		AST_selectActionBlock : ^( ASTItem* item ) {
			blockSender = item;
		},
	} ];
	
	[ item performSelectionAction ];
	
	XCTAssertEqualObjects( item, blockSender );
}

//------------------------------------------------------------------------------

#pragma mark -

//------------------------------------------------------------------------------

- (void) testTableViewCellTableViewProperty
{
	UITableView* tableView = [ [ UITableView alloc ] init ];
	UITableViewCell* tableViewCell = [ [ UITableViewCell alloc ] init ];
	
	XCTAssertNil( tableViewCell.tableView );
	
	[ tableView addSubview: tableViewCell ];
	
	XCTAssertEqualObjects( tableView, tableViewCell.tableView );
}

//------------------------------------------------------------------------------

- (void) testSelectedBackgroundViewBackgroundColorProperty
{
	UITableViewCell* tableViewCell = [ [ UITableViewCell alloc ] init ];
	UIColor* testColor = [ UIColor whiteColor ];
	
	tableViewCell.selectedBackgroundViewBackgroundColor = testColor;
	
	XCTAssertEqualObjects( tableViewCell.selectedBackgroundViewBackgroundColor, testColor );
	XCTAssertEqualObjects( tableViewCell.selectedBackgroundView.backgroundColor, testColor );
}

//------------------------------------------------------------------------------

- (void) testTextLabelFontProperty
{
	UITableViewCell* tableViewCell = [ [ UITableViewCell alloc ] init ];
	UIFont* testFont = [ UIFont systemFontOfSize: 100 ];
	
	tableViewCell.textLabelFont = testFont;
	
	XCTAssertEqualObjects( tableViewCell.textLabelFont, testFont );
	XCTAssertEqualObjects( tableViewCell.textLabel.font, testFont );
}

//------------------------------------------------------------------------------

- (void) testTableViewCellTextLabelTextColorProperty
{
	UITableViewCell* tableViewCell = [ [ UITableViewCell alloc ] init ];
	UIColor* testColor = [ UIColor whiteColor ];
	
	tableViewCell.textLabelTextColor = testColor;
	
	XCTAssertEqualObjects( tableViewCell.textLabelTextColor, testColor );
	XCTAssertEqualObjects( tableViewCell.textLabel.textColor, testColor );
}

//------------------------------------------------------------------------------

- (void) testTableViewCellTextLabelHighlightedTextColorProperty
{
	UITableViewCell* tableViewCell = [ [ UITableViewCell alloc ] init ];
	UIColor* testColor = [ UIColor whiteColor ];
	
	tableViewCell.textLabelHighlightedTextColor = testColor;
	
	XCTAssertEqualObjects( tableViewCell.textLabelHighlightedTextColor, testColor );
	XCTAssertEqualObjects( tableViewCell.textLabel.highlightedTextColor, testColor );
}

//------------------------------------------------------------------------------

- (void) testDetailTextLabelFontProperty
{
	UITableViewCell* tableViewCell = [ [ UITableViewCell alloc ]
			initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier: nil ];
	UIFont* testFont = [ UIFont systemFontOfSize: 100 ];
	
	tableViewCell.detailTextLabelFont = testFont;
	
	XCTAssertEqualObjects( tableViewCell.detailTextLabelFont, testFont );
	XCTAssertEqualObjects( tableViewCell.detailTextLabel.font, testFont );
}

//------------------------------------------------------------------------------

- (void) testTableViewCellDetailTextLabelTextColorProperty
{
	UITableViewCell* tableViewCell = [ [ UITableViewCell alloc ]
			initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier: nil ];
	UIColor* testColor = [ UIColor whiteColor ];
	
	tableViewCell.detailTextLabelTextColor = testColor;
	
	XCTAssertEqualObjects( tableViewCell.detailTextLabelTextColor, testColor );
	XCTAssertEqualObjects( tableViewCell.detailTextLabel.textColor, testColor );
}

//------------------------------------------------------------------------------

- (void) testTableViewCellDetailTextLabelHighlightedTextColorProperty
{
	UITableViewCell* tableViewCell = [ [ UITableViewCell alloc ]
			initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier: nil ];
	UIColor* testColor = [ UIColor whiteColor ];
	
	tableViewCell.detailTextLabelHighlightedTextColor = testColor;
	
	XCTAssertEqualObjects( tableViewCell.detailTextLabelHighlightedTextColor, testColor );
	XCTAssertEqualObjects( tableViewCell.detailTextLabel.highlightedTextColor, testColor );
}

//------------------------------------------------------------------------------

#pragma mark -

//------------------------------------------------------------------------------

- (void) testSetImageName
{
	UIImageView* imageView = [ [ UIImageView alloc ] init ];
	
	[ imageView setImageName: @"ren" ];
	XCTAssertNotNil( imageView.image );
	
	[ imageView setImageName: nil ];
	XCTAssertNil( imageView.image );
}

//------------------------------------------------------------------------------

- (void) testSetHighlightedImageName
{
	UIImageView* imageView = [ [ UIImageView alloc ] init ];
	
	[ imageView setHighlightedImageName: @"ren" ];
	XCTAssertNotNil( imageView.highlightedImage );
	
	[ imageView setHighlightedImageName: nil ];
	XCTAssertNil( imageView.highlightedImage );
}

//------------------------------------------------------------------------------

#pragma mark - Support methods

//------------------------------------------------------------------------------

- (void) actionThatRecordsSender: (id) sender
{
	_actionItem = sender;
}

//------------------------------------------------------------------------------

@end
