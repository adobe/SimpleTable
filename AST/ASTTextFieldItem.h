//==============================================================================
//
//  ASTTextFieldItem.h
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

#import "ASTItem.h"


NS_ASSUME_NONNULL_BEGIN

//------------------------------------------------------------------------------

extern NSString* const AST_textFieldValueActionKey;
extern NSString* const AST_textFieldValueTargetKey;
extern NSString* const AST_textFieldReturnKeyActionKey;
extern NSString* const AST_textFieldReturnKeyTargetKey;

extern NSString* const AST_cell_textInput_text;
extern NSString* const AST_cell_textInput_placeholder;
extern NSString* const AST_cell_textInput_placeholderColor;
extern NSString* const AST_cell_textInput_clearButtonMode;
extern NSString* const AST_cell_textInput_returnKeyType;
extern NSString* const AST_cell_textInput_keyboardType;
extern NSString* const AST_cell_textInput_secureTextEntry;
extern NSString* const AST_cell_textInput_autocapitalizationType;
extern NSString* const AST_cell_textInput_autocorrectionType;
extern NSString* const AST_cell_textInput_delegate;

@class ASTTextField;

//------------------------------------------------------------------------------

@interface ASTTextFieldItem : ASTItem

@property (nullable,weak,nonatomic) id textFieldValueTarget;
@property (nullable,nonatomic) SEL textFieldValueAction;
@property (nullable,weak,nonatomic) id textFieldReturnKeyTarget;
@property (nullable,nonatomic) SEL textFieldReturnKeyAction;

@property(nonatomic,readonly,getter=isEditing) BOOL editing;

- (void) becomeFirstResponder;

@end

//------------------------------------------------------------------------------

@interface ASTTextFieldItemCell : UITableViewCell

@property (readonly,nullable,nonatomic) ASTTextField* textInput;
@property (readonly,nullable,nonatomic) UILabel* textLabel;

@end

//------------------------------------------------------------------------------

@interface ASTTextField : UITextField

@property (copy,nullable,nonatomic) UIColor* placeholderColor;

@end

//------------------------------------------------------------------------------

NS_ASSUME_NONNULL_END
