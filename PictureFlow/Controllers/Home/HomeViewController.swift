//
//  HomeViewController.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/13/23.
//

import UIKit

final class HomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        view.backgroundColor = .white
        
        
        let a = KeyChain.read(key: "accessToken")
        let r = KeyChain.read(key: "refreshToken")
        
        print("accessToken: \(a)")
        print("refreshToken: \(r)")
        
    }
}
