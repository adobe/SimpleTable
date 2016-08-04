//==============================================================================
//
//  MainViewController.m
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

#import "MainViewController.h"

#import "AnimationController.h"
#import "AppearanceController.h"
#import "BatchAnimationsController.h"

#import <AST/AST.h>

#import <UIKit/UIKit.h>


//------------------------------------------------------------------------------

@interface BigTestCell : UITableViewCell

@end

@implementation BigTestCell

@end

//------------------------------------------------------------------------------

@interface MainViewController ()

@end

//------------------------------------------------------------------------------

@implementation MainViewController

//------------------------------------------------------------------------------

- (instancetype) init
{
	self = [ super initWithStyle: UITableViewStyleGrouped ];
	if( self ) {
		self.title = @"Main";
		self.data = [ self buildTableData ];
	}
	return self;
}

//------------------------------------------------------------------------------

- (NSArray*) buildTableData
{
	return @[
		[ ASTSection sectionWithDict: @{
			AST_headerText : @"Blah Section",
			AST_items : @[
				@{
					AST_cellStyle : @(UITableViewCellStyleSubtitle),
					AST_selectAction : @"testAction:",
					AST_cell_textLabel_text : @"Foo",
					AST_cell_detailTextLabel_text : @"This is the detail text",
					AST_cell_accessoryType : @(UITableViewCellAccessoryCheckmark),
					AST_cell_backgroundColor : [ UIColor orangeColor ],
					AST_cell_selectedBackgroundColor : [ UIColor purpleColor ],
					AST_cell_textLabel_textColor : [ UIColor redColor ],
					AST_cell_textLabel_highlightedTextColor : [ UIColor blueColor ],
					AST_cell_detailTextLabel_textColor : [ UIColor colorWithRed: 1 green: 0.75 blue: 0.75 alpha: 1 ],
					AST_cell_detailTextLabel_highlightedTextColor : [ UIColor colorWithRed: 0.75 green: 0.75 blue: 1 alpha: 1 ],
				},
				[ ASTItem itemWithDict: @{
					AST_cell_textLabel_text : @"Bar",
				} ],
			],
			AST_footerText : @"Here is an example of a really long footer string. Will this wrap around?",
		} ],
		[ ASTSection sectionWithDict: @{
			AST_headerText : @"Other Stuff",
			AST_items : @[
				@{
					AST_selectAction : @"valueItemsAction:",
					AST_cell_textLabel_text : @"Value Items",
					AST_cell_accessoryType : @(UITableViewCellAccessoryDisclosureIndicator),
				},
				@{
					AST_selectAction : @"appearanceAction:",
					AST_cell_textLabel_text : @"Appearance",
					AST_cell_accessoryType : @(UITableViewCellAccessoryDisclosureIndicator),
				},
				@{
					AST_selectAction : @"animationAction:",
					AST_cell_textLabel_text : @"Animation",
					AST_cell_accessoryType : @(UITableViewCellAccessoryDisclosureIndicator),
				},
				@{
					AST_selectAction : @"batchAction:",
					AST_cell_textLabel_text : @"Batch Animations",
					AST_cell_accessoryType : @(UITableViewCellAccessoryDisclosureIndicator),
				},
				@{
					AST_selectAction : @"bigTestAction:",
					AST_cell_textLabel_text : @"Big Test",
					AST_cell_accessoryType : @(UITableViewCellAccessoryDisclosureIndicator),
				},
				@{
					AST_selectAction : @"prefExampleAction:",
					AST_cell_textLabel_text : @"Prefs Example",
					AST_cell_accessoryType : @(UITableViewCellAccessoryDisclosureIndicator),
				},
				@{
					AST_selectAction : @"readmeExampleAction:",
					AST_cell_textLabel_text : @"Readme Example",
					AST_cell_accessoryType : @(UITableViewCellAccessoryDisclosureIndicator),
				},
			],
		} ],
	];
}

//------------------------------------------------------------------------------

- (void) testAction: (ASTItem*) item
{
	NSLog( @"testAction:" );
	[ item.tableViewController deselectItem: item withAnimation: YES ];
}

//------------------------------------------------------------------------------

