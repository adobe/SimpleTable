//==============================================================================
//
//  AnimationController.m
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

#import "AnimationController.h"


//------------------------------------------------------------------------------

@implementation AnimationController

//------------------------------------------------------------------------------

- (instancetype) init
{
	self = [ super initWithStyle: UITableViewStyleGrouped ];
	if( self ) {
		self.title = @"Animation";
		self.data = [ self buildTableData ];
	}
	return self;
}

//------------------------------------------------------------------------------

- (NSArray*) buildTableData
{
	ASTItem* peekItem = [ ASTItem itemWithDict: @{
		AST_cell_textLabel_text : @"Peek A Boo",
		AST_cell_indentationLevel : @1,
	} ];
	
	ASTItemActionBlock toggleCheckBlock = ^( ASTItem* item ) {
		item.cell.accessoryType = (item.cell.accessoryType == UITableViewCellAccessoryCheckmark)
				? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
		[ item deselectWithAnimation: YES ];
	};
	
	ASTItemActionBlock toggleRowBlock = ^( ASTItem* item ) {
		[ item.tableViewController.tableView performUpdates: ^{
			if( peekItem.tableViewController == nil ) {
				[ item.section insertItems: @[ peekItem ] atIndexes: @[ @(item.indexPath.row + 1) ]
						withRowAnimation: UITableViewRowAnimationAutomatic ];
			} else {
				[ peekItem removeFromContainerWithAnimation: UITableViewRowAnimationAutomatic ];
			}
		} ];
		[ item deselectWithAnimation: YES ];
	};

	ASTItemActionBlock cycleRowBlock = ^( ASTItem* item ) {
		ASTViewController* tableVC = item.tableViewController;
		NSIndexPath* fromPath = [ NSIndexPath indexPathForItem: item.indexPath.row + 1
				inSection: item.indexPath.section ];
		NSIndexPath* toPath = [ NSIndexPath indexPathForItem: fromPath.row + 2
				inSection: fromPath.section ];
		
		[ tableVC.tableView performUpdates: ^{
			[ tableVC moveItemWithAnimationAtIndexPath: fromPath toIndexPath: toPath ];
		} ];

		[ item deselectWithAnimation: YES ];
	};

	return @[
		[ ASTSection sectionWithDict: @{
			AST_headerText : @"Animation Section",
			AST_items : @[
				@{
					AST_selectActionBlock : toggleCheckBlock,
					AST_cell_textLabel_text : @"Toggle Check",
				},
				@{
					AST_selectActionBlock : toggleRowBlock,
					AST_cell_textLabel_text : @"Toggle Row",
				},
				peekItem,
				@{
					AST_selectActionBlock : cycleRowBlock,
					AST_cell_textLabel_text : @"Cycle Rows",
				},
				[ ASTItem itemWithDict: @{
					AST_cell_textLabel_text : @"1",
					AST_cell_indentationLevel : @1,
				} ],
				[ ASTItem itemWithDict: @{
					AST_cell_textLabel_text : @"2",
					AST_cell_indentationLevel : @1,
				} ],
				[ ASTItem itemWithDict: @{
					AST_cell_textLabel_text : @"3",
					AST_cell_indentationLevel : @1,
				} ],
			],
		} ],
	];
}

//------------------------------------------------------------------------------

@end
