//==============================================================================
//
//  ASTSliderItem.h
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

extern NSString* const AST_sliderActionKey;
extern NSString* const AST_sliderTargetKey;

extern NSString* const AST_cell_slider_value;
extern NSString* const AST_cell_slider_minimumValue;
extern NSString* const AST_cell_slider_maximumValue;
extern NSString* const AST_cell_slider_minimumValueImage;
extern NSString* const AST_cell_slider_minimumValueImageName;
extern NSString* const AST_cell_slider_maximumValueImage;
extern NSString* const AST_cell_slider_maximumValueImageName;
extern NSString* const AST_cell_slider_continuous;
extern NSString* const AST_cell_slider_minimumTrackTintColor;
extern NSString* const AST_cell_slider_maximumTrackTintColor;
extern NSString* const AST_cell_slider_thumbTintColor;
extern NSString* const AST_cell_slider_label_text;

//------------------------------------------------------------------------------

@interface ASTSliderItem : ASTItem

@property (nullable,assign,nonatomic) id sliderValueTarget;
@property (nullable,assign,nonatomic) SEL sliderValueAction;

@end

//------------------------------------------------------------------------------

@interface ASTSliderItemCell : UITableViewCell

@property (readonly,nonatomic) UISlider* slider;
@property (readonly,nullable,nonatomic) UILabel* textLabel;

@end

//------------------------------------------------------------------------------

@interface UISlider( ASTItem )

- (void) setMinimumValueImageName: (NSString* __nullable) imageName;
- (void) setMaximumValueImageName: (NSString* __nullable) imageName;

@end

NS_ASSUME_NONNULL_END
