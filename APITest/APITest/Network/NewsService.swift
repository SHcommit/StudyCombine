//
//  NewsService.swift
//  APITest
//
//  Created by 양승현 on 2023/01/04.
//

import Foundation
import Combine

enum NewsServiceError: LocalizedError {
    case addressUnreachable(URL)
    case invalidResponse
}
extension NewsServiceError: CustomStringConvertible {
    var description: String {
        switch self {
        case .invalidResponse:
            return "The server responded with garbage"
        case .addressUnreachable(let url):
            return "\(url.absoluteString) is unreachable!!!!!!!!"
        }
    }
}

enum NewsServiceEndPoint {
    static let baseURL = PrivateAPIs.baseURL
    case stories
    case story(Int)
    
    var url: URL {
        switch self {
        case .stories:
            return NewsServiceEndPoint.baseURL.appendingPathComponent("newstories.json")
        case .story(let id):
            return NewsServiceEndPoint.baseURL.appendingPathComponent("item/\(id).json")
        }
    }
}

struct NewsService {
    private static let decoder = JSONDecoder()
    
    static func story(id: Int) -> AnyPublisher<Story,NewsServiceError> {
        return URLSession.shared
            .dataTaskPublisher(for: NewsServiceEndPoint.story(id).url)
            .print()
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: RunLoop.main)
            .map(\.data)
            .decode(type: Story.self, decoder: decoder)
            .mapError { error -> NewsServiceError in
                return error as? NewsServiceError ?? .invalidResponse
            }.eraseToAnyPublisher()
            
        //mapError의 Error를 통한 .finish가 가능하다. .catch를 통해서 잡아줄 수도 있다.
        //ex) .mapError 대신 .catch { _ in Empty<Story,Error>() }
            
    }
}
