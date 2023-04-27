//
//  ViewModel.swift
//  MVVM Inputs-Outputs binding with combine
//
//  Created by 양승현 on 2023/04/27.
//

import Foundation
import Combine

struct ViewModel: ViewModelCase {
  typealias Input = ViewControllerInput
  typealias Output = AnyPublisher<ViewControllerState, Never>
  typealias State = ViewControllerState
  let model: Model
}

// MARK: - transform()
extension ViewModel {
  func transform(_ input: Input) -> Output {
    let viewDidLoadChains = input
      .viewDidLoad
      .map { _ -> State in
        return .none
      }
      .eraseToAnyPublisher()
    
    let showTimeChains = input
      .showDate
      .throttle(for: .seconds(0.4), scheduler: RunLoop.main,latest: true)
      .map{ date -> State in
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let curTime = dateFormatter.string(from: date)
        return .showTime(curTime)
      }
      .eraseToAnyPublisher()
    
    let hideTimeChains = input
      .hideDate
      .throttle(for: .seconds(0.4), scheduler: RunLoop.main,latest: true)
      .map{ _ -> State in
        return .hideTime(model.labelData)
      }
      .eraseToAnyPublisher()
    
    return Publishers
      .MergeMany([
        viewDidLoadChains,
        showTimeChains,
        hideTimeChains
      ])
      .eraseToAnyPublisher()
  }
}
