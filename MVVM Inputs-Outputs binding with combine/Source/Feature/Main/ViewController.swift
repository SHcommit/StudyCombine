//
//  ViewController.swift
//  MVVM Inputs-Outputs binding with combine
//
//  Created by 양승현 on 2023/04/27.
//

import UIKit
import Combine

protocol ViewControllerBindCase {
  associatedtype State
  func bind()
  func render(_ state: State)
}

class ViewController: UIViewController {
  
  // MARK: - Properties
  let viewLoad = PassthroughSubject<Void,Never>()
  let showDate = PassthroughSubject<Date,Never>()
  let hideDate = PassthroughSubject<Void,Never>()
  
  lazy var dateView: UILabel = { return setDateView() }()
  lazy var showDateButton: UIButton = { return setButtonLayout(with: "", true) }()
  lazy var hideDateButton: UIButton = { return setButtonLayout(with: "", false) }()
  var viewModel: ViewModel
  var subscriptions = Set<AnyCancellable>()
  
  // MARK: - Lifecycle
  init(viewModel: ViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    view.backgroundColor = .white
    awakeLazySubviews()
    bind()
    viewLoad.send()
  }
  
  // MARK: - Event handler
  @objc func didTapShowDate() {
    animate(button: showDateButton)
    showDate.send(Date())
  }
  @objc func didTapHideDate() {
    animate(button: hideDateButton)
    hideDate.send()
  }
  
}

// MARK: - ViewControllerBindCase
extension ViewController: ViewControllerBindCase {
  typealias State = ViewControllerState
  
  func bind() {
    let input = ViewControllerInput(
      viewDidLoad: viewLoad.eraseToAnyPublisher(),
      showDate: showDate.eraseToAnyPublisher(),
      hideDate: hideDate.eraseToAnyPublisher())
    let output = viewModel.transform(input)
    output
      .receive(on: RunLoop.main)
      .sink { self.render($0) }
      .store(in: &subscriptions)
  }
  
  func render(_ state: State) {
    switch state {
    case .none:
      print("뷰야 화면에 로드 됬니? :)")
    case .showTime(let currentTime):
      dateView.text = currentTime
    case .hideTime(let labelData):
      dateView.text = labelData
    }
  }
  
}

// MARK: - Helpers
extension ViewController {
  
  //요곤 일단 블로그 글을 위해.. UIComponent들 lazy로 해서 함수로 묶었습니다.
  func awakeLazySubviews() {
    dateView.isHidden = false
    showDateButton.setTitle("showDate", for: .normal)
    hideDateButton.setTitle("hideDate", for: .normal)
  }
  
  func animate(button: UIButton) {
    UIView.animate(withDuration: 0.2, animations: {
      button.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
    }) { _ in
      UIView.animate(withDuration: 0.2, animations: {
        button.transform = CGAffineTransform.identity
      })
    }
  }
  
  func setDateView() -> UILabel {
    let v = UILabel()
    v.font = UIFont.systemFont(ofSize: 20)
    v.text = "Outputs UI Rendered"
    v.textAlignment = .center
    v.translatesAutoresizingMaskIntoConstraints = false
    v.backgroundColor = .systemPink.withAlphaComponent(0.8)
    v.clipsToBounds = true
    v.layer.cornerRadius = 10
    view.addSubview(v)
    NSLayoutConstraint.activate([
      v.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
      v.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      v.widthAnchor.constraint(equalToConstant: 280),
      v.heightAnchor.constraint(equalToConstant: 100)
    ])
    return v
  }
  
  func setButtonLayout(with title: String, _ isShowButton: Bool) -> UIButton {
    let b = UIButton()
    b.setTitle(title, for: .normal)
    b.backgroundColor = .brown.withAlphaComponent(0.8)
    b.layer.cornerRadius = 10
    b.translatesAutoresizingMaskIntoConstraints = false
    b.layer.shadowColor = UIColor.brown.cgColor
    b.layer.shadowOffset = CGSize(width: 3, height: 2)
    b.layer.shadowOpacity = 0.3
    b.layer.shadowRadius = 3
    view.addSubview(b)
    if isShowButton {
      NSLayoutConstraint.activate([
        b.topAnchor.constraint(equalTo: dateView.bottomAnchor, constant: 100),
        b.leadingAnchor.constraint(equalTo: dateView.leadingAnchor),
        b.widthAnchor.constraint(equalToConstant: 120),
        b.heightAnchor.constraint(equalToConstant: 60)])
      b.addTarget(self, action: #selector(didTapShowDate), for: .touchUpInside)
    }else {
      NSLayoutConstraint.activate([
        b.topAnchor.constraint(equalTo: dateView.bottomAnchor, constant: 100),
        b.trailingAnchor.constraint(equalTo: dateView.trailingAnchor),
        b.widthAnchor.constraint(equalToConstant: 120),
        b.heightAnchor.constraint(equalToConstant: 60)])
      b.addTarget(self, action: #selector(didTapHideDate), for: .touchUpInside)
    }
    return b
  }
  
}
