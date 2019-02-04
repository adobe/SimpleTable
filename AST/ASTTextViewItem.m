//==============================================================================
//
//  ASTTextViewItem.m
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

#import "ASTTextViewItem.h"

#import "ASTItemSubclass.h"
#import "ASTTextFieldItem.h"


//------------------------------------------------------------------------------

static void* ASTTextViewItemCellTextContext;

//------------------------------------------------------------------------------

@interface ASTTextViewItem() <UITextViewDelegate>

@end

//------------------------------------------------------------------------------

@implementation ASTTextViewItem

//------------------------------------------------------------------------------

- (instancetype) initWithDict: (NSDictionary*) dict
{
	self = [ super initWithDict: dict ];
	if( self ) {
		self.cellClass = [ ASTTextViewItemCell class ];
		
		id actionValue = dict[ AST_textViewValueActionKey ];
		if( actionValue ) {
			NSAssert( [ actionValue isKindOfClass: [ NSString class ] ],
					@"%@ should be of type NSString", AST_textViewValueActionKey );
			_textViewValueAction = NSSelectorFromString( actionValue );
		}
		_textViewValueTarget = dict[ AST_textViewValueTargetKey ];

		id returnActionValue = dict[ AST_textViewReturnKeyActionKey ];
		if( returnActionValue ) {
			NSAssert( [ returnActionValue isKindOfClass: [ NSString class ] ],
					@"%@ should be of type NSString", AST_textViewReturnKeyActionKey );
			_textViewReturnKeyAction = NSSelectorFromString( returnActionValue );
		}
		_textViewReturnKeyTarget = dict[ AST_textViewReturnKeyTargetKey ];
	}
	return self;
}

//------------------------------------------------------------------------------

- (void) loadCell
{
	[ super loadCell ];
	
	if( self.cellLoaded ) {
		ASTTextViewItemCell* textViewCell = (ASTTextViewItemCell*)self.cell;
		textViewCell.textInput.delegate = self;
	}
}

//------------------------------------------------------------------------------

- (void) textViewDidChange: (UITextView*) textView
{
	ASTTextViewItemCell* textFieldCell = (ASTTextViewItemCell*)self.cell;
	[ self setCellPropertiesValue: textFieldCell.textInput.text forKeyPath: AST_cell_textInput_text ];
	
	if( _textViewValueAction ) {
		[ self sendAction: _textViewValueAction
				to: [ self resolveTargetObjectReference: _textViewValueTarget ] ];
	}
	
	NSNotificationCenter* nc = [ NSNotificationCenter defaultCenter ];
	[ nc postNotificationName: UITextViewTextDidChangeNotification object: self ];
}

//------------------------------------------------------------------------------

- (BOOL) textView: (UITextView*) textView
		shouldChangeTextInRange: (NSRange) range
		replacementText: (NSString*) text
{
	if( [ text isEqualToString: @"\n" ] ) {
		if( _textViewReturnKeyAction ) {
			[ self sendAction: _textViewReturnKeyAction
					to: [ self resolveTargetObjectReference: _textViewReturnKeyTarget ] ];
		}
	}
	return YES;
}

//------------------------------------------------------------------------------

- (void) becomeFirstResponder
{
	// Note that we don't animate the scroll because we want the cell to be
	// available synchronously.
	[ self scrollToPosition: UITableViewScrollPositionBottom animated: NO ];
	if( [ self.cell isKindOfClass: [ ASTTextViewItemCell class ] ] ) {
		ASTTextViewItemCell* cell = (ASTTextViewItemCell*)self.cell;
		[ cell.textInput becomeFirstResponder ];
	}
}

//------------------------------------------------------------------------------

- (BOOL) isEditing
{
	if( [ self cellLoaded ] && [ self.cell isKindOfClass: [ ASTTextViewItemCell class ] ] ) {
		ASTTextViewItemCell* cell = (ASTTextViewItemCell*)self.cell;
		return [ cell.textInput isFirstResponder ];
	}
	return NO;
}

//------------------------------------------------------------------------------

@end

//------------------------------------------------------------------------------

@implementation ASTTextView

//------------------------------------------------------------------------------

