//
//  ViewModelType.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/11/23.
//

import Foundation
import RxSwift

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    var disposeBag: DisposeBag { get }
    func transform(input: Input) -> Output
}
