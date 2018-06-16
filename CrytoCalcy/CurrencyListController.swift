//
//  CurrencyListController.swift
//  CryptoCalcy
//
//  Created by Vigneshwar Devendran on 15/06/18.
//  Copyright © 2018 Vigneshwar Devendran. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds

class CurrencyListController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var array = [Coins]()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        bannerView.rootViewController = self
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.load(GADRequest())
        tableView.register(UINib(nibName: "CoinCell", bundle: nil), forCellReuseIdentifier: "coinCell")
        loadAllItems()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "coinCell", for: indexPath) as! CoinCell
        cell.coinName.text = array[indexPath.row].name
        cell.coinIcon.image = UIImage(named: array[indexPath.row].imageName!)
        cell.accessoryType = .none
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let defaults = UserDefaults.standard
        defaults.set(array[indexPath.row].name, forKey: "currencyName")
        defaults.set(array[indexPath.row].imageName, forKey: "currencyIcon")
        dismiss(animated: true, completion: nil)
    }
    
    func loadAllItems(){
        let request: NSFetchRequest<Coins> = Coins.fetchRequest()
        do{
            try array = context.fetch(request)
        }
        catch{
            print("Error fetching contents \(error)")
        }
    }
    
    @IBAction func crossPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func segView(_ sender: UISegmentedControl) {
        print("\(sender.selectedSegmentIndex)")
        switch sender.selectedSegmentIndex{
        case 0:
            loadAllItems()
            tableView.reloadData()
        case 1:
            let request: NSFetchRequest<Coins> = Coins.fetchRequest()
            let predicate = NSPredicate(format: "currencyType == 0")
            request.predicate = predicate
            do{
                array = try context.fetch(request)
            }catch{
                print("Error getting data with predicate")
            }
            tableView.reloadData()
        case 2:
            let request: NSFetchRequest<Coins> = Coins.fetchRequest()
            let predicate = NSPredicate(format: "currencyType == 1")
            request.predicate = predicate
            do{
                array = try context.fetch(request)
            }catch{
                print("Error getting data with predicate")
            }
            tableView.reloadData()
        default:
            print("A defautlt value")
        }
    }
    
}
