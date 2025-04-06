//
//  MainVC.swift
//  FBSnapshotTestCase
//
//  Created by Shafran Naizer on 05/04/2025.
//

import UIKit
import WebKit

class MainVC: UIViewController {
    
    // MARK: - Properties
    private var webView: WKWebView!
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupWebView()
        loadNotabeneWidget()
    }
    
    // MARK: - Setup Methods
    private func setupWebView() {
        // Create WKWebView configuration
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        
        // Create WebView with configuration
        webView = WKWebView(frame: view.bounds, configuration: configuration)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        
        // Add WebView to the view hierarchy
        view.addSubview(webView)
    }
    
    // MARK: - Load Widget
    private func loadNotabeneWidget() {
        // HTML content for the Notabene widget
        let html = """
        <!DOCTYPE html>
        <html lang="en">
        
        <head>
          <meta charset="UTF-8" />
          <meta http-equiv="X-UA-Compatible" content="IE=edge" />
          <meta name="viewport" content="width=device-width, initial-scale=1.0" />
          <title>Notabene Widget Example</title>
          <script id="notabene" async src="https://unpkg.com/@notabene/javascript-sdk@1.20.0/dist/es/index.js"></script>
          <script>
            document.querySelector('#notabene').addEventListener('load', function () {
              const nb = new Notabene({
                widget: 'YOUR_WIDGET_URL', // Replace with actual URL
                vaspDID: 'YOUR_VASP_DID', // Replace with actual VASP DID
                container: '#container',
                authToken: 'YOUR_AUTH_TOKEN', // Replace with actual auth token
                dictionary: {
                },
                onValidStateChange: (isValid) => {
                  console.log(isValid)
                  console.log(nb.tx)
                },
        
                transactionTypeAllowed: 'ALL', // 'ALL', 'SELF_TRANSACTION_ONLY', 'VASP_2_VASP_ONLY'
                nonCustodialDeclarationType: 'DECLARATION', // 'SIGNATURE', 'DECLARATION'
        
              });
              nb.setTransaction({
                transactionAsset: 'eth',
                beneficiaryAccountNumber: '0xFc201F202ae8BF5f315c49f1fB074043A1558867',
                transactionAmount: '1500000000000000000000',
              });
              nb.renderWidget();
            });
          </script>
        </head>
        
        <body>
          <div id="container"></div>
        </body>
        
        </html>
        """
        
        // Load the HTML content into the WebView
        webView.loadHTMLString(html, baseURL: nil)
    }
}

// MARK: - WKNavigationDelegate
extension MainVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("WebView finished loading")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("WebView failed to load: \(error.localizedDescription)")
    }
}