- (void) valueItemsAction: (ASTItem*) item
{
	NSArray* multiValueValues = @[
		@{
			AST_title : @"One",
			AST_value : @1,
		},
		@{
			AST_title : @"Two",
			AST_value : @2,
		},
		@{
			AST_title : @"Three",
			AST_value : @3,
		},
		@{
			AST_title : @"Four",
			AST_value : @4,
		},
	];

	ASTViewController* valuesExample = [ [ ASTViewController alloc ] initWithStyle: UITableViewStyleGrouped ];
	valuesExample.title = item.cell.textLabel.text;
	valuesExample.data = @[
		[ ASTSection sectionWithDict: @{
			AST_headerText : @"Controls",
			AST_items : @[
				@{
					AST_itemClass : @"ASTSwitchItem",
					AST_cell_textLabel_text : @"Cool Switch",
					AST_cell_switch_onTintColor : [ UIColor purpleColor ],
					AST_cell_switch_tintColor : [ UIColor greenColor ],
					AST_cell_switch_thumbTintColor : [ UIColor orangeColor ],
				},
				@{
					AST_itemClass : @"ASTSliderItem",
					AST_cell_slider_minimumValueImageName : @"ren",
					AST_cell_slider_maximumValueImageName : @"stimpy",
					AST_cell_slider_minimumTrackTintColor : [ UIColor greenColor ],
					AST_cell_slider_maximumTrackTintColor : [ UIColor redColor ],
					AST_cell_slider_thumbTintColor : [ UIColor brownColor ],
				},
			],
		} ],
		[ ASTSection sectionWithDict: @{
			AST_headerText : @"Text",
			AST_items : @[
				@{
					AST_itemClass : @"ASTTextFieldItem",
					AST_cell_textLabel_text : @"Enter Text",
					AST_cell_textInput_placeholder : @"Boo",
					AST_cell_textInput_keyboardType : @(UIKeyboardTypeEmailAddress),
					AST_cell_textInput_autocorrectionType : @(UITextAutocorrectionTypeNo),
				},
				@{
					AST_itemClass : @"ASTTextViewItem",
					AST_cell_textInput_minHeightInLines : @2,
					AST_cell_textInput_placeholder : @"Text View",
				},
			],
		} ],
		[ ASTSection sectionWithDict: @{
			AST_headerText : @"Multi Value",
			AST_items : @[
				[ ASTMultiValueItem itemWithDict: @{
					AST_cell_textLabel_text : @"Multi Item (Default)",
					AST_value : @1,
					AST_values : multiValueValues,
				} ],
				[ ASTMultiValueItem itemWithDict: @{
					AST_cell_textLabel_text : @"Multi Item (Modal)",
					AST_value : @1,
					AST_values : multiValueValues,
					AST_presentation : @(ASTItemPresentation_modal),
				} ],
				[ ASTMultiValueItem itemWithDict: @{
					AST_cell_textLabel_text : @"Multi Item (Action Sheet)",
					AST_value : @1,
					AST_values : multiValueValues,
					AST_presentation : @(ASTItemPresentation_actionSheet),
				} ],
			],
		} ],
	];
	
	[ self.navigationController pushViewController: valuesExample animated: YES ];
}

//------------------------------------------------------------------------------

- (void) prefExampleAction: (ASTItem*) item
{
	NSString* groupPrefKey = @"groupPref";
	NSArray* numberValues = @[
		@{
			AST_title : @"One",
			AST_value : @1,
		},
		@{
			AST_title : @"Two",
			AST_value : @2,
		},
		@{
			AST_title : @"Three",
			AST_value : @3,
		},
		@{
			AST_title : @"Four",
			AST_value : @4,
		},
	];
	ASTViewController* prefsExample = [ [ ASTViewController alloc ] initWithStyle: UITableViewStyleGrouped ];
	prefsExample.title = item.cell.textLabel.text;
	prefsExample.data = @[
		@{
			AST_headerText : @"Misc",
			AST_items : @[
				@{
					AST_itemClass : @"ASTPrefSwitchItem",
					AST_prefKey : @"samplePrefKey",
					AST_cell_textLabel_text : @"Switch",
				},
			],
		},
		@{
			AST_headerText : @"Group Example",
			AST_items : @[
				@{
					AST_itemClass : @"ASTPrefGroupItem",
					AST_prefKey : groupPrefKey,
					AST_itemPrefValue : @"fee",
					AST_itemIsDefault : @YES,
					AST_cell_textLabel_text : @"Fee",
				},
				@{
					AST_itemClass : @"ASTPrefGroupItem",
					AST_prefKey : groupPrefKey,
					AST_itemPrefValue : @"fi",
					AST_cell_textLabel_text : @"Fi",
				},
				@{
					AST_itemClass : @"ASTPrefGroupItem",
					AST_itemPrefValue : @"fo",
					AST_prefKey : groupPrefKey,
					AST_cell_textLabel_text : @"Fo",
				},
				@{
					AST_itemClass : @"ASTPrefGroupItem",
					AST_itemPrefValue : @"fum",
					AST_prefKey : groupPrefKey,
					AST_cell_textLabel_text : @"Fum",
				},
			],
		},
		@{
			AST_headerText : @"Multi-value Example",
			AST_items : @[
				@{
					AST_itemClass : @"ASTMultiValuePrefItem",
					AST_prefKey : @"multivalueprefkey",
					AST_values : numberValues,
					AST_defaultValue : @1,
					AST_cell_textLabel_text : @"Numbers",
				},
				@{
					AST_itemClass : @"ASTMultiValuePrefItem",
					AST_prefKey : @"multivalueprefkey",
					AST_values : numberValues,
					AST_defaultValue : @1,
					AST_presentation : @(ASTItemPresentation_modal),
					AST_cell_textLabel_text : @"Numbers (Modal)",
				},
				@{
					AST_itemClass : @"ASTMultiValuePrefItem",
					AST_prefKey : @"multivalueprefkey",
					AST_values : numberValues,
					AST_defaultValue : @1,
					AST_presentation : @(ASTItemPresentation_actionSheet),
					AST_cell_textLabel_text : @"Numbers (Action Sheet)",
				},
			],
		},
	];
	
	[ self.navigationController pushViewController: prefsExample animated: YES ];
}

