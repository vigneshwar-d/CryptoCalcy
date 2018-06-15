//
//  CurrencyListController.swift
//  CryptoCalcy
//
//  Created by Vigneshwar Devendran on 15/06/18.
//  Copyright © 2018 Vigneshwar Devendran. All rights reserved.
//

import UIKit

class CurrencyListController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    let currencyName = ["US Dollars", "British Pounds", "Euro","Canadian Dollars","Australian Dollars","Russian Rubels","Chinese Yuan","Japanese Yen"]
    let currencyImages = ["USD","GBP","EUR","CAD","AUD","RUB","CNY","JPY"]
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CoinCell", bundle: nil), forCellReuseIdentifier: "coinCell")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "coinCell", for: indexPath) as! CoinCell
        cell.coinName.text = currencyName[indexPath.row]
        cell.coinIcon.image = UIImage(named: currencyImages[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencyImages.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let defaults = UserDefaults.standard
        defaults.set(currencyName[indexPath.row], forKey: "currencyName")
        defaults.set(currencyImages[indexPath.row], forKey: "currencyIcon")
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func crossPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
