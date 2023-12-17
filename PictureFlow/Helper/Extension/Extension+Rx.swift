//
//  Extension+Rx.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/17/23.
//

import UIKit
import RxSwift

extension Reactive where Base: UIActivityIndicatorView {

    /// Bindable sink for `startAnimating()`, `stopAnimating()` methods.
    public var isAnimating: Binder<Bool> {
        return Binder(self.base) { activityIndicator, active in
            if active {
                activityIndicator.startAnimating()
            } else {
                activityIndicator.stopAnimating()
            }
        }
    }

}
