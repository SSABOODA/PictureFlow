앱 소개
일상의 이야기를 공유하고 자신의 게시글을 관리하고 추적해볼 수 있는 앱입니다. 
- 게시글 작성 기능(이미지 포함)
- 게시글 좋아요
- 게시글 해시태그 기능
- 유저 팔로우 기능
- 프로필 관리 기능
# 🗓️ 프로젝트 기간
2023/11/17 ~ 2023/12/17
# 👥 프로젝트 참여 인원
1명(개인)
# 🛠️ 사용된 프레임워크, 라이브러리, 디자인 패턴
- MVVM
- UIKit
- RxSwift
- RxDatasource
- Snapkit
- Kingfisher
- Tabman
- IQKeyboardManager
# 🔍 구현 기능
- 회원가입, 로그인 기능을 구현하였고 로그인 같은 경우 JWT Token기반으로 구현하였습니다. `Refresh Token` 관리 또한 `Alamofire`의 `Interceptor`를 통해 `Refresh Token`을 갱신하여 현재 유저의 로그인 상태를 유지하거나 `Refresh Token`이 만료되었다면 재로그인 하는 방식으로 구현하였습니다.
- 게시글을 관리하는 피드에서는 RxSwift 기반의 UITableView를 활용해서 구성하였고 셀안에 이미지 데이터 또한 dataSet을 tableView의 cell을 구성할 때 Observable로 Stream을 방출하여 Rx CollectionView로 구성하였습니다.
- 게시글 목록에서 Rx기반의 `PullToRefresh`를 구현해 데이터를 Reload할 수 있도록 하였고, `Cursor 기반 Pagination`을 `Rx PrefetchRows`를 사용하여 구현하였습니다.
- 게시글 상세 View에서는 `RxDataSource`를 활용해 Section의 HeaderView와 CollectionView를 통해 게시글 정보 아래에 댓글 정보를 표현하도록하였습니다.
- 게시글이나 앱 전체의 이미지들은 확대하여 확인할수 있도록 FullScreen View를 Custom하여 구현하였습니다.
- 해시태그를 구현하기 위해 UITextView의 RxSwift를 Custom 함수를 정의하였고 UITapGestureRecognizer 클래스를 Custom하여 해시태그 단어에 대해 Link처럼 Click이 가능하도록 구현하였습니다.
- 해시태그를 사용자가 쉽게 작성하도록 UITextView를 Custom하였고 정규식을 통해 `#`을 기준으로 사용자가 입력하는 단어에 대해서는 대비 색상 적용하도록 하였습니다.
- 게시글 작성 View에서는 UITextView의 `sizeThatFits` 메서드를 사용해 줄바꿈을 하면 View가 늘어나도록 효과를 주었습니다. 
- 게시글 작성에서 `PHPickerViewController`를 통해 이미지를 가져올 수 있도록 하였고 CollectionView를 활용해 선택한 이미지를 나타내고 삭제할 수 있도록 하였습니다.
- 프로필에서는 `TabMan`, `Pageboy` 라이브러리를 활용해 내가 작성한 게시글, 팔로워, 팔로잉 목록을 확인할 수 있도록 구현하였습니다.
# 📖 프로젝트 기획 및 기록
노션 링크 같은 거 있으면 고고
# 🔥 이슈
## 1. tableHeaderView dynamic height
게시글의 상세화면 View 밑에 해당 게시글에 대한 댓글들을 표시할 수 있도록 댓글 아이템들은 TableView로 표시하고 TableView위에는 게시글 상세 View가 위치하는 View를 구성할 필요가 있었습니다.

상단 게시글 정보 View와 함께 댓글을 구성하던 Tableview 또한 같이 Scroll되길 원했기 때문에 HeaderView나 ScrollView로 구성을 해야했습니다. 

### 문제 상황
그렇다면 UITableView가 가지고 있는 tableHeaderView 속성에 UIView를 넣어줄 수 있는 속성을 사용했었을 때 발생했습니다. 게시글의 컨텐츠 양에 따라(Content, Image 여부 등…) 유동적인 높이를 잡아줬어야했는데 tableHeaderView에서는 유동적인 높이를 잡기가 않았습니다. 

물론 구글링을 통해 다음과 같이 유동적인 높이를 다시 계산해서 잡아주는 코드를 작성해봤지만 UILabel같은 경우 높이를 컨텐츠의 양에 맞게 잡아 주지 않아서 딱 알맞게 들어가지 않는 문제가 발생했습니다. 

우선 왜 굳이 가변 높이의 HeaderView를 사용하기 위해 Layout잡기 까다로운 tableHeaderView를 사용하려 했나? 에 대한 답변은 게시글 상세 View에는 섹션이 없기 때문에 tableHeaderView만으로 해결하기 위해 노력했던 것 같습니다.

### **문제 해결**
1. Layout 잡기
우선 문제 해결을 위해 시도했던 방법은 tableHeaderView 자체를 View에서 확인해야했고, Build 결과 tableHeaderView가 보이지 않았습니다. 그래서 우선 `Debug View Hierarchy` 를 통해 확인 결과 headerView의 Layout이 잡히지 않았기 때문에 시뮬레이터에서 보지지 않았던 겁니다.

그래서 우선 Layout을 잡아줘야겠다는 생각을 했고 다음과 같이 Layout을 잡았습니다.
```swift
headerView.snp.makeConstraints { make in
    make.width.equalTo(view.bounds.width)
    make.height.equalTo(150)
}
```

