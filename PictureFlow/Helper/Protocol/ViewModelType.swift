//
//  ViewModelType.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/11/23.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