- (instancetype) initWithFrame: (CGRect) frame
		textContainer: (NSTextContainer*) textContainer
{
	self = [ super initWithFrame: frame textContainer: textContainer ];
	if( self ) {
		_minHeightInLines = 3;
		_maxHeightInLines = 10;
		self.backgroundColor = [ UIColor clearColor ];
		
		[ [ NSNotificationCenter defaultCenter ] addObserver: self 
				selector: @selector( textChanged: ) 
				name: UITextViewTextDidChangeNotification 
				object: self ];
	}
	return self;
}

//------------------------------------------------------------------------------

- (void) dealloc
{
	[ [ NSNotificationCenter defaultCenter ] removeObserver: self
			name: UITextViewTextDidChangeNotification object: self ];
}

//------------------------------------------------------------------------------

- (void) setPlaceholder: (NSString*) placeholder
{
	_placeholder = placeholder;
	[ self setNeedsDisplay ];
}

//------------------------------------------------------------------------------

- (void) setPlaceholderColor: (UIColor*) placeholderColor
{
	_placeholderColor = placeholderColor;
	[ self setNeedsDisplay ];
}

//------------------------------------------------------------------------------

- (void) setMinHeightInLines: (NSUInteger) minHeightInLines
{
	_minHeightInLines = minHeightInLines;
	[ self invalidateIntrinsicContentSize ];
}

//------------------------------------------------------------------------------

- (void) setMaxHeightInLines: (NSUInteger) maxHeightInLines
{
	_maxHeightInLines = maxHeightInLines;
	[ self invalidateIntrinsicContentSize ];
}

//------------------------------------------------------------------------------

// LCOV_EXCL_START

- (CGSize) intrinsicContentSize
{
	CGSize result = [ super intrinsicContentSize ];
	
	// The min and max height values could be cached if it was deemed
	// necessary.
	NSDictionary* attributes = @{
		NSFontAttributeName : self.font,
	};
	CGSize lineSize = [ @"Line Height" sizeWithAttributes: attributes ];
	CGFloat verticalMargins = self.textContainerInset.top + self.textContainerInset.bottom;
	CGFloat minHeight = lineSize.height * _minHeightInLines + verticalMargins;
	CGFloat maxHeight = lineSize.height * _maxHeightInLines + verticalMargins;
	if( result.height < minHeight ) {
		result.height = minHeight;
	} else if( result.height > maxHeight ) {
		result.height = maxHeight;
	}
	
	return result;
}

// LCOV_EXCL_STOP

//------------------------------------------------------------------------------

// LCOV_EXCL_START

- (BOOL) shouldDrawPlaceholder
{
	if( self.text.length == 0 && _placeholder.length > 0 ) {
		return YES;
	}
	return NO;
}

// LCOV_EXCL_STOP

//------------------------------------------------------------------------------

// LCOV_EXCL_START

- (void) drawRect: (CGRect) rect
{
	[ super drawRect: rect ];

	if ( [ self shouldDrawPlaceholder ] ) {
		static UIColor* defaultColor = nil;
		if( defaultColor == nil ) {
			defaultColor = [ UIColor colorWithWhite: 0 alpha: 0.22 ];
		}

		CGRect placeholderBounds = self.bounds;
		UIFont* font = self.font;
		if( self.placeholderFont ) {
			font = self.placeholderFont;
		}
		NSDictionary* placeholderAttributes = @{
			NSFontAttributeName : font,
			NSForegroundColorAttributeName : self.placeholderColor ?: defaultColor,
		};
		[ _placeholder drawInRect: placeholderBounds
				withAttributes: placeholderAttributes ];
	}
}

// LCOV_EXCL_STOP

//------------------------------------------------------------------------------

#pragma mark - Notification methods

//------------------------------------------------------------------------------

// LCOV_EXCL_START

- (void) textChanged: (NSNotification*) theNotification
{
	// This needs to be called in order to start/stop drawing the placeholder
	// text when the value changes.
	
	[ self setNeedsDisplay ];
}

// LCOV_EXCL_STOP

//------------------------------------------------------------------------------

@end

//------------------------------------------------------------------------------

@interface ASTTextViewItemCell() {
	NSLayoutConstraint* _heightConstraint;
}

@end

//------------------------------------------------------------------------------

@implementation ASTTextViewItemCell

//------------------------------------------------------------------------------

