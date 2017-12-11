//==============================================================================
//
//  ASTItem+Rx.swift
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

import AST
import RxCocoa
import RxSwift
import UIKit


//------------------------------------------------------------------------------

var rx_selected_key: UInt8 = 0

//------------------------------------------------------------------------------

extension Reactive where Base: ASTItem {
	
	//--------------------------------------------------------------------------
	// Bindable sink for `textLabel.text` property.

	public var textLabelText: AnyObserver<String> {
		
		return Binder( self.base ) { item, value in
			item.setValue( value, forKeyPath: AST_cell_textLabel_text )
		}.asObserver()
		
	}
	
	//--------------------------------------------------------------------------
	// Bindable sink for `detailTextLabel.text` property.

	public var detailTextLabelText: AnyObserver<String> {
		
		return Binder( self.base ) { item, value in
			item.setValue( value, forKeyPath: AST_cell_detailTextLabel_text )
		}.asObserver()
		
	}
	
	//--------------------------------------------------------------------------
	// Bindable sink for `imageView.image` property.

	public var imageViewImage: AnyObserver<UIImage> {
		
		return Binder( self.base ) { item, value in
			item.setValue( value, forKeyPath: AST_cell_imageView_image )
		}.asObserver()
		
	}
	
	//--------------------------------------------------------------------------
	// Bindable sink for `accessoryType` property.

	public var accessoryType: AnyObserver<UITableViewCellAccessoryType> {
		
		return Binder( self.base ) { item, value in
			item.setValue( value.rawValue, forKeyPath: AST_cell_accessoryType )
		}.asObserver()
		
	}
	
	//--------------------------------------------------------------------------
	// Bindable sink for `selectable` property.

	public var selectable: AnyObserver<Bool> {
		
		return Binder( self.base ) { item, value in
			item.selectable = value
		}.asObserver()
		
	}
	
	//--------------------------------------------------------------------------
    // Reactive wrapper for return key action
	
    public var selected: ControlEvent<Void> {
		
        let source = lazyInstanceObservable( &rx_selected_key ) { () -> Observable<Void> in
            Observable.create { [weak item = self.base] observer in
                guard let item = item else {
                    observer.on(.completed)
                    return Disposables.create()
                }
				let target = GenericActionTarget<ASTItem>(
					subject: item,
					setter: { item, target, action in
						item.selectActionTarget = target
						item.selectAction = action
					},
					callback: {
						observer.on( .next() )
					}
				)
                return target
            }
            .takeUntil( self.deallocated )
            .share()
        }
        
        return ControlEvent( events: source )
		
    }

	//--------------------------------------------------------------------------
	
	public func value<E>( _ type: E.Type, forKeyPath keyPath: String ) -> AnyObserver<E> {
		
		return Binder( self.base ) { element, value in
			element.setValue( value, forKeyPath: keyPath )
		}.asObserver()
		
	}

}
