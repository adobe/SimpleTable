//==============================================================================
//
//  ASTTextFieldItem.m
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

#import "ASTTextFieldItem.h"

#import "ASTItemSubclass.h"


//------------------------------------------------------------------------------

@interface ASTTextFieldItem() <UITextFieldDelegate> {
}

@end

//------------------------------------------------------------------------------

@implementation ASTTextFieldItem

//------------------------------------------------------------------------------

- (instancetype) initWithDict: (NSDictionary*) dict
{
	self = [ super initWithDict: dict ];
	if( self ) {
		self.cellClass = [ ASTTextFieldItemCell class ];
		
		id actionValue = dict[ AST_textFieldValueActionKey ];
		if( actionValue ) {
			NSAssert( [ actionValue isKindOfClass: [ NSString class ] ],
					@"%@ should be of type NSString", AST_textFieldValueActionKey );
			_textFieldValueAction = NSSelectorFromString( actionValue );
		}
		_textFieldValueTarget = dict[ AST_textFieldValueTargetKey ];

		id returnActionValue = dict[ AST_textFieldReturnKeyActionKey ];
		if( returnActionValue ) {
			NSAssert( [ returnActionValue isKindOfClass: [ NSString class ] ],
					@"%@ should be of type NSString", AST_textFieldReturnKeyActionKey );
			_textFieldReturnKeyAction = NSSelectorFromString( returnActionValue );
		}
		_textFieldReturnKeyTarget = dict[ AST_textFieldReturnKeyTargetKey ];
	}
	return self;
}

//------------------------------------------------------------------------------

- (void) loadCell
{
	[ super loadCell ];
	
	if( self.cellLoaded ) {
		ASTTextFieldItemCell* textFieldCell = (ASTTextFieldItemCell*)self.cell;
		[ textFieldCell.textInput addTarget: self
				action: @selector(textFieldEditingChangedAction:)
				forControlEvents: UIControlEventEditingChanged ];
		textFieldCell.textInput.delegate = self;
	}
}

//------------------------------------------------------------------------------

- (void) textFieldEditingChangedAction: (id) sender
{
	ASTTextFieldItemCell* textFieldCell = (ASTTextFieldItemCell*)self.cell;
	[ self setCellPropertiesValue: textFieldCell.textInput.text forKeyPath: AST_cell_textInput_text ];
	
	if( _textFieldValueAction ) {
		[ self sendAction: _textFieldValueAction
				to: [ self resolveTargetObjectReference: _textFieldValueTarget ] ];
	}
	
	NSNotificationCenter* nc = [ NSNotificationCenter defaultCenter ];
	[ nc postNotificationName: UITextFieldTextDidChangeNotification object: self ];
}

//------------------------------------------------------------------------------

- (BOOL) textFieldShouldReturn: (UITextField*) textField
{
	if( _textFieldReturnKeyAction ) {
		[ self sendAction: _textFieldReturnKeyAction
				to: [ self resolveTargetObjectReference: _textFieldReturnKeyTarget ] ];
	}
	return NO;
}

//------------------------------------------------------------------------------

- (void) becomeFirstResponder
{
	// Note that we don't animate the scroll because we want the cell to be
	// available synchronously.
	[ self scrollToPosition: UITableViewScrollPositionBottom animated: NO ];
	ASTTextFieldItemCell* cell = (ASTTextFieldItemCell*)self.cell;
	[ cell.textInput becomeFirstResponder ];
}

//------------------------------------------------------------------------------

- (BOOL) isEditing
{
	if( [ self cellLoaded ] ) {
		ASTTextFieldItemCell* cell = (ASTTextFieldItemCell*)self.cell;
		return [ cell.textInput isFirstResponder ];
	}
	return NO;
}

//------------------------------------------------------------------------------

@end

//------------------------------------------------------------------------------

@interface ASTTextFieldItemCell() {
	UILabel* _textLabel;
	ASTTextField* _textInput;
	NSArray* _updatedConstraints;
}

@end

//------------------------------------------------------------------------------

@implementation ASTTextFieldItemCell

//------------------------------------------------------------------------------

- (instancetype) initWithStyle: (UITableViewCellStyle) style
		reuseIdentifier: (NSString*) reuseIdentifier
{
	self = [ super initWithStyle: style reuseIdentifier: reuseIdentifier ];
	if( self ) {
		// Force the textField to be created.
		[ self textInput ];
	}
	return self;
}

//------------------------------------------------------------------------------

- (UILabel*) textLabel
{
	if( _textLabel == nil ) {
		_textLabel = [ [ UILabel alloc ] init ];
		_textLabel.translatesAutoresizingMaskIntoConstraints = NO;
		[ _textLabel setContentHuggingPriority: UILayoutPriorityDefaultHigh forAxis: UILayoutConstraintAxisHorizontal ];
		[ self.contentView addSubview: _textLabel ];
		[ self setNeedsUpdateConstraints ];
	}
	
	return _textLabel;
}

//------------------------------------------------------------------------------

- (UITextField*) textInput
{
	if( _textInput == nil ) {
		_textInput = [ [ ASTTextField alloc ] init ];
		_textInput.translatesAutoresizingMaskIntoConstraints = NO;
		[ _textInput setContentHuggingPriority: UILayoutPriorityDefaultLow
				forAxis: UILayoutConstraintAxisHorizontal ];
		[ self.contentView addSubview: _textInput ];
		[ self setNeedsUpdateConstraints ];
	}
	
	return _textInput;
}

