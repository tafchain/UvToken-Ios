//
//  WalletApproveTool.swift
//  Blockchain Wallet
//
//  Created by Panerly on 2021/5/10.
//

import UIKit
import WalletConnect
import PromiseKit
import TrustWalletCore
import UserNotifications
typealias transParamBlock = (NSDictionary, Int64)->()
typealias getPkBlock = (NSString)->()

@objcMembers
class WalletApproveTool: NSObject {

    static let shared = WalletApproveTool()
    private override init() {
    }
    
    var wcString: String!
    var privateKeyStr: String!
    var ethAddressStr: String!
    var transParamBlock: transParamBlock?
    var getPkBlock: getPkBlock?
    
    
    var interactor: WCInteractor?
    let clientMeta = WCPeerMeta(name: "WalletConnect SDK", url: "https://github.com/TrustWallet/wallet-connect-swift")

    let privateKey = PrivateKey(data: Data(hexString: "9f701bffe4fe45f28455b19a1166f15e1e8e746eab09adea0c84890737e6e594")!)!

    var defaultAddresss: String = ""
    var defaultChainId: Int = 1
    var recoverSession: Bool = false
    var notificationGranted: Bool = false
    var chainID:String = "1"
    
    weak var uriField: UITextField?
    weak var addressField: UITextField?
    weak var chainIdField: UITextField?
    weak var connectButton: UIButton!
    weak var approveButton: UIButton!
    
    private var backgroundTaskId: UIBackgroundTaskIdentifier?
    private weak var backgroundTimer: Timer?
    
    func connect(session: WCSession) {
        print("==> session", session)
        let interactor = WCInteractor(session: session, meta: clientMeta, uuid: UIDevice.current.identifierForVendor ?? UUID())

        configure(interactor: interactor)

        interactor.connect().done { [weak self] connected in
            self?.connectionStatusUpdated(connected)
            self?.approveTapped()
            SVProgressHUD.dismiss()
        }.catch { [weak self] error in
            self?.present(error: error)
        }

        self.interactor = interactor
    }

    func configure(interactor: WCInteractor) {
        let accounts = [defaultAddresss]
        let chainId = defaultChainId

        interactor.onError = { [weak self] error in
            self?.present(error: error)
        }

        interactor.onSessionRequest = { [weak self] (id, peerParam) in
//            let peer = peerParam.peerMeta
//            let message = [peer.description, peer.url].joined(separator: "\n")
//            let alert = UIAlertController(title: peer.name, message: message, preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "Reject", style: .destructive, handler: { _ in
//                self?.interactor?.rejectSession().cauterize()
//            }))
//            alert.addAction(UIAlertAction(title: "Approve", style: .default, handler: { _ in
//                self?.interactor?.approveSession(accounts: accounts, chainId: chainId).cauterize()
//            }))
//            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            
            self?.interactor?.approveSession(accounts: accounts, chainId: chainId).cauterize()
            LSStatusBarHUD.showMessage(PTool.getLocalizedString(with: PTool.getLocalizedString(with: "WallectConnect已连接")))
        }

        interactor.onDisconnect = { [weak self] (error) in
            self?.connectionStatusUpdated(false)
            if let error = error {
                print(error)
                print("已断开连接："+error.localizedDescription)
            }
//            SVProgressHUD.showInfo(withStatus: PTool.getLocalizedString(with: "已断开与DApp的连接"))
            SVProgressHUD.dismiss(withDelay: 2.0)
        }

        /*
         UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
         PwdInputView * inputView = [[PwdInputView alloc] initWithFrame:keyWindow.bounds];
         inputView.titleLabel.text = Localized(@"输入钱包密码");
         inputView.inputString = ^(NSString * _Nonnull str) {
             [[PWallet shareInstance] verifyWalletPwdWithWalletID:wallet_id Pwd:str valid:^(BOOL valid) {
                 if (valid) {
                     [self transWithPassword:str];
                 } else {
                     [LSStatusBarHUD showMessageAndImage:Localized(@"密码错误")];
                 }
             }];
         };
         [keyWindow addSubview:inputView];*/
        
        //ETH交易签名
        interactor.eth.onSign = { [weak self] (id, payload) in
            let alert = UIAlertController(title: payload.method, message: payload.message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { _ in
                self?.interactor?.rejectRequest(id: id, message: "User canceled").cauterize()
            }))

            alert.addAction(UIAlertAction(title: "Sign", style: .default, handler: { _ in
                PTool.getCurrentWalletPkString { pkString in
                    self?.signEth(id: id, payload: payload, pkString: pkString as NSString)
                }
            }))
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }

        interactor.eth.onTransaction = { [weak self] (id, event, transaction) in
            let data = try! JSONEncoder().encode(transaction)
            let message = String(data: data, encoding: .utf8)
            let alert = UIAlertController(title: PTool.getLocalizedString(with: "是否发起交易"), message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: PTool.getLocalizedString(with: "取消"), style: .destructive, handler: {[weak self] _ in
                let status = self?.getConnectStatus()
                if status == true{
                    self?.interactor?.rejectRequest(id: id, message: "user reject").cauterize()
                }else{
                    self?.connectAction()
                    self?.interactor?.rejectRequest(id: id, message: "user reject").cauterize()
                }
            }))
            alert.addAction(UIAlertAction(title: PTool.getLocalizedString(with: "继续"), style: .default, handler: {[weak self] _ in
                self!.transParamBlock!(self!.getDictionaryFromJSONString(jsonString: message!), id)
            }))
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }

        interactor.bnb.onSign = { [weak self] (id, order) in
            let message = order.encodedString
            let alert = UIAlertController(title: "bnb_sign", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { [weak self] _ in
                self?.interactor?.rejectRequest(id: id, message: "User canceled").cauterize()
            }))
            alert.addAction(UIAlertAction(title: "Sign", style: .default, handler: { [weak self] _ in
                self?.signBnbOrder(id: id, order: order)
            }))
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: 字符串转字典
    func getDictionaryFromJSONString(jsonString:String) ->NSDictionary{
     
        let jsonData:Data = jsonString.data(using: .utf8)!
     
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return dict as! NSDictionary
        }
        return NSDictionary()
    }

    func approve(accounts: [String], chainId: Int) {
        interactor?.approveSession(accounts: accounts, chainId: chainId).done {
            print("<== approveSession done")
            self.approveTapped()
        }.catch { [weak self] error in
            self?.present(error: error)
        }
    }
    
    //发送交易成功消息
    func sendTransResult(txid:String, id:Int64) {
        
        interactor?.approveRequest(id: id, result: txid).done{
            print("<== 交易发送成功")
        }.catch{[weak self] error in
            self?.present(error: error)
        }
        
//        interactor?.approveRequest(id: id, result: txid).cauterize()
    }
    func rejectTransRequest(id:Int64, message:String) -> Void {
        interactor?.rejectRequest(id: id, message: message).cauterize()
    }

    func signEth(id: Int64, payload: WCEthereumSignPayload, pkString: NSString) {
        
        let data: Data = {
            switch payload {
            case .sign(let data, _):
                return data
            case .personalSign(let data, _):
                let prefix = "\u{19}Ethereum Signed Message:\n\(data)".data(using: .utf8)!
                return prefix + data
            case .signTypeData(_, let data, _):
                // FIXME
                return data
            }
        }()
        
        let ethPrivateKey = PrivateKey(data: Data(hexString: pkString as String)!)!
        var result = ethPrivateKey.sign(digest: Hash.keccak256(data: data), curve: .secp256k1)!
        result[64] += 27
        let str = "0x" + result.hexString
        self.interactor?.approveRequest(id: id, result: str).cauterize()
    }

    func signBnbOrder(id: Int64, order: WCBinanceOrder) {
        let data = order.encoded
        print("==> signbnbOrder", String(data: data, encoding: .utf8)!)
        let signature = privateKey.sign(digest: Hash.sha256(data: data), curve: .secp256k1)!
        let signed = WCBinanceOrderSignature(
            signature: signature.dropLast().hexString,
            publicKey: privateKey.getPublicKeySecp256k1(compressed: false).data.hexString
        )
        interactor?.approveBnbOrder(id: id, signed: signed).done({ confirm in
            print("<== approveBnbOrder", confirm)
        }).catch { [weak self] error in
            self?.present(error: error)
        }
    }

    func connectionStatusUpdated(_ connected: Bool) {
//        self.approveButton.isEnabled = connected
//        self.connectButton.setTitle(!connected ? "Connect" : "Kill Session", for: .normal)
        if connected {
            
//            let view = (UIApplication.shared.keyWindow?.rootViewController?.view)!
//
//            PJToastView.show(in: view, text: "已授权", duration: 1.5, autoHide: true)
        }
    }

    func present(error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }

    @IBAction func connectTapped() {
        
//        let privateKey = PrivateKey(data: Data(hexString: privateKeyStr)!)!
//
        defaultAddresss = self.ethAddressStr
        addressField?.text = defaultAddresss
        chainIdField?.text = "1"
        chainIdField?.textAlignment = .center
        uriField?.text = wcString
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            print("<== notification permission: \(granted)")
            if let error = error {
                print(error)
            }
            self.notificationGranted = granted
        }
        
        guard let string = wcString, let session = WCSession.from(string: string) else {
            print("invalid uri: \(String(describing: wcString))")
            SVProgressHUD.dismiss()
            return
        }
        if let i = interactor, i.state == .connected {
            i.killSession().done {  [weak self] in
//                self?.approveButton.isEnabled = false
//                self?.connectButton.setTitle("Connect", for: .normal)
            }.cauterize()
        } else {
            connect(session: session)
        }
    }
    
    func disConnectAction(){
        if let i = interactor, i.state == .connected {
            i.killSession().done {  [weak self] in
//                SVProgressHUD.showInfo(withStatus: "已断开连接")
                SVProgressHUD.dismiss(withDelay: 2)
            }.cauterize()
        }
    }
    func connectAction(){
        guard let string = wcString, let session = WCSession.from(string: string) else {
            print("invalid uri: \(String(describing: wcString))")
            return
        }
        connect(session: session)
    }
    
    func getConnectStatus() -> (Bool){
        
        if let i = interactor, i.state == .connected {
            return true
        }
        return false
    }

    @IBAction func approveTapped() {
        
        
        guard let address = addressField?.text,
            let chainIdString = chainIdField?.text else {
            print("empty address or chainId")
            return
        }
        guard let chainId = Int(chainIdString) else {
            print("invalid chainId")
            return
        }
        guard EthereumAddress.isValidString(string: address) || CosmosAddress.isValidString(string: address) else {
            print("invalid eth or bnb address")
            return
        }
        approve(accounts: [address], chainId: chainId)
    }
}

