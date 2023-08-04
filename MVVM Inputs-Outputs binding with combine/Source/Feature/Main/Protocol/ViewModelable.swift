//
//  ViewModelable.swift
//  MVVM Inputs-Outputs binding with combine
//
//  Created by 양승현 on 2023/08/05.
//

protocol ViewModelable {
  associatedtype Input
  associatedtype State
  associatedtype Output
  
  func transform(_ input: Input) -> Output
}
