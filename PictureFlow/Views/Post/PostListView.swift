//
//  PostListView.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/17/23.
//

import UIKit

final class PostListView: UIView {
    
    let nicknameLabel = {
        let lb = UILabel()
        return lb
    }()
    
    let postTitleLabel = {
        let lb = UILabel()
        return lb
    }()
    
    let postContentLabel = {
        let lb = UILabel()
        return lb
    }()
    
    let tableView: UITableView = {
        let view = UITableView()
        view.register(
            PostListTableViewCell.self,
            forCellReuseIdentifier: PostListTableViewCell.description()
        )
        view.rowHeight = UITableView.automaticDimension
        view.estimatedRowHeight = 100
        view.backgroundColor = UIColor(resource: .background)
        return view
    }()
    
    let refreshControl: UIRefreshControl = UIRefreshControl()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(resource: .background)
        configureHierarchy()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureHierarchy() {
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.horizontalEdges.bottom.equalToSuperview()
        }
    }
}
