//
//  ViewBindable.swift
//  MVVM Inputs-Outputs binding with combine
//
//  Created by 양승현 on 2023/08/05.
//

protocol ViewBindable {
  associatedtype State
  associatedtype OutputError: Error
  
  func bind()
  func render(_ state: State)
  /// publisher의 occured error 에 대한 헨들링이 필요하다면, 이 메서드를 구현해서 사용하셔야 합니다.
  /// 기본적으로 동작x
  func handleError(_ error: OutputError)
}

extension ViewBindable {
  func handleError(_ error: OutputError) { }
}
