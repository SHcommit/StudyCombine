//
//  Protocols.swift
//  MVVM Inputs-Outputs binding with combine
//
//  Created by 양승현 on 2023/04/27.
//

import Foundation
import Combine

/**
 TODO : ViewController에서 발생되는 user  interaction event, view lifecycle를 publisher 인스턴스로 정의
 
 - Param viewDidLoad : 뷰가 화면에 로드되는 이벤트 발생
 - Param showDate : showDate 버튼 클릭. 이때 버튼 클릭 당시의 Date인스턴스 필요
 - Param hideDate : hideDate 버튼 클릭. 단순 이벤트 발생했다는 신호 전달.
 
  Notes:
 1. 이 인스턴스 각각은 publisher입니다. ViewControllerInput 구조체 생성하기 위해선 3개의 publihser가 있어야 합니다.
 
 */
struct ClockViewModelInput {
  let viewDidLoad: AnyPublisher<Void,Never>
  let showDate: AnyPublisher<Date,Never>
  let hideDate: AnyPublisher<Void,Never>
}

/**
 TODO : viewModel.transform()함수를 통해 로직 처리 이후 ViewController에서 업데이트 해야 할 view의 state를 방출.
 
 - Case none : 뷰의 상태 변화 없음.
 - Case showTime : label 상태를 String으로 변경
 - Case hideTime : label 상태를 원래 label 데이터로 변경
 */
enum ClockViewModelState {
  case none
  case showTime(String)
  case hideTime(String)
}
