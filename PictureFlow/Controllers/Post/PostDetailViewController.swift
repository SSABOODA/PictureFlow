//
//  PostViewController.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/17/23.
//

import UIKit
import RxSwift
import RxCocoa

final class PostDetailViewModel {
    var postItem: PostList? = nil
}

final class PostDetailViewController: UIViewController {
    
    var postDetailViewModel = PostDetailViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .orange
        
        print(postDetailViewModel.postItem)
    }
}
