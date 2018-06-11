//
//  ViewController.swift
//  CrytoCalcy
//
//  Created by Vigneshwar Devendran on 10/06/18.
//  Copyright © 2018 Vigneshwar Devendran. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var currrencyIcon: UIImageView!
    @IBOutlet weak var currencyButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currencyTextField: UITextField!
    //var array = [Coins]()
    var nameArray = [String]()
    var iconArray = [String]()
    override func viewWillAppear(_ animated: Bool) {
        //super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        //tableView.reloadData()
        nameArray.removeAll()
        iconArray.removeAll()
        tableView.keyboardDismissMode = .interactive
        tableView.register(UINib(nibName: "WatchList", bundle: nil), forCellReuseIdentifier: "watchCell")
        if UserDefaults.standard.string(forKey: "wasLaunchedFromSource") != nil{
            print("Has been launched before")
        }else{
            print("App not launched")
            setSourceBase()
            let defaults = UserDefaults.standard
            defaults.set(true, forKey: "wasLaunchedFromSource")
        }
        loadSelectedSources()
        tableView.reloadData()
    }

    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "watchCell", for: indexPath) as! WatchList
        cell.coinName.text = nameArray[indexPath.row]
        cell.coinIcon.image = UIImage(named: iconArray[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func currencyPressed(_ sender: Any) {
    }
    
    @IBAction func addPressed(_ sender: Any) {
        performSegue(withIdentifier: "selectCoins", sender: self)
    }
    
    func setSourceBase(){
        print("Set Source Base Called")
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let btc = Coins(context: context)
        btc.name = "Bitcoin [BTC]"
        btc.imageName = "BTC"
        btc.selected = true
        
        let eth = Coins(context: context)
        eth.name = "Ethereum [ETH]"
        eth.imageName = "ETH"
        eth.selected = true
        
        let xrp = Coins(context: context)
        xrp.name = "Ripple [XRP]"
        xrp.imageName = "XRP"
        xrp.selected = true
        
        let bch = Coins(context: context)
        bch.name = "Bitcoin Cash [BCH]"
        bch.imageName = "BCH"
        bch.selected = true
        
        let ltc = Coins(context: context)
        ltc.name = "Litecoin [LTC]"
        ltc.imageName = "LTC"
        ltc.selected = true
        
        let ada = Coins(context: context)
        ada.name = "Cardano [ADA]"
        ada.imageName = "ADA"
        ada.selected = false
        
        let neo = Coins(context: context)
        neo.name = "NEO [NEO]"
        neo.imageName = "NEO"
        neo.selected = false
        
        let xlm = Coins(context: context)
        xlm.name = "Stellar [XLM]"
        xlm.imageName = "XLM"
        xlm.selected = false
        
        let eos = Coins(context: context)
        eos.name = "EOS [EOS]"
        eos.imageName = "EOS"
        eos.selected = false
        
        let xmr = Coins(context: context)
        xmr.name = "Monero [XMR]"
        xmr.imageName = "XMR"
        xmr.selected = false
        
        let dash = Coins(context: context)
        dash.name = "Dash [DASH]"
        dash.imageName = "DASH"
        dash.selected = false
        
        let nem = Coins(context: context)
        nem.name = "NEM [NEM]"
        nem.imageName = "NEM"
        nem.selected = false
        
        let iota = Coins(context: context)
        iota.name = "IOTA [MIOTA]"
        iota.imageName = "MIOTA"
        iota.selected = false
        
        let usdt = Coins(context: context)
        usdt.name = "Tether [USDT]"
        usdt.imageName = "USDT"
        usdt.selected = false
        
        let trx = Coins(context: context)
        trx.name = "Tron [TRX]"
        trx.imageName = "TRX"
        trx.selected = false
        
        let etc = Coins(context: context)
        etc.name = "Ethereum [ETC]"
        etc.imageName = "ETC"
        etc.selected = false
        
        let ven = Coins(context: context)
        ven.name = "VeChain [VEN]"
        ven.imageName = "VEN"
        ven.selected = false
        
        let lsk = Coins(context: context)
        lsk.name = "Lisk [LSK]"
        lsk.imageName = "LSK"
        lsk.selected = false
        
        let nano = Coins(context: context)
        nano.name = "Nano [NANO]"
        nano.imageName = "NANO"
        nano.selected = false
        
        let omg = Coins(context: context)
        omg.name = "OmiseOMG [OMG]"
        omg.imageName = "OMG"
        omg.selected = false
        
        do{
            try context.save()
        }catch{
            print("Error Saving Data")
        }
    }
    
    func loadSelectedSources(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        var localArray = [Coins]()
        let request: NSFetchRequest<Coins> = Coins.fetchRequest()
        let predicate = NSPredicate(format: "selected == true")
        request.predicate = predicate
        do{
            localArray = try context.fetch(request)
        }catch{
            print("Error getting data with predicate")
        }
        for i in 0..<localArray.count{
            nameArray.append(localArray[i].name!)
            iconArray.append(localArray[i].imageName!)
            //array.append(localArray[i])
        }
        tableView.reloadData()
    }

}