extension WalletApproveTool {
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("<== applicationDidEnterBackground")

        if interactor?.state != .connected {
            return
        }

        if notificationGranted {
            pauseInteractor()
        } else {
            startBackgroundTask(application)
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        print("==> applicationWillEnterForeground")
        if let id = backgroundTaskId {
            application.endBackgroundTask(id)
        }
        backgroundTimer?.invalidate()

        if recoverSession {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                self.interactor?.resume()
            }
        }
    }

    func startBackgroundTask(_ application: UIApplication) {
        backgroundTaskId = application.beginBackgroundTask(withName: "WalletConnect", expirationHandler: {
            self.backgroundTimer?.invalidate()
            print("<== background task expired")
        })

        var alerted = false
        backgroundTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            print("<== background time remainning: ", application.backgroundTimeRemaining)
            if application.backgroundTimeRemaining < 15 {
                self.pauseInteractor()
            } else if application.backgroundTimeRemaining < 120 && !alerted {
                let notification = self.createWarningNotification()
                UNUserNotificationCenter.current().add(notification, withCompletionHandler: { error in
                    alerted = true
                    if let error = error {
                        print("post error \(error.localizedDescription)")
                    }
                })
            }
        }
    }

    func pauseInteractor() {
        recoverSession = true
        interactor?.pause()
    }

    func createWarningNotification() -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = "WC session will be interrupted"
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        return UNNotificationRequest(identifier: "session.warning", content: content, trigger: trigger)
    }
}
