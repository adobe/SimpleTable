//==============================================================================
//
//  ASTItem.h
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


#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

//------------------------------------------------------------------------------

extern NSString* const AST_itemClass;
extern NSString* const AST_cellClass;
extern NSString* const AST_cellStyle;
extern NSString* const AST_cellReuseIdentifier;
extern NSString* const AST_id;
extern NSString* const AST_selectable;
extern NSString* const AST_selectAction;
extern NSString* const AST_selectActionTarget;
extern NSString* const AST_selectActionBlock;
extern NSString* const AST_representedObject;
extern NSString* const AST_prefKey;
extern NSString* const AST_minimumHeight;

extern NSString* const AST_cell_indentationLevel;
extern NSString* const AST_cell_indentationWidth;
extern NSString* const AST_cell_accessoryType;
extern NSString* const AST_cell_accessoryView;
extern NSString* const AST_cell_backgroundColor;
extern NSString* const AST_cell_selectedBackgroundColor;
extern NSString* const AST_cell_imageView_image;
extern NSString* const AST_cell_imageView_imageName;
extern NSString* const AST_cell_imageView_highlightedImage;
extern NSString* const AST_cell_imageView_highlightedImageName;
extern NSString* const AST_cell_textLabel_text;
extern NSString* const AST_cell_textLabel_textAlignment;
extern NSString* const AST_cell_textLabel_textColor;
extern NSString* const AST_cell_textLabel_highlightedTextColor;
extern NSString* const AST_cell_textLabel_font;
extern NSString* const AST_cell_detailTextLabel_text;
extern NSString* const AST_cell_detailTextLabel_textColor;
extern NSString* const AST_cell_detailTextLabel_highlightedTextColor;
extern NSString* const AST_cell_detailTextLabel_font;

extern NSString* const AST_targetSelf;
extern NSString* const AST_targetTableViewController;

@class ASTItem;
@class ASTSection;
@class ASTViewController;

typedef void (^ASTItemActionBlock)( ASTItem* item );

//------------------------------------------------------------------------------

@interface ASTItem : NSObject

/// Creates and returns an ASTItem with a cell style of UITableViewCellStyleDefault.
/// @return A new ASTItem.
+ (instancetype) item;

/// Creates and returns an ASTItem with a cell style of UITableViewCellStyleDefault
/// and textLabel text.
/// @param text A string for the textLabel text.
/// @return A new ASTItem.
+ (instancetype) itemWithText: (NSString*) text;

/// Creates and returns an ASTItem with the cell style, textLabel text,
/// and detailTextLabel text.
/// @param style A UITableViewCellStyle.
/// @param text A string for the textLabel text.
/// @param detailText A string for the detailTextLabel text. (Optional)
/// @return A new ASTItem.
+ (instancetype) itemWithStyle: (UITableViewCellStyle) style
		text: (NSString*) title detailText: (NSString* __nullable) detailText;

/// Creates and returns an ASTItem with parameters from a dictionary.
/// - parameter dict: A dictionary of parameters used to configure.
/// @return A new class or subclass of ASTItem.
+ (instancetype) itemWithDict: (NSDictionary*) dict;

/// Creates and returns an ASTItem with a cell style of UITableViewCellStyleDefault
/// and textLabel text.
/// @param text A string for the textLabel text.
/// @return A new ASTItem.
- (instancetype) initWithText: (NSString*) text;

/// Creates and returns an ASTItem with the cell style.
/// @param style A UITableViewCellStyle.
/// @return A new ASTItem.
- (instancetype) initWithCellStyle: (UITableViewCellStyle) style;

/// Creates and returns an ASTItem with the cell style, textLabel text,
/// and detailTextLabel text.
/// @param style A UITableViewCellStyle.
/// @param text A string for the textLabel text.
/// @param detailText A string for the detailTextLabel text. (Optional)
/// @return A new ASTItem.
- (instancetype) initWithStyle: (UITableViewCellStyle) style
		text: (NSString*) text detailText: (NSString* __nullable) detailText;

/// Creates and returns an ASTItem with parameters from a dictionary.
/// - parameter dict: A dictionary of parameters used to configure.
/// @return A new ASTItem.
- (instancetype) initWithDict: (NSDictionary*) dict NS_DESIGNATED_INITIALIZER;

/// The class of the cell for this item. This class must be a subclass of UITableViewCell.
@property (readonly,nonatomic) Class cellClass;

