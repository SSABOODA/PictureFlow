//
//  PostListTableViewCell.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/19/23.
//

import UIKit
import RxSwift
import RxDataSources
import Kingfisher

protocol CustomTableViewCellDelegate: AnyObject {
    func didTapButton(in cell: PostListTableViewCell, image: UIImage)
    func didTapHashTag(in cell: PostListTableViewCell, hashTagWord: String)
}

final class PostListTableViewCell: UITableViewCell {
    
    let profileImageView = {
        let view = ProfileImageView(frame: .zero)
        return view
    }()
     
    let profileFlollowCheckButtonView = {
        let view = UIView()
        view.backgroundColor = UIColor(resource: .background)
        return view
    }()
    
    let profileFlollowCheckButton = {
        let button = UIButton()
        let spacing:CGFloat = 13
        button.setImage(UIImage(systemName: "plus"), for: .normal) // checkmark
        button.backgroundColor = UIColor(resource: .text)
        button.tintColor = UIColor(resource: .background)
        button.clipsToBounds = true
        button.isUserInteractionEnabled = false
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(
            top: spacing,
            left: spacing,
            bottom: spacing,
            right: spacing
        )
        return button
    }()
    
    let leftDividLineView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        return view
    }()
    
    let nicknameLabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.numberOfLines = 2
        label.textColor = UIColor(resource: .text)
        return label
    }()
    
    let postCreatedTimeLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = UIColor(resource: .text)
        return label
    }()
    
    let moreInfoButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.tintColor = UIColor(resource: .text)
        return button
    }()

    let contentTextView = {
        let textView = HashtagTextView()
        textView.font = .systemFont(ofSize: 18)
        textView.textColor = UIColor(resource: .text)
        textView.sizeToFit()
        textView.isScrollEnabled = false
        textView.backgroundColor = UIColor(resource: .background)
        return textView
    }()
    
    let collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: createLayout()
        )
        collectionView.register(
            BasePostListImageCollectionViewCell.self,
            forCellWithReuseIdentifier: BasePostListImageCollectionViewCell.description()
        )
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = UIColor(resource: .background).withAlphaComponent(0)
        return collectionView
    }()
    
    let likeButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.tintColor = UIColor(resource: .tint)
        return button
    }()
    
    let commentButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "bubble"), for: .normal)
        button.tintColor = UIColor(resource: .tint)
        return button
    }()
    
    let bookmarkButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "bookmark"), for: .normal)
        button.tintColor = UIColor(resource: .tint)
        return button
    }()
    
    let shareButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "paperplane"), for: .normal)
        button.tintColor = UIColor(resource: .tint)
        return button
    }()

    lazy var functionButtonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            likeButton,
            commentButton,
            bookmarkButton,
            shareButton,
        ])
        stackView.axis = .horizontal
        stackView.spacing = 15
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    let commentCountButton = {
        let button = UIButton()
        button.setTitle("0 답글", for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        return button
    }()
    
    let likeCountButton = {
        let button = UIButton()
        button.setTitle("0 좋아요", for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        return button
    }()
    
    lazy var countButtonStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                commentCountButton,
                likeCountButton
            ])
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.distribution = .fill
        return stackView
    }()
    
    weak var delegate: CustomTableViewCellDelegate?
    var disposeBag = DisposeBag()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor(resource: .background)
        selectionStyle = .none
        configureHierarchy()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = nil
        disposeBag = DisposeBag()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profileImageView.layoutIfNeeded()
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        
        profileFlollowCheckButtonView.layoutIfNeeded()
        profileFlollowCheckButtonView.layer.cornerRadius = profileFlollowCheckButtonView.frame.width / 2
        
        profileFlollowCheckButton.layoutIfNeeded()
        profileFlollowCheckButton.layer.cornerRadius = profileFlollowCheckButton.frame.width / 2
    }
    
    private func configureHierarchy() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(profileFlollowCheckButtonView)
        profileFlollowCheckButtonView.addSubview(profileFlollowCheckButton)
        contentView.addSubview(leftDividLineView)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(postCreatedTimeLabel)
        contentView.addSubview(moreInfoButton)
        contentView.addSubview(contentTextView)
        
        contentView.addSubview(collectionView)
        contentView.addSubview(functionButtonStackView)
        contentView.addSubview(countButtonStackView)
    }
    
    private func configureLayout() {
        profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(15)
            make.leading.equalToSuperview().inset(10)
            make.trailing.equalTo(nicknameLabel.snp.leading).offset(-10)
            make.size.equalTo(45)
        }
        
        profileFlollowCheckButtonView.snp.makeConstraints { make in
            make.bottom.equalTo(profileImageView.snp.bottom)
            make.trailing.equalTo(profileImageView.snp.trailing).offset(5)
            make.size.equalTo(20)
        }
        
        profileFlollowCheckButton.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(2)
        }
        
        leftDividLineView.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(10)
            make.centerX.equalTo(profileImageView.snp.centerX)
            make.bottom.equalToSuperview().inset(15)
            make.width.equalTo(2)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.top)
            make.leading.equalTo(profileImageView.snp.trailing).offset(10)
            make.width.equalToSuperview().multipliedBy(0.5)
        }
    
        postCreatedTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.top)
            make.trailing.equalTo(moreInfoButton.snp.leading).offset(-10)
        }

        moreInfoButton.snp.makeConstraints { make in
            make.centerY.equalTo(postCreatedTimeLabel.snp.centerY)
            make.trailing.equalToSuperview().offset(-15)
            make.size.equalTo(25)
        }
        
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(5)
            make.leading.equalTo(nicknameLabel.snp.leading)
            make.trailing.equalToSuperview().offset(-15)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(contentTextView.snp.bottom).offset(15)
            make.leading.equalTo(safeAreaLayoutGuide)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(200)
        }
        
        functionButtonStackView.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(10)
            make.leading.equalTo(nicknameLabel.snp.leading)
            make.width.equalToSuperview().multipliedBy(0.35)
            make.height.equalTo(30)
        }
        
        countButtonStackView.snp.makeConstraints { make in
            make.top.equalTo(functionButtonStackView.snp.bottom).offset(5)
            make.leading.equalTo(nicknameLabel.snp.leading)
            make.width.equalToSuperview().multipliedBy(0.35)
            make.bottom.equalToSuperview().inset(15)
        }
    }

    func configureCell(with elements: PostList) {
        updateCollectionViewHeight(isEmpty: elements.image.isEmpty)
        
        // Profile Image
        if let profileImageURL = elements.creator.profile {
            profileImageURL.loadProfileImageByKingfisher(imageView: profileImageView)
        } else {
            profileImageView.image = UIImage(named: "empty-user")
        }
        // 시간 작업
        let timeContent = DateTimeInterval.shared.calculateDateTimeInterval(createdTime: elements.time)
        
        nicknameLabel.text = elements.creator.nick
        postCreatedTimeLabel.text = timeContent
        contentTextView.text = elements.content

        contentTextView.hashtagArr = elements.hashTags
        contentTextView.resolveHashTags()
        
        contentTextView.rx.didTapWord()
            .subscribe(with: self) { owner, word in
                owner.delegate?.didTapHashTag(in: self, hashTagWord: word)
            }
            .disposed(by: disposeBag)
        
        commentCountButton.setTitle("\(elements.comments.count) 답글", for: .normal)
        likeCountButton.setTitle("\(elements.likes.count) 좋아요", for: .normal)
        
        let userId = UserDefaultsManager.userID
        if elements.likes.contains(userId) {
            likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            likeButton.tintColor = .red
        } else {
            likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
            likeButton.tintColor = UIColor(resource: .tint)
        }
        
        // 컬렉션 뷰 구성
        configureCollectionView(with: elements.image)
    }
    
    private func updateCollectionViewHeight(isEmpty: Bool) {
        let height = isEmpty ? 0 : 200
        self.collectionView.snp.updateConstraints { make in
            make.height.equalTo(height)
        }
        self.collectionView.layoutIfNeeded()
    }
    
    private func configureCollectionView(with imageList: [String]) {
        
        Observable.just(imageList)
            .bind(
                to: collectionView.rx.items(
                    cellIdentifier: BasePostListImageCollectionViewCell.description(),
                    cellType: BasePostListImageCollectionViewCell.self)
            ) { (row, element, cell) in
                element.loadImageByKingfisher(imageView: cell.postImageView)
                
                cell.imageTappedHandler = { [weak self] in
                    guard let self = self else { return }
                    guard let image = cell.postImageView.image else { return }
                    delegate?.didTapButton(in: self, image: image) // TODO: 이동
                }
            }
            .disposed(by: disposeBag)
    }

    static func createLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.itemSize = CGSize(width: 200, height: 200)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 60, bottom: 10, right: 10)
        return layout
    }
}

