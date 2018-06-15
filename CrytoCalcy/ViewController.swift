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
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currencyText: UITextField!
    @IBOutlet weak var currencyButton: UIButton!
    @IBOutlet weak var currencyImage: UIImageView!
    //var array = [Coins]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var nameArray = [String]()
    var iconArray = [String]()
    var priceArray = [Double]()
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    var calculatedPriceArray = [Double]()
    var defaultCurrencyValue = [DefaultPrice]()
    var statusMessage = "Connecting..."
    var currencyTitle = ""
    var currencyIcon = ""
    var currencyInfo = [SelectedCurrency]()
    override func viewWillAppear(_ animated: Bool) {
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        tableView.delegate = self
        tableView.dataSource = self
        //currencyText.text = "0"
        nameArray.removeAll()
        iconArray.removeAll()
        priceArray.removeAll()
        calculatedPriceArray.removeAll()
        tableView.keyboardDismissMode = .interactive
        tableView.register(UINib(nibName: "WatchList", bundle: nil), forCellReuseIdentifier: "watchCell")
        
        
    
        if UserDefaults.standard.string(forKey: "wasLaunchedFromSource") != nil{
            print("Has been launched before")
            
            print(UserDefaults.standard.string(forKey: "currencyName")!)
            print(UserDefaults.standard.string(forKey: "currencyIcon")!)
            currencyTitle = UserDefaults.standard.string(forKey: "currencyName")!
            currencyIcon = UserDefaults.standard.string(forKey: "currencyIcon")!
            let requestOne: NSFetchRequest<SelectedCurrency> = SelectedCurrency.fetchRequest()
            do{
                try currencyInfo = context.fetch(requestOne)
            }catch{
                print("Error getting currency type: \(currencyInfo)")
            }
            currencyButton.setTitle(currencyTitle, for: .normal)
            currencyImage.image = UIImage(named: (currencyIcon))
            
            
            let request: NSFetchRequest<DefaultPrice> = DefaultPrice.fetchRequest()
            do{
                try defaultCurrencyValue = context.fetch(request)
                
            }catch{
                print("Error fetching currency value \(error)")
            }
            currencyText.text = defaultCurrencyValue.first?.value
            
            
        }
        else{
            print("App not launched")

            setSourceBase()
            
            let request: NSFetchRequest<DefaultPrice> = DefaultPrice.fetchRequest()
            do{
                try defaultCurrencyValue = context.fetch(request)

            }catch{
                print("Error fetching currency value \(error)")
            }
            
            
            
            currencyText.text = defaultCurrencyValue.first?.value

            let defaults = UserDefaults.standard
            defaults.set(true, forKey: "wasLaunchedFromSource")
            defaults.set("US Dollars", forKey: "currencyName")
            defaults.set("USD", forKey: "currencyIcon")
            
            
            currencyTitle = UserDefaults.standard.string(forKey: "currencyName")!
            currencyIcon = UserDefaults.standard.string(forKey: "currencyIcon")!
            currencyButton.setTitle(currencyTitle, for: .normal)
            currencyImage.image = UIImage(named: (currencyIcon))
        }
        
        loadSelectedSources()
        loadPrices()
    }
    //MARK: - Table View Functions
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "watchCell", for: indexPath) as! WatchList
        cell.coinName.text = nameArray[indexPath.row]
        cell.coinIcon.image = UIImage(named: iconArray[indexPath.row])
        if calculatedPriceArray == []{
            cell.priceLabel.text = statusMessage
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

        let value = DefaultPrice(context: context)
        value.value = "1000"
        
        let currency = SelectedCurrency(context: context)
        currency.currencyName?.removeAll()
        currency.currencyName?.removeAll()
        currency.currencyName = "US Dollars"
        currency.currencyIcon = "USD"
        
        
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
        ltc.selected = false
        
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
        
        let nxt = Coins(context: context)
        nxt.name = "NXT [NXT]"
        nxt.imageName = "NXT"
        nxt.selected = false
        
        let drgn = Coins(context: context)
        drgn.name = "DragonChain [DRGN]"
        drgn.imageName = "DRGN"
        drgn.selected = false
        
        let knc = Coins(context: context)
        knc.name = "Kyber Network [KNC]"
        knc.imageName = "KNC"
        knc.selected = false
        
        let mona = Coins(context: context)
        mona.name = "MonaCoin [MONA]"
        mona.imageName = "MONA"
        mona.selected = false
        
        let pivx = Coins(context: context)
        pivx.name = "PIVX [PIVX]"
        pivx.imageName = "PIVX"
        pivx.selected = false
        
        let ardr = Coins(context: context)
        ardr.name = "Ardor [ARDR]"
        ardr.imageName = "ARDR"
        ardr.selected = false
        
        let ark = Coins(context: context)
        ark.name = "Ark [ARK]"
        ark.imageName = "ARK"
        ark.selected = false
        
        let kmd = Coins(context: context)
        kmd.name = "Komodo [KMD]"
        kmd.imageName = "KMD"
        kmd.selected = false
        
        let bat = Coins(context: context)
        bat.name = "BAT [BAT]"
        bat.imageName = "BAT"
        bat.selected = false
        
        let dgd = Coins(context: context)
        dgd.name = "DigixDAO [DGD]"
        dgd.imageName = "DGD"
        dgd.selected = false
        
        let hsr = Coins(context: context)
        hsr.name = "Hshare [HSR]"
        hsr.imageName = "HSR"
        hsr.selected = false
        
        let wtc = Coins(context: context)
        wtc.name = "Walton Chain [WTC]"
        wtc.imageName = "WTC"
        wtc.selected = false
        
        let iost = Coins(context: context)
        iost.name = "IOSToken [IOST]"
        iost.imageName = "IOST"
        iost.selected = false
        
        let snt = Coins(context: context)
        snt.name = "Status [SNT]"
        snt.imageName = "SNT"
        snt.selected = false
        
        let dgb = Coins(context: context)
        dgb.name = "DigiByte [DGB]"
        dgb.imageName = "DGB"
        dgd.selected = false
        
        let gnt = Coins(context: context)
        gnt.name = "Golem [GNT]"
        gnt.imageName = "GNT"
        gnt.selected = false
        
        let btcp = Coins(context: context)
        btcp.name = "Bitcoin Private [BTCP]"
        btcp.imageName = "BTCP"
        btcp.selected = false
        
        let doge = Coins(context: context)
        doge.name = "Dogecoin [DOGE]"
        doge.imageName = "DOGE"
        doge.selected = false
        
        let rhoc = Coins(context: context)
        rhoc.name = "RChain [RHOC]"
        rhoc.imageName = "RHOC"
        rhoc.selected = false
        
        let rep = Coins(context: context)
        rep.name = "Augur [REP]"
        rep.imageName = "REP"
        rep.selected = false
        
        let bcd = Coins(context: context)
        bcd.name = "Bitcoin Diamond [BCD]"
        bcd.imageName = "BCD"
        bcd.selected = false
        
        let waves = Coins(context: context)
        waves.name = "Waves [WAVES]"
        waves.imageName = "WAVES"
        waves.selected = false
        
        let wan = Coins(context: context)
        wan.name = "Wanchain [WAN]"
        wan.imageName = "WAN"
        wan.selected = false
        
        let mkr = Coins(context: context)
        mkr.name = "Maker [MKR]"
        mkr.imageName = "MKR"
        mkr.selected = false
        
        let ppt = Coins(context: context)
        ppt.name = "Populous [PPT]"
        ppt.imageName = "PPT"
        ppt.selected = false
        
        let strat = Coins(context: context)
        strat.name = "Stratis [STRAT]"
        strat.imageName = "STRAT"
        strat.selected = false
        
        let bts = Coins(context: context)
        bts.name = "BitShares [BTS]"
        bts.imageName = "BTS"
        bts.selected = false
        
        let zrx = Coins(context: context)
        zrx.name = "OX [ZRX]"
        zrx.imageName = "ZRX"
        zrx.selected = false
        
        let btm = Coins(context: context)
        btm.name = "Bytom [BTM]"
        btm.imageName = "BTM"
        btm.selected = false
        
        let sc = Coins(context: context)
        sc.name = "Siacoin [SC]"
        sc.imageName = "SC"
        sc.selected = false
        
        let xvg = Coins(context: context)
        xvg.name = "Verge [XVG]"
        xvg.imageName = "XVG"
        xvg.selected = false
        
        let ae = Coins(context: context)
        ae.name = "Aeternity [AE]"
        ae.imageName = "AE"
        ae.selected = false
        
        let dcr = Coins(context: context)
        dcr.name = "Decred [DCR]"
        dcr.imageName = "DCR"
        dcr.selected = false
        
        let ont = Coins(context: context)
        ont.name = "Ontology [ONT]"
        ont.imageName = "ONT"
        ont.selected = false
        
        let steem = Coins(context: context)
        steem.name = "Steem [STEEM]"
        steem.imageName = "STEEM"
        steem.selected = false
        
        let btg = Coins(context: context)
        btg.name = "Bitcoin Gold [BTG]"
        btg.imageName = "BTG"
        btg.selected = false
        
        let zil = Coins(context: context)
        zil.name = "Zilliqa [ZIL]"
        zil.imageName = "ZIL"
        zil.selected = false
        
        let icx = Coins(context: context)
        icx.name = "ICON [ICX]"
        icx.imageName = "ICX"
        icx.selected = false
        
        let zec = Coins(context: context)
        zec.name = "Zcash [ZEC]"
        zec.imageName = "ZEC"
        zec.selected = true
        
        let qtum = Coins(context: context)
        qtum.name = "QTUM [QTUM]"
        qtum.imageName = "QTUM"
        qtum.selected = false
        
        let bcn = Coins(context: context)
        bcn.name = "Bytecoin [BCN]"
        bcn.imageName = "BCN"
        bcn.selected = false
        
        let bnb = Coins(context: context)
        bnb.name = "Binance Coin [BNB]"
        bnb.imageName = "BNB"
        bnb.selected = false
        
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
        var globe: String = "https://min-api.cryptocompare.com/data/price?fsym=\(currencyIcon)&tsyms="
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
//                    let alert = UIAlertController(title: "Oops!", message: "No Internet Connection", preferredStyle: .alert)
//                    let action = UIAlertAction(title: "Settings", style: .default) { (action) in
//                        UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!)
//                    }
//                    alert.addAction(action)
//                    self.present(alert, animated: true, completion: nil)
                    statusMessage = "No Internet"
                }
       
    }
    
    @IBAction func textFieldAction(_ sender: Any) {
        loadArrays()
    }
    func loadArrays(){
        print("Something is happening")
        calculatedPriceArray.removeAll()
        var it = 0
//        let saveDefault = DefaultPrice(context: context)
//        saveDefault.value = ""
//        saveDefault.value = currencyText.text
        do{
            try context.save()
        }catch{
            print("Error saving default value \(error)")
        }
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
    
    @IBAction func clearButton(_ sender: Any) {
        currencyText.text = "0"
        loadPrices()
    }
    
    @IBAction func currencyButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "selectCurrency", sender: self)
    }
    
    

}

