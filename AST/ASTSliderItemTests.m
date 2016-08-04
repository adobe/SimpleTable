//==============================================================================
//
//  ASTSliderItemTests.m
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

#import <XCTest/XCTest.h>


//------------------------------------------------------------------------------

@interface SliderItemTestTarget : NSObject

@property (nonatomic) BOOL actionSent;

- (void) sliderTestAction: (id) sender;

@end

//------------------------------------------------------------------------------

@interface ASTSliderItemTests : XCTestCase

@end

//------------------------------------------------------------------------------

@implementation ASTSliderItemTests

//------------------------------------------------------------------------------

- (void) testDictionaryValueKey
{
	ASTSliderItem* item = [ ASTSliderItem itemWithDict: @{
		AST_cell_slider_value : @(0.5),
	} ];
	
	ASTSliderItemCell* cell = (ASTSliderItemCell*)item.cell;
	XCTAssertEqual( cell.slider.value, 0.5 );
}

//------------------------------------------------------------------------------

- (void) testDictionaryMinimumValueKey
{
	ASTSliderItem* item = [ ASTSliderItem itemWithDict: @{
		AST_cell_slider_minimumValue : @(0.5),
	} ];
	
	ASTSliderItemCell* cell = (ASTSliderItemCell*)item.cell;
	XCTAssertEqual( cell.slider.minimumValue, 0.5 );
}

//------------------------------------------------------------------------------

- (void) testDictionaryMaximumValueKey
{
	ASTSliderItem* item = [ ASTSliderItem itemWithDict: @{
		AST_cell_slider_maximumValue : @(2.0),
	} ];
	
	ASTSliderItemCell* cell = (ASTSliderItemCell*)item.cell;
	XCTAssertEqual( cell.slider.maximumValue, 2.0 );
}

//------------------------------------------------------------------------------

- (void) testDictionaryMinimumValueImageKey
{
	{
		UIImage* image = [ [ UIImage alloc ] init ];
		ASTSliderItem* item = [ ASTSliderItem itemWithDict: @{
			AST_cell_slider_minimumValueImage : image,
		} ];
		
		ASTSliderItemCell* cell = (ASTSliderItemCell*)item.cell;
		XCTAssertEqualObjects( cell.slider.minimumValueImage, image );
	}
	{
		ASTSliderItem* item = [ ASTSliderItem itemWithDict: @{
			AST_cell_slider_minimumValueImageName : @"ren",
		} ];
		
		ASTSliderItemCell* cell = (ASTSliderItemCell*)item.cell;
		XCTAssertNotNil( cell.slider.minimumValueImage );
	}
}

//------------------------------------------------------------------------------

- (void) testDictionaryMaximumValueImageKey
{
	{
		UIImage* image = [ [ UIImage alloc ] init ];
		ASTSliderItem* item = [ ASTSliderItem itemWithDict: @{
			AST_cell_slider_maximumValueImage : image,
		} ];
		
		ASTSliderItemCell* cell = (ASTSliderItemCell*)item.cell;
		XCTAssertEqualObjects( cell.slider.maximumValueImage, image );
	}
	{
		ASTSliderItem* item = [ ASTSliderItem itemWithDict: @{
			AST_cell_slider_maximumValueImageName : @"ren",
		} ];
		
		ASTSliderItemCell* cell = (ASTSliderItemCell*)item.cell;
		XCTAssertNotNil( cell.slider.maximumValueImage );
	}
}

//------------------------------------------------------------------------------

- (void) testDictionaryContinuousKey
{
	ASTSliderItem* item = [ ASTSliderItem itemWithDict: @{
		AST_cell_slider_continuous : @YES,
	} ];
	
	ASTSliderItemCell* cell = (ASTSliderItemCell*)item.cell;
	XCTAssertEqual( cell.slider.continuous, YES );
}

//------------------------------------------------------------------------------

- (void) testDictionaryMinimumTrackTintColorKey
{
	UIColor* color = [ UIColor redColor ];
	ASTSliderItem* item = [ ASTSliderItem itemWithDict: @{
		AST_cell_slider_minimumTrackTintColor : color,
	} ];
	
	ASTSliderItemCell* cell = (ASTSliderItemCell*)item.cell;
	XCTAssertEqual( cell.slider.minimumTrackTintColor, color );
}

//------------------------------------------------------------------------------

