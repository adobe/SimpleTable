//==============================================================================
//
//  ASTItem.m
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
#import "ASTItemSubclass.h"

#import "ASTViewController.h"


//------------------------------------------------------------------------------

NSString* const AST_cellPropertiesKeyPathPrefix = @"cellProperties.";

//------------------------------------------------------------------------------

static NSDictionary* removeNullsFromDictionaryLeavingCellProperties( NSDictionary* dict )
{
	NSMutableDictionary* result = [ NSMutableDictionary dictionaryWithCapacity: dict.count ];
	Class nullClass = [ NSNull class ];
	for( id key in  dict ) {
		id value = dict[ key ];
		if( [ key hasPrefix: AST_cellPropertiesKeyPathPrefix ]
				|| [ value isKindOfClass: nullClass ] == NO ) {
			result[ key ] = value;
		}
	}
	return result;
}

//------------------------------------------------------------------------------

@interface ASTItem() {
	CGFloat _minimumHeight;
}

@end

//------------------------------------------------------------------------------

@implementation ASTItem

//------------------------------------------------------------------------------

+ (instancetype) item
{
	return [ [ self alloc ] initWithDict: @{} ];
}

//------------------------------------------------------------------------------

+ (instancetype) itemWithStyle: (UITableViewCellStyle) style
		text: (NSString*) text detailText: (NSString*) detailText
{
	return [ [ ASTItem alloc ] initWithStyle: style
			text: text detailText: detailText ];
}

//------------------------------------------------------------------------------

+ (instancetype) itemWithText: (NSString*) text
{
	return [ self itemWithStyle: UITableViewCellStyleDefault
			text: text detailText: nil ];
}

//------------------------------------------------------------------------------

+ (instancetype) itemWithDict: (NSDictionary*) dict
{
	NSString* className = dict[ AST_itemClass ];
	Class class = className ? NSClassFromString( className ) : [ self class ];
	NSAssert( [ class isSubclassOfClass: [ ASTItem class ] ], @"type \"%@\" must be a subclass of ASTItem", className );
	ASTItem* result = [ [ class alloc ] initWithDict: dict ];
	return result;
}

//------------------------------------------------------------------------------

- (instancetype) init
{
	return [ self initWithCellStyle: UITableViewCellStyleDefault ];
}

//------------------------------------------------------------------------------

- (instancetype) initWithText: (NSString*) text
{
	return [ self initWithStyle: UITableViewCellStyleDefault
			text: text detailText: nil ];
}

//------------------------------------------------------------------------------

- (instancetype) initWithCellStyle: (UITableViewCellStyle) style
{
	NSDictionary* dict = @{
		AST_cellStyle : @(style),
	};
	return [ self initWithDict: dict ];
}

//------------------------------------------------------------------------------

- (instancetype) initWithStyle: (UITableViewCellStyle) style
		text: (NSString*) text detailText: (NSString*) detailText
{
	NSDictionary* dict = @{
		AST_cellStyle : @(style),
		AST_cell_textLabel_text : text ?: [ NSNull null ],
		AST_cell_detailTextLabel_text : detailText ?: [ NSNull null ],
	};
	return [ self initWithDict: dict ];
}

//------------------------------------------------------------------------------

- (instancetype) initWithDict: (NSDictionary*) dict
{
	self = [ super init ];
	if( self ) {
		dict = removeNullsFromDictionaryLeavingCellProperties( dict );

		_identifier = dict[ AST_id ];
		_representedObject = dict[ AST_representedObject ];
		
		id selectActionValue = dict[ AST_selectAction ];
		if( selectActionValue ) {
			NSAssert( [ selectActionValue isKindOfClass: [ NSString class ] ],
					@"%@ should be of type NSString", AST_selectAction );
			_selectAction = NSSelectorFromString( selectActionValue );
			_selectable = YES;
		}

		id selectActionTargetValue = dict[ AST_selectActionTarget ];
		if( selectActionTargetValue ) {
			_selectActionTarget = selectActionTargetValue;
		}
		
		ASTItemActionBlock selectBlock = dict[ AST_selectActionBlock ];
		if( selectBlock ) {
			_selectBlock = selectBlock;
			_selectable = YES;
		}
		
		id selectableValue = dict[ AST_selectable ];
		if( selectableValue ) {
			_selectable = [ selectableValue boolValue ];
		}
		
		id deselectValue = dict[ AST_deselectAutomatically ];
		if( deselectValue ) {
			_deselectAutomatically = [ deselectValue boolValue ];
		}
		
		id cellClassValue = dict[ AST_cellClass ];
		if( cellClassValue ) {
			if( [ cellClassValue isKindOfClass: [ NSString class ] ] ) {
				_cellClass = NSClassFromString( cellClassValue );
				NSAssert1( _cellClass != nil, @"No class found with the name \"%@\"", cellClassValue );
			} else {
				NSAssert1( cellClassValue == [ cellClassValue class ],
						@"Object %@ is not a Class object", cellClassValue );
				_cellClass = cellClassValue;
			}
			NSAssert1( [ _cellClass isSubclassOfClass: [ UITableViewCell class ] ],
					@"Class \"%@\" is not a subclass of Class UITableViewCell", cellClassValue );
		}
		if( _cellClass == nil ) {
			_cellClass = [ ASTCell class ];
		}
		
		_cellStyle = [ dict[ AST_cellStyle ] integerValue ];
		_cellReuseIdentifier = dict[ AST_cellReuseIdentifier ];
		
		id minimumHeightValue = dict[ AST_minimumHeight ];
		if( minimumHeightValue ) {
			_minimumHeight = [ minimumHeightValue floatValue ];
		}
		
		NSMutableDictionary* cellProperties = [ NSMutableDictionary dictionary ];
		for( NSString* key in dict ) {
			if( [ key hasPrefix: AST_cellPropertiesKeyPathPrefix ] ) {
				cellProperties[ key ] = dict[ key ];
			}
		}
		_cellProperties = cellProperties;
	}
	
	return self;
}

