//
//  ViewModelable.swift
//  MVVM Inputs-Outputs binding with combine
//
//  Created by 양승현 on 2023/08/05.
//

import Combine

protocol ViewModelable {
  associatedtype Input
  associatedtype State
  typealias Output = AnyPublisher<State, Never>
  
  func transform(_ input: Input) -> Output
}

