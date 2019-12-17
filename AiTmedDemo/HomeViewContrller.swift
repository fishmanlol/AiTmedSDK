//
//  HomeViewContrller.swift
//  Prynote1
//
//  Created by Yi Tong on 11/27/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import UIKit
import AiTmedSDK

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        if let start = storyboard?.instantiateViewController(withIdentifier: "StartViewController") as? StartViewController {
            present(start, animated: true, completion: nil)
        }
    }
    
    @IBAction func logoutTapped(_ sender: UIBarButtonItem) {
//        if let start = storyboard?.instantiateViewController(withIdentifier: "StartViewController") as? StartViewController {
//            present(start, animated: true, completion: nil)
//            AiTmed.logout()
//        }
        
        AiTmed.retrieveNotebooks(args: AiTmedSDK.RetrieveNotebooksArgs()) { (result) in
            switch result {
            case .success(let _):
                print("success")
            case .failure(let error):
                print("failed: \(error.localizedDescription)")
            }
        }
    }
    @IBAction func newNoteTapped(_ sender: UIBarButtonItem) {
        AiTmed.createNoteBook(args: AiTmedSDK.CreateNotebookArgs(title: "TItle", isEncrypt: true)) { (result) in
            switch result {
            case .success(let _):
                print("success")
            case .failure(let error):
                print("failed: \(error.localizedDescription)")
            }

        }

    }
}