//------------------------------------------------------------------------------

- (void) dealloc
{
	[ self didEndDisplayingCell ];
}

//------------------------------------------------------------------------------

- (NSIndexPath*) indexPath
{
	return [ self.tableViewController indexPathForItem: self ];
}

//------------------------------------------------------------------------------

- (void) removeFromContainerWithAnimation: (UITableViewRowAnimation) rowAnimation;
{
	[ self.tableViewController removeItemsAtIndexPaths: @[ self.indexPath ]
			withRowAnimation: rowAnimation ];
}

//------------------------------------------------------------------------------

- (UITableViewCell*) cell
{
	if( _cell == nil ) {
		[ self loadCell ];
	}
	return _cell;
}

//------------------------------------------------------------------------------

- (BOOL) cellLoaded
{
	return _cell != nil;
}

//------------------------------------------------------------------------------

- (void) setValue: (id) value forObject: (id) object forFancyKeypath: (NSString*) fancyKeypath
{
	NSArray* components = [ fancyKeypath componentsSeparatedByString: @"." ];
	NSUInteger componentCount = components.count;
	id currentTarget = object;
	NSUInteger componentIndex = 0;
	for( NSString* component in components ) {
		BOOL lastComponent = componentIndex == componentCount - 1;
		if( [ component hasPrefix: @"-" ] ) {
			SEL keySelector = NSSelectorFromString( [ component substringFromIndex: 1 ] );
			if( lastComponent ) {
				NSMethodSignature* signature = [ currentTarget methodSignatureForSelector: keySelector ];
				NSAssert2( signature != nil, @"No signature for selector: %@ with object: %@", component, currentTarget );
				NSAssert2( [ signature numberOfArguments ] == 3, @"Wrong number of arguments, selector: %@ with object: %@", component, currentTarget );

				__strong NSInvocation* invocation = [ NSInvocation invocationWithMethodSignature: signature ];
				[ invocation setTarget: currentTarget ];
				[ invocation setSelector: keySelector ];
				
				NSUInteger argIndex = 2;
				const char * argType = [ signature getArgumentTypeAtIndex: argIndex ];
				if( strcmp( argType, "@" ) == 0 ) {
					[ invocation setArgument: &value atIndex: argIndex ];
				} else if( strcmp( argType, "*" ) == 0 ) {
					const char* argValue = [ value UTF8String ];
					[ invocation setArgument: &argValue atIndex: argIndex ];
				} else if( strcmp( argType, "r*" ) == 0 ) {
					const char* argValue = [ value UTF8String ];
					[ invocation setArgument: &argValue atIndex: argIndex ];
				} else if( strcmp( argType, "c" ) == 0 ) {
					char argValue = [ value charValue ];
					[ invocation setArgument: &argValue atIndex: argIndex ];
				} else if( strcmp( argType, "i" ) == 0 ) {
					int argValue = [ value intValue ];
					[ invocation setArgument: &argValue atIndex: argIndex ];
				} else if( strcmp( argType, "s" ) == 0 ) {
					short argValue = [ value shortValue ];
					[ invocation setArgument: &argValue atIndex: argIndex ];
				} else if( strcmp( argType, "l" ) == 0 ) {
// LCOV_EXCL_START
					// On 64 bit systems this appears to never get hit. Not
					// sure if we should remove it or not.
					long argValue = [ value longValue ];
					[ invocation setArgument: &argValue atIndex: argIndex ];
// LCOV_EXCL_STOP
				} else if( strcmp( argType, "q" ) == 0 ) {
					long long argValue = [ value longLongValue ];
					[ invocation setArgument: &argValue atIndex: argIndex ];
				} else if( strcmp( argType, "C" ) == 0 ) {
					unsigned char argValue = [ value unsignedCharValue ];
					[ invocation setArgument: &argValue atIndex: argIndex ];
				} else if( strcmp( argType, "I" ) == 0 ) {
					unsigned int argValue = [ value unsignedIntValue ];
					[ invocation setArgument: &argValue atIndex: argIndex ];
				} else if( strcmp( argType, "S" ) == 0 ) {
					unsigned short argValue = [ value unsignedShortValue ];
					[ invocation setArgument: &argValue atIndex: argIndex ];
				} else if( strcmp( argType, "L" ) == 0 ) {
// LCOV_EXCL_START
					// On 64 bit systems this appears to never get hit. Not
					// sure if we should remove it or not.
					unsigned long argValue = [ value unsignedLongValue ];
					[ invocation setArgument: &argValue atIndex: argIndex ];
// LCOV_EXCL_STOP
				} else if( strcmp( argType, "Q" ) == 0 ) {
					unsigned long long argValue = [ value unsignedLongLongValue ];
					[ invocation setArgument: &argValue atIndex: argIndex ];
				} else if( strcmp( argType, "f" ) == 0 ) {
					float argValue = [ value floatValue ];
					[ invocation setArgument: &argValue atIndex: argIndex ];
				} else if( strcmp( argType, "d" ) == 0 ) {
					double argValue = [ value doubleValue ];
					[ invocation setArgument: &argValue atIndex: argIndex ];
				} else if( strcmp( argType, "B" ) == 0 ) {
					BOOL argValue = [ value boolValue ];
					[ invocation setArgument: &argValue atIndex: argIndex ];
				} else if( strcmp( argType, ":" ) == 0 ) {
					SEL argValue = NSSelectorFromString( value );
					[ invocation setArgument: &argValue atIndex: argIndex ];
				} else if( strcmp( argType, "#" ) == 0 ) {
					[ invocation setArgument: &value atIndex: argIndex ];
				} else {
					[ NSException raise: @"Unknown argument type" format: @"Encountered and unknown argument with type %s", argType ];
				}
				[ invocation invoke ];
			} else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
				currentTarget = [ currentTarget performSelector: keySelector ];
#pragma clang diagnostic pop
			}
		} else {
			if( lastComponent ) {
				[ currentTarget setValue: value forKey: component ];
			} else {
				currentTarget = [ currentTarget valueForKey: component ];
			}
		}
		++componentIndex;
	}
}

