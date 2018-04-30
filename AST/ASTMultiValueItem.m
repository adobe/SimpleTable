//==============================================================================
//
//  ASTMultiValueItem.m
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

#import "ASTMultiValueItem.h"

#import "ASTViewController.h"


//------------------------------------------------------------------------------

static NSString* localizedStringFromUIKit( NSString* keyAndDefault )
{
	// I don't want to require our own localized strings so use this to fetch
	// the common localized strings.
	return [ [ NSBundle bundleWithIdentifier: @"com.apple.UIKit" ]
			localizedStringForKey: keyAndDefault value: nil table: nil ]
			?: keyAndDefault;
}

//------------------------------------------------------------------------------

@interface ASTMultiValueItem() <UIActionSheetDelegate> {
	NSDictionary* _valuesMap;
}

@property (readwrite) id modalValue;

@end

//------------------------------------------------------------------------------

@implementation ASTMultiValueItem

//------------------------------------------------------------------------------

- (instancetype) initWithDict: (NSDictionary*) initialDict
{
	NSMutableDictionary* dict = [ initialDict mutableCopy ];
	if( dict[ AST_cellStyle ] == nil ) {
		dict[ AST_cellStyle ] = @(UITableViewCellStyleValue1);
	}
	
	self = [ super initWithDict: dict ];
	if( self ) {
		self.values = dict[ AST_values ];
		self.value = dict[ AST_value ];
		self.presentation = [ dict[ AST_presentation ] integerValue ];

		self.selectable = YES;
		
		[ self setValue: @(UITableViewCellAccessoryDisclosureIndicator)
				forKeyPath: AST_cell_accessoryType ];
	}
	return self;
}

//------------------------------------------------------------------------------

- (void) syncValueDisplayWithValue
{
	NSDictionary* valueDict = _value ? _valuesMap[ _value ] : nil;
	NSString* valueTitle = valueDict[ AST_title ] ?: @"";

	[ self setValue: valueTitle forKeyPath: AST_cell_detailTextLabel_text ];
}

//------------------------------------------------------------------------------

// LCOV_EXCL_START

- (ASTItemPresentation) resolvedPresentation
{
	UIViewController* vc = self.tableViewController;
	
	if( _presentation == ASTItemPresentation_default ) {
		if( vc.navigationController ) {
			return ASTItemPresentation_navigation;
		}
		return ASTItemPresentation_modal;
	}
	return _presentation;
}

// LCOV_EXCL_STOP

//------------------------------------------------------------------------------

- (ASTViewController*) buildSelectionController: (ASTItemActionBlock) extraActionBlock
{
	ASTViewController* vc = [ [ ASTViewController alloc ]
			initWithStyle: UITableViewStyleGrouped ];
	
	ASTItemActionBlock selectBlock = ^( ASTItem* item ) {
		[ item deselectWithAnimation: YES ];
		ASTSection* section = item.section;
		for ( ASTItem* i in section.items ) {
			[ i setValue: @(UITableViewCellAccessoryNone) forKeyPath: AST_cell_accessoryType ];
		}
		[ item setValue: @(UITableViewCellAccessoryCheckmark) forKeyPath: AST_cell_accessoryType ];
		
		extraActionBlock( item );
	};
	
	NSMutableArray* items = [ NSMutableArray arrayWithCapacity: _values.count ];
	for( NSDictionary* valueInfo in _values ) {
		id value = valueInfo[ AST_value ];
		NSString* title = valueInfo[ AST_title ];
		ASTItem* item = [ ASTItem itemWithText: title ];
		item.representedObject = value;
		item.selectable = YES;
		item.selectBlock = selectBlock;
		
		UITableViewCellAccessoryType accessoryType = [ _value isEqual: value ]
				? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
		[ item setValue: @(accessoryType) forKeyPath: AST_cell_accessoryType ];

		[ items addObject: item ];
	}
	
	vc.data = @[
		[ ASTSection sectionWithItems: items ],
	];
	vc.title = [ self valueForKeyPath: AST_cell_textLabel_text ];
	
	return vc;
}

//------------------------------------------------------------------------------

// LCOV_EXCL_START

- (void) presentValueSelectionInActionSheet
{
	// The effect of this version test is to exclude the use of UIActionSheet
	// if the minimum deployment target is 8.0 ar later.
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 80000
	UIActionSheet* actionSheet = [ [ UIActionSheet alloc ]
			initWithTitle: [ self valueForKeyPath: AST_cell_textLabel_text ]
			delegate: self
			cancelButtonTitle: localizedStringFromUIKit( @"Cancel" )
			destructiveButtonTitle: nil
			otherButtonTitles: nil ];
	
	for( NSDictionary* value in _values ) {
		[ actionSheet addButtonWithTitle: value[ AST_title ] ];
	}
	
	[ actionSheet showInView: self.cell ];
#endif
}

// LCOV_EXCL_STOP

//------------------------------------------------------------------------------

// LCOV_EXCL_START

