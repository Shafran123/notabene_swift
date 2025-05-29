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
            titleText: "Example Notabene Widget", widgetUrl: "https://api.notabene.dev",
            vaspDID: "did:ethr:0x4c6e5cf8081131c55923c9fdd5496b6d9522c317",
            authToken:"eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NkstUiJ9.eyJpYXQiOjE3NDg0MjQ4NDMsImV4cCI6bnVsbCwidmMiOnsiQGNvbnRleHQiOlsiaHR0cHM6Ly93d3cudzMub3JnLzIwMTgvY3JlZGVudGlhbHMvdjEiLCJodHRwczovL2FwaS5ub3RhYmVuZS5pZC9zY2hlbWFzL3YxIl0sInR5cGUiOlsiVmVyaWZpYWJsZUNyZWRlbnRpYWwiLCJBY2Nlc3NUb2tlbiJdLCJjcmVkZW50aWFsU3ViamVjdCI6eyJub25jZSI6ImNhZDgyMzMyLWVhZWItNDZhNS05YmEyLTQzYjhhYmQ4ODljYSIsImV4cGlyYXRpb25EYXRlIjoxNzQ4NTExMjQzMzc1LCJzY29wZSI6ImN1c3RvbWVyIiwidmFzcF9kaWQiOiJkaWQ6ZXRocjoweDRjNmU1Y2Y4MDgxMTMxYzU1OTIzYzlmZGQ1NDk2YjZkOTUyMmMzMTcifX0sInN1YiI6ImRpZDprZXk6ejZNa3dWdHJrd2p2Q2h6WjRZaDhyVHptSlY2UzhwRjhZdFpMZEF1QzFFamFZd2ljIiwiaXNzIjoiZGlkOmV0aHI6MHg0YzZlNWNmODA4MTEzMWM1NTkyM2M5ZmRkNTQ5NmI2ZDk1MjJjMzE3In0.eGI24H18TUBrNt1jWEDxsN0pbZINXDomE02-vdgLyr1zbtIBSwq74t2RcCEwThUia6kEcDBmOioRL0XHAl_NAwA",
            theme: "dark",
            primaryColor: "green",
            secondaryColor: "",
            logoURL: ""
        )
        
        // Optional: Create transaction data
        let transaction = TransactionData_NT(
            transactionAsset: "USDT",
            beneficiaryAccountNumber: "0x1A6fF6d18606Bee136e841CDFF0bF4414eC66DEA",
            transactionAmount: "10"
        )
        
        //Initialize and present widget
//        NotaBeneSwift.shared.initialize(
//            with: config,
//            transaction: transaction,
//            presentingViewController: self,
//            onValidStateChange: { isValid, txData in
//                print("Transaction valid: \(isValid)")
//                if let txData = txData {
//                    print("Transaction data: \(txData)")
//                }
//            }
//        )
        
        NotaBeneSwift.shared.initializeWidget_v2(
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