//------------------------------------------------------------------------------

- (void) loadCell
{
	UITableViewCell* cell = nil;
	
	if( _cellReuseIdentifier ) {
		cell = [ self.tableViewController.tableView
				dequeueReusableCellWithIdentifier: _cellReuseIdentifier
				forIndexPath: self.indexPath ];
		NSAssert( cell != nil, @"Creating cell failed for reuse identifier \"%@\"", _cellReuseIdentifier );
	} else {
		cell = [ [ _cellClass alloc ] initWithStyle: _cellStyle reuseIdentifier: nil ];
		NSAssert( cell != nil, @"Creating cell failed for cell class \"%@\"", NSStringFromClass( _cellClass ) );
	}
	
	_cell = cell;
	
	for( NSString* keyPath in _cellProperties ) {
		id value = _cellProperties[ keyPath ];
		[ self setCellPropertyValue: value forKeyPath: keyPath ];
	}
	
	[ self minimumHeightChanged ];
}

//------------------------------------------------------------------------------

- (void) setCellPropertiesValue: (id) value forKeyPath: (NSString*) keyPath
{
	NSParameterAssert( keyPath );
	
	if( value ) {
		_cellProperties[ keyPath ] = value;
	} else {
		[ _cellProperties removeObjectForKey: keyPath ];
	}
}

//------------------------------------------------------------------------------

- (id) cellPropertiesValueForKeyPath: (NSString*) keyPath
{
	return _cellProperties[ keyPath ];
}

//------------------------------------------------------------------------------

- (void) setCellPropertyValue: (id) value forKeyPath: (NSString*) keyPath
{
	NSParameterAssert( keyPath );
	
	if( _cell ) {
		if( [ value isEqual: [ NSNull null ] ] ) {
			value = nil;
		}
		NSString* remainder = [ keyPath substringFromIndex: AST_cellPropertiesKeyPathPrefix.length ];
		[ self setValue: value forObject: _cell forFancyKeypath: remainder ];
	}
}

