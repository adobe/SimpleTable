//==============================================================================
//
//  ASTSection.h
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

extern NSString* const AST_headerText;
extern NSString* const AST_footerText;
extern NSString* const AST_items;

//------------------------------------------------------------------------------

@class ASTItem;
@class ASTViewController;

//------------------------------------------------------------------------------

@interface ASTSection : NSObject

/// Creates and returns an ASTSection.
/// @return A new ASTSection.
+ (instancetype) section;
/// Creates and returns an ASTSection containing the array of items.
/// @param items The array of items to be contained in the section.
/// @return A new ASTSection.
+ (instancetype) sectionWithItems: (NSArray*) items;
/// Creates and returns an ASTSection with the header text and containing the
/// array of items.
/// @param headerText The string to be used as the header text.
/// @param array The array of items to be contained in the section.
/// @return A new ASTSection.
+ (instancetype) sectionWithHeaderText: (NSString*) headerText
		items: (NSArray*) items;
/// Creates and returns an ASTSection configured using the contents of the
/// dictionary. See the list of key strings in ASTSection.h.
/// @param dict The dictionary of configuration parameters for the section.
/// @return A new ASTSection.
+ (instancetype) sectionWithDict: (NSDictionary*) dict;

/// Initializes and returns an ASTSection.
/// @return A new ASTSection.
- (instancetype) init;
/// Initializes and returns an ASTSection containing the array of items.
/// @param items The array of items to be contained in the section.
/// @return A new ASTSection.
- (instancetype) initWithItems: (NSArray*) items;
/// Initializes and returns an ASTSection with the header text and containing the
/// array of items.
/// @param headerText The string to be used as the header text.
/// @param array The array of items to be contained in the section.
/// @return A new ASTSection.
- (instancetype) initWithHeaderText: (NSString*) headerText items: (NSArray*) items;
/// Initializes and returns an ASTSection configured using the contents of the
/// dictionary. See the list of key strings in ASTSection.h.
/// @param dict The dictionary of configuration parameters for the section.
/// @return A new ASTSection.
- (instancetype) initWithDict: (NSDictionary*) dict NS_DESIGNATED_INITIALIZER;

/// Identifier for the section. This can be used to search for the section or to
/// identify the section in a callback.
@property (nullable,nonatomic) NSString* identifier;

/// The text to be displayed in the header.
@property (nullable,nonatomic) NSString* headerText;
/// The text to be displayed in the footer.
@property (nullable,nonatomic) NSString* footerText;

// Containment

/// The ASTViewController the section is currently contained in. May be nil if
/// the section is not currently installed in a table view controller.
@property (readonly,nullable,weak,nonatomic) ASTViewController* tableViewController;
/// The index of the section if it is currently installed in a table view
/// controller.
@property (readonly,nonatomic) NSInteger index;

/// Removes the section from its container using the specified row animation.
- (void) removeFromContainerWithRowAnimation: (UITableViewRowAnimation) animation;

/// Returns a copy of the sections items.
@property (copy,nonatomic) NSArray* items;
/// The number of items in the section.
@property (readonly,nonatomic) NSUInteger numberOfItems;

/// Returns the item at the specified index or nil if the index is invalid.
/// @param index An index number identifying an item of section.
/// @return The item at the index or nil if the index is invalid.
- (ASTItem* __nullable) itemAtIndex: (NSUInteger) index;
/// Returns the first item with the identifier or nil if there is no
/// item with the identifier.
/// @param identifier A string identifying the item to return.
/// @return The first item with an identifier matching the identifier or nil
/// if no matching item is found.
- (ASTItem* __nullable) itemWithIdentifier: (NSString*) identifier;
/// Returns the first item with a representedObject that matches the parameter.
/// The objects are compared with isEqual:. The parameter may be nil.
/// @param representedObject An object to compare to the representedObject of
/// each of the items. May be nil.
/// @return The first item with a represented object matching the parameter or
/// nil if no matching item is found.
- (ASTItem* __nullable) itemWithRepresentedObject: (id) representedObject;

/// Inserts items in the section at the locations identified by an array of
/// indexes, with an option to animate the insertion.
/// @param items An array of ASTItem objects.
/// @param indexes An array of NSNumber objects.
/// @param animation A constant that either specifies the kind of animation to
/// perform when inserting the items or requests no animation.
- (void) insertItems: (NSArray*) items atIndexes: (NSArray*) indexes
		withRowAnimation: (UITableViewRowAnimation) animation;
/// Removes the items specified by an array of indexes, with an option to
/// animate the removal.
/// @param indexes An array of NSNumber objects.
/// @param animation A constant that either specifies the kind of animation to
/// perform when removing the items or requests no animation.
- (void) removeItemsAtIndexes: (NSArray*) indexes
		withRowAnimation: (UITableViewRowAnimation) animation;
/// Moves an item from one location to another within the section.
/// @param index An index identifying the item to move.
/// @param newIndex An index identifying the item that is the destination of the
/// item at index. The existing item at that location slides up or down to an
/// adjoining index position to make room for it.
- (void) moveItemAtIndex: (NSUInteger) index toIndex: (NSUInteger) newIndex;

@end

NS_ASSUME_NONNULL_END
