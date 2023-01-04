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
        configureData()
    }
}
extension ViewController {
    func configureData() {
        //single story fetch
        fetchNewsStory(with: 1000)
        print("----- Line break -----")
        fetchAndMergeNewsStory(with: [1000, 1001, 1002])
    }
}

//MARK: - API
extension ViewController {
    
    /// fetch one story
    func fetchNewsStory(with id: Int)  {
        NewsService.story(id: id)
            .receive(on: RunLoop.main)
            .sink { [unowned self] state in
                render(state)
            } receiveValue: {
                print($0)
                self.story = $0
            }.store(in: &subscriptions)
    }
    
    func fetchAndMergeNewsStory(with storyIDs: [Int]) {
        print("DEBUG: MergedNewsStory")
        NewsService.stories(ids: storyIDs)
            .sink { [unowned self] state in
                render(state)
            } receiveValue: { story in
                print(story)
            } .store(in: &subscriptions)
    }
    
}

//MARK: - API Helpers
extension ViewController {
    func render(_ state: Subscribers.Completion<NewsServiceError>) {
        switch state {
        case .failure(let error):
            failedNewsStoryErrorHandler(with: error)
        case .finished:
            print("DEBUG: Success fetch new story.")
        }
    }
    
    func failedNewsStoryErrorHandler(with error: NewsServiceError) {
        print("DEBUG: \(error)")
        switch error {
        case .invalidResponse:
            ///InvalidResponse error 처리
            break
        case .addressUnreachable(_):
            ///addressUnreachable error 처리
            break
        }
    }
}
