//
//  NewPostWriteViewController.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/8/23.
//

import UIKit
import PhotosUI
import RxSwift
import RxCocoa
import SnapKit

class NewPostWriteView: UIView {
    let scrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    let contentView = {
        let view = UIView()
        return view
    }()
    
    let backView = {
        let view = UIView()
        return view
    }()
    
    let profileImageView = {
        let view = ProfileImageView(frame: .zero)
        return view
    }()
    
    let nicknameLabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.numberOfLines = 1
        label.textColor = UIColor(resource: .text)
        label.text = "sssabooda"
        return label
    }()
    
    let leftDividLineView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        return view
    }()
    
    let postContentTextView = {
        let tv = UITextView()
        tv.text = "이야기를 시작해보세요..."
        tv.textColor = .lightGray
        tv.font = .systemFont(ofSize: 17)
        tv.isScrollEnabled = false
        tv.sizeToFit()
        tv.backgroundColor = .clear
        return tv
    }()
    
    lazy var collectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: createLayout()
        )
        collectionView.register(
            PostListImageCancelCollectionViewCell.self,
            forCellWithReuseIdentifier: PostListImageCancelCollectionViewCell.description()
        )
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = UIColor(resource: .background).withAlphaComponent(0)
        return collectionView
    }()
    
    let addImageButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "photo.on.rectangle.angled"), for: .normal)
        button.tintColor = UIColor(resource: .tint)
        return button
    }()
    
    let addGIFButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "doc"), for: .normal)
        button.tintColor = UIColor(resource: .tint)
        return button
    }()
    
    let addVoiceRecordButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "waveform"), for: .normal)
        button.tintColor = UIColor(resource: .tint)
        return button
    }()
    
    let addSurveyButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "list.bullet"), for: .normal)
        button.tintColor = UIColor(resource: .tint)
        return button
    }()
    
    lazy var functionButtonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            addImageButton,
            addGIFButton,
            addVoiceRecordButton,
            addSurveyButton,
        ])
        stackView.axis = .horizontal
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(resource: .background)
        configureHierarchy()
        configureLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profileImageView.layoutIfNeeded()
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
    }
    
    private func configureHierarchy() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(backView)
        backView.addSubview(profileImageView)
        backView.addSubview(leftDividLineView)
        backView.addSubview(nicknameLabel)
        backView.addSubview(postContentTextView)
        
        backView.addSubview(collectionView)
        backView.addSubview(functionButtonStackView)
    }
    
    private func configureLayout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.height.greaterThanOrEqualTo(self.snp.height).priority(.low)
            make.width.equalTo(scrollView)
        }
        
        backView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(functionButtonStackView.snp.bottom)
            make.bottom.equalTo(scrollView.snp.bottom)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(15)
            make.leading.equalToSuperview().inset(15)
            make.size.equalTo(35)
        }
        
        leftDividLineView.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(10)
            make.centerX.equalTo(profileImageView.snp.centerX)
            make.bottom.equalToSuperview().inset(5)
            make.width.equalTo(2)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.top)
            make.leading.equalTo(profileImageView.snp.trailing).offset(15)
        }
        
        postContentTextView.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(10)
            make.leading.equalTo(nicknameLabel.snp.leading)
            make.trailing.equalToSuperview().offset(-15)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(postContentTextView.snp.bottom).offset(5)
            make.leading.equalTo(safeAreaLayoutGuide)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(0)
        }
        
        functionButtonStackView.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(15)
            make.leading.equalTo(nicknameLabel.snp.leading)
            make.width.equalToSuperview().multipliedBy(0.4)
        }

    }
}

// collection layout
extension NewPostWriteView {
    func createLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.itemSize = CGSize(width: 200, height: 200)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 50, bottom: 10, right: 10)
        return layout
    }
}


/* 
 ///////////  분기점 ///////////
*/

class NewPostWriteViewModel: ViewModelType {
    struct Input {
        let postCreateButtonTap: ControlEvent<Void>
        let postContentText: ControlProperty<String>
    }
    
    struct Output {
        let photoImageObservableList: BehaviorSubject<[UIImage]>
        let postWriteRequestObservable: PublishSubject<PostWriteRequest>
        let successPostCreate: BehaviorRelay<Bool>
    }
    
    var disposeBag = DisposeBag()
    
    var postWriteRequestModel = PostWriteRequest(
        title: "",
        content: "",
        file: [UIImage](),
        content1: "",
        content2: ""
    )
    
    var photoImageList = [UIImage]()
    var photoImageObservableList = BehaviorSubject<[UIImage]>(value: [])
    var postWriteRequestObservable = PublishSubject<PostWriteRequest>()
    var successPostCreate = BehaviorRelay(value: false)
    
    func transform(input: Input) -> Output {
        Observable.combineLatest(
            input.postContentText,
            photoImageObservableList
        )
        .subscribe(with: self) { owner, postCreateData in
            let model = PostWriteRequest(
                title: "",
                content: postCreateData.0,
                file: postCreateData.1,
                content1: "test1",
                content2: "test2"
            )
            owner.postWriteRequestObservable.onNext(model)
        }
        .disposed(by: disposeBag)
            
        input.postContentText
            .subscribe(with: self) { owner, text in
                owner.postWriteRequestModel.content = text
            }
            .disposed(by: disposeBag)
        
        input.postCreateButtonTap
            .withLatestFrom(postWriteRequestObservable)
            .flatMap {
                Network.shared.requestFormDataConvertible(
                    router: .post(
                        accessToken: KeyChain.read(key: APIConstants.accessToken) ?? "",
                        model: $0
                    )
                )
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
                    print("======", data)
                    owner.successPostCreate.accept(true)
                case .failure(let error):
                    print("======", error)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            photoImageObservableList: photoImageObservableList, 
            postWriteRequestObservable: postWriteRequestObservable,
            successPostCreate: successPostCreate
        )
    }
}

