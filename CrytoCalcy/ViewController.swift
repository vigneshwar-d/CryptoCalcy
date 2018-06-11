//
//  ViewController.swift
//  CrytoCalcy
//
//  Created by Vigneshwar Devendran on 10/06/18.
//  Copyright © 2018 Vigneshwar Devendran. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var currrencyIcon: UIImageView!
    @IBOutlet weak var currencyButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currencyText: UITextField!
    //var array = [Coins]()
    var nameArray = [String]()
    var iconArray = [String]()
    var priceArray = [Double]()
    var calculatedPriceArray = [Double]()
    override func viewWillAppear(_ animated: Bool) {
        //super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        currencyText.text = "0"
        //tableView.reloadData()
        nameArray.removeAll()
        iconArray.removeAll()
        priceArray.removeAll()
        calculatedPriceArray.removeAll()
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
//        _ = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(ViewController.loadPrices), userInfo: nil, repeats: true)

        loadPrices()
        //loadArrays()
    }
    //MARK: - Table View Functions
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "watchCell", for: indexPath) as! WatchList
        cell.coinName.text = nameArray[indexPath.row]
        cell.coinIcon.image = UIImage(named: iconArray[indexPath.row])
        if calculatedPriceArray == []{
            cell.priceLabel.text = "Loading..."
        }else{
            cell.priceLabel.text = String(calculatedPriceArray[indexPath.row])
        }
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    @IBAction func addPressed(_ sender: Any) {
        performSegue(withIdentifier: "selectCoins", sender: self)
    }
    
    //MARK: - Source
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
        nem.name = "NEM [XEM]"
        nem.imageName = "XEM"
        nem.selected = false
        
        let iota = Coins(context: context)
        iota.name = "IOTA [MIOTA]"
        iota.imageName = "IOTA"
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
        etc.name = "Ethereum Cash[ETC]"
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
    }
    
    @objc func loadPrices(){
        var globe: String = "https://min-api.cryptocompare.com/data/price?fsym=USD&tsyms="
        for i in 0..<iconArray.count{
            globe = globe + "\(iconArray[i]),"
        }
        print(globe)
        parseURL(url: globe)
    }
    
    func parseURL(url: String){
                if NetworkReachabilityManager()?.isReachable == true{
                    print("Network Available")
                    Alamofire.request(url, method: .get)
                        .responseJSON { response in
                            if response.result.isSuccess {
                                
                                print("Sucess! Got the Coin data")
                                let coinJSON : JSON = JSON(response.result.value!)
                                for i in 0..<self.nameArray.count{
                                    if let coinResult = coinJSON[self.iconArray[i]].double {
                                        self.priceArray.append(coinResult)
                                    }
                                    else{
                                        print("Error parsing json at \(self.iconArray[i])")
                                    }
                                }
                            } else {
                                print("Error: \(String(describing: response.result.error))")
                            }
                            print(self.priceArray)
                            self.loadArrays()
                            self.tableView.reloadData()
                    }
                }
                if NetworkReachabilityManager()?.isReachable == false{
                    print("No Internet")
                    let alert = UIAlertController(title: "Oops!", message: "No Internet Connection", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Settings", style: .default) { (action) in
                        UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!)
                    }
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
       
    }
    
    @IBAction func textFieldAction(_ sender: Any) {
        loadArrays()
    }
    func loadArrays(){
        print("Something is happening")
        calculatedPriceArray.removeAll()
        var it = 0
        for _ in 0..<nameArray.count{
            if currencyText.text != ""{
            let calculatedValue = Double(currencyText.text!)! * Double(priceArray[it])
            calculatedPriceArray.append(calculatedValue)
            it = it + 1
            }else{
                currencyText.text = "0"
                let calculatedValue = Double(currencyText.text!)! * Double(priceArray[it])
                calculatedPriceArray.append(calculatedValue)
                it = it + 1
            }
        }
        print(calculatedPriceArray)
//        priceArray.removeAll()
//        priceArray = calculatedPriceArray
        tableView.reloadData()
    }
    
    @IBAction func refreshButton(_ sender: Any) {
        loadPrices()
    }
    

}

