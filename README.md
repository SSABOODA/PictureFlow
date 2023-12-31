# FLOW
<img src="https://github.com/SSABOODA/PictureFlow/assets/69753846/d1c941cf-ab81-450b-9bc4-eceaed7438a8" height="100" width="100">

## 프로젝트 소개
<p align="center" width="100%">
    <img src="https://github.com/SSABOODA/PictureFlow/assets/69753846/fdf26979-fd5e-4121-8500-5bc2d2b2adba" width="100%">
</p>

### 작동화면
|회원가입 & 로그인|게시글 & 댓글|해시태그 & 좋아요|프로필 & 팔로우|
|:-:|:-:|:-:|:-:|
|![회원가입 로그인](https://github.com/SSABOODA/PictureFlow/assets/69753846/233c6f0b-e03c-4c44-8d50-a2ffb559341e)|![게시글](https://github.com/SSABOODA/PictureFlow/assets/69753846/6ebc94ec-f5ed-4a48-851f-f6274fe18740)|![해시태그 좋아요](https://github.com/SSABOODA/PictureFlow/assets/69753846/5b6e2510-2bf4-4915-a586-64965ec583a5)|![프로필 팔로잉](https://github.com/SSABOODA/PictureFlow/assets/69753846/9d80dc1f-e609-4b0f-96f1-cf615ff3f3b4)|

<details>
	<summary> 
		<h3>주요 기능 Screenshot</h3>
	</summary>

### 회원가입 & 로그인: 회원가입을 통해 자신의 게시글을 관리하고 타인의 게시글을 확인할 수 있어요
<p align="center" width="100%">
    <img src="https://github.com/SSABOODA/PictureFlow/assets/69753846/44ad5fae-4164-4b99-8084-61b3e64155a9" width="100%">
</p>

### 게시글: 모든 유저의 게시글을 확인하고 좋아요 할 수 있고, 댓글을 남길 수 있어요, 여러 장의 사진 및 해시태그가 담긴 게시글도 남겨볼 수 있어요
<p align="center" width="100%">
    <img src="https://github.com/SSABOODA/PictureFlow/assets/69753846/932c9744-336f-4e5a-923e-3c2507237b13" width="100%">
</p>

### 좋아요 & 해시태그: 좋아요한 게시글과 해시태그 검색을 통해 게시글을 확인해볼 수 있어요
<p align="center" width="100%">
    <img src="https://github.com/SSABOODA/PictureFlow/assets/69753846/01ef441d-5747-4cd9-a8e0-46532d36c636" width="100%">
</p>

### 프로필 & 팔로우: 다른 유저를 팔로우할 수 있고, 자신의 프로필에서 게시글, 팔로워, 팔로잉 목록, 프로필 수정등을 해볼 수 있어요
<p align="center" width="100%">
    <img src="https://github.com/SSABOODA/PictureFlow/assets/69753846/174a0cca-68a0-4e6c-9fef-4586960c2cf8" width="100%">
</p>
</details>

### 앱 소개
일상의 이야기를 공유하고 자신의 게시글을 관리하고 추적해볼 수 있는 Thread 및 Twitter 기반 SNS 앱입니다.

### 주요 기능
- **회원가입**, **로그인**을 통해 자신의 게시글을 관리할 수 있어요
	- 로그아웃, 회원탈퇴도 해볼 수 있어요
- 이미지를 포함한 **게시글**을 작성, 수정, 삭제가 가능해요
- 타인 게시글에 **댓글** 작성, 수정, 삭제가 가능해요
- 게시글에 대해서 **좋아요**가 가능해요
- **해시태그**를 통해 관련 게시글을 검색해볼 수 있어요
- 다른 유저를 **팔로우**해볼 수 있어요
- 나의 **프로필**에 게시글, 팔로우를 관리해볼 수 있어요

### 프로젝트 기간
- 2023.11.17 ~ 2023.12.17
### 프로젝트 참여 인원
- 1명(개인)

<br>
<br>

## 🛠️ 사용된 기술 스택
- **Framework**
`UIKit`
- **Library**
`RxSwift`, `RxDatasource`,  `Snapkit`,  `Kingfisher`
`Tabman`, `IQKeyboardManager`
- **Design Pattern**
`MVVM`, `Router`, `Singleton`, `Input/Output`

<br>
<br>

## 구현 기능
### 회원가입, 로그인
- **JWT Token** 기반의 로그인 구현, **Alamofire RequestInterceptor**를 통한 **AccessToken** 갱신과  **RefeshToken** 만료 로직 처리
- **정규표현식**을 활용한 회원가입 인증 로직 구현
### 게시글
- **RxSwift**기반 TableView, CollectionView UI 구현
- **RxCollectionViewSectionedReloadDataSource**를 활용한 게시글 상세 View UI구현
- **RxSwift**기반 **UIRefreshControl**를 활용해 **PullToRefresh** 를 구현하여 게시글 데이터 갱신
- **Rx prefetchRows** 를 사용하여 **Cursor** 기반 **Pagination** 구현
### 네트워크
- **Router Pattern**을 활용해 네트워크 계층의 가독성 증가 및 코드 재사용성을 올렸습니다.

<br>
<br>
  
## Trouble Shooting
### 1. 유동적인 높이(dynamic height)를 가진 tableHeaderView
#### 문제 상황
상단 HeaderView에 유동적인 높이를 가진 게시글 데이터와 하단에 게시글에 대한 댓글 리스트를 tableView 형식으로 가진 UI를 만들 때 유동적인 높이를 가지는 **Dynamic Height** HeaderView를 만들 때 문제가 발생하였습니다.

#### 문제 해결
게시글 상세 View에서는 섹션이 없었기 때문에 UITableView의 **tableHeaderView** property에 custom view를 할당하는 방식으로 해결했습니다. 
**tableHeaderView** 는 UILabel 컨텐츠에 따라 자동으로 높이를 조절해주지 않아 모든 객체의 Height를 직접 계산하여 Layout을 다시 그리는 방식으로 해결했습니다.

```swift
final class HeaderView: UIView {
    private let titleLabel = UILabel()
    private let likeButton = UIButton()
    private var contentHeight: CGFloat {
        let height = 
        titleLabel.bounds.height +
        likeButton.bounds.height +
        labelTopDistance +
        labelToButtonBetweenDistance +
         10.0
        return height
    }
    private let labelTopDistance = 5.0
    private let labelToButtonBetweenDistance = 10.0
}
```

```swift
final class TableHeaderViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        headerView.layoutIfNeeded()
        updateHederViewHeight()
    }
	
    private func updateHederViewHeight() {
        let calculatedHeight: CGFloat = headerView.contentHeight
        headerView.frame = CGRect(
            x: 0,
            y: 0,
            width: view.bounds.width,
            height: calculatedHeight
        )
        tableView.tableHeaderView = headerView
    }
}
```
<br>

### 2. 게시글 컨텐츠에서 hash tag 클릭시 Link 기능 구현
#### 문제 상황
게시글의 Text 중 특정 URL이 아닌 일반 텍스트에 **Link** 기능을 통해 해시태그를 구현해야했습니다.
#### 문제 해결
게시글의 컨텐츠는 UILabel의 Text로 구현되어 있었지만, Link 기능 사용하려면 UITextView의 Link기능 즉, attributes를 설정할 때 `data detectors` 와 특정 문자의 style을 변경할 수 있는 `NSMutableAttributedString` 를 활용해 해시태의 특정 문자의 색상 변경과 link기능을 추가하였습니다.

```swift
final class HashtagTextView: UITextView {
    var hashtagArr: [String]?
    
    func resolveHashTags() {
        self.isEditable = false
        self.isSelectable = true
        
        let nsText: NSString = self.text as NSString
        let attrString = NSMutableAttributedString(string: nsText as String)
        let hashtagDetector = try? NSRegularExpression(
            pattern: "#(\\w+)",
            options: NSRegularExpression.Options.caseInsensitive
        )
        
        let results = hashtagDetector?.matches(
            in: self.text,
            options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds,
            range: NSMakeRange(0, self.text.utf16.count)
        )
        
        let hashtagAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor.systemBlue
        ]
        
        let regularTextAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18),
            .foregroundColor: UIColor(resource: .text)
        ]
        
        // 기존 속성 초기화
        attrString.removeAttribute(.foregroundColor, range: NSRange(location: 0, length: attrString.length))
        attrString.addAttributes(regularTextAttributes, range: NSRange(location: 0, length: attrString.length))

        hashtagArr = results?.map { (self.text as NSString).substring(with: $0.range(at: 1)) }
        if hashtagArr?.count != 0 {
            var i = 0
            for var word in hashtagArr! {
                word = "#" + word
                if word.hasPrefix("#") {
                    let matchRange:NSRange = nsText.range(of: word as String, options: [.caseInsensitive, .backwards])
                                                                
                    attrString.addAttribute(NSAttributedString.Key.link, value: "\(i)", range: matchRange)
                    attrString.addAttributes(hashtagAttributes, range: matchRange)
                    i += 1
                }
            }
        }
        
        self.attributedText = attrString
    }
}
```
<br>

### 3. Rxswift button tap stream error handling
#### 문제 상황
RxSwift로 로그인 버튼 클릭 시 로그인 API에 Request를 보내는 로직을 구현하였는데 네트워크 통신이 실패하면 해당 Rx Stream이 dispose 되어버리고 더 이상 해당 로그인 버튼을 누를 수 없는 문제가 발생했습니다.
#### 문제 해결
`Single` traits를 사용하여 **fetch** 메서드에서 방출하는 단일 **Observable** 이벤트를 래핑하여 error를 방출하지 않고 해당 버튼 stream에서 에러를 처리하는 방법을 사용하였습니다.
- Network.swift
```swift
func fetchSingle<T: Decodable> (
    type: T.Type,
    router: Router
) -> Single<Result<T, AFError>> {
    return Single.create { emitter -> Disposable in
	let request = AF.request(
	    router,
	    interceptor: AuthManager()
	)
	    .validate()
            .responseDecodable(of: T.self) { response in
            switch response.result {
            case .success(let success):
                emitter(.success(.success(success)))
            case .failure(let failure):
                emitter(.success(.failure(failure)))
            }
        }
	return Disposables.create() {
            request.cancel()
	}
    }
}
```

- loginViewModel.swift
```swift
input.loginButtonTap
    .withLatestFrom(loginModelObservable)
    .flatMap {
	Network.shared.fetchSingle(
	    type: LoginResponse.self,
	    router: .login(model: $0)
	)
    }
    .subscribe(with: self) { owner, result in
        switch result {
        case .success(let data):
            print(data)
        case .failure(let error):
            print(error)
        }
    } onError: { owner, error in
	print("Rx login onError")
    } onCompleted: { owner in
	print("Rx login onCompleted")
    } onDisposed: { owner in
	print("Rx login onDisposed")
    }
    .disposed(by: disposeBag)
```
