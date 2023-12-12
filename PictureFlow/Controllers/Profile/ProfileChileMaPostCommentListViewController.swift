//
//  ProfileChileMaPostCommentListViewController.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/11/23.
//

import UIKit
import RxSwift

final class ProfileChileMaPostCommentListViewController: UIViewController {
    let mainView = ProfileChileMyPostCommentListView()
    let viewModel = ProfileChileMaPostCommentListViewModel()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function, "ProfileChileMaPostCommentListViewController")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // update datasource
    }
}


