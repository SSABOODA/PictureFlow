//
//  LikeViewController.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/17/23.
//

import UIKit
import RxSwift

final class LikeViewController: UIViewController {
    
    let mainView = LikeView()
    let viewModel = LikeViewModel()
    var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
    }
}

extension LikeViewController {
    private func configureNavigationBar() {
        navigationItem.title = "좋아요"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}