- (void) testDictionaryMaximumTrackTintColorKey
{
#if 0
	UIColor* color = [ UIColor redColor ];
	ASTSliderItem* item = [ ASTSliderItem itemWithDict: @{
		AST_sliderMaximumTrackTintColorKey : color,
	} ];
	
	// Note that there seems to be a bug in iOS 8.3 that causes
	// maximumTrackTintColor to be nil immediately after being set but it will
	// be correct later.
	ASTSliderItemCell* cell = (ASTSliderItemCell*)item.cell;
	XCTAssertEqual( cell.slider.maximumTrackTintColor, color );
#endif
}

//------------------------------------------------------------------------------

- (void) testDictionaryThumbTintColorKey
{
	UIColor* color = [ UIColor redColor ];
	ASTSliderItem* item = [ ASTSliderItem itemWithDict: @{
		AST_cell_slider_thumbTintColor : color,
	} ];
	
	ASTSliderItemCell* cell = (ASTSliderItemCell*)item.cell;
	XCTAssertEqual( cell.slider.thumbTintColor, color );
}

//------------------------------------------------------------------------------

- (void) testDictionarySliderActionAndTargetKeys
{
	ASTSliderItem* item = [ ASTSliderItem itemWithDict: @{
		AST_sliderActionKey : @"testDictionarySliderActionKey",
		AST_sliderTargetKey : self,
	} ];
	
	XCTAssertEqualObjects( NSStringFromSelector( item.sliderValueAction ), @"testDictionarySliderActionKey" );
	XCTAssertEqual( item.sliderValueTarget, self );
}

//------------------------------------------------------------------------------

- (void) testSliderItemActionAndTargetProperties
{
	SliderItemTestTarget* target = [ [ SliderItemTestTarget alloc ] init ];
	ASTSliderItem* item = [ ASTSliderItem item ];
	item.sliderValueAction = @selector(sliderTestAction:);
	item.sliderValueTarget = target;
	
	XCTAssertEqualObjects( NSStringFromSelector( item.sliderValueAction ), @"sliderTestAction:" );
	XCTAssertEqual( item.sliderValueTarget, target );
	
	ASTSliderItemCell* cell = (ASTSliderItemCell*)item.cell;
	
	cell.slider.value = 0.5;
	[ cell.slider sendActionsForControlEvents: UIControlEventValueChanged ];
	
	XCTAssertTrue( target.actionSent );
	XCTAssertEqual( [ [ item valueForKeyPath: AST_cell_slider_value ] floatValue ], 0.5 );
	
	target.actionSent = NO;
	item.sliderValueAction = nil;
	
	[ cell.slider sendActionsForControlEvents: UIControlEventValueChanged ];
	
	XCTAssertFalse( target.actionSent );
}

//------------------------------------------------------------------------------

- (void) testSliderItemActionPropertiesViaKey
{
	ASTSliderItem* item = [ ASTSliderItem item ];
	
	[ item setValue: @"sliderTestAction:" forKey: @"sliderValueAction" ];
	XCTAssertEqualObjects( NSStringFromSelector( item.sliderValueAction ), @"sliderTestAction:" );

	[ item setValue: nil forKey: @"sliderValueAction" ];
	XCTAssertEqual( item.sliderValueAction, nil );
}

//------------------------------------------------------------------------------

- (void) testSetMinimumValueImageName
{
	UISlider* slider = [ [ UISlider alloc ] init ];
	[ slider setMinimumValueImageName: @"ren" ];
	
	XCTAssertNotNil( slider.minimumValueImage );
	
	[ slider setMinimumValueImageName: nil ];
	
	XCTAssertNil( slider.minimumValueImage );
}

//------------------------------------------------------------------------------

- (void) testSetMaximumValueImageName
{
	UISlider* slider = [ [ UISlider alloc ] init ];
	[ slider setMaximumValueImageName: @"ren" ];
	
	XCTAssertNotNil( slider.maximumValueImage );
	
	[ slider setMaximumValueImageName: nil ];
	
	XCTAssertNil( slider.maximumValueImage );
}

//------------------------------------------------------------------------------

@end

//------------------------------------------------------------------------------

@implementation SliderItemTestTarget

//------------------------------------------------------------------------------

- (void) sliderTestAction: (id) sender
{
	self.actionSent = YES;
}

//------------------------------------------------------------------------------

@end
