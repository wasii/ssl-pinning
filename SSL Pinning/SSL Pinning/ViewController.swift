//
//  ViewController.swift
//  SSL Pinning
//
//  Created by NaheedPK on 28/06/2022.
//

import UIKit

class ViewController: UIViewController {

    var session: URLSession?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        callServer()
    }

    private func callServer() {
        session?.dataTask(with: URL(string: "https://run.mocky.io/v3/befb0a8b-154f-4cdd-93f8-7fa98454e783")!) { data, response, error in
            if error == nil {
                do {
                    let dResponse = try JSONDecoder().decode(DummyResponse.self, from: data!)
                    print(dResponse)
                    DispatchQueue.main.async {
                        debugPrint(dResponse.message)
                    }
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
}


class DummyResponse: Codable {
    var purpose: String
    var sslPort: Int
    var status: Int
    var message: String
    
    enum CodingKeys: String, CodingKey {
        case purpose
        case sslPort
        case status
        case message
    }
}
