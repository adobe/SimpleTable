//==============================================================================
//
//  ASTSliderItem.m
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

#import "ASTSliderItem.h"

#import "ASTItemSubclass.h"


//------------------------------------------------------------------------------

@implementation ASTSliderItem

//------------------------------------------------------------------------------

- (instancetype) initWithDict: (NSDictionary*) dict
{
	self = [ super initWithDict: dict ];
	if( self ) {
		self.cellClass = [ ASTSliderItemCell class ];
		
		[ self setValue: dict[ AST_sliderActionKey ] forKey: AST_sliderActionKey ];
		self.sliderValueTarget = dict[ AST_sliderTargetKey ];
	}
	return self;
}

//------------------------------------------------------------------------------

- (void) loadCell
{
	[ super loadCell ];
	
	if( self.cellLoaded ) {
		ASTSliderItemCell* sliderCell = (ASTSliderItemCell*)self.cell;
		[ sliderCell.slider addTarget: self
				action: @selector(sliderValueChangedAction:)
				forControlEvents: UIControlEventValueChanged ];
		// Note that we never remove the target/action for the slider. Since we
		// own the slider and the control holds the target weakly and controls
		// auto release and/or don't care if the target/action is removed it
		// would seem to be unnecessary.
	}
}

//------------------------------------------------------------------------------

- (void) sliderValueChangedAction: (id) sender
{
	ASTSliderItemCell* sliderCell = (ASTSliderItemCell*)self.cell;
	[ self setCellPropertiesValue: @(sliderCell.slider.value) forKeyPath: AST_cell_slider_value ];
	
	if( _sliderValueAction ) {
		[ self sendAction: _sliderValueAction to: _sliderValueTarget ];
	}
}

//------------------------------------------------------------------------------

- (void) setValue: (id) value forKey: (NSString*) key
{
	if( [ key isEqualToString: @"sliderValueAction" ] ) {
		NSParameterAssert( value == nil || [ value isKindOfClass: [ NSString class ] ] );
		if( value ) {
			_sliderValueAction = NSSelectorFromString( value );
		} else {
			_sliderValueAction = nil;
		}
	} else {
// LCOV_EXCL_START
		[ super setValue: value forKey: key ];
// LCOV_EXCL_STOP
	}
}

//------------------------------------------------------------------------------

@end

//------------------------------------------------------------------------------

@interface ASTSliderItemCell() {
	UISlider* _slider;
	UILabel* _textLabel;
	NSArray* _updatedConstraints;
}

@end

//------------------------------------------------------------------------------

@implementation ASTSliderItemCell

//------------------------------------------------------------------------------

- (instancetype) initWithStyle: (UITableViewCellStyle) style
		reuseIdentifier: (NSString*) reuseIdentifier
{
	self = [ super initWithStyle: style reuseIdentifier: reuseIdentifier ];
	if( self ) {
		// Force the slider to be created.
		[ self slider ];
	}
	return self;
}

//------------------------------------------------------------------------------

- (UISlider*) slider
{
	if( _slider == nil ) {
		_slider = [ [ UISlider alloc ] init ];
		_slider.translatesAutoresizingMaskIntoConstraints = NO;
		[ self.contentView addSubview: _slider ];
		[ self setNeedsUpdateConstraints ];
	}
	
	return _slider;
}

//------------------------------------------------------------------------------

// LCOV_EXCL_START

- (UILabel*) textLabel
{
	if( _textLabel == nil ) {
		_textLabel = [ [ UILabel alloc ] init ];
		_textLabel.translatesAutoresizingMaskIntoConstraints = NO;
		[ _textLabel setContentHuggingPriority: UILayoutPriorityDefaultHigh
				forAxis: UILayoutConstraintAxisHorizontal ];
		[ self.contentView addSubview: _textLabel ];
		[ self setNeedsUpdateConstraints ];
	}
	
	return _textLabel;
}

// LCOV_EXCL_STOP

//------------------------------------------------------------------------------

// LCOV_EXCL_START

- (void) updateConstraints
{
	if( _updatedConstraints ) {
		[ self.contentView removeConstraints: _updatedConstraints ];
	}
	
	[ super updateConstraints ];
	
	NSDictionary* metrics = @{
		@"vMargin" : @8,
		@"sliderMinSize" : @80,
	};
	
	UILabel* textLabel = _textLabel;
	UISlider* slider = _slider;
	
	NSMutableDictionary* views = [ NSMutableDictionary dictionary ];
	if( textLabel ) {
		views[ @"textLabel" ] = textLabel;
	}
	if( slider ) {
		views[ @"slider" ] = slider;
	}
	
	NSMutableArray* newConstraints = [ NSMutableArray array ];
	
	if( textLabel ) {
		[ newConstraints addObjectsFromArray: [ NSLayoutConstraint
				constraintsWithVisualFormat: @"V:|-(>=vMargin)-[textLabel]-(>=vMargin)-|"
				options: 0 metrics: metrics views: views ] ];
	}
	
	if( slider ) {
		[ newConstraints addObjectsFromArray: [ NSLayoutConstraint
				constraintsWithVisualFormat: @"V:|-(>=vMargin)-[slider]-(>=vMargin)-|"
				options: 0 metrics: metrics views: views ] ];
		[ newConstraints addObject: [ NSLayoutConstraint
				constraintWithItem: slider
				attribute: NSLayoutAttributeCenterY
				relatedBy: NSLayoutRelationEqual
				toItem: slider.superview
				attribute: NSLayoutAttributeCenterY
				multiplier: 1
				constant: 0 ] ];
	}

	if( textLabel && slider ) {
		[ newConstraints addObjectsFromArray: [ NSLayoutConstraint
				constraintsWithVisualFormat: @"H:|-[textLabel]-[slider(>=sliderMinSize)]-|"
				options: NSLayoutFormatAlignAllBaseline metrics: metrics views: views ] ];
	} else if( slider ) {
		[ newConstraints addObjectsFromArray: [ NSLayoutConstraint
				constraintsWithVisualFormat: @"H:|-[slider(>=sliderMinSize)]-|"
				options: 0 metrics: metrics views: views ] ];
	} else {
		NSLog( @"ASTSliderItemCell has no slider" );
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
}

// LCOV_EXCL_STOP

//------------------------------------------------------------------------------

@end

//------------------------------------------------------------------------------

@implementation UISlider( ASTItem )

//------------------------------------------------------------------------------

- (void) setMinimumValueImageName: (NSString*) imageName
{
	UIImage* image = imageName ? [ UIImage imageNamed: imageName ] : nil;
	[ self setMinimumValueImage: image ];
}

//------------------------------------------------------------------------------

- (void) setMaximumValueImageName: (NSString*) imageName
{
	UIImage* image = imageName ? [ UIImage imageNamed: imageName ] : nil;
	[ self setMaximumValueImage: image ];
}

//------------------------------------------------------------------------------

@end
