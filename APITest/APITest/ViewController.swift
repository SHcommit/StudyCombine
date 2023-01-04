//
//  ViewController.swift
//  APITest
//
//  Created by 양승현 on 2023/01/04.
//

import UIKit
import Combine

class ViewController: UIViewController {
    //MARK: - Constraints
    
    //MARK: - Properties
    var story: Story?
    //MARK: - Combine properties
    var subscriptions = Set<AnyCancellable>()
    //MARK: - Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        fetchNewsStory(with: 1000)
    }
}

//MARK: - API
extension ViewController {
    func fetchNewsStory(with id: Int)  {
        NewsService.story(id: id)
            .receive(on: RunLoop.main)
            .sink { state in
                switch state {
                case .failure(let error):
                    print("DEBUG: \(error)")
                case .finished:
                    print("DEBUG: Success fetch new story.")
                }
                
            } receiveValue: {
                print($0)
                self.story = $0
            }.store(in: &subscriptions)
    }
}
