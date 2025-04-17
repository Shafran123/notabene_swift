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
    private var currentTransaction: TransactionData_NT?
    
    /// Called when the validation state changes
    var onValidStateChange: ((Bool, Any?) -> Void)?
    
    /// Add this property to track if the webView is ready for JavaScript execution
    private var isWebViewReady = false
    private var isDismissing = false
    // MARK: - Initialization
    
    init(configuration: NotaBeneConfiguration) {
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle methods
    
    // MARK: - Lifecycle methods
      
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = (configuration.theme == "dark") ? .init(red: 45/255, green: 45/255, blue: 45/255, alpha: 1) : .white
        setupWebView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        
        // Create WebView with configuration first
        webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        
        // Add all views before setting up constraints
        view.addSubview(webView)
        
        let headerView = UIView()
        headerView.backgroundColor = .clear
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        
        let titleLabel = UILabel()
        titleLabel.text = configuration.titleText
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)
        
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = (configuration.theme == "dark") ? .white : .black
        backButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(backButton)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),
            
            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            webView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        
        print("NotaBene: WebView setup complete")
    }
    
    // Add dismiss method
       @objc func dismissView() {
           if let navigationController = navigationController {
               navigationController.popViewController(animated: true)
           } else {
               dismiss(animated: true)
           }
       }
    
    private func setupJavascriptBridge() {
        // Add JavaScript bridge for communication between Swift and JS
        let script = WKUserScript(
            source: """
            window.notabeneNativeCallback = function(data) {
                window.webkit.messageHandlers.notabeneCallback.postMessage(
                              JSON.stringify(data)
            );
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
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        } else {
            // Fallback on earlier versions
        }
        let baseURL = URL(string: configuration.widgetUrl)
        webView.loadHTMLString(html, baseURL: baseURL)
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
                dictionary:{
                
                },
                theme: {
                  mode: '\(configuration.theme)',
                  primaryColor: '\(configuration.primaryColor)',
                  logo: '\(configuration.logoURL)'
                  // You can also customize other theme elements if needed:
                  // secondaryColor: '#yourColor',
                  // backgroundColor: '#yourColor',
                  // primaryFontColor: '#yourColor',
                  // secondaryFontColor: '#yourColor',
                  // fontFamily: 'yourFont'
                
                },
                onValidStateChange: (isValid) => {
                  console.log(isValid);
                  console.log(nb.tx);
                  window.notabeneNativeCallback({
                    isValid: isValid,
                    transaction: nb.tx
                  });
                },
                transactionTypeAllowed: 'ALL',
                nonCustodialDeclarationType: 'DECLARATION',
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
              background-color: \((configuration.theme == "dark") ? "#2D2D2D" : "#FFFFFF");
            }
            #container {
              width: 100%;
              height: 100%;
              padding: 20;
              margin: 0 auto;
              position: relative;
              overflow-y: auto;
              -webkit-overflow-scrolling: touch;
              display: flex;
              justify-content: center;
              align-items: center;
              background-color: \((configuration.theme == "dark") ? "#2D2D2D" : "#FFFFFF");
            }
          </style>
        </head>
        <body>
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
    func setTransaction(_ transaction: TransactionData_NT) {
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
    private func applyTransactionToWidget(_ transaction: TransactionData_NT) {
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
        if message.name == "notabeneCallback" {
            if let jsonString = message.body as? String {
                print("Notabene Response (raw): \(jsonString)")
                if let data = jsonString.data(using: .utf8) {
                    do {
                        let parsedResponse = try JSONSerialization.jsonObject(with: data, options: [])
                        print("Notabene Response (parsed): \(parsedResponse)")
                        // Safely check if the isValid property exists and is true
                        if let jsonDict = parsedResponse as? [String: Any],
                           let isValid = jsonDict["isValid"] as? Bool,
                             isValid {
                                // Prevent multiple dismiss operations
                                guard !self.isBeingDismissed else { return }
                                
                                // Then dismiss after a short delay to show success state
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    // Only proceed if we haven't started dismissing yet
                                    guard !self.isDismissing else { return }
                                    self.isDismissing = true
                                    
                                    //print("Back From NB")
                                    if let navigationController = self.navigationController {
                                        navigationController.popViewController(animated: true)
                                        // First call the callback to notify about the valid state
                                        self.onValidStateChange?(isValid, parsedResponse)
                                    } else {
                                        self.dismiss(animated: true)
                                    }
                                }
                            }
                    } catch {
                        print("Notabene Response (parsing error): \(error)")
                    }
                } else {
                    print("Notabene Response (couldn't convert to data)")
                }
            } else {
                print("Notabene Response (unexpected format): \(message.body)")
            }
        }
    }
} 
