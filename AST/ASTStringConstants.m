//==============================================================================
//
//  ASTStringConstants.m
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
#import "ASTSection.h"

#import "ASTTextFieldItem.h"


//------------------------------------------------------------------------------
// The only reason these are defined in this separate file is so they can be
// used by both the tests and the app code. See:
// http://stackoverflow.com/questions/23821947/extern-nsstring-constants-nil-for-test-target

NSString* const AST_id = @"id";
NSString* const AST_itemClass = @"type";
NSString* const AST_cellClass = @"cellClass";
NSString* const AST_cellStyle = @"cellStyle";
NSString* const AST_cellReuseIdentifier = @"cellReuseIdentifier";

NSString* const AST_selectable = @"selectable";
NSString* const AST_selectAction = @"selectAction";
NSString* const AST_selectActionTarget = @"selectActionTarget";
NSString* const AST_selectActionBlock = @"selectActionBlock";

NSString* const AST_targetSelf = @"self";
NSString* const AST_targetTableViewController = @"AST_targetTableViewController";

NSString* const AST_prefKey = @"prefKey";

NSString* const AST_minimumHeight = @"minimumHeight";

NSString* const AST_representedObject = @"representedObject";

//------------------------------------------------------------------------------

NSString* const AST_cell_accessoryType = @"cellProperties.accessoryType";
NSString* const AST_cell_accessoryView = @"cellProperties.accessoryView";
NSString* const AST_cell_backgroundColor = @"cellProperties.backgroundColor";
NSString* const AST_cell_selectedBackgroundColor = @"cellProperties.selectedBackgroundViewBackgroundColor";
NSString* const AST_cell_indentationLevel = @"cellProperties.indentationLevel";
NSString* const AST_cell_indentationWidth = @"cellProperties.indentationWidth";
NSString* const AST_cell_textLabel_text = @"cellProperties.textLabel.text";
NSString* const AST_cell_textLabel_textAlignment = @"cellProperties.textLabel.textAlignment";
NSString* const AST_cell_textLabel_textColor = @"cellProperties.textLabel.textColor";
NSString* const AST_cell_textLabel_highlightedTextColor = @"cellProperties.textLabel.highlightedTextColor";
NSString* const AST_cell_textLabel_font = @"cellProperties.textLabel.font";
NSString* const AST_cell_detailTextLabel_text = @"cellProperties.detailTextLabel.text";
NSString* const AST_cell_detailTextLabel_textColor = @"cellProperties.detailTextLabel.textColor";
NSString* const AST_cell_detailTextLabel_highlightedTextColor = @"cellProperties.detailTextLabel.highlightedTextColor";
NSString* const AST_cell_detailTextLabel_font = @"cellProperties.detailTextLabel.font";
NSString* const AST_cell_imageView_image = @"cellProperties.imageView.image";
NSString* const AST_cell_imageView_imageName = @"cellProperties.imageView.imageName";
NSString* const AST_cell_imageView_highlightedImage = @"cellProperties.imageView.highlightedImage";
NSString* const AST_cell_imageView_highlightedImageName = @"cellProperties.imageView.highlightedImageName";

//------------------------------------------------------------------------------

NSString* const AST_headerText = @"headerText";
NSString* const AST_footerText = @"footerText";
NSString* const AST_headerView = @"headerView";
NSString* const AST_footerView = @"footerView";
NSString* const AST_items = @"items";

//------------------------------------------------------------------------------

