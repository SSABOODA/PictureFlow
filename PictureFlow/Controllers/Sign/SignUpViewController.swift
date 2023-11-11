//
//  SignUpViewController.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/10/23.
//

import UIKit

final class SignUpViewController: UIViewController {
    
    let mainView = SignUpView()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
    }
}