class NewPostWriteViewController: UIViewController {
    
    let mainView = NewPostWriteView()
    var viewModel = NewPostWriteViewModel()
    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureTextView()
        bind()
    }
    
    override func loadView() {
        view = mainView
    }
    
    private func bind() {
        mainView.addImageButton.rx.tap
            .bind(with: self) { owner, _ in
                print("addImageButton did tap")
                owner.addImageButtonClicked()
            }
            .disposed(by: disposeBag)
        
        guard let rightBarButton = navigationItem.rightBarButtonItem else { return }
        
        let input = NewPostWriteViewModel.Input(
            postCreateButtonTap: rightBarButton.rx.tap,
            postContentText: mainView.postContentTextView.rx.text.orEmpty
        )
        
        let output = viewModel.transform(input: input)
        
        output.photoImageObservableList
            .subscribe(with: self) { owner, imageList in
                let height = imageList.count == 0 ? 0 : 200
                
                self.mainView.collectionView.snp.updateConstraints { make in
                    make.height.equalTo(height)
                }
            }
            .disposed(by: disposeBag)
        
        output.photoImageObservableList
            .bind(to: mainView.collectionView.rx.items(
                cellIdentifier: PostListImageCancelCollectionViewCell.description(),
                cellType: PostListImageCancelCollectionViewCell.self)) { (row, element, cell) in

                    print("⭐️ rx element: \(element)")
                    cell.postImageView.image = element
                    cell.cancelButton.rx.tap
                        .bind(with: self) { owner, _ in
                            print("cancel button did tap")
                            owner.viewModel.photoImageList.remove(at: row)
                            owner.viewModel.photoImageObservableList.onNext(owner.viewModel.photoImageList)
                        }
                        .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        output.successPostCreate
            .bind(with: self) { owner, isCreated in
                if isCreated {
                    owner.dismiss(animated: true)
                }
            }
            .disposed(by: disposeBag)
    
    }
}

// PHPickerViewControllerDelegate
extension NewPostWriteViewController: PHPickerViewControllerDelegate {
    private func addImageButtonClicked() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 5
        configuration.filter = .any(of: [.images, .videos])
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        print(#function)
        
        if !results.isEmpty {
            viewModel.photoImageList.removeAll()
            for result in results {
                let itemProvider = result.itemProvider
                if itemProvider.canLoadObject(ofClass: UIImage.self) {
                    itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                        guard let image = image as? UIImage else { return }
                        print("🔥 image: \(image)")
                        DispatchQueue.main.async {
                            self?.viewModel.photoImageList.append(image)
                            self?.viewModel.photoImageObservableList.onNext(self?.viewModel.photoImageList ?? [])
                        }
                    }
                }
            }
        }
        
    }
}

// Configure TextView
extension NewPostWriteViewController {
    @objc func configureTextView() {
        mainView.postContentTextView.rx.didBeginEditing
            .bind(with: self) { owner, _ in
                if (owner.mainView.postContentTextView.text) == "이야기를 시작해보세요..." {
                    owner.mainView.postContentTextView.text = nil
                    owner.mainView.postContentTextView.textColor = UIColor(resource: .text)
                }
            }
            .disposed(by: disposeBag)
        
        mainView.postContentTextView.rx.didEndEditing
            .bind(with: self) { owner, _ in
                if (owner.mainView.postContentTextView.text) == nil ||  (owner.mainView.postContentTextView.text) == "" {
                    owner.mainView.postContentTextView.text = "이야기를 시작해보세요..."
                    owner.mainView.postContentTextView.textColor = .lightGray
                }
            }
            .disposed(by: disposeBag)
        
        textViewDynamicHeight()
    }
    
    func textViewDynamicHeight() {
        mainView.postContentTextView.becomeFirstResponder()
        mainView.postContentTextView.rx.didChange
            .withLatestFrom(mainView.postContentTextView.rx.text)
            .bind(with: self) { owner, text in
                let size = CGSize(width: owner.view.frame.width, height: .infinity)
                let estimatedSize = owner.mainView.postContentTextView.sizeThatFits(size)
                
                owner.mainView.postContentTextView.constraints.forEach { (constraint) in
                    /// 180 이하일때는 더 이상 줄어들지 않게하기
                    if estimatedSize.height <= 180 {
                        
                    } else {
                        if constraint.firstAttribute == .height {
                            constraint.constant = estimatedSize.height
                        }
                    }
                }
            }
            .disposed(by: disposeBag)
    }
    
    
}

// Navigation
extension NewPostWriteViewController {
    private func configureNavigationBar() {
        navigationItem.title = "새로운 글 작성"
        
        // postCancelButton
        let postCancelButton = UIBarButtonItem(
            title: "취소",
            style: .plain,
            target: self,
            action: #selector(cancelButtonClicked)
        )
        navigationItem.leftBarButtonItem = postCancelButton
        navigationItem.leftBarButtonItem?.tintColor = UIColor(resource: .tint)
        
        // postCreateButton
        let postCreateButton = UIBarButtonItem(
            title: "게시",
            style: .plain,
            target: self,
            action: #selector(plusButtonClicked)
        )
        navigationItem.rightBarButtonItem = postCreateButton
        navigationItem.rightBarButtonItem?.tintColor = UIColor(resource: .tint)
    }
    
    @objc func cancelButtonClicked() {
        print(#function)

        self.showAlertAction2(title: "게시글 작성을 취소하시겠습니까?") {
            print("")
        } _: {
            self.dismiss(animated: true)
        }
    }
    
    @objc func plusButtonClicked() { }
}





