//
//  SearchView.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/14/23.
//

import UIKit

final class SearchView: PostListView {
    
    let searchBar = UISearchBar()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(resource: .background)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
