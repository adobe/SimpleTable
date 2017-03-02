//==============================================================================
//
//  ASTTextViewItem.h
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

extern NSString* const AST_textViewValueActionKey;
extern NSString* const AST_textViewValueTargetKey;
extern NSString* const AST_textViewReturnKeyActionKey;
extern NSString* const AST_textViewReturnKeyTargetKey;

extern NSString* const AST_cell_textInput_minHeightInLines;
extern NSString* const AST_cell_textInput_maxHeightInLines;

@class ASTTextView;

//------------------------------------------------------------------------------

@interface ASTTextViewItem : ASTItem

@property (nullable,assign,nonatomic) id textViewValueTarget;
@property (nullable,assign,nonatomic) SEL textViewValueAction;
@property (nullable,weak,nonatomic) id textViewReturnKeyTarget;
@property (nullable,nonatomic) SEL textViewReturnKeyAction;

- (void) becomeFirstResponder;

@end

//------------------------------------------------------------------------------

@interface ASTTextView : UITextView

@property (copy,nullable,nonatomic) NSString* placeholder;
@property (copy,nullable,nonatomic) UIColor* placeholderColor;
@property (nonatomic) NSUInteger minHeightInLines;
@property (nonatomic) NSUInteger maxHeightInLines;

@end

//------------------------------------------------------------------------------

@interface ASTTextViewItemCell : UITableViewCell

@property (readonly,nullable,nonatomic) ASTTextView* textInput;

@end

//------------------------------------------------------------------------------

NS_ASSUME_NONNULL_END
