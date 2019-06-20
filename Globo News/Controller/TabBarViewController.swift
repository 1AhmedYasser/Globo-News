//
//  TabBarViewController.swift
//  Globo News
//
//  Created by Ahmed yasser on 6/15/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import UIKit
import SwipeableTabBarController

// A custom tab bar controller that conforms to Swipeable tab bar controller to enable page swiping
class TabBarViewController: SwipeableTabBarController{
    
    // MARK: View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up swipe animation
        swipeAnimatedTransitioning?.animationType = SwipeAnimationType.push
        
        // Set up tab animation
        tapAnimatedTransitioning?.animationType = SwipeAnimationType.push
    }
}
