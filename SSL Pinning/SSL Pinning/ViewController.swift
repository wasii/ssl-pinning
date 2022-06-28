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

extension ViewController: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0)
        
        //SSL Policies for domain name check
        let policy = NSMutableArray()
        policy.add(SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString))
        
        //evaluate server certificate
        let isServerTrusted = SecTrustEvaluateWithError(serverTrust, nil)
        
        //Remote and Local Certificate data
        let remoteCertificateData: NSData = SecCertificateCopyData(certificate!)
        
        let pathToCertificate = Bundle.main.path(forResource: "mocky", ofType: ".cer")
        let localCertificateData: NSData = NSData(contentsOfFile: pathToCertificate!)!
        
        //Compare Certificates
        if isServerTrusted && remoteCertificateData.isEqual(to: localCertificateData as Data) {
            let credentials = URLCredential(trust: serverTrust)
            print("SSL Pinning is successful")
            completionHandler(.useCredential, nil)
        } else {
            debugPrint("Signature Failed")
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
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
