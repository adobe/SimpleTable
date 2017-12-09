//==============================================================================
//
//  ASTSwitchItem+Rx.swift
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

import Foundation

import AST
import RxCocoa
import RxSwift
import UIKit


//------------------------------------------------------------------------------

private var rx_ASTSwitchItem_on_key: UInt8 = 0

extension Reactive where Base: ASTSwitchItem {
	
	//--------------------------------------------------------------------------
	// Reactive wrapper for `on` property.
	
	public var on: ControlProperty<Bool> {
		
		let keyPath = AST_cell_switch_on
		let source = lazyInstanceObservable( &rx_ASTSwitchItem_on_key ) { () -> Observable<Bool> in
			let initialValue = self.base.value( forKeyPath: keyPath ) as? Bool ?? false
			return Observable.create { [weak item = self.base] observer in
				guard let item = item else {
					observer.on( .completed )
					return Disposables.create()
				}
				let target = GenericActionTarget<ASTSwitchItem>(
					subject: item,
					setter: { switchItem, target, action in
						switchItem.switchTarget = target
						switchItem.switchAction = action
					},
					callback: {
						observer.on( .next( item.value( forKeyPath: keyPath ) as? Bool ?? false ) )
					}
				)
				return target
			}
			.takeUntil( self.deallocated )
			.startWith( initialValue )
			.share()
		}

		let bindingObserver = Binder<Bool>( self.base, binding: { (switchItem, state) -> () in
			switchItem.setValue( state, forKeyPath: keyPath )
		} )

		return ControlProperty<Bool>( values: source, valueSink: bindingObserver )
		
	}
	
}