- (void) presentValueSelectionInAlertController
{
	NSString* title = [ self valueForKeyPath: AST_cell_textLabel_text ];
	UIAlertController* alertController = [ UIAlertController
			alertControllerWithTitle: title
			message: nil
			preferredStyle: UIAlertControllerStyleActionSheet ];
	
	for( NSDictionary* value in _values ) {
		NSString* title = value[ AST_title ];
		id valueObject = value[ AST_value ];
		UIAlertAction* action = [ UIAlertAction
				actionWithTitle: title
				style: UIAlertActionStyleDefault
				handler: ^( UIAlertAction* _Nonnull action ) {
			[ self selectedValue: valueObject ];
			[ self deselectWithAnimation: YES ];
		} ];
		[ alertController addAction: action ];
	}
	
	UIAlertAction* cancelAction = [ UIAlertAction
			actionWithTitle: localizedStringFromUIKit( @"Cancel" )
			style: UIAlertActionStyleCancel
			handler:^( UIAlertAction * _Nonnull action ) {
				[ self deselectWithAnimation: YES ];
			} ];
	[ alertController addAction: cancelAction ];
	
	[ self.tableViewController presentViewController: alertController
			animated: YES completion: nil ];
}

// LCOV_EXCL_STOP

//------------------------------------------------------------------------------

// LCOV_EXCL_START

- (void) pushValueSelectionOnNavigationController
{
	UIViewController* vc = self.tableViewController;
	ASTViewController* selection = [ self buildSelectionController: ^( ASTItem* item ) {
		[ self selectedValue: item.representedObject ];
	} ];
	
	[ vc.navigationController pushViewController: selection animated: YES ];
}

// LCOV_EXCL_STOP

//------------------------------------------------------------------------------

// LCOV_EXCL_START

- (void) presentValueSelectionModally
{
	UIViewController* vc = self.tableViewController;
	ASTViewController* selection = [ self buildSelectionController: ^( ASTItem* item ) {
		self.modalValue = item.representedObject;
	} ];
	
	self.modalValue = _value;
	UINavigationController* nav = [ [ UINavigationController alloc ] initWithRootViewController: selection ];
	selection.navigationItem.leftBarButtonItem = [ [ UIBarButtonItem alloc ]
			initWithBarButtonSystemItem: UIBarButtonSystemItemCancel
			target: self
			action: @selector(cancelModalViewController:) ];
	selection.navigationItem.rightBarButtonItem = [ [ UIBarButtonItem alloc ]
			initWithBarButtonSystemItem: UIBarButtonSystemItemDone
			target: self
			action: @selector(dismissModalViewController:) ];
	[ vc presentViewController: nav animated: YES completion: nil ];
}

// LCOV_EXCL_STOP

//------------------------------------------------------------------------------

// LCOV_EXCL_START

- (void) presentValueSelection
{
	ASTItemPresentation actualPresentation = [ self resolvedPresentation ];
	
	switch( actualPresentation ) {
		case ASTItemPresentation_actionSheet:
			if( [ UIAlertController class ] != nil ) {
				[ self presentValueSelectionInAlertController ];
			} else {
				[ self presentValueSelectionInActionSheet ];
			}
			break;
		case ASTItemPresentation_navigation:
			[ self pushValueSelectionOnNavigationController ];
			break;
		case ASTItemPresentation_modal:
			[ self presentValueSelectionModally ];
			break;
		default:
			NSLog( @"Unexpected presentation value: %ld", (long)actualPresentation );
			break;
	}
}

// LCOV_EXCL_STOP

//------------------------------------------------------------------------------

// LCOV_EXCL_START

- (void) performSelectionAction
{
	[ self presentValueSelection ];
}

// LCOV_EXCL_STOP

//------------------------------------------------------------------------------

- (void) setValues: (NSArray*) values
{
	_values = values;
	
	NSMutableDictionary* valuesMap = [ NSMutableDictionary
			dictionaryWithCapacity: values.count ];
	for( NSDictionary* value in values ) {
		NSParameterAssert( [ value isKindOfClass: [ NSDictionary class ] ] );
		id valueValue = value[ AST_value ];
		[ valuesMap setObject: value forKey: valueValue ];
	}
	_valuesMap = valuesMap;
}

//------------------------------------------------------------------------------

- (void) setValue: (id) value
{
	_value = value;
	[ self syncValueDisplayWithValue ];
}

//------------------------------------------------------------------------------

- (void) selectedValue: (id) value
{
	self.value = value;
}

//------------------------------------------------------------------------------

// LCOV_EXCL_START

- (void) cancelModalViewController: (id) sender
{
	[ self.tableViewController dismissViewControllerAnimated: YES completion: nil ];
}

// LCOV_EXCL_STOP

//------------------------------------------------------------------------------

// LCOV_EXCL_START

- (void) dismissModalViewController: (id) sender
{
	[ self.tableViewController dismissViewControllerAnimated: YES completion: nil ];
	[ self selectedValue: self.modalValue ];
}

// LCOV_EXCL_STOP

//------------------------------------------------------------------------------

// LCOV_EXCL_START

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 80000
- (void) actionSheet: (UIActionSheet*) actionSheet
		willDismissWithButtonIndex: (NSInteger) buttonIndex
{
	[ self deselectWithAnimation: YES ];
	
	if( buttonIndex == actionSheet.cancelButtonIndex ) {
		return;
	}
	
	NSInteger valueIndex = buttonIndex - 1;
	NSDictionary* value = _values[ valueIndex ];
	[ self selectedValue: value[ AST_value ] ];
}
#endif

// LCOV_EXCL_STOP

//------------------------------------------------------------------------------

@end
