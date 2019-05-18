//
//  InAppPurchase.swift
//  CryptoCalcy
//
//  Created by Vigneshwar Devendran on 30/07/18.
//  Copyright © 2018 Vigneshwar Devendran. All rights reserved.
//

import Foundation
import StoreKit


class InAppPurchase: NSObject{
    
    private override init() {}
    
    static let shared = InAppPurchase()
    
    let request = SKProductsRequest()
}
