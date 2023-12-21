//
//  Network.swift
//  SwiftConcurrency
//
//  Created by 선상혁 on 2023/12/19.
//

import UIKit

enum abcError: Error {
    case invalidResponse
    case unknown
    case invalidImage
}

/*
 GCD vs Swift Concurrency
 - completion handler
 - 비동기를 동기처럼
 
 - Thread Explosion
 - Context Switching
 -> 코어의 수와 쓰레드의 수를 같게
 -> 같은 쓰레드 내에서 Continuation 전환 형식으로 방식을 변경
 
 - async throws / try await: 비동기를 동기처럼
 - Task : 비동기 함수와 동기 함수를 연결
 - async let : (ex. dispatchGroup)
 - taskGroup:
 
 */

class Network {
    
    static let shared = Network()
    
    private init() {}
    func fetchThumbnail(completion: @escaping (UIImage) -> Void) {
        
        let url = "https://www.themoviedb.org/t/p/w600_and_h900_bestv2/tpUhFQWn5gV7GnagWOOMHToJOsX.jpg"
        
        DispatchQueue.global().async {
            
            if let data = try? Data(contentsOf: URL(string: url)!) {
                
                if let image = UIImage(data: data) {
                    
                    DispatchQueue.main.async {
                        completion(image)
                    }
                }
            }
        }
    }
    
    func fetchThumbnailWithURLSession(completion: @escaping (Result<UIImage,abcError>) -> Void) {
        
        let url = URL(string: "https://www.themoviedb.org/t/p/w600_and_h900_bestv2/tpUhFQWn5gV7GnagWOOMHToJOsX.jpg")!
        
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5) //cachePolicy: , timeoutInterval:
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let data else {
                completion(.failure(.unknown))
                return
            }
            
            guard error == nil else {
                completion(.failure(.unknown))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let image = UIImage(data: data) else {
                completion(.failure(.invalidImage))
                return
            }
            
            completion(.success(image))
            
        }.resume()
        
    }
    
    //async 비동기로 작업할 함수
    func fetchThumbnailAsyncAwait(value: String) async throws -> UIImage {
        let url = URL(string: "https://www.themoviedb.org/t/p/w600_and_h900_bestv2/\(value).jpg")!
        
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5)

        //비동기를 동기처럼 작업 할꺼니까, 응답 올때까지 기다려
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw abcError.invalidResponse
        }
        
        guard let image = UIImage(data: data) else {
            throw abcError.invalidImage
        }
        
        print(url.description)
        
        return image
    }
    
    @MainActor
    func fetchThumbnailAsyncLet() async throws -> [UIImage] {
        
        async let result1 = Network.shared.fetchThumbnailAsyncAwait(value: "tpUhFQWn5gV7GnagWOOMHToJOsX")
        async let result2 = Network.shared.fetchThumbnailAsyncAwait(value: "90D6sXfbXKhDpd4S1cHICdAe8VD")
        async let result3 = Network.shared.fetchThumbnailAsyncAwait(value: "jFuH0md41x5mB4qj5344mSmtHrO")
        
        return try await [result1, result2, result3]
    }
    
    func fetchThumbnailTaskGroup() async throws -> [UIImage] {
        let poster = ["tpUhFQWn5gV7GnagWOOMHToJOsX", "90D6sXfbXKhDpd4S1cHICdAe8VD", "jFuH0md41x5mB4qj5344mSmtHrO"]
        
        //
        return try await withThrowingTaskGroup(of: UIImage.self) { group in
            
            for item in poster {
                
                group.addTask {
                    try await self.fetchThumbnailAsyncAwait(value: item)
                }
                
            }
            var resultImages: [UIImage] = []
            
            for try await item in group {
                resultImages.append(item)
            }
            
            return resultImages
        }
    }
}