//------------------------------------------------------------------------------

- (NSDictionary*) cellProperties
{
	return [ _cellProperties copy ];
}

//------------------------------------------------------------------------------

- (void) setValue: (id) value forKeyPath: (NSString*) keyPath
{
	if( [ keyPath hasPrefix: AST_cellPropertiesKeyPathPrefix ] ) {
		[ self setCellPropertiesValue: value forKeyPath: keyPath ];
		[ self setCellPropertyValue: value forKeyPath: keyPath ];
	} else {
// LCOV_EXCL_START
		[ super setValue: value forKeyPath: keyPath ];
// LCOV_EXCL_STOP
	}
}

//------------------------------------------------------------------------------

- (id) valueForKeyPath: (NSString*) keyPath
{
	id result = nil;
	if( [ keyPath hasPrefix: AST_cellPropertiesKeyPathPrefix ] ) {
		result = [ self cellPropertiesValueForKeyPath: keyPath ];
	} else {
// LCOV_EXCL_START
		result = [ super valueForKeyPath: keyPath ];
// LCOV_EXCL_STOP
	}
	return result;
}

//------------------------------------------------------------------------------

- (void) setMinimumHeight: (CGFloat) minimumHeight
{
	_minimumHeight = minimumHeight;
	[ self minimumHeightChanged ];
}

//------------------------------------------------------------------------------

- (CGFloat) minimumHeight
{
	return _minimumHeight;
}

//------------------------------------------------------------------------------

- (void) minimumHeightChanged
{
	NSLayoutConstraint* minimumHeightConstraint = nil;
	for( NSLayoutConstraint* constraint in _cell.constraints ) {
		if( [ constraint.identifier isEqualToString: @"minimumHeightConstraint" ] ) {
			minimumHeightConstraint = constraint;
			break;
		}
	}
	
	if( _minimumHeight == 0 && minimumHeightConstraint != nil ) {
		minimumHeightConstraint.active = NO;
	}
	if( _minimumHeight > 0 && _cell != nil ) {
		if( minimumHeightConstraint != nil ) {
			minimumHeightConstraint.constant = _minimumHeight;
		} else {
			minimumHeightConstraint = [ NSLayoutConstraint
				constraintWithItem: _cell.contentView
				attribute: NSLayoutAttributeHeight
				relatedBy: NSLayoutRelationGreaterThanOrEqual
				toItem: nil
				attribute: NSLayoutAttributeHeight
				multiplier: 1
				constant: _minimumHeight
			];
			minimumHeightConstraint.identifier = @"minimumHeightConstraint";
			minimumHeightConstraint.active = YES;
		}
	}
}

//------------------------------------------------------------------------------

- (void) performSelectionAction
{
	if( _selectAction ) {
		id target = [ self resolveTargetObjectReference: _selectActionTarget ];
		[ self sendAction: _selectAction to: target ];
	} else if( _selectBlock ) {
		_selectBlock( self );
	}
	
	if( _deselectAutomatically ) {
		[ self deselectWithAnimation: YES ];
	}
}

//------------------------------------------------------------------------------

- (void) selectWithAnimation: (BOOL) animated
		scrollPosition: (UITableViewScrollPosition) scrollPosition
{
	[ self.tableViewController selectItem: self withAnimation: animated
			scrollPosition: scrollPosition ];
}

//------------------------------------------------------------------------------

- (void) deselectWithAnimation: (BOOL) animated
{
	[ self.tableViewController deselectItem: self withAnimation: animated ];
}

//------------------------------------------------------------------------------

- (id) resolveTargetObjectReference: (id) objectReference
{
	if( objectReference == nil ) {
		objectReference = self.tableViewController;
	} else if( [ objectReference isKindOfClass: [ NSString class ] ] ) {
		if( [ objectReference isEqualToString: AST_targetSelf ] ) {
			objectReference = self;
		} else if( [ objectReference isEqualToString: AST_targetTableViewController ] ) {
			objectReference = self.tableViewController;
		}
	} else if( [ objectReference isKindOfClass: [ NSNull class ] ] ) {
		objectReference = nil;
	}
	return objectReference;
}

//------------------------------------------------------------------------------