/// The cell style of the cell for this item. Note that not all cell classes
/// use the cellStyle.
@property (readonly,nonatomic) UITableViewCellStyle cellStyle;
/// The cell reuse identifier to be used to create the cell. If this property is
/// nil then the items cell is not created via the table views reuse queue and
/// is created using the cellClass property.
@property (readonly,nullable,nonatomic) NSString* cellReuseIdentifier;

/// The identifier for this item. This is used to find items in a table view
/// by name without having to keep a reference to it.
@property (nullable,nonatomic) NSString* identifier;
/// The represented object can be used to hold any kind of arbitrary data.
@property (nullable,nonatomic) id representedObject;

/// Returns the cell to be used by this item. If the cell is nil then it will
/// be created and returned.
@property (readonly) UITableViewCell* cell;
/// Returns if a cell has been loaded for this item.
@property (readonly) BOOL cellLoaded;

/// Returns a copy of the cell properties. These are all of the properties that
/// will be set on a cell when it is created.
@property (readonly,copy) NSDictionary* cellProperties;

/// The minimum height for the row. The default is 0 which indicates the row
/// height is determined by auto layout. If the row would be taller than the
/// minimumHeight due to auto layout it will be the taller height.
@property CGFloat minimumHeight;

// Selection

/// Determines if the row in the table is selectable.
@property (nonatomic) BOOL selectable;
/// The selector to be called if the row is selected.
@property (nullable,nonatomic) SEL selectAction;
/// The object the selector will be sent to if the row is selected. If this is
/// nil then the selector is sent to the table view controller. If you want the
/// selector sent to the current responder use a value of NSNull.
@property (nullable,nonatomic) id selectActionTarget;
/// The block to be called when a row is selected. Note that the action and
/// block are mutually exclusive and the action has precedence.
@property (nullable,strong,nonatomic) ASTItemActionBlock selectBlock;

/// Perform the selection action for the item, either calling the selector or
/// calling the block, as appropriate.
- (void) performSelectionAction;
/// Deselect the row for this item.
- (void) deselectWithAnimation: (BOOL) animated;

// Editing

/// Determines if the row is editable. Currently used for row deletion.
@property (nonatomic) BOOL editable;
/// The block to be called when the user deletes the row.
@property (nullable,strong,nonatomic) ASTItemActionBlock deleteBlock;

// Containment

/// The current table view controller for this item.
@property (readonly,weak,nullable,nonatomic) ASTViewController* tableViewController;
/// The current section for this item.
@property (readonly,nullable,nonatomic) ASTSection* section;
/// The current indexPath of this item in its table view. Note that this always
/// searches for the item in the table view controller data so it is O(n).
@property (readonly,nullable,nonatomic) NSIndexPath* indexPath;

/// Removes the item from the table view controllers data with the specified
/// animation.
- (void) removeFromContainerWithAnimation: (UITableViewRowAnimation) rowAnimation;

/// Scrolls the table view so that this item is visible.
- (void) scrollToPosition: (UITableViewScrollPosition) position
		animated: (BOOL) animated;

@end

//------------------------------------------------------------------------------

@interface UITableViewCell( ASTItem )

@property (nullable,nonatomic,readonly) UITableView* tableView;

// These properties are useful for using with UIAppearance.
@property (nullable,nonatomic) UIColor* selectedBackgroundViewBackgroundColor UI_APPEARANCE_SELECTOR;
@property (null_resettable,nonatomic) UIFont* textLabelFont UI_APPEARANCE_SELECTOR;
@property (null_resettable,nonatomic) UIColor* textLabelTextColor UI_APPEARANCE_SELECTOR;
@property (nullable,nonatomic) UIColor* textLabelHighlightedTextColor UI_APPEARANCE_SELECTOR;
@property (null_resettable,nonatomic) UIFont* detailTextLabelFont UI_APPEARANCE_SELECTOR;
@property (null_resettable,nonatomic) UIColor* detailTextLabelTextColor UI_APPEARANCE_SELECTOR;
@property (nullable,nonatomic) UIColor* detailTextLabelHighlightedTextColor UI_APPEARANCE_SELECTOR;

@end

//------------------------------------------------------------------------------

@interface UIImageView( ASTItem )

// These methods allow the the image to be set by name. Useful for setting
// the image via cell proprties on ASTItems.
- (void) setImageName: (NSString* __nullable) imageName;
- (void) setHighlightedImageName: (NSString* __nullable) imageName;

@end

NS_ASSUME_NONNULL_END