NSString* const AST_textFieldValueActionKey = @"textFieldValueAction";
NSString* const AST_textFieldValueTargetKey = @"textFieldValueTarget";
NSString* const AST_textFieldReturnKeyActionKey = @"textFieldReturnKeyAction";
NSString* const AST_textFieldReturnKeyTargetKey = @"textFieldReturnKeyTarget";
NSString* const AST_cell_textInput_text = @"cellProperties.textInput.text";
NSString* const AST_cell_textInput_placeholder = @"cellProperties.textInput.placeholder";
NSString* const AST_cell_textInput_placeholderColor = @"cellProperties.textInput.placeholderColor";
NSString* const AST_cell_textInput_clearButtonMode = @"cellProperties.textInput.clearButtonMode";
NSString* const AST_cell_textInput_returnKeyType = @"cellProperties.textInput.-setReturnKeyType:";
NSString* const AST_cell_textInput_keyboardType = @"cellProperties.textInput.-setKeyboardType:";
NSString* const AST_cell_textInput_secureTextEntry = @"cellProperties.textInput.secureTextEntry";
NSString* const AST_cell_textInput_autocapitalizationType = @"cellProperties.textInput.-setAutocapitalizationType:";
NSString* const AST_cell_textInput_autocorrectionType = @"cellProperties.textInput.-setAutocorrectionType:";
NSString* const AST_cell_textInput_delegate = @"cellProperties.textInput.delegate";

//------------------------------------------------------------------------------

NSString* const AST_textViewValueActionKey = @"textViewValueActionKey";
NSString* const AST_textViewValueTargetKey = @"textViewValueTargetKey";
NSString* const AST_textViewReturnKeyActionKey = @"textViewReturnKeyActionKey";
NSString* const AST_textViewReturnKeyTargetKey = @"textViewReturnKeyTargetKey";
NSString* const AST_cell_textInput_minHeightInLines = @"cellProperties.textInput.minHeightInLines";
NSString* const AST_cell_textInput_maxHeightInLines = @"cellProperties.textInput.maxHeightInLines";

//------------------------------------------------------------------------------

NSString* const AST_sliderActionKey = @"sliderValueAction";
NSString* const AST_sliderTargetKey = @"sliderValueTarget";
NSString* const AST_cell_slider_value = @"cellProperties.slider.value";
NSString* const AST_cell_slider_minimumValue = @"cellProperties.slider.minimumValue";
NSString* const AST_cell_slider_maximumValue = @"cellProperties.slider.maximumValue";
NSString* const AST_cell_slider_minimumValueImage = @"cellProperties.slider.minimumValueImage";
NSString* const AST_cell_slider_minimumValueImageName = @"cellProperties.slider.minimumValueImageName";
NSString* const AST_cell_slider_maximumValueImage = @"cellProperties.slider.maximumValueImage";
NSString* const AST_cell_slider_maximumValueImageName = @"cellProperties.slider.maximumValueImageName";
NSString* const AST_cell_slider_continuous = @"cellProperties.slider.continuous";
NSString* const AST_cell_slider_minimumTrackTintColor = @"cellProperties.slider.minimumTrackTintColor";
NSString* const AST_cell_slider_maximumTrackTintColor = @"cellProperties.slider.maximumTrackTintColor";
NSString* const AST_cell_slider_thumbTintColor = @"cellProperties.slider.thumbTintColor";
NSString* const AST_cell_slider_label_text = @"cellProperties.label.text";

//------------------------------------------------------------------------------

NSString* const AST_switchActionKey = @"switchAction";
NSString* const AST_switchTargetKey = @"switchTarget";
NSString* const AST_cell_switch_on = @"cellProperties.itemSwitch.on";
NSString* const AST_cell_switch_onTintColor = @"cellProperties.itemSwitch.onTintColor";
NSString* const AST_cell_switch_tintColor = @"cellProperties.itemSwitch.tintColor";
NSString* const AST_cell_switch_thumbTintColor = @"cellProperties.itemSwitch.thumbTintColor";

//------------------------------------------------------------------------------

NSString* const AST_prefDefaultValue = @"prefDefaultValue";
NSString* const AST_prefOnValue = @"prefOnValue";
NSString* const AST_prefOffValue = @"prefOffValue";

NSString* const AST_itemIsDefault = @"isDefault";
NSString* const AST_itemPrefValue = @"prefValue";

//------------------------------------------------------------------------------

NSString* const AST_title = @"title";
NSString* const AST_value = @"value";

NSString* const AST_defaultValue = @"defaultValue";
NSString* const AST_values = @"values";
NSString* const AST_presentation = @"presentation";