//------------------------------------------------------------------------------

- (void) readmeExampleAction: (ASTItem*) item
{
	ASTViewController* readmeExample = [ [ ASTViewController alloc ]
			initWithStyle: UITableViewStyleGrouped ];
	readmeExample.title = @"Example";
	readmeExample.data = @[
		@{
			AST_headerText : @"Simple",
			AST_items : @[
				[ ASTItem itemWithText: @"A simple text item" ],
				[ ASTItem itemWithStyle: UITableViewCellStyleValue1
						text: @"Simple style 1" detailText: @"Detail" ],
				[ ASTItem itemWithStyle: UITableViewCellStyleValue2
						text: @"Simple style 2" detailText: @"Detail" ],
				[ ASTItem itemWithStyle: UITableViewCellStyleSubtitle
						text: @"Simple subtitle" detailText: @"Subtitle" ],
			],
			AST_footerText : @"An example of some really long footer text which shows how the text will wrap.",
		},
		@{
			AST_headerText : @"Advanced",
			AST_items : @[
				[ ASTSliderItem item ],
				[ ASTTextFieldItem itemWithDict: @{
					AST_cell_textLabel_text : @"Text Field",
					AST_cell_textInput_placeholder : @"Text Field Placeholder",
				} ],
				[ ASTTextViewItem itemWithDict: @{
					AST_cell_textInput_placeholder : @"Text View Placeholder",
				} ],
			],
		},
	];
	
	[ self.navigationController pushViewController: readmeExample animated: YES ];
}

//------------------------------------------------------------------------------

- (void) appearanceAction: (ASTItem*) item
{
	[ self.navigationController
			pushViewController: [ [ AppearanceController alloc ] init ]
			animated: YES ];
}

//------------------------------------------------------------------------------

- (void) animationAction: (ASTItem*) item
{
	[ self.navigationController
			pushViewController: [ [ AnimationController alloc ] init ]
			animated: YES ];
}

//------------------------------------------------------------------------------

- (void) batchAction: (ASTItem*) item
{
	[ self.navigationController
			pushViewController: [ [ BatchAnimationsController alloc ] init ]
			animated: YES ];
}

//------------------------------------------------------------------------------

- (void) bigTestAction: (ASTItem*) item
{
	ASTViewController* bigExample = [ [ ASTViewController alloc ]
			initWithStyle: UITableViewStyleGrouped ];
	bigExample.title = item.cell.textLabel.text;
	
	[ bigExample.tableView registerClass: [ BigTestCell class ] forCellReuseIdentifier: @"bigcell" ];
	
	NSUInteger rowCount = 10000;
	NSUInteger sectionRowCount = 10;
	NSUInteger sectionCount = ceil( (double)rowCount / (double)sectionRowCount );
	NSMutableArray* bigData = [ NSMutableArray arrayWithCapacity: sectionCount ];
	
	NSMutableArray* sectionItems = [ NSMutableArray array ];
	for( NSUInteger row = 0 ; row < rowCount; ++row ) {
		NSString* itemText = [ NSString stringWithFormat: @"Item %ld", (unsigned long)row ];
		ASTItem* item = [ ASTItem itemWithDict: @{
			AST_cellReuseIdentifier : @"bigcell",
			AST_cell_textLabel_text : itemText,
		} ];
		
		[ sectionItems addObject: item ];
		
		if( sectionItems.count >= sectionRowCount ) {
			ASTSection* section = [ ASTSection sectionWithItems: sectionItems ];
			[ bigData addObject: section ];
			[ sectionItems removeAllObjects ];
		}
	}
	
	if( sectionItems.count >= sectionRowCount ) {
		ASTSection* section = [ ASTSection sectionWithItems: sectionItems ];
		[ bigData addObject: section ];
	}
	
	bigExample.data = bigData;
	
	[ self.navigationController pushViewController: bigExample animated: YES ];
}

//------------------------------------------------------------------------------

@end
