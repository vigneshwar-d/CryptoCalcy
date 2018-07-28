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
import GoogleMobileAds

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var currrencyIcon: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currencyText: UITextField!
    @IBOutlet weak var currencyButton: UIButton!
    @IBOutlet weak var currencyImage: UIImageView!
    @IBOutlet weak var bannerView: GADBannerView!
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
        //bannerView.delegate = self
        bannerView.rootViewController = self
        bannerView.adUnitID = "ca-app-pub-6592950954286804/2301485709"
        //bannerView.load(GADRequest())
        tableView.keyboardDismissMode = .interactive
        tableView.register(UINib(nibName: "WatchList", bundle: nil), forCellReuseIdentifier: "watchCell")
        
        
    
        if UserDefaults.standard.string(forKey: "wasLaunchedFromSource") != nil{
            print("Has been launched before")
            
            if UserDefaults.standard.string(forKey: "updateWithNewData") == nil{
                print("\nUpdating With Data\n")
                updateWithNewData()
                let defaults = UserDefaults.standard
                defaults.set(true, forKey: "updateWithNewData")
            }else{
                print("\nAlready Updated with new data\n")
            }
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
            updateWithNewData()
            
            let request: NSFetchRequest<DefaultPrice> = DefaultPrice.fetchRequest()
            do{
                try defaultCurrencyValue = context.fetch(request)

            }catch{
                print("Error fetching currency value \(error)")
            }
            
            currencyText.text = defaultCurrencyValue.first?.value

            let defaults = UserDefaults.standard
            defaults.set(true, forKey: "wasLaunchedFromSource")
            defaults.set(true, forKey: "updateWithNewData")
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
    
    //MARK: - Setting All The Sources
    
    func setSourceBase(){
        print("Set Source Base Called")

        let value = DefaultPrice(context: context)
        value.value = "1000"
        
        
        
        //MARK: - Crytos
        let btc = Coins(context: context)
        btc.name = "Bitcoin [BTC]"
        btc.imageName = "BTC"
        btc.selected = true
        btc.currencyType = true
        
        let eth = Coins(context: context)
        eth.name = "Ethereum [ETH]"
        eth.imageName = "ETH"
        eth.selected = true
        eth.currencyType = true
        
        
        let xrp = Coins(context: context)
        xrp.name = "Ripple [XRP]"
        xrp.imageName = "XRP"
        xrp.selected = true
        xrp.currencyType = true
        
        let bch = Coins(context: context)
        bch.name = "Bitcoin Cash [BCH]"
        bch.imageName = "BCH"
        bch.selected = true
        bch.currencyType = true
        
        let ltc = Coins(context: context)
        ltc.name = "Litecoin [LTC]"
        ltc.imageName = "LTC"
        ltc.selected = false
        ltc.currencyType = true
        
        let ada = Coins(context: context)
        ada.name = "Cardano [ADA]"
        ada.imageName = "ADA"
        ada.selected = false
        ada.currencyType = true
        
        let neo = Coins(context: context)
        neo.name = "NEO [NEO]"
        neo.imageName = "NEO"
        neo.selected = false
        neo.currencyType = true
        
        let xlm = Coins(context: context)
        xlm.name = "Stellar [XLM]"
        xlm.imageName = "XLM"
        xlm.selected = false
        xlm.currencyType = true
        
        let eos = Coins(context: context)
        eos.name = "EOS [EOS]"
        eos.imageName = "EOS"
        eos.selected = false
        eos.currencyType = true
        
        let xmr = Coins(context: context)
        xmr.name = "Monero [XMR]"
        xmr.imageName = "XMR"
        xmr.selected = false
        xmr.currencyType = true
        
        let dash = Coins(context: context)
        dash.name = "Dash [DASH]"
        dash.imageName = "DASH"
        dash.selected = false
        dash.currencyType = true
        
        let nem = Coins(context: context)
        nem.name = "NEM [XEM]"
        nem.imageName = "XEM"
        nem.selected = false
        nem.currencyType = true
        
        let iota = Coins(context: context)
        iota.name = "IOTA [MIOTA]"
        iota.imageName = "IOTA"
        iota.selected = false
        iota.currencyType = true
        
        let usdt = Coins(context: context)
        usdt.name = "Tether [USDT]"
        usdt.imageName = "USDT"
        usdt.selected = false
        usdt.currencyType = true
        
        let trx = Coins(context: context)
        trx.name = "Tron [TRX]"
        trx.imageName = "TRX"
        trx.selected = false
        trx.currencyType = true
        
        let etc = Coins(context: context)
        etc.name = "Ethereum Cash[ETC]"
        etc.imageName = "ETC"
        etc.selected = false
        etc.currencyType = true
        
        let ven = Coins(context: context)
        ven.name = "VeChain [VEN]"
        ven.imageName = "VEN"
        ven.selected = false
        ven.currencyType = true
        
        let lsk = Coins(context: context)
        lsk.name = "Lisk [LSK]"
        lsk.imageName = "LSK"
        lsk.selected = false
        lsk.currencyType = true
        
        let nano = Coins(context: context)
        nano.name = "Nano [NANO]"
        nano.imageName = "NANO"
        nano.selected = false
        nano.currencyType = true
        
        let omg = Coins(context: context)
        omg.name = "OmiseOMG [OMG]"
        omg.imageName = "OMG"
        omg.selected = false
        omg.currencyType = true
        
        let nxt = Coins(context: context)
        nxt.name = "NXT [NXT]"
        nxt.imageName = "NXT"
        nxt.selected = false
        nxt.currencyType = true
        
        let drgn = Coins(context: context)
        drgn.name = "DragonChain [DRGN]"
        drgn.imageName = "DRGN"
        drgn.selected = false
        drgn.currencyType = true
        
        let knc = Coins(context: context)
        knc.name = "Kyber Network [KNC]"
        knc.imageName = "KNC"
        knc.selected = false
        knc.currencyType = true
        
        let mona = Coins(context: context)
        mona.name = "MonaCoin [MONA]"
        mona.imageName = "MONA"
        mona.selected = false
        mona.currencyType = true
        
        let pivx = Coins(context: context)
        pivx.name = "PIVX [PIVX]"
        pivx.imageName = "PIVX"
        pivx.selected = false
        pivx.currencyType = true
        
        let ardr = Coins(context: context)
        ardr.name = "Ardor [ARDR]"
        ardr.imageName = "ARDR"
        ardr.selected = false
        ardr.currencyType = true
        
        let ark = Coins(context: context)
        ark.name = "Ark [ARK]"
        ark.imageName = "ARK"
        ark.selected = false
        ark.currencyType = true
        
        let kmd = Coins(context: context)
        kmd.name = "Komodo [KMD]"
        kmd.imageName = "KMD"
        kmd.selected = false
        kmd.currencyType = true
        
        let bat = Coins(context: context)
        bat.name = "BAT [BAT]"
        bat.imageName = "BAT"
        bat.selected = false
        bat.currencyType = true
        
        let dgd = Coins(context: context)
        dgd.name = "DigixDAO [DGD]"
        dgd.imageName = "DGD"
        dgd.selected = false
        dgd.currencyType = true
        
        let hsr = Coins(context: context)
        hsr.name = "Hshare [HSR]"
        hsr.imageName = "HSR"
        hsr.selected = false
        hsr.currencyType = true
        
        let wtc = Coins(context: context)
        wtc.name = "Walton Chain [WTC]"
        wtc.imageName = "WTC"
        wtc.selected = false
        wtc.currencyType = true
        
        let iost = Coins(context: context)
        iost.name = "IOSToken [IOST]"
        iost.imageName = "IOST"
        iost.selected = false
        iost.currencyType = true
        
        let snt = Coins(context: context)
        snt.name = "Status [SNT]"
        snt.imageName = "SNT"
        snt.selected = false
        snt.currencyType = true
        
        let dgb = Coins(context: context)
        dgb.name = "DigiByte [DGB]"
        dgb.imageName = "DGB"
        dgb.selected = false
        dgb.currencyType = true
        
        let gnt = Coins(context: context)
        gnt.name = "Golem [GNT]"
        gnt.imageName = "GNT"
        gnt.selected = false
        gnt.currencyType = true
        
        let btcp = Coins(context: context)
        btcp.name = "Bitcoin Private [BTCP]"
        btcp.imageName = "BTCP"
        btcp.selected = false
        btcp.currencyType = true
        
        let doge = Coins(context: context)
        doge.name = "Dogecoin [DOGE]"
        doge.imageName = "DOGE"
        doge.selected = false
        doge.currencyType = true
        
        let rhoc = Coins(context: context)
        rhoc.name = "RChain [RHOC]"
        rhoc.imageName = "RHOC"
        rhoc.selected = false
        rhoc.currencyType = true
        
        let rep = Coins(context: context)
        rep.name = "Augur [REP]"
        rep.imageName = "REP"
        rep.selected = false
        rep.currencyType = true
        
        let bcd = Coins(context: context)
        bcd.name = "Bitcoin Diamond [BCD]"
        bcd.imageName = "BCD"
        bcd.selected = false
        bcd.currencyType = true
        
        let waves = Coins(context: context)
        waves.name = "Waves [WAVES]"
        waves.imageName = "WAVES"
        waves.selected = false
        waves.currencyType = true
        
        let wan = Coins(context: context)
        wan.name = "Wanchain [WAN]"
        wan.imageName = "WAN"
        wan.selected = false
        wan.currencyType = true
        
        let mkr = Coins(context: context)
        mkr.name = "Maker [MKR]"
        mkr.imageName = "MKR"
        mkr.selected = false
        mkr.currencyType = true
        
        let ppt = Coins(context: context)
        ppt.name = "Populous [PPT]"
        ppt.imageName = "PPT"
        ppt.selected = false
        ppt.currencyType = true
        
        let strat = Coins(context: context)
        strat.name = "Stratis [STRAT]"
        strat.imageName = "STRAT"
        strat.selected = false
        strat.currencyType = true
        
        let bts = Coins(context: context)
        bts.name = "BitShares [BTS]"
        bts.imageName = "BTS"
        bts.selected = false
        bts.currencyType = true
        
        let zrx = Coins(context: context)
        zrx.name = "OX [ZRX]"
        zrx.imageName = "ZRX"
        zrx.selected = false
        zrx.currencyType = true
        
        let btm = Coins(context: context)
        btm.name = "Bytom [BTM]"
        btm.imageName = "BTM"
        btm.selected = false
        btm.currencyType = true
        
        let sc = Coins(context: context)
        sc.name = "Siacoin [SC]"
        sc.imageName = "SC"
        sc.selected = false
        sc.currencyType = true
        
        let xvg = Coins(context: context)
        xvg.name = "Verge [XVG]"
        xvg.imageName = "XVG"
        xvg.selected = false
        xvg.currencyType = true
        
        let ae = Coins(context: context)
        ae.name = "Aeternity [AE]"
        ae.imageName = "AE"
        ae.selected = false
        ae.currencyType = true
        
        let dcr = Coins(context: context)
        dcr.name = "Decred [DCR]"
        dcr.imageName = "DCR"
        dcr.selected = false
        dcr.currencyType = true
        
        let ont = Coins(context: context)
        ont.name = "Ontology [ONT]"
        ont.imageName = "ONT"
        ont.selected = false
        ont.currencyType = true
        
        let steem = Coins(context: context)
        steem.name = "Steem [STEEM]"
        steem.imageName = "STEEM"
        steem.selected = false
        steem.currencyType = true
        
        let btg = Coins(context: context)
        btg.name = "Bitcoin Gold [BTG]"
        btg.imageName = "BTG"
        btg.selected = false
        btg.currencyType = true
        
        let zil = Coins(context: context)
        zil.name = "Zilliqa [ZIL]"
        zil.imageName = "ZIL"
        zil.selected = false
        zil.currencyType = true
        
        let icx = Coins(context: context)
        icx.name = "ICON [ICX]"
        icx.imageName = "ICX"
        icx.selected = false
        icx.currencyType = true
        
        let zec = Coins(context: context)
        zec.name = "Zcash [ZEC]"
        zec.imageName = "ZEC"
        zec.selected = true
        zec.currencyType = true
        
        let qtum = Coins(context: context)
        qtum.name = "QTUM [QTUM]"
        qtum.imageName = "QTUM"
        qtum.selected = false
        qtum.currencyType = true
        
        let bcn = Coins(context: context)
        bcn.name = "Bytecoin [BCN]"
        bcn.imageName = "BCN"
        bcn.selected = false
        bcn.currencyType = true
        
        let bnb = Coins(context: context)
        bnb.name = "Binance Coin [BNB]"
        bnb.imageName = "BNB"
        bnb.selected = false
        bnb.currencyType = true
        
        //MARK: - Currencies
        let usd = Coins(context: context)
        usd.name = "US Dollars [USD]"
        usd.imageName = "USD"
        usd.selected = false
        usd.currencyType = false
        
        let gbp = Coins(context: context)
        gbp.name = "British Pounds [GBP]"
        gbp.imageName = "GBP"
        gbp.selected = false
        gbp.currencyType = false
        
        let cad = Coins(context: context)
        cad.name = "Canadian Dollars [CAD]"
        cad.imageName = "CAD"
        cad.selected = false
        cad.currencyType = false
        
        let eur = Coins(context: context)
        eur.name = "Euros [EUR]"
        eur.imageName = "EUR"
        eur.selected = false
        eur.currencyType = false
        
        let cny = Coins(context: context)
        cny.name = "Chinese Yuan [CNY]"
        cny.imageName = "CNY"
        cny.selected = false
        cny.currencyType = false
        
        let jpy = Coins(context: context)
        jpy.name = "Japanese Yen [JPY]"
        jpy.imageName = "JPY"
        jpy.selected = false
        jpy.currencyType = false
        
        let rub = Coins(context: context)
        rub.name = "Russian Ruble [RUB]"
        rub.imageName = "RUB"
        rub.selected = false
        rub.currencyType = false
        
        let inr = Coins(context: context)
        inr.name = "Indian Rupees [INR]"
        inr.imageName = "INR"
        inr.selected = false
        inr.currencyType = false
        
        let aud = Coins(context: context)
        aud.name = "Australian Dollars [AUD]"
        aud.imageName = "AUD"
        aud.selected = false
        aud.currencyType = false
        
        do{
            try context.save()
        }catch{
            print("Error Saving Data")
        }
    }
    
    
    func updateWithNewData(){
        print("updateWithNewData Called")
        
        let value = DefaultPrice(context: context)
        value.value = "1000"
        
        //MARK: - Cryptos
        
        
        
        //MARK: - Currencies
        
        let brl = Coins(context: context)
        brl.name = "Brazilian Real [BRL]"
        brl.imageName = "BRL"
        brl.selected = false
        brl.currencyType = false
        
        let clp = Coins(context: context)
        clp.name = "Chilean Peso [CLP]"
        clp.imageName = "CLP"
        clp.selected = false
        clp.currencyType = false
        
//        let czk = Coins(context: context)
//        czk.name = "Czech Koruna [CZK]"
//        czk.imageName = "CZK"
//        czk.selected = false
//        czk.currencyType = false
        
//        let dkk = Coins(context: context)
//        dkk.name = "Danish Krone [DKK]"
//        dkk.imageName = "DKK"
//        dkk.selected = false
//        dkk.currencyType = false
        
        let hkd = Coins(context: context)
        hkd.name = "Hong Kong Dollar [HKD]"
        hkd.imageName = "HKD"
        hkd.selected = false
        hkd.currencyType = false
        
//        let huf = Coins(context: context)
//        huf.name = "Hungarian Forint [HUF]"
//        huf.imageName = "HUF"
//        huf.selected = false
//        huf.currencyType = false
        
        let idr = Coins(context: context)
        idr.name = "Indonesian Rupiah [IDR]"
        idr.imageName = "IDR"
        idr.selected = false
        idr.currencyType = false
        
        let myr = Coins(context: context)
        myr.name = "Malaysian Ringgit [MYR]"
        myr.imageName = "MYR"
        myr.selected = false
        myr.currencyType = false
        
        let mxn = Coins(context: context)
        mxn.name = "Mexicon Peso [MXN]"
        mxn.imageName = "MXN"
        mxn.selected = false
        mxn.currencyType = false
        
//        let nzd = Coins(context: context)
//        nzd.name = "New Zealand Dollar [NZD]"
//        nzd.imageName = "NZD"
//        nzd.selected = false
//        nzd.currencyType = false
        
//        let nok = Coins(context: context)
//        nok.name = "Norwegian Krone [NOK]"
//        nok.imageName = "NOK"
//        nok.selected = false
//        nok.currencyType = false
        
        let php = Coins(context: context)
        php.name = "Philippine Peso [PHP]"
        php.imageName = "PHP"
        php.selected = false
        php.currencyType = false
        
        let pln = Coins(context: context)
        pln.name = "Polish Zloty [PLN]"
        pln.imageName = "PLN"
        pln.selected = false
        pln.currencyType = false
        
        let sgd = Coins(context: context)
        sgd.name = "Singapore Dollar [SGD]"
        sgd.imageName = "SGD"
        sgd.selected = false
        sgd.currencyType = false
        
        let zar = Coins(context: context)
        zar.name = "South African Rand [ZAR]"
        zar.imageName = "ZAR"
        zar.selected = false
        zar.currencyType = false
        
//        let sek = Coins(context: context)
//        sek.name = "Swedish Krona [SEK]"
//        sek.imageName = "SEK"
//        sek.selected = false
//        sek.currencyType = false
        
        let chf = Coins(context: context)
        chf.name = "Swiss Franc [CHF]"
        chf.imageName = "CHF"
        chf.selected = false
        chf.currencyType = false
        
//        let twd = Coins(context: context)
//        twd.name = "Taiwan Dollar [TWD]"
//        twd.imageName = "TWD"
//        twd.selected = false
//        twd.currencyType = false
        
        let thb = Coins(context: context)
        thb.name = "Thai Baht [THB]"
        thb.imageName = "THB"
        thb.selected = false
        thb.currencyType = false
        
        let trky = Coins(context: context)
        trky.name = "Turkish Lira [TRY]"
        trky.imageName = "TRY"
        trky.selected = false
        trky.currencyType = false
        
//        let sar = Coins(context: context)
//        sar.name = "Saudi Arabian Riyal [SAR]"
//        sar.imageName = "SAR"
//        sar.selected = false
//        sar.currencyType = false
        
//        let yer = Coins(context: context)
//        yer.name = "Yemen Riyal [YER]"
//        yer.imageName = "YER"
//        yer.selected = false
//        yer.currencyType = false
        
//        let omr = Coins(context: context)
//        omr.name = "Oman Riyal [OMR]"
//        omr.imageName = "OMR"
//        omr.selected = false
//        omr.currencyType = false
        
//        let aed = Coins(context: context)
//        aed.name = "UAE Dirham [AED]"
//        aed.imageName = "AED"
//        aed.selected = false
//        aed.currencyType = false
        
//        let qar = Coins(context: context)
//        qar.name = "Qatar Riyal [QAR]"
//        qar.imageName = "QAR"
//        qar.selected = false
//        qar.currencyType = false
        
//        let kwd = Coins(context: context)
//        kwd.name = "Kuwait Dinar [KWD]"
//        kwd.imageName = "KWD"
//        kwd.selected = false
//        kwd.currencyType = false
        
        do{
            try context.save()
        }catch{
            print("Error Saving Data")
        }
    }
    
    //MARK: - Loading and Parsing
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
                                        self.statusMessage = "Conversion not available"
                                        self.tableView.reloadData()
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
    
    
    //MARK: - IBActions
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

