//
//  Publishers+.swift
//  MVVM Inputs-Outputs binding with combine
//
//  Created by 양승현 on 6/2/24.
//

import Combine
import Foundation

public extension Publisher {
  /// https://dev-with-precious-dreams.tistory.com/285
  func subscribeAndReceive(
    on queue: DispatchQueue
  ) -> AnyPublisher<Self.Output, Self.Failure> {
    return self
      .subscribe(on: queue)
      .receive(on: queue)
      .eraseToAnyPublisher()
  }
}
