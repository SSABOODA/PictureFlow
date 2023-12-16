//
//  SearchView.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/14/23.
//

import UIKit

final class SearchView: PostListView {
    let searchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "검색"
        searchController.searchBar.showsCancelButton = true
        searchController.searchBar.setShowsCancelButton(false, animated: true)
        return searchController
    }()
    
    let emptyLabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = .boldSystemFont(ofSize: 17)
        label.text = "해시태그를 검색해보세요..."
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
        configureLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureHierarchy() {
        addSubview(emptyLabel)
    }
    
    private func configureLayout() {
        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