- (instancetype) initWithStyle: (UITableViewCellStyle) style
		reuseIdentifier: (NSString*) reuseIdentifier
{
	self = [ super initWithStyle: style reuseIdentifier: reuseIdentifier ];
	if( self ) {
		[ self textView ];
	}
	return self;
}

//------------------------------------------------------------------------------

- (void) dealloc
{
	NSNotificationCenter* nc = [ NSNotificationCenter defaultCenter ];
	[ nc removeObserver: self name: UITextViewTextDidChangeNotification
			object: _textInput ];
	
	[ _textInput removeObserver: self forKeyPath: @"text"
			context: &ASTTextViewItemCellTextContext ];
}

//------------------------------------------------------------------------------

- (UITextView*) textView
{
	if( _textInput == nil ) {
		_textInput = [ [ ASTTextView alloc ] init ];
		_textInput.translatesAutoresizingMaskIntoConstraints = NO;
		
		_textInput.font = [ UIFont systemFontOfSize: [ UIFont labelFontSize ] ];

		// Note that scrollEnabled also controls the resizing behavior and so
		// is significant to making the auto resizing work.
		_textInput.scrollEnabled = NO;
		
		_textInput.textContainer.lineFragmentPadding = 0;
		_textInput.textContainerInset = UIEdgeInsetsZero;
		
		[ self.contentView addSubview: _textInput ];
		NSDictionary* views = NSDictionaryOfVariableBindings( _textInput );
		NSDictionary* metrics = @{
			@"vMargin" : @12,
		};
		
		[ self.contentView addConstraints: [ NSLayoutConstraint
				constraintsWithVisualFormat: @"V:|-(>=vMargin)-[_textInput]-(>=vMargin)-|"
				options: 0 metrics: metrics views: views ] ];
		[ self.contentView addConstraint: [ NSLayoutConstraint
				constraintWithItem: _textInput
				attribute: NSLayoutAttributeCenterY
				relatedBy: NSLayoutRelationEqual
				toItem: _textInput.superview
				attribute: NSLayoutAttributeCenterY
				multiplier: 1
				constant: 0 ] ];
		[ self.contentView addConstraints: [ NSLayoutConstraint
				constraintsWithVisualFormat: @"H:|-[_textInput]-|"
				options: 0 metrics: metrics views: views ] ];
		
		NSNotificationCenter* nc = [ NSNotificationCenter defaultCenter ];
		[ nc addObserver: self selector: @selector(textViewDidChange:)
				name: UITextViewTextDidChangeNotification object: _textInput ];
		[ _textInput addObserver: self forKeyPath: @"text" options: 0
				context: &ASTTextViewItemCellTextContext ];
	}
	
	return _textInput;
}

//------------------------------------------------------------------------------

// LCOV_EXCL_START

- (void) updateCellSize
{
	UITableView* tableView = self.tableView;
	
	// Note that we are disabling animations because beginUpdates/endUpdates
	// has the effect of resetting the scroll position to be under the keyboard.
	// This should be fixed so the animation can look nice.
	BOOL animationsEnabled = [ UIView areAnimationsEnabled ];
	if( [ _textInput isFirstResponder ] ) {
		[ UIView setAnimationsEnabled: NO ];
	}
	
	[ tableView beginUpdates ];
	[ tableView endUpdates ];
	
	if( [ _textInput isFirstResponder ] ) {
		NSIndexPath* indexPath = [ tableView indexPathForCell: self ];
		[ tableView scrollToRowAtIndexPath: indexPath
				atScrollPosition: UITableViewScrollPositionBottom
				animated: NO ];
		
		[ UIView setAnimationsEnabled: animationsEnabled ];
	}
}

// LCOV_EXCL_STOP

//------------------------------------------------------------------------------

// LCOV_EXCL_START

- (void) textViewDidChange: (NSNotification*) notification
{
	[ self updateCellSize ];
}

// LCOV_EXCL_STOP

//------------------------------------------------------------------------------

// LCOV_EXCL_START

- (void) observeValueForKeyPath: (NSString*) keyPath ofObject: (id) object
		change: (NSDictionary*) change context: (void*) context
{
	if( context == &ASTTextViewItemCellTextContext ) {
		[ self updateCellSize ];
		return;
	}
	
	[ super observeValueForKeyPath: keyPath ofObject: object
			change: change context: context ];
}

// LCOV_EXCL_STOP

//------------------------------------------------------------------------------

@end