//------------------------------------------------------------------------------

// LCOV_EXCL_START

- (void) updateConstraints
{
	if( _updatedConstraints ) {
		[ self.contentView removeConstraints: _updatedConstraints ];
	}
	
	NSDictionary* metrics = @{
		@"vMargin" : @8,
		@"textFieldMinSize" : @80,
	};
	
	UILabel* textLabel = _textLabel;
	UITextField* textField = _textInput;
	
	NSMutableDictionary* views = [ NSMutableDictionary dictionary ];
	if( textLabel ) {
		views[ @"textLabel" ] = textLabel;
	}
	if( textField ) {
		views[ @"textField" ] = textField;
	}
	
	NSMutableArray* newConstraints = [ NSMutableArray array ];
	
	if( textLabel ) {
		[ newConstraints addObjectsFromArray: [ NSLayoutConstraint
				constraintsWithVisualFormat: @"V:|-(>=vMargin)-[textLabel]-(>=vMargin)-|"
				options: 0 metrics: metrics views: views ] ];
	}
	
	if( textField ) {
		[ newConstraints addObjectsFromArray: [ NSLayoutConstraint
				constraintsWithVisualFormat: @"V:|-(>=vMargin)-[textField]-(>=vMargin)-|"
				options: 0 metrics: metrics views: views ] ];
		[ newConstraints addObject: [ NSLayoutConstraint
				constraintWithItem: textField
				attribute: NSLayoutAttributeCenterY
				relatedBy: NSLayoutRelationEqual
				toItem: textField.superview
				attribute: NSLayoutAttributeCenterY
				multiplier: 1
				constant: 0 ] ];
	}

	if( textLabel && textField ) {
		[ newConstraints addObjectsFromArray: [ NSLayoutConstraint
				constraintsWithVisualFormat: @"H:|-[textLabel]-[textField(>=textFieldMinSize)]-|"
				options: NSLayoutFormatAlignAllBaseline metrics: metrics views: views ] ];
	} else if( textField ) {
		[ newConstraints addObjectsFromArray: [ NSLayoutConstraint
				constraintsWithVisualFormat: @"H:|-[textField(>=textFieldMinSize)]-|"
				options: 0 metrics: metrics views: views ] ];
	} else {
		NSLog( @"ASTTextFieldItemCell has no textField" );
	}
	
	// What is the best way to have a min height on a cell? The system cells all
	// seem to be 44 tall but self.tableView.rowHeight is 0 by default. If we
	// don't do this then the cell gets a little shorter.
	CGFloat rowHeight = self.tableView.rowHeight;
	if( rowHeight == 0 ) {
		rowHeight = 44;
	}
	
	[ newConstraints addObject: [ NSLayoutConstraint
			constraintWithItem: self.contentView
			attribute: NSLayoutAttributeHeight
			relatedBy: NSLayoutRelationGreaterThanOrEqual
			toItem: nil
			attribute: NSLayoutAttributeHeight
			multiplier: 1
			constant: rowHeight ] ];
	
	[ self.contentView addConstraints: newConstraints ];
	
	_updatedConstraints = newConstraints;

	[ super updateConstraints ];
	
}

// LCOV_EXCL_STOP

//------------------------------------------------------------------------------

@end

//------------------------------------------------------------------------------

@implementation ASTTextField

//------------------------------------------------------------------------------

- (void) setPlaceholderColor: (UIColor*) placeholderColor
{
	_placeholderColor = placeholderColor;
	[ self setNeedsDisplay ];
}

//------------------------------------------------------------------------------

// LCOV_EXCL_START

- (void) drawPlaceholderInRect: (CGRect) rect
{
	// The documentation claims we can call [ super drawPlaceholderInRect: ]
	// after modifying the context which would imply that we could just set
	// the fill color and call super. But that does not work so instead we need
	// to draw the text ourselves.
	
	static UIColor* defaultColor = nil;
	if( defaultColor == nil ) {
		defaultColor = [ UIColor colorWithWhite: 0.75 alpha: 1 ];
	}
	
	NSMutableParagraphStyle* paragraphStyle =
			[ [ NSMutableParagraphStyle alloc ] init ];
	paragraphStyle.alignment = self.textAlignment;
	
	UIFont* font = self.font;
	if( self.placeholderFont ) {
		font = self.placeholderFont;
	}
	
	NSDictionary* drawAttributes = @{
		NSFontAttributeName: font,
		NSParagraphStyleAttributeName : paragraphStyle,
		NSForegroundColorAttributeName : _placeholderColor ?: defaultColor,
	};
	
	[ self.placeholder drawInRect: rect withAttributes: drawAttributes ];
}

// LCOV_EXCL_STOP

//------------------------------------------------------------------------------

- (BOOL) resignFirstResponder
{
	// This fixes a problem with the text appearing to jump the first time the
	// focus is moved off of the field. See:
	// https://stackoverflow.com/questions/32765372/uitextfield-text-jumps#33334567
	BOOL resigned = [ super resignFirstResponder ];
	[ self layoutIfNeeded ];
	return resigned;
}

//------------------------------------------------------------------------------

@end
