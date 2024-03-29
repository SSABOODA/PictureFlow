//
//  ProfileChileMaPostCommentListViewController.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/11/23.
//

import UIKit
import RxSwift

final class ProfileChildMyPostCommentListViewController: UIViewController {
    let mainView = ProfileChileMyPostCommentListView()
    let viewModel = ProfileChileMaPostCommentListViewModel()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}