/* Rxswift hash tag */
extension Reactive where Base: UITextView {
    func didTapWord() -> Observable<String> {
        return Observable.create { observer in
            let target = GestureTarget()
            self.base.addGestureRecognizer(target.gesture!)

            target.observer = observer

            return Disposables.create {
                self.base.removeGestureRecognizer(target.gesture!)
            }
        }
    }
}

class GestureTarget: NSObject, UIGestureRecognizerDelegate {
    var gesture: UITapGestureRecognizer?
    var observer: AnyObserver<String>?

    override init() {
        super.init()
        gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        gesture?.delegate = self
    }

    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let textView = gesture.view as? UITextView else {
            return
        }

        let layoutManager = textView.layoutManager
        let location = gesture.location(in: textView)
        let characterIndex = layoutManager.characterIndex(for: location, in: textView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        let wordRange = textView.text.wordRange(at: characterIndex)

        if let wordRange = wordRange, let observer = observer {
            let word = (textView.text as NSString).substring(with: wordRange)
            observer.onNext(word)
        }
    }
}

extension String {
    func wordRange(at index: Int) -> NSRange? {
//        let pattern = "\\S*\\b"
        let pattern = "#(\\w+)"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let matches = regex?.matches(in: self, options: [], range: NSRange(location: 0, length: self.count))

        for match in matches ?? [] {
            if NSLocationInRange(index, match.range) {
                return match.range
            }
        }

        return nil
    }
}