Width같은 경우는 기기 Screen에 꽉차게 구성을 했고 높이는 우선 고정으로 잡고 Build하였습니다.
그 결과 View에는 잘 표시되었지만 TableView Cell과 겹쳐서 View에 표시되는 상황이 되었습니다. 

한참을 시도한 결과 애초에 Frame으로 높이를 잡아주는 방법을 사용했습니다.
```swift
headerView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 150)
```

frame을 잡아줬더니 cell과 겹치지 않고 View에 잘 나타나게 되었습니다. 그렇다면 인제 header view의 컨텐츠에 따라 유동적으로 높이를 잡아보려고 시도했습니다. 그럴려면 height를 고정적으로 주면 안되었기에 또 한번에 문제에 부딪히게 되었습니다.

우선 가변 높이를 지정하기 위해 많은 방법을 찾던 중 다음 코드를 활용해 headerView의 높이를 가변적으로 잡아줄 수 있지 않을까? 해서 적용해보게되었습니다.

```swift
func sizeHeaderToFit() {
    if let headerView = mainView.tableView.tableHeaderView {
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()

        let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        var newFrame = headerView.frame
        if height != newFrame.size.height {
            newFrame.size.height = height
            headerView.frame = newFrame

            mainView.tableView.tableHeaderView = headerView
        }
    }
}
```

하지만 위 코드조차 Label의 높이가 지정되어 있지 않으면 headerView는 사라지고 Label만 남게 되어 원하는 View의 형태가 나오질 않았습니다. 
 
마지막으로 시도했던 방법은 가변적인 컨텐츠의 높이를 일일이 계산하여 `layoutIfNeeded` 메서드를 활용해 HeaderView의 높이를 다시 잡아주는 방법을 활용했었습니다.

```swift
class HeaderView: UIView {
    let label = {
        let lb = UILabel()
        lb.numberOfLines = 0
        return lb
    }()
    
    let button = {
        let bt = UIButton()
        bt.setTitle("클릭", for: .normal)
        bt.backgroundColor = .darkGray
        return bt
    }()
    
    var contentHeight: CGFloat {
        let height = 
        label.bounds.height +
        button.bounds.height +
        labelTopDistance +
        labelToButtonBetweenDistance +
	10.0
        return height
    }
    
    let labelTopDistance = 5.0
    let labelToButtonBetweenDistance = 10.0

    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func layout() {
        addSubview(label)
        label.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview().inset(labelTopDistance)
        }
        
        addSubview(button)
        button.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(labelToButtonBetweenDistance)
            make.horizontalEdges.equalToSuperview().inset(5)
        }
    }
}
```

위와 같이 일일히 모든 View 객체의 높이와 top과 bottom 사이의 거리를 모두 계산하는 `contentHeight` 라는 계산속성을 통해 계산한 뒤 ViewController에서 Layout을 잡을 때 Frame에 대입해주는 방식으로 해결했습니다.

```swift
class TableHeaderViewController: UIViewController {
    private func updateHederViewHeight() {
        let calculatedHeight: CGFloat = headerView.contentHeight
        print("calculatedHeight: \(calculatedHeight)")
        headerView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: calculatedHeight)
        tableView.tableHeaderView = headerView
    }
}
```

이렇게 되면 해당 컨텐츠에 따라 유동적인 높이를 가지는 tableHeaderView를 나타낼 수 있게 되었습니다.

하지만 결론적으로 모든 객체의 높이를 계산해서 다시 Layout을 그린다는 방법 자체가 마음에 들지는 않아서 결국 `RxDataSource`를 사용했고 `configureSupplementaryView`에 HeaderView를 그려서 해결했습니다.

## 2. 게시글 컨텐츠에서 hash tag 클릭시 다른 View 이동
### 문제 상황
게시글의 텍스트 컨텐츠에서 해시태그를 설정하면 해당 해시 태그는 다른 텍스트와 색상이 대비되도록 설정하고 해당 해시태그는 클릭시 link가 되도록 설정해야했습니다.

### 문제 해결
1. 우선 텍스트가 link가 될 수 있도록 설정하려면 어떤 방법이 있는지 고민하던 중 스토리보드로 UITextView를 구성할 때 attributes를 설정할 때 `data detectors` 에 link를 체크하면 텍스트 안에 url이 있으면 자동으로 대비 색상과 함께 클릭 시 해당 url으로 이동할 수 있었던 기능을 활용하면 특정 단어에도 link 기능을 넣을 수 있지 않을까? 해서 해당 접근하게 되었습니다.

문자열의 특정 문자의 Style을 변경할 수 있는 클래스인 `NSMutableAttributedString` 을 활용해 해시태그의 특정 문자의 Style과 기능을 추가할 수 있겠다라고 접근했습니다.

`NSMutableAttributedString`은 `NSAttributedString` 를 상속받고 있으며 `NSAttributedString`에 속한 특정 범위에 문자의 시각적 스타일, 하이퍼링크 또는 접근성 데이터를 설정할 수 있는 타입이라고 나와있습니다.

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

```swift
contentTextView.text = elements.content
contentTextView.hashtagArr = elements.hashTags
contentTextView.resolveHashTags()
```

`NSMutableAttributedString` 를 통해 해당 문자열에 해시태그를 ‘#’ 과 붙어있는 문자를 추출하는 정규식을 사용하였고 추출한 문자들의 속성만 link 속성과 색상, font 크기를 변경시켜주었습니다.

## 3. rx button tap stream error handling
---
