//
//  TimeViewController.swift
//  MVVM Inputs-Outputs binding with combine
//
//  Created by 양승현 on 2023/04/27.
//

import UIKit
import Combine

class ClockViewController: UIViewController {
  // MARK: - Properties
  private let viewLoad = PassthroughSubject<Void,Never>()
  private let showDate = PassthroughSubject<Date,Never>()
  private let hideDate = PassthroughSubject<Void,Never>()
  
  private var dateView: UILabel!
  private var showDateButton: UIButton!
  private var hideDateButton: UIButton!
  
  private var viewModel: any ClockViewModelable & ClockViewModelDataSource
  
  private var subscriptions = Set<AnyCancellable>()
  
  // MARK: - Lifecycle
  init(viewModel: some ClockViewModelable & ClockViewModelDataSource) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    configureUI()
    bind()
    viewLoad.send()
  }
  
  // MARK: - Event handler
  @objc func didTapShowDate() {
    showDate.send(Date())
  }
  
  @objc func didTapHideDate() {
    hideDate.send()
  }
}

// MARK: - ViewControllerBindCase
extension ClockViewController: ViewBindable {
  typealias OutputError = Error
  typealias State = ClockViewModelState
  
  func bind() {
    
    /// 퍼블리셔는
    let input = ClockViewModelInput(
      viewDidLoad: viewLoad.eraseToAnyPublisher(),
      showDate: showDate.eraseToAnyPublisher(),
      hideDate: hideDate.eraseToAnyPublisher())
    
    /// type erased된 퍼블리셔들의 집합인 input structure 인스턴스를 인자값으로 보냅니다.
    let output = viewModel.transform(input)
    
    /// output의 upstream에선 비동기적으로 background queue에서 작업할 수 있지만
    ///   ui render를 할 때는 뷰의 ui를 변화시켜야 함으로 반드시 메인스레드에서 담당해야합니다.
    output
      .receive(on: RunLoop.current)
      .sink { self.render($0) }
      .store(in: &subscriptions)
  }
  
  func render(_ state: State) {
    switch state {
    case .none:
      print("뷰야 화면에 로드 됬니? :)")
      print("DEBUG: 아맞다,, 서버에서 데이터를 요청해서 받기까지 화면의 상태는 none")
      print("DEBUG: 서버에서 데이터를 받았다면, model의 특정 함수는 completionHandler호출!")
      print("DEBUG: 이에 대한 로직 처리 후 뷰한테 ViewModel이 뷰의 특정한 state로 업데이트하도록 notify!!")
    case .showTime(let currentTime):
      animate(
        button: showDateButton,
        logic: self.dateView.text = currentTime)
    case .hideTime(let labelData):
      animate(
        button: hideDateButton,
        logic: self.dateView.text = labelData)
    case .unexpectedError(let description):
      print("Unexpected Error Occured: \(description)")
    }
  }
}

// MARK: - Helpers
extension ClockViewController {
  func configureUI() {
    dateView = setDateView()
    showDateButton = setButtonLayout(with: "showDate", true)
    hideDateButton = setButtonLayout(with: "hideDate", false)
  }
}

// MARK: - Private helpers
extension ClockViewController {
  private func animate(
    button: UIButton,
    logic: @escaping @autoclosure ()->Void
  ) {
    UIView.animate(withDuration: 0.2, animations: {
      button.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
    }) { _ in
      logic()
      UIView.animate(withDuration: 0.2, animations: {
        button.transform = CGAffineTransform.identity
      })
    }
  }
  
  private func setDateView() -> UILabel {
    let v = UILabel()
    v.font = UIFont.systemFont(ofSize: 20)
    v.text = "Outputs UI Rendered"
    v.isHidden = false
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
  
  private func setButtonLayout(with title: String, _ isShowButton: Bool) -> UIButton {
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
    var constants: [NSLayoutConstraint] = [
      b.topAnchor.constraint(equalTo: dateView.bottomAnchor, constant: 100),
      b.widthAnchor.constraint(equalToConstant: 120),
      b.heightAnchor.constraint(equalToConstant: 60)
    ]
    if isShowButton {
      constants.append(b.leadingAnchor.constraint(equalTo: dateView.leadingAnchor))
      b.addTarget(self, action: #selector(didTapShowDate), for: .touchUpInside)
    }else {
      constants.append(b.trailingAnchor.constraint(equalTo: dateView.trailingAnchor))
      b.addTarget(self, action: #selector(didTapHideDate), for: .touchUpInside)
    }
    NSLayoutConstraint.activate(constants)
    return b
  }
}
