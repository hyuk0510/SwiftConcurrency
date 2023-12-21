//
//  ViewController.swift
//  SwiftConcurrency
//
//  Created by 선상혁 on 2023/12/19.
//

import UIKit

/*
 @MainActor: Swift Concurrency를 작성한 코드에서 다시 메인 쓰레드로 돌려주는 역할을 수행
 */

class MyClassA {
    var target: MyClassB?
    
    deinit {
        print("MyClassA Deinit")
    }
}

class MyClassB {
    var target: MyClassA?
    
    deinit {
        print("MyClassB Deinit")
    }
}

/*
 SwiftUI -> UIKit
 
 */

class DetailViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        view.backgroundColor = .gray
        
        let a = MyClassA()
        let b = MyClassB()
        
        a.target = b
        b.target = a
        
//        a.target = nil
    }
    
    deinit {
        print("DEINIT")
    }
}

class ViewController: UIViewController {

    @IBOutlet var posterImageView: UIImageView!
    @IBOutlet var secondImageView: UIImageView!
    @IBOutlet var thirdImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tpUhFQWn5gV7GnagWOOMHToJOsX
        //90D6sXfbXKhDpd4S1cHICdAe8VD
        //jFuH0md41x5mB4qj5344mSmtHrO
        
//        Task {
//            let result1 = try await Network.shared.fetchThumbnailAsyncAwait(value: "tpUhFQWn5gV7GnagWOOMHToJOsX")
//            let result2 = try await Network.shared.fetchThumbnailAsyncAwait(value: "90D6sXfbXKhDpd4S1cHICdAe8VD")
//            let result3 = try await Network.shared.fetchThumbnailAsyncAwait(value: "jFuH0md41x5mB4qj5344mSmtHrO")
//            posterImageView.image = result1
//            secondImageView.image = result2
//            thirdImageView.image = result3
//        }
        
        
//        Network.shared.fetchThumbnail { image in
//            self.posterImageView.image = image
//        }
        
//        Network.shared.fetchThumbnailWithURLSession { data in
//            switch data {
//            case .success(let value):
//                
//                DispatchQueue.main.async {
//                    self.posterImageView.image = value
//                }
//                
//            case .failure(let failure):
//                DispatchQueue.main.async {
//                    self.posterImageView.backgroundColor = .gray
//                }
//                print(failure)
//            }
//        }
        
        Task {
            print(#function, "1", Thread.isMainThread)
            let result = try await Network.shared.fetchThumbnailAsyncLet()
            print(#function, "2", Thread.isMainThread)

            posterImageView.image = result[0]
            secondImageView.image = result[1]
            thirdImageView.image = result[2]
            print(#function, "3", Thread.isMainThread)
        }
      
//        Task {
//            let result = try await Network.shared.fetchThumbnailTaskGroup()
//            
//            posterImageView.image = result[0]
//            secondImageView.image = result[1]
//            thirdImageView.image = result[2]
//        }
        
    }

    @IBAction func testButtonPressed(_ sender: UIButton) {
        
        let vc = HostingTestView(rootView: TestView())
        
        present(vc, animated: true)
//        present(DetailViewController(), animated: true)
    }
    

}

