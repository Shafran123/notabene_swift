import Foundation

/// Configuration model for NotaBeneSwift
public struct NotaBeneConfiguration {
    public let titleText: String
    
    /// The URL for the Notabene widget
    public let widgetUrl: String
    
    /// The VASP DID for the originator
    public let vaspDID: String
    
    /// Authentication token for the service
    public let authToken: String
    
    /// Transaction type allowed for this session
    public let transactionTypeAllowed: TransactionType_NT
    
    /// Non-custodial declaration type
    public let nonCustodialDeclarationType: DeclarationType
    
    /// Customizable dictionary for localizations
    public let dictionary: [String: String]?
    
    public let theme: String
    
    public let primaryColor: String
    
    public let secondaryColor: String
    
    public let logoURL: String
    
    /// Initializer with required parameters and optional configurations
    public init(
        titleText: String,
        widgetUrl: String,
        vaspDID: String,
        authToken: String,
        transactionTypeAllowed: TransactionType_NT = .all,
        nonCustodialDeclarationType: DeclarationType = .declaration,
        dictionary: [String: String]? = nil,
        theme: String,
        primaryColor: String,
        secondaryColor: String,
        logoURL: String
    ) {
        self.titleText = titleText
        self.widgetUrl = widgetUrl
        self.vaspDID = vaspDID
        self.authToken = authToken
        self.transactionTypeAllowed = transactionTypeAllowed
        self.nonCustodialDeclarationType = nonCustodialDeclarationType
        self.dictionary = dictionary
        self.theme = theme
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.logoURL = logoURL
    }
}

/// Transaction type options
public enum TransactionType_NT: String {
    case all = "ALL"
    case selfTransactionOnly = "SELF_TRANSACTION_ONLY"
    case vaspToVaspOnly = "VASP_2_VASP_ONLY"
}

/// Declaration type options
public enum DeclarationType: String {
    case signature = "SIGNATURE"
    case declaration = "DECLARATION"
} 
