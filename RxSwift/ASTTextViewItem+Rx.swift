//==============================================================================
//
//  ASTTextViewItem+Rx.swift
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

var rx_ASTTextViewItem_text_key: UInt8 = 0
var rx_ASTTextViewItem_return_key: UInt8 = 0

extension Reactive where Base: ASTTextViewItem {
	
	//--------------------------------------------------------------------------
	// Bindable sink for `enabled` property.

	public var enabled: AnyObserver<Bool> {
		
		return Binder( self.base ) { textViewItem, value in
			textViewItem.setValue( value, forKeyPath: "cellProperties.textInput.enabled" )
		}.asObserver()
		
	}
	
	//--------------------------------------------------------------------------
	// Bindable sink for to make text view active.

	public var becomeFirstResponder: AnyObserver<Void> {
		
		return Binder( self.base ) { textViewItem, _ in
			textViewItem.becomeFirstResponder()
		}.asObserver()
		
	}
	
	//--------------------------------------------------------------------------
	// Reactive wrapper for `text` property.
	
	public var text: ControlProperty<String> {
		
		let source = lazyInstanceObservable( &rx_ASTTextViewItem_text_key ) { () -> Observable<String> in
			let initialValue = self.base.value( forKeyPath: AST_cell_textInput_text ) as? String ?? ""
			return Observable.create { [weak item = self.base] observer in
				guard let item = item else {
					observer.on( .completed )
					return Disposables.create()
				}
				let target = GenericActionTarget<ASTTextViewItem>(
					subject: item,
					setter: { textViewItem, target, action in
						textViewItem.textViewValueTarget = target
						textViewItem.textViewValueAction = action
					},
					callback: {
						observer.on( .next( item.value( forKeyPath: AST_cell_textInput_text ) as? String ?? "" ) )
					}
				)
				return target
			}
			.takeUntil( self.deallocated )
			.startWith( initialValue )
			.share()
		}

		let bindingObserver = Binder<String>( self.base, binding: { (textViewItem, text) -> () in
			textViewItem.setValue( text, forKeyPath: AST_cell_textInput_text )
		} )

		return ControlProperty<String>( values: source, valueSink: bindingObserver )
		
	}

	//--------------------------------------------------------------------------
	// Reactive wrapper for return key action
	
	public var returnKey: ControlEvent<Void> {
		
		let source = lazyInstanceObservable( &rx_ASTTextViewItem_return_key ) { () -> Observable<Void> in
			Observable.create { [weak item = self.base] observer in
				guard let item = item else {
					observer.on(.completed)
					return Disposables.create()
				}
				let target = GenericActionTarget<ASTTextViewItem>(
					subject: item,
					setter: { textViewItem, target, action in
						textViewItem.textViewReturnKeyTarget = target
						textViewItem.textViewReturnKeyAction = action
					},
					callback: {
						observer.on( .next( Void() ) )
					}
				)
				return target
			}
			.takeUntil( self.deallocated )
			.share()
		}
		
		return ControlEvent( events: source )
		
	}

}

//------------------------------------------------------------------------------

func <-> ( textViewItem: ASTTextViewItem, variable: Variable<String> ) -> Disposable {
	
	var changeFromUI = false
	
	let bindToUIDisposable = variable.asObservable()
		.filter { _ in !changeFromUI && !textViewItem.isEditing }
		.bind( to: textViewItem.rx.text )
	
	let bindToVariable = textViewItem.rx.text.changed
		.subscribe( onNext: { textValue in
			if textValue != variable.value {
				changeFromUI = true
				variable.value = textValue
				changeFromUI = false
			}
		}, onCompleted: {
			bindToUIDisposable.dispose()
		} )

	let bindEndEditingToVariable = NotificationCenter.default.rx
		.notification( NSNotification.Name.UITextViewTextDidEndEditing, object: textViewItem as AnyObject? )
		.subscribe( onNext: { _ in
			textViewItem.rx.text.onNext( variable.value )
		}, onCompleted: {
			bindToUIDisposable.dispose()
		} )

	return Disposables.create( bindToUIDisposable, bindToVariable, bindEndEditingToVariable )
	
}

