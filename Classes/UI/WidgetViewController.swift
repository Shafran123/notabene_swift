import UIKit
import WebKit

/// Internal view controller responsible for displaying the Notabene widget
internal final class WidgetViewController: UIViewController {
    // MARK: - Properties
    
    /// The web view that will display the widget
    private var webView: WKWebView!
    
    /// Configuration for the widget
    private let configuration: NotaBeneConfiguration
    
    /// Current transaction data
    private var currentTransaction: TransactionData?
    
    /// Called when the validation state changes
    var onValidStateChange: ((Bool, [String: Any]?) -> Void)?
    
    /// Add this property to track if the webView is ready for JavaScript execution
    private var isWebViewReady = false
    
    // MARK: - Initialization
    
    init(configuration: NotaBeneConfiguration) {
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupWebView()
        setupJavascriptBridge()
        loadNotabeneWidget()
    }
    
    // MARK: - Setup methods
    
    private func setupWebView() {
        print("NotaBene: Setting up WebView")
        // Create WKWebView configuration
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        
        // Setup JavaScript message handler
        let contentController = WKUserContentController()
        contentController.add(self, name: "notabeneCallback")
        config.userContentController = contentController
        
        // Create WebView with configuration
        webView = WKWebView(frame: view.bounds, configuration: config)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        
        // Add WebView to the view hierarchy
        view.addSubview(webView)
        print("NotaBene: WebView setup complete")
    }
    
    private func setupJavascriptBridge() {
        // Add JavaScript bridge for communication between Swift and JS
        let script = WKUserScript(
            source: """
            window.notabeneNativeCallback = function(data) {
                window.webkit.messageHandlers.notabeneCallback.postMessage(data);
            }
            """,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        )
        
        webView.configuration.userContentController.addUserScript(script)
    }
    
    // MARK: - Widget methods
    
    /// Load the NotaBene widget into the web view
    private func loadNotabeneWidget() {
        print("NotaBene: Loading widget HTML content")
        // Generate HTML with proper configuration
        let html = generateWidgetHTML()
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    /// Generate the HTML content for the widget
    private func generateWidgetHTML() -> String {
        // Create dictionary JSON representation if available
        let dictionaryJSON = configuration.dictionary != nil ?
            try? JSONSerialization.data(withJSONObject: configuration.dictionary!, options: []) : nil
        let dictionaryString = dictionaryJSON != nil ?
            String(data: dictionaryJSON!, encoding: .utf8) ?? "{}" : "{}"
        
        return """
        <!DOCTYPE html>
        <html lang="en">
        <head>
          <meta charset="UTF-8" />
          <meta http-equiv="X-UA-Compatible" content="IE=edge" />
          <meta name="viewport" content="width=device-width, initial-scale=1.0" />
          <title>Notabene Widget</title>
          <script id="notabene" async src="https://unpkg.com/@notabene/javascript-sdk@1.20.0/dist/es/index.js"></script>
          <script>
            document.querySelector('#notabene').addEventListener('load', function () {
              const nb = new Notabene({
                widget: '\(configuration.widgetUrl)',
                vaspDID: '\(configuration.vaspDID)',
                container: '#container',
                authToken: '\(configuration.authToken)',
                dictionary: \(dictionaryString),
                onValidStateChange: (isValid) => {
                  console.log(isValid);
                  console.log(nb.tx);
                  window.notabeneNativeCallback({
                    isValid: isValid,
                    transaction: nb.tx
                  });
                },
                transactionTypeAllowed: '\(configuration.transactionTypeAllowed.rawValue)',
                nonCustodialDeclarationType: '\(configuration.nonCustodialDeclarationType.rawValue)',
              });
              
              // Store reference to nb for later use
              window.notabeneInstance = nb;
              
              // Set transaction data if available
              \(currentTransaction != nil ? generateSetTransactionJS() : "")
              
              // Render the widget
              nb.renderWidget();
            });
          </script>
          <style>
            body, html {
              margin: 0;
              padding: 0;
              width: 100%;
              height: 100%;
            }
            #container {
              width: 100%;
              height: 100%;
            }
          </style>
        </head>
        <body>
            <p>Hello</p>
          <div id="container"></div>
        </body>
        </html>
        """
    }
    
    /// Generate JavaScript to set transaction data
    private func generateSetTransactionJS() -> String {
        guard let transaction = currentTransaction else { return "" }
        
        return """
        nb.setTransaction({
          transactionAsset: '\(transaction.transactionAsset)',
          beneficiaryAccountNumber: '\(transaction.beneficiaryAccountNumber)',
          transactionAmount: '\(transaction.transactionAmount)',
        });
        """
    }
    
    /// Set transaction data for the widget
    func setTransaction(_ transaction: TransactionData) {
        self.currentTransaction = transaction
        
        // Only execute JavaScript if the webView is fully ready
        if isWebViewReady, let webView = self.webView {
            applyTransactionToWidget(transaction)
        }
        // Otherwise it will be applied when webView finishes loading
    }
    
    // Add this delegate method to know when the webView is truly ready
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("NotaBene: Widget finished loading")
        isWebViewReady = true
        
        // If we have a transaction waiting to be applied, do it now
        if let transaction = currentTransaction {
            print("NotaBene: Applying cached transaction after WebView loaded")
            applyTransactionToWidget(transaction)
        }
    }
    
    // Extract the JavaScript execution to a separate method
    private func applyTransactionToWidget(_ transaction: TransactionData) {
        print("NotaBene: Applying transaction to widget")
        let js = """
        if (window.notabeneInstance) {
            window.notabeneInstance.setTransaction({
                transactionAsset: '\(transaction.transactionAsset)',
                beneficiaryAccountNumber: '\(transaction.beneficiaryAccountNumber)',
                transactionAmount: '\(transaction.transactionAmount)',
            });
        }
        """
        webView.evaluateJavaScript(js) { result, error in
            if let error = error {
                print("NotaBene: Error evaluating JavaScript: \(error.localizedDescription)")
            } else {
                print("NotaBene: Transaction successfully applied to widget")
            }
        }
    }
}

// MARK: - WKNavigationDelegate
extension WidgetViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("NotaBene: Widget started loading")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("NotaBene: Widget failed to load: \(error.localizedDescription)")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("NotaBene: Widget failed initial loading: \(error.localizedDescription)")
    }
}

// MARK: - WKScriptMessageHandler
extension WidgetViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("NotaBene: Received message from widget JavaScript")
        if message.name == "notabeneCallback", let messageBody = message.body as? [String: Any] {
            if let isValid = messageBody["isValid"] as? Bool {
                let transaction = messageBody["transaction"] as? [String: Any]
                print("NotaBene: Widget validation state changed - isValid: \(isValid)")
                DispatchQueue.main.async {
                    self.onValidStateChange?(isValid, transaction)
                }
            }
        }
    }
} 