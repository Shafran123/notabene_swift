import UIKit
import WebKit

/// Main NotaBeneSwift public API
public final class NotaBeneSwift {
    // MARK: - Singleton
    
    /// Shared instance for the NotaBene service
    public static let shared = NotaBeneSwift()
    
    // Private constructor to enforce singleton pattern
    private init() {}
   
    /// Current widget view controller if active
    private weak var widgetInstance_v1: WidgetViewController?
    private weak var widgetInstance_v2: WidgetViewControllerV2?
    /// Callback for when the widget state changes
    private var onValidStateChangeHandler: ((Bool, Any?) -> Void)?
    
    // MARK: - Public API
    
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
        
        widgetInstance_v1 = widgetVC
        
        // Present the widget view controller
        if let navController = presentingViewController.navigationController {
            print("NotaBene: Presenting with navigation controller")
            navController.pushViewController(widgetVC, animated: true)
        } else {
            print("NotaBene: Presenting modally")
            presentingViewController.present(widgetVC, animated: true)
        }
    }
    
    public func initializeWidget_v2(
        with configuration: NotaBeneConfiguration,
        transaction: TransactionData_NT? = nil,
        presentingViewController: UIViewController,
        onValidStateChange: ((Bool, Any?) -> Void)? = nil
    ) {
        self.onValidStateChangeHandler = onValidStateChange
        
        let widgetVC = WidgetViewControllerV2(configuration: configuration)
        widgetVC.onValidStateChange = { [weak self] isValid, txData in
            self?.onValidStateChangeHandler?(isValid, txData)
        }
        
        if let transactionData = transaction {
            widgetVC.setTransaction(transactionData)
        }
        
        widgetInstance_v2 = widgetVC
        
        // Present the widget view controller
        if let navController = presentingViewController.navigationController {
            print("NotaBene: Presenting with navigation controller")
            navController.pushViewController(widgetVC, animated: true)
        } else {
            print("NotaBene: Presenting modally")
            presentingViewController.present(widgetVC, animated: true)
        }
    }
    
    /// Set or update transaction data
    /// - Parameter transaction: The transaction data to set
    public func setTransaction(_ transaction: TransactionData_NT) {
        widgetInstance_v1?.setTransaction(transaction)
    }
    
    /// Dismiss the widget if it's currently presented
    public func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        widgetInstance_v1?.dismiss(animated: animated, completion: completion)
    }
} 
