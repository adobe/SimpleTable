//==============================================================================
//
//  ASTTextFieldItemTests.m
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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>


//------------------------------------------------------------------------------

@interface TextFieldItemTestTarget : NSObject

@property (nonatomic) BOOL actionSent;

- (void) textFieldTestAction: (id) sender;

@end

//------------------------------------------------------------------------------

@interface ASTTextFieldItemTests : XCTestCase

@end

//------------------------------------------------------------------------------

@implementation ASTTextFieldItemTests

//------------------------------------------------------------------------------

- (void) testValueTargetActions
{
	TextFieldItemTestTarget* target = [ [ TextFieldItemTestTarget alloc ] init ];
	ASTTextFieldItem* item = [ ASTTextFieldItem item ];
	item.textFieldValueAction = @selector(textFieldTestAction:);
	item.textFieldValueTarget = target;
	
	XCTAssertEqualObjects( NSStringFromSelector( item.textFieldValueAction ), @"textFieldTestAction:" );
	XCTAssertEqual( item.textFieldValueTarget, target );
	
	ASTTextFieldItemCell* cell = (ASTTextFieldItemCell*)item.cell;
	
	cell.textInput.text = @"foo";
	[ cell.textInput sendActionsForControlEvents: UIControlEventEditingChanged ];
	
	XCTAssertTrue( target.actionSent );
	XCTAssertEqualObjects( [ item valueForKeyPath: AST_cell_textInput_text ], @"foo" );
	
	target.actionSent = NO;
	item.textFieldValueAction = nil;
	
	[ cell.textInput sendActionsForControlEvents: UIControlEventEditingChanged ];
	
	XCTAssertFalse( target.actionSent );
}

//------------------------------------------------------------------------------

- (void) testPlaceholderKey
{
	ASTTextFieldItem* item = [ ASTTextFieldItem itemWithDict: @{
		AST_cell_textInput_placeholder : @"Placeholder",
	} ];
	
	ASTTextFieldItemCell* cell = (ASTTextFieldItemCell*)item.cell;
	XCTAssertEqual( cell.textInput.placeholder, @"Placeholder" );
}

//------------------------------------------------------------------------------

- (void) testClearButtonModeKey
{
	ASTTextFieldItem* item = [ ASTTextFieldItem itemWithDict: @{
		AST_cell_textInput_clearButtonMode : @(UITextFieldViewModeWhileEditing),
	} ];
	
	ASTTextFieldItemCell* cell = (ASTTextFieldItemCell*)item.cell;
	XCTAssertEqual( cell.textInput.clearButtonMode, UITextFieldViewModeWhileEditing );
}

//------------------------------------------------------------------------------

- (void) testReturnKeyTypeKey
{
	ASTTextFieldItem* item = [ ASTTextFieldItem itemWithDict: @{
		AST_cell_textInput_returnKeyType : @(UIReturnKeyYahoo),
	} ];
	
	ASTTextFieldItemCell* cell = (ASTTextFieldItemCell*)item.cell;
	XCTAssertEqual( cell.textInput.returnKeyType, UIReturnKeyYahoo );
}

//------------------------------------------------------------------------------

- (void) testKeyboardTypeKey
{
	ASTTextFieldItem* item = [ ASTTextFieldItem itemWithDict: @{
		AST_cell_textInput_keyboardType : @(UIKeyboardTypePhonePad),
	} ];
	
	ASTTextFieldItemCell* cell = (ASTTextFieldItemCell*)item.cell;
	XCTAssertEqual( cell.textInput.keyboardType, UIKeyboardTypePhonePad );
}

//------------------------------------------------------------------------------

- (void) testSecureTextEntryKey
{
	ASTTextFieldItem* item = [ ASTTextFieldItem itemWithDict: @{
		AST_cell_textInput_secureTextEntry : @YES,
	} ];
	
	ASTTextFieldItemCell* cell = (ASTTextFieldItemCell*)item.cell;
	XCTAssertEqual( cell.textInput.secureTextEntry, YES );
}

//------------------------------------------------------------------------------

- (void) testAutocapitalizationTypeKey
{
	ASTTextFieldItem* item = [ ASTTextFieldItem itemWithDict: @{
		AST_cell_textInput_autocapitalizationType : @(UITextAutocapitalizationTypeAllCharacters),
	} ];
	
	ASTTextFieldItemCell* cell = (ASTTextFieldItemCell*)item.cell;
	XCTAssertEqual( cell.textInput.autocapitalizationType, UITextAutocapitalizationTypeAllCharacters );
}

//------------------------------------------------------------------------------

- (void) testAutocorrectionTypeKey
{
	ASTTextFieldItem* item = [ ASTTextFieldItem itemWithDict: @{
		AST_cell_textInput_autocorrectionType : @(UITextAutocorrectionTypeYes),
	} ];
	
	ASTTextFieldItemCell* cell = (ASTTextFieldItemCell*)item.cell;
	XCTAssertEqual( cell.textInput.autocorrectionType, UITextAutocorrectionTypeYes );
}

//------------------------------------------------------------------------------

- (void) testTextFieldDelegateKey
{
	ASTTextFieldItem* item = [ ASTTextFieldItem itemWithDict: @{
		AST_cell_textInput_delegate : self,
	} ];
	
	ASTTextFieldItemCell* cell = (ASTTextFieldItemCell*)item.cell;
	XCTAssertEqualObjects( cell.textInput.delegate, self );
}

//------------------------------------------------------------------------------

- (void) testTextFieldPlaceholderColorKey
{
	UIColor* placeholderColor = [ UIColor cyanColor ];
	ASTTextFieldItem* item = [ ASTTextFieldItem itemWithDict: @{
		AST_cell_textInput_placeholderColor : placeholderColor,
	} ];
	
	ASTTextFieldItemCell* cell = (ASTTextFieldItemCell*)item.cell;
	XCTAssertEqualObjects( cell.textInput.placeholderColor, placeholderColor );
}

//------------------------------------------------------------------------------

- (void) testTextFieldWithLabel
{
	ASTTextFieldItem* item = [ ASTTextFieldItem itemWithDict: @{
		AST_cell_textLabel_text : @"Foo",
	} ];
	
	ASTTextFieldItemCell* cell = (ASTTextFieldItemCell*)item.cell;
	XCTAssertEqualObjects( cell.textLabel.text, @"Foo" );
}

//------------------------------------------------------------------------------

@end

//------------------------------------------------------------------------------

@implementation TextFieldItemTestTarget

//------------------------------------------------------------------------------

- (void) textFieldTestAction: (id) sender
{
	self.actionSent = YES;
}

//------------------------------------------------------------------------------

@end