- (void) sendAction: (SEL) action to: (id) target
{
	// In an app we can do the following but this is not available in an
	// extension. So for now if the target is nil we start at the table view
	// controller and go up the responder chain from there. Perhaps we want to
	// still use the old code if an app is being built.
	
//		[ [ UIApplication sharedApplication ] sendAction: _selectAction
//				to: target from: self forEvent: nil ];
	
	UIResponder* actualTarget = target;
	if( actualTarget == nil ) {
		actualTarget = [ [ self tableViewController ] targetForAction: action withSender: self ];
	}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	[ (id)actualTarget performSelector: action withObject: self	];
#pragma clang diagnostic pop
}

//------------------------------------------------------------------------------

- (void) didEndDisplayingCell
{
	// The behavior of UITableView has changed so we can no longer depend on
	// this call to mean the cell is going away.
}

//------------------------------------------------------------------------------

- (void) scrollToPosition: (UITableViewScrollPosition) position
		animated: (BOOL) animated
{
	NSIndexPath* indexPath = self.indexPath;
	UITableView* tableView = self.tableViewController.tableView;
	if( tableView && indexPath ) {
		[ tableView scrollToRowAtIndexPath: indexPath
				atScrollPosition: position
				animated: animated ];
	}
}

//------------------------------------------------------------------------------

@end

//------------------------------------------------------------------------------

@implementation UITableViewCell( ASTItem )

//------------------------------------------------------------------------------

- (UITableView*) tableView
{
	UIView* parent = self;
	while( parent ) {
		if( [ parent isKindOfClass: [ UITableView class ] ] ) {
			return (UITableView*)parent;
		}
		parent = parent.superview;
	}
	return nil;
}

//------------------------------------------------------------------------------

- (void) setSelectedBackgroundViewBackgroundColor: (UIColor*) newColor
{
	// TODO: This generates a new view every time a color is set. Can we
	// only create the view is none is there already?
	UIView* selectedBackgroundView = [ [ UIView alloc ] initWithFrame: self.bounds ];
	selectedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth
			| UIViewAutoresizingFlexibleHeight;
	selectedBackgroundView.backgroundColor = newColor;
	self.selectedBackgroundView = selectedBackgroundView;
}

//------------------------------------------------------------------------------

- (UIColor*) selectedBackgroundViewBackgroundColor
{
	return self.selectedBackgroundView.backgroundColor;
}

//------------------------------------------------------------------------------

- (void) setTextLabelFont: (UIFont*) font
{
	self.textLabel.font = font;
}

//------------------------------------------------------------------------------

- (UIFont*) textLabelFont
{
	return self.textLabel.font;
}

//------------------------------------------------------------------------------

- (void) setTextLabelTextColor: (UIColor*) newColor
{
	self.textLabel.textColor = newColor;
}

//------------------------------------------------------------------------------

- (UIColor*) textLabelTextColor
{
	return self.textLabel.textColor;
}

//------------------------------------------------------------------------------

- (void)  setTextLabelHighlightedTextColor: (UIColor*) newColor
{
	self.textLabel.highlightedTextColor = newColor;
}

//------------------------------------------------------------------------------

- (UIColor*) textLabelHighlightedTextColor
{
	return self.textLabel.highlightedTextColor;
}

//------------------------------------------------------------------------------

- (void) setDetailTextLabelFont: (UIFont*) font
{
	self.detailTextLabel.font = font;
}

//------------------------------------------------------------------------------

- (UIFont*) detailTextLabelFont
{
	return self.detailTextLabel.font;
}

//------------------------------------------------------------------------------

- (void) setDetailTextLabelTextColor: (UIColor*) newColor
{
	self.detailTextLabel.textColor = newColor;
}

//------------------------------------------------------------------------------

- (UIColor*) detailTextLabelTextColor
{
	return self.detailTextLabel.textColor;
}

//------------------------------------------------------------------------------

- (void) setDetailTextLabelHighlightedTextColor: (UIColor*) newColor
{
	self.detailTextLabel.highlightedTextColor = newColor;
}

//------------------------------------------------------------------------------

- (UIColor*) detailTextLabelHighlightedTextColor
{
	return self.detailTextLabel.highlightedTextColor;
}

//------------------------------------------------------------------------------

@end

//------------------------------------------------------------------------------

@implementation UIImageView( ASTItem )

//------------------------------------------------------------------------------

- (void) setImageName: (NSString*) imageName
{
	UIImage* image = imageName ? [ UIImage imageNamed: imageName ] : nil;
	[ self setImage: image ];
}

//------------------------------------------------------------------------------

- (void) setHighlightedImageName: (NSString*) imageName
{
	UIImage* image = imageName ? [ UIImage imageNamed: imageName ] : nil;
	[ self setHighlightedImage: image ];
}

//------------------------------------------------------------------------------

@end

//------------------------------------------------------------------------------

@implementation ASTCell

@end
