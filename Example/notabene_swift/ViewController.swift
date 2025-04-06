//
//  ViewController.swift
//  notabene_swift
//
//  Created by 12469262 on 04/04/2025.
//  Copyright (c) 2025 12469262. All rights reserved.
//

import UIKit
import notabene_swift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .white
        
        let button = UIButton(type: .system)
        button.setTitle("Launch Notabene Widget", for: .normal)
        button.addTarget(self, action: #selector(launchWidget), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 250),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func launchWidget() {
        // Create configuration
        let config = NotaBeneConfiguration(
            widgetUrl: "https://beta-widget.notabene.dev", 
            vaspDID: "YOUR_VASP_DID",
            authToken: "YOUR_AUTH_TOKEN"
        )
        
        // Optional: Create transaction data
        let transaction = TransactionData(
            transactionAsset: "eth",
            beneficiaryAccountNumber: "YOUR_ACCOUNT_NUMBER",
            transactionAmount: "1500000000000000000000"
        )
        
        // Initialize and present widget
        NotaBeneSwift.shared.initialize(
            with: config,
            transaction: transaction,
            presentingViewController: self,
            onValidStateChange: { isValid, txData in
                print("Transaction valid: \(isValid)")
                if let txData = txData {
                    print("Transaction data: \(txData)")
                }
            }
        )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

