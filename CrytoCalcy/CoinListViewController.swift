//
//  CoinListViewController.swift
//  CrytoCalcy
//
//  Created by Vigneshwar Devendran on 10/06/18.
//  Copyright © 2018 Vigneshwar Devendran. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds

class CoinListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var array = [Coins]()
   // var filteredData = [Coins]()
    @IBOutlet weak var bannerView: GADBannerView!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //var isSearching = false
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        bannerView.rootViewController = self
        bannerView.adUnitID = "ca-app-pub-6592950954286804/2301485709"
        //bannerView.load(GADRequest())
        tableView.keyboardDismissMode = .interactive
        tableView.register(UINib(nibName: "CoinCell", bundle: nil), forCellReuseIdentifier: "coinCell")
        loadAllItems()
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "coinCell", for: indexPath) as! CoinCell
//        if isSearching{
//            cell.coinIcon.image = UIImage(named: filteredData[indexPath.row].imageName!)
//            cell.coinName.text = filteredData[indexPath.row].name
//            cell.accessoryType = filteredData[indexPath.row].selected == true ? .checkmark : .none
//            return cell
        //        }else{}
            cell.coinIcon.image = UIImage(named: array[indexPath.row].imageName!)
            cell.coinName.text = array[indexPath.row].name
            cell.accessoryType = array[indexPath.row].selected == true ? .checkmark : .none
            return cell
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if isSearching{
//            return filteredData.count
//        }
        return array.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        array[indexPath.row].selected = !array[indexPath.row].selected
        do{
            try context.save()
        }catch{
            print("Error saving data")
        }
        tableView.reloadData()
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
    
    @IBAction func close(_ sender: Any) {
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











