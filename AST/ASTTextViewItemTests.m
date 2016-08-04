//==============================================================================
//
//  ASTTextViewItemTests.m
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

#import "ASTTextFieldItem.h"

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>


//------------------------------------------------------------------------------

@interface TextViewItemTestTarget : NSObject

@property (nonatomic) BOOL actionSent;

- (void) textViewTestAction: (id) sender;

@end

//------------------------------------------------------------------------------

@interface ASTTextViewItemTests : XCTestCase

@end

//------------------------------------------------------------------------------

@implementation ASTTextViewItemTests

//------------------------------------------------------------------------------

- (void) testValueTargetActions
{
	TextViewItemTestTarget* target = [ [ TextViewItemTestTarget alloc ] init ];
	ASTTextViewItem* item = [ ASTTextViewItem item ];
	item.textViewValueAction = @selector(textViewTestAction:);
	item.textViewValueTarget = target;
	
	XCTAssertEqualObjects( NSStringFromSelector( item.textViewValueAction ), @"textViewTestAction:" );
	XCTAssertEqual( item.textViewValueTarget, target );
	
	ASTTextViewItemCell* cell = (ASTTextViewItemCell*)item.cell;
	
	cell.textInput.text = @"foo";
	NSNotificationCenter* nc = [ NSNotificationCenter defaultCenter ];
	[ nc postNotificationName: UITextViewTextDidChangeNotification object: cell.textInput ];
	
	XCTAssertTrue( target.actionSent );
	XCTAssertEqualObjects( [ item valueForKeyPath: AST_cell_textInput_text ], @"foo" );
	
	target.actionSent = NO;
	item.textViewValueAction = nil;
	
	[ nc postNotificationName: UITextViewTextDidChangeNotification object: cell.textInput ];
	
	XCTAssertFalse( target.actionSent );
}

//------------------------------------------------------------------------------

- (void) testPlaceholderKey
{
	ASTTextViewItem* item = [ ASTTextViewItem itemWithDict: @{
		AST_cell_textInput_placeholder : @"Placeholder",
	} ];
	ASTTextViewItemCell* cell = (ASTTextViewItemCell*)item.cell;
	XCTAssertEqual( cell.textInput.placeholder, @"Placeholder" );
}

//------------------------------------------------------------------------------

- (void) testReturnKeyTypeKey
{
	ASTTextViewItem* item = [ ASTTextViewItem itemWithDict: @{
		AST_cell_textInput_returnKeyType : @(UIReturnKeyYahoo),
	} ];
	
	ASTTextViewItemCell* cell = (ASTTextViewItemCell*)item.cell;
	XCTAssertEqual( cell.textInput.returnKeyType, UIReturnKeyYahoo );
}

//------------------------------------------------------------------------------

- (void) testKeyboardTypeKey
{
	ASTTextViewItem* item = [ ASTTextViewItem itemWithDict: @{
		AST_cell_textInput_keyboardType : @(UIKeyboardTypePhonePad),
	} ];
	
	ASTTextViewItemCell* cell = (ASTTextViewItemCell*)item.cell;
	XCTAssertEqual( cell.textInput.keyboardType, UIKeyboardTypePhonePad );
}

//------------------------------------------------------------------------------

- (void) testAutocapitalizationTypeKey
{
	ASTTextViewItem* item = [ ASTTextViewItem itemWithDict: @{
		AST_cell_textInput_autocapitalizationType : @(UITextAutocapitalizationTypeAllCharacters),
	} ];
	
	ASTTextViewItemCell* cell = (ASTTextViewItemCell*)item.cell;
	XCTAssertEqual( cell.textInput.autocapitalizationType, UITextAutocapitalizationTypeAllCharacters );
}

//------------------------------------------------------------------------------

- (void) testAutocorrectionTypeKey
{
	ASTTextViewItem* item = [ ASTTextViewItem itemWithDict: @{
		AST_cell_textInput_autocorrectionType : @(UITextAutocorrectionTypeYes),
	} ];
	
	ASTTextViewItemCell* cell = (ASTTextViewItemCell*)item.cell;
	XCTAssertEqual( cell.textInput.autocorrectionType, UITextAutocorrectionTypeYes );
}

//------------------------------------------------------------------------------

- (void) testTextInputDelegateKey
{
	ASTTextViewItem* item = [ ASTTextViewItem itemWithDict: @{
		AST_cell_textInput_delegate : self,
	} ];
	
	ASTTextViewItemCell* cell = (ASTTextViewItemCell*)item.cell;
	XCTAssertEqualObjects( cell.textInput.delegate, self );
}

//------------------------------------------------------------------------------

- (void) testTextFieldPlaceholderColorKey
{
	UIColor* placeholderColor = [ UIColor cyanColor ];
	ASTTextViewItem* item = [ ASTTextViewItem itemWithDict: @{
		AST_cell_textInput_placeholderColor : placeholderColor,
	} ];
	
	ASTTextViewItemCell* cell = (ASTTextViewItemCell*)item.cell;
	XCTAssertEqualObjects( cell.textInput.placeholderColor, placeholderColor );
}

//------------------------------------------------------------------------------

- (void) testMinAndMaxHeightInLinesKeys
{
	ASTTextViewItem* item = [ ASTTextViewItem itemWithDict: @{
		AST_cell_textInput_minHeightInLines : @2,
		AST_cell_textInput_maxHeightInLines : @10,
	} ];
	
	ASTTextViewItemCell* cell = (ASTTextViewItemCell*)item.cell;
	XCTAssertEqual( cell.textInput.minHeightInLines, 2 );
	XCTAssertEqual( cell.textInput.maxHeightInLines, 10 );
}

//------------------------------------------------------------------------------

@end

//------------------------------------------------------------------------------

@implementation TextViewItemTestTarget

//------------------------------------------------------------------------------

- (void) textViewTestAction: (id) sender
{
	self.actionSent = YES;
}

//------------------------------------------------------------------------------

@end
