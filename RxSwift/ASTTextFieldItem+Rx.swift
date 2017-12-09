//==============================================================================
//
//  ASTTextFieldItem+Rx.swift
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

private var rx_ASTTextFieldItem_text_key: UInt8 = 0
private var rx_ASTTextFieldItem_return_key: UInt8 = 0

extension Reactive where Base: ASTTextFieldItem {
	
	//--------------------------------------------------------------------------
	// Bindable sink for `enabled` property.

	public var enabled: AnyObserver<Bool> {
		
		return Binder( self.base ) { textFieldItem, value in
			textFieldItem.setValue( value, forKeyPath: "cellProperties.textInput.enabled" )
		}.asObserver()
		
	}
	
	//--------------------------------------------------------------------------
	// Bindable sink for to make text field active.

	public var becomeFirstResponder: AnyObserver<Void> {
		
		return Binder( self.base ) { textFieldItem, _ in
			textFieldItem.becomeFirstResponder()
		}.asObserver()
		
	}
	
	//--------------------------------------------------------------------------
	// Reactive wrapper for `text` property.
	
	public var text: ControlProperty<String> {
		
		let source = lazyInstanceObservable( &rx_ASTTextFieldItem_text_key ) { () -> Observable<String> in
			let initialValue = self.base.value( forKeyPath: AST_cell_textInput_text ) as? String ?? ""
			return Observable.create { [weak item = self.base] observer in
				guard let item = item else {
					observer.on( .completed )
					return Disposables.create()
				}
				let target = GenericActionTarget<ASTTextFieldItem>(
					subject: item,
					setter: { textFieldItem, target, action in
						textFieldItem.textFieldValueTarget = target
						textFieldItem.textFieldValueAction = action
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

		let bindingObserver = Binder<String>( self.base, binding: { (textFieldItem, text) -> () in
			textFieldItem.setValue( text, forKeyPath: AST_cell_textInput_text )
		} )

		return ControlProperty<String>( values: source, valueSink: bindingObserver )
		
	}
	
	//--------------------------------------------------------------------------
	// Reactive wrapper for return key action
	
	public var returnKey: ControlEvent<Void> {
		
		let source = lazyInstanceObservable( &rx_ASTTextFieldItem_return_key ) { () -> Observable<Void> in
			Observable.create { [weak item = self.base] observer in
				guard let item = item else {
					observer.on(.completed)
					return Disposables.create()
				}
				let target = GenericActionTarget<ASTTextFieldItem>(
					subject: item,
					setter: { textFieldItem, target, action in
						textFieldItem.textFieldReturnKeyTarget = target
						textFieldItem.textFieldReturnKeyAction = action
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

}

//------------------------------------------------------------------------------

class GenericActionTarget<Subject:AnyObject>: NSObject, Disposable {
	
	typealias Callback = () -> Void
	typealias Setter = (Subject,AnyObject?,Selector?) -> Void
	
	private var retainSelf: GenericActionTarget?
	weak var subject: Subject?
	var callback: Callback!
	var setter: Setter!
	
	//--------------------------------------------------------------------------
	
	init( subject: Subject, setter: @escaping Setter, callback: @escaping Callback ) {
		
		self.subject = subject
		self.callback = callback

		super.init()

		self.retainSelf = self
		setter( subject, self, #selector(GenericActionTarget.action(_:)) )
		
	}
	
	//--------------------------------------------------------------------------
	
	func dispose() {
		
#if DEBUG
		MainScheduler.ensureExecutingOnScheduler()
#endif
		
		if let subject = subject, let setter = setter {
			setter( subject, nil, nil )
		}
		
		callback = nil
		self.retainSelf = nil
		
	}
	
	//--------------------------------------------------------------------------
	
	func action( _ sender: AnyObject ) {
		
		callback()
		
	}
	
}

//------------------------------------------------------------------------------

func <-> ( textFieldItem: ASTTextFieldItem, variable: Variable<String> ) -> Disposable {
	
	var changeFromUI = false
	
	let bindToUIDisposable = variable.asObservable()
		.filter { _ in !changeFromUI && !textFieldItem.isEditing }
		.bind( to: textFieldItem.rx.text )
	
	let bindToVariable = textFieldItem.rx.text.changed
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
		.notification( NSNotification.Name.UITextFieldTextDidEndEditing, object: textFieldItem as AnyObject? )
		.subscribe( onNext: { _ in
			textFieldItem.rx.text.onNext( variable.value )
		}, onCompleted: {
			bindToUIDisposable.dispose()
		} )

	return Disposables.create( bindToUIDisposable, bindToVariable, bindEndEditingToVariable )
	
}

//------------------------------------------------------------------------------
// This is copied from NSObject+Rx.swift. Since lazyInstanceObservable() is
// not public we need our own copy.

extension Reactive where Base: AnyObject {
	/**
	 Helper to make sure that `Observable` returned from `createCachedObservable` is only created once.
	 This is important because there is only one `target` and `action` properties on `NSControl` or `UIBarButtonItem`.
	 */
	func lazyInstanceObservable<T: AnyObject>(_ key: UnsafeRawPointer, createCachedObservable: () -> T) -> T {
		if let value = objc_getAssociatedObject(base, key) {
			return value as! T
		}
		
		let observable = createCachedObservable()
		
		objc_setAssociatedObject(base, key, observable, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		
		return observable
	}
}

