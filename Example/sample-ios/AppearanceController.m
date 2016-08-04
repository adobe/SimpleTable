//==============================================================================
//
//  AppearanceController.m
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

#import "AppearanceController.h"


//------------------------------------------------------------------------------

@implementation AppearanceController

//------------------------------------------------------------------------------

- (instancetype) init
{
	self = [ super initWithStyle: UITableViewStyleGrouped ];
	if( self ) {
		[ self customizeAppearance ];
		
		self.title = @"Appearance";
		self.data = [ self buildTableData ];
	}
	return self;
}

//------------------------------------------------------------------------------

- (void) customizeAppearance
{
	Class thisClass = [ AppearanceController class ];
	
	UIColor* lightGreen = [ UIColor colorWithRed: 0.9 green: 1 blue: 0.9 alpha: 1 ];
	UIColor* mediumGreen = [ UIColor colorWithRed: 0.5 green: 0.75 blue: 0.5 alpha: 1 ];
	UIColor* placeholderColor = mediumGreen;
	UIColor* darkGreen = [ UIColor colorWithRed: 0 green: 0.5 blue: 0 alpha: 1 ];
	
	id tableAppearance = [ UITableView appearanceWhenContainedIn: thisClass, nil ];
	[ tableAppearance setBackgroundColor: mediumGreen ];
	[ tableAppearance setTintColor: darkGreen ];
	[ tableAppearance setSeparatorColor: darkGreen ];
	
	id headerFooterLabelAppearance = [ UILabel appearanceWhenContainedIn:
			[ UITableViewHeaderFooterView class ], thisClass, nil ];
	[ headerFooterLabelAppearance setTextColor: lightGreen ];
	
	id tableCellAppearance = [ UITableViewCell appearanceWhenContainedIn: thisClass, nil ];
	[ tableCellAppearance setBackgroundColor: lightGreen ];
	[ tableCellAppearance setTextLabelTextColor: darkGreen ];
	[ tableCellAppearance setDetailTextLabelTextColor: mediumGreen ];
	
	id textFieldAppearance = [ ASTTextField appearanceWhenContainedIn:
			thisClass, nil ];
	[ textFieldAppearance setPlaceholderColor: placeholderColor ];
	
	id textViewAppearance = [ ASTTextView appearanceWhenContainedIn:
			thisClass, nil ];
	[ textViewAppearance setPlaceholderColor: placeholderColor ];
}

//------------------------------------------------------------------------------

- (NSArray*) buildTableData
{
	return @[
		[ ASTSection sectionWithDict: @{
			AST_headerText : @"Example Header Text",
			AST_items : @[
				@{
					AST_cellStyle : @(UITableViewCellStyleSubtitle),
					AST_cell_textLabel_text : @"textLabel",
					AST_cell_detailTextLabel_text : @"detailTextLabel",
					AST_cell_accessoryType : @(UITableViewCellAccessoryCheckmark),
				},
				[ ASTItem itemWithText: @"textLabel" ],
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
			AST_footerText : @"Here is an example of a really long footer string. Will this wrap around?",
		} ],
	];
}

//------------------------------------------------------------------------------

@end
