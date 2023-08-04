//
//  ClockViewModel.swift
//  MVVM Inputs-Outputs binding with combine
//
//  Created by 양승현 on 2023/04/27.
//

import Foundation
import Combine

/// ViewModel은 model의 특정 데이터 중 현재 시간을 반환해야 한다면? protocol과 Composition을 사용합니다: ]
protocol ClockViewModelDataSource {
  func currentHour() -> String
}

final class ClockViewModel {
  // MARK: - Properties
  private var model: Model
  
  init(model: Model) {
    self.model = model
  }
}

// MARK: - ClockViewModelable
extension ClockViewModel: ClockViewModelable {
  func transform(_ input: Input) -> Output {
    let viewDidLoad = viewDidLoadChains(input)
    
    let showTime = showTimeChains(input)
    
    let hideTime = hideTimeChains(input)
    
    return Publishers
      .MergeMany([
        viewDidLoad,
        showTime,
        hideTime
      ]).eraseToAnyPublisher()
  }
}

/// 이것은 예시를 위해 만들었습니다. View에서 protocol로 ClockViewModelable 타입만 선언하면
/// View는 transform()함수만 쓸 수 있습니다.
/// 추가적으로 model로부터 특정 데이터를 가공해서 반환해야 한다면, 프로토콜을 통해서 반환하는 함수를 준수하고,
/// View에서는 protocol composition으로 타입을 선언하면 됩니다.
extension ClockViewModel: ClockViewModelDataSource {
  func currentHour() -> String {
    /// Model 레이블 형식은 "yyyy-MM-dd HH:mm:ss" or "Outputs UI Rendered" 인데.. 쉽게 시간을 저장했을 때
    /// HH만 추출해서 반환하려고 합니다.
    /// 근데 여기서는 Input/ output만 예시로 보여줄 것이기에,, 실질적으로 사용하지는 않습니다.
    if model.labelData.contains("Outputs") { return "NN" }
    return model.labelData.split{$0==" "}.last?.split{$0==":"}.first.map{ String($0) } ?? "00"
  }
}

// MARK: - Private helper
extension ClockViewModel {
  
  private func viewDidLoadChains(_ input: Input) -> Output {
    return input
      .viewDidLoad
      .map { _ -> State in
        return .none
      }
      .eraseToAnyPublisher()
  }
  
  private func showTimeChains(_ input: Input) -> Output {
    return input
      .showDate
      .throttle(for: .seconds(0.4), scheduler: RunLoop.main, latest: true)
      .map{ date -> State in
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let curTime = dateFormatter.string(from: date)
        return .showTime(curTime)
      }
      .eraseToAnyPublisher()
  }
  
  private func hideTimeChains(_ input: Input) -> Output {
    return input
      .hideDate
      .throttle(for: .seconds(0.4), scheduler: RunLoop.main,latest: true)
      .map{ [weak self] _ -> State in
        guard let model = self?.model else {
          // 사실 여기서 에러 처리 전용 state 로 상태 변경해야 합니다.
          return .none
        }
        return .hideTime(model.labelData)
      }
      .eraseToAnyPublisher()
  }
}
