import UIKit
import WebKit

/// Main NotaBeneSwift public API
public final class NotaBeneSwift {
    // MARK: - Singleton
    
    /// Shared instance for the NotaBene service
    public static let shared = NotaBeneSwift()
    
    // Private constructor to enforce singleton pattern
    private init() {}
    
    // MARK: - Properties
    
    /// Current widget view controller if active
    private weak var widgetViewController: WidgetViewController?
    
    /// Callback for when the widget state changes
    private var onValidStateChangeHandler: ((Bool, Any?) -> Void)?
    
    // MARK: - Public API
    
    /// Initialize NotaBene with configuration
    /// - Parameters:
    ///   - configuration: The configuration for the NotaBene service
    ///   - transaction: Optional transaction data to pre-populate
    ///   - presentingViewController: The view controller to present the widget on
    ///   - onValidStateChange: Optional callback for when validation state changes
    public func initialize(
        with configuration: NotaBeneConfiguration,
        transaction: TransactionData_NT? = nil,
        presentingViewController: UIViewController,
        onValidStateChange: ((Bool, Any?) -> Void)? = nil
    ) {
        self.onValidStateChangeHandler = onValidStateChange
        
        let widgetVC = WidgetViewController(configuration: configuration)
        widgetVC.onValidStateChange = { [weak self] isValid, txData in
            self?.onValidStateChangeHandler?(isValid, txData)
        }
        
        if let transactionData = transaction {
            widgetVC.setTransaction(transactionData)
        }
        
        widgetViewController = widgetVC
        
        // Present the widget view controller
        if let navController = presentingViewController.navigationController {
            navController.pushViewController(widgetVC, animated: true)
        }
    }
    
    /// Set or update transaction data
    /// - Parameter transaction: The transaction data to set
    public func setTransaction(_ transaction: TransactionData_NT) {
        widgetViewController?.setTransaction(transaction)
    }
    
    /// Dismiss the widget if it's currently presented
    public func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        widgetViewController?.dismiss(animated: animated, completion: completion)
    }
} 
