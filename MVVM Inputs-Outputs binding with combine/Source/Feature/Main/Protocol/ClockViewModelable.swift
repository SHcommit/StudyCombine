//
//  ClockViewModelable.swift
//  MVVM Inputs-Outputs binding with combine
//
//  Created by 양승현 on 2023/08/05.
//

import Combine

protocol ClockViewModelable: ViewModelable
where Input == ClockViewModelInput,
      State == ClockViewModelState { }
