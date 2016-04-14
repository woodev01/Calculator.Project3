//
//  SplitViewControllerTwoPointOh.swift
//  Calculator.Project3
//
//  Created by Evan on 4/13/16.
//  Copyright © 2016 Evan. All rights reserved.
//

import UIKit

class SplitViewControllerTwoPointOh: UISplitViewController, UISplitViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
    }
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        return true
    }
}
