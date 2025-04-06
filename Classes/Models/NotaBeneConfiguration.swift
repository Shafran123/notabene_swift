import Foundation

/// Configuration model for NotaBeneSwift
public struct NotaBeneConfiguration {
    /// The URL for the Notabene widget
    public let widgetUrl: String
    
    /// The VASP DID for the originator
    public let vaspDID: String
    
    /// Authentication token for the service
    public let authToken: String
    
    /// Transaction type allowed for this session
    public let transactionTypeAllowed: TransactionType
    
    /// Non-custodial declaration type
    public let nonCustodialDeclarationType: DeclarationType
    
    /// Customizable dictionary for localizations
    public let dictionary: [String: String]?
    
    /// Initializer with required parameters and optional configurations
    public init(
        widgetUrl: String,
        vaspDID: String,
        authToken: String,
        transactionTypeAllowed: TransactionType = .all,
        nonCustodialDeclarationType: DeclarationType = .declaration,
        dictionary: [String: String]? = nil
    ) {
        self.widgetUrl = widgetUrl
        self.vaspDID = vaspDID
        self.authToken = authToken
        self.transactionTypeAllowed = transactionTypeAllowed
        self.nonCustodialDeclarationType = nonCustodialDeclarationType
        self.dictionary = dictionary
    }
}

/// Transaction type options
public enum TransactionType: String {
    case all = "ALL"
    case selfTransactionOnly = "SELF_TRANSACTION_ONLY"
    case vaspToVaspOnly = "VASP_2_VASP_ONLY"
}

/// Declaration type options
public enum DeclarationType: String {
    case signature = "SIGNATURE"
    case declaration = "DECLARATION"
} 