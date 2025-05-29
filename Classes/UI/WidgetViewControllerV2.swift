import UIKit
import WebKit

/// Internal view controller responsible for displaying the Notabene widget
internal final class WidgetViewControllerV2: UIViewController {
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
        return """
        <!DOCTYPE html>
        <html lang="en">
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            body, html {
              background-color: \((configuration.theme == "dark") ? "#2D2D2D" : "#FFFFFF");
            }
          </style>
        </head>
        <body>
          <div id="output"></div>
          
          <script type="module">
            // Import the Notabene class from the SDK using unpkg
            import Notabene from 'https://unpkg.com/@notabene/javascript-sdk@next/dist/notabene.js';

            // Create a new Notabene instance
            const nbInstance = new Notabene({
              nodeUrl: '\(configuration.widgetUrl)',
              authToken: '\(configuration.authToken)',
              locale: 'en',
              theme: {
                primaryColor: '\(configuration.primaryColor)',
                mode: '\(configuration.theme)',
                logo: '\(configuration.logoURL)',
                fontFamily: 'Roboto'
              },
            });
            
            const tx = {
              asset: '\(currentTransaction?.transactionAsset ?? "")',
              destination: '\(currentTransaction?.beneficiaryAccountNumber ?? "")',
              amountDecimal: \(currentTransaction?.transactionAmount ?? "0")
            };

            const options = {
              proofs: {
                microTransfer: {
                  destination: '\(currentTransaction?.beneficiaryAccountNumber ?? "")',
                  amountSubunits: 50000000000000,
                  timeout: 86440,
                },
                fallbacks: ['screenshot', 'self-declaration'],
              },
              allowedAgentTypes: ['WALLET','VASP'],
              allowedCounterpartyTypes: ['legal', 'natural', 'self'],
              fields: {
                naturalPerson: {
                  name: true,
                  placeOfBirth: true,
                  countryOfResidence: true,
                },
                legalPerson: {
                  name: true,
                  lei: true,
                  website: { optional: true },
                },
              },
            };

            const withdrawal = nbInstance.createWithdrawalAssist(tx, options);
            withdrawal.mount("#output");

            // Add all relevant callbacks for data handling
            withdrawal.on('error', (error) => {
              window.webkit.messageHandlers.notabeneCallback.postMessage(
                JSON.stringify({
                  type: 'error',
                  error: error
                })
              );
            });

            withdrawal.on('ready', () => {
              window.webkit.messageHandlers.notabeneCallback.postMessage(
                JSON.stringify({
                  type: 'ready'
                })
              );
            });

            withdrawal.on('close', () => {
              window.webkit.messageHandlers.notabeneCallback.postMessage(
                JSON.stringify({
                  type: 'close'
                })
              );
            });

            withdrawal.on('complete', (transaction) => {
                window.webkit.messageHandlers.notabeneCallback.postMessage(
                JSON.stringify({
                    type: 'complete',
                    transaction: transaction
                })
                );
            });
          </script>
        </body>
        </html>
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
extension WidgetViewControllerV2: WKNavigationDelegate {
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
extension WidgetViewControllerV2: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "notabeneCallback" {
            guard let jsonString = message.body as? String,
                  let data = jsonString.data(using: .utf8) else {
                print("Notabene Response (invalid format)")
                return
            }
            
            do {
                guard let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                      let type = jsonDict["type"] as? String else {
                    print("Notabene Response (invalid JSON structure)")
                    return
                }
                
                print("Notabene Response (type: \(type)): \(jsonDict)")
                switch type {
                case "error":
                    if let error = jsonDict["error"] as? [String: Any] {
                        print("Error occurred: \(error)")
                        NotificationCenter.default.post(name: NSNotification.Name("NotabeneError"),
                                                      object: nil,
                                                      userInfo: ["error": error])
                    }
                case "ready":
                    print("Widget is ready")
                case "close":
                    print("Widget is closing")
                case "complete":
                    if let transaction = jsonDict["transaction"] as? [String: Any] {
                        handleValidStateChange(transaction)
                    }
                default:
                    print("Unknown message type: \(type)")
                }
            } catch {
                print("Notabene Response (parsing error): \(error)")
            }
        }
    }
    
    private func handleValidStateChange(_ transaction: [String: Any]) {
       
        guard let response = transaction["response"] as? [String: Any],
              let value = response["value"] as? [String: Any] else {
            print("Could not extract response.value from transaction")
            return
            
        }
           
        print("Transaction value data: \(value)")
        
        // Prevent multiple dismiss operations
        //guard !self.isBeingDismissed else { return }
        
        // Call the callback to notify about the valid state
        self.onValidStateChange?(true, value)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Only proceed if we haven't started dismissing yet
            guard !self.isDismissing else { return }
            self.isDismissing = true
            
            if let navigationController = self.navigationController {
                navigationController.popViewController(animated: true)
            } else {
                self.dismiss(animated: true)
            }
        }
    }
    
    private func handleClose() {
        guard !self.isBeingDismissed && !self.isDismissing else { return }
        self.isDismissing = true
        
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
}
