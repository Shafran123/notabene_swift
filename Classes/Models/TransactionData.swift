import Foundation

/// Transaction data model
public struct TransactionData_NT {
    /// Asset type (e.g. "eth", "btc")
    public let transactionAsset: String
    
    /// Beneficiary account identifier
    public let beneficiaryAccountNumber: String
    
    /// Transaction amount as string (to maintain precision)
    public let transactionAmount: String
    
    public init(
        transactionAsset: String,
        beneficiaryAccountNumber: String,
        transactionAmount: String
    ) {
        self.transactionAsset = transactionAsset
        self.beneficiaryAccountNumber = beneficiaryAccountNumber
        self.transactionAmount = transactionAmount
    }
} 
