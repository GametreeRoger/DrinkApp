//
//  LoadingViewController.swift
//  LoadingViewController
//
//  Created by 張又壬 on 2021/9/12.
//

import UIKit

class LoadingViewController: UIViewController {

    @IBOutlet weak var whiteView: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        whiteView.layer.cornerRadius = 25
        loadingIndicator.startAnimating()
    }
}
