//
//  ViewController.swift
//  PubNubSample
//
//  Created by QBurst on 11/07/17.
//  Copyright © 2017 QBurst. All rights reserved.
//

import UIKit
import PubNub

fileprivate let publishKey = "pub-c-372c94c6-81d6-4288-823d-6f48b5cd2fdd"
fileprivate let subscribeKey = "sub-c-8207de66-bd94-11e7-a84a-1e64a053e7fc"

extension Date {
    
    static var formatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss.SSSSz"
        return dateFormatter
    } ()
    
    var stringFormat: String {
        return Date.formatter.string(from: self)
    }
    
}

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var label: UILabel!
    var client : PubNub?
    let publishQueue = DispatchQueue(label: "Publish Queue", qos: .userInitiated, attributes: [.concurrent])
    let callbackQueue = DispatchQueue(label: "PubNubCallbackQueue", qos: .userInitiated, attributes: [.concurrent])
    
    
    
    @IBAction func publish(_ sender: Any) {
        // We NEED to get the text field contents in the main thread or we violate UIKit API
        let publishStep0 = Date()
        DispatchQueue.main.async {
            let publishStep1 = Date()
            let publishText = self.textField.text ?? "default"
            self.publishQueue.async {
                let publishStep2 = Date()
                self.client?.publish(publishText, toChannel: "my_channel1",
                                     compressed: false, withCompletion: { (status) in
                                        let publishStep3 = Date()
                                        print("****** \(#function) publish steps ******")
                                        print("Step 1: \(#function) => Tap Button: \(publishStep0.stringFormat)")
                                        print("Step 1: \(#function) => Get Text from TextField \(publishStep1.stringFormat)")
                                        print("Step 2: \(#function) => Initiate Publish \(publishStep2.stringFormat)")
                                        print("Step 3: \(#function) => Receive Publish Callback \(publishStep3.stringFormat)")
                                        print("****************************************")
                                        if !status.isError {
                                        }
                                        else{
                                            
                                        }
                })
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let config = PNConfiguration(publishKey: publishKey, subscribeKey: subscribeKey)
        config.stripMobilePayload = false
        self.client = PubNub.clientWithConfiguration(config, callbackQueue: callbackQueue)
        self.client?.logger.enabled = true
        self.client?.logger.setLogLevel(PNLogLevel.PNVerboseLogLevel.rawValue)
        // optionally add the app delegate as a listener, or anything else
        // View Controllers should get the client from the App Delegate
        // and add themselves as listeners if they are interested in
        // stream events (subscribe, presence, status)
        self.client?.addListener(self)
        self.client?.subscribeToChannels(["my_channel1"], withPresence: false)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// MARK: - PNObjectEventListener
extension ViewController: PNObjectEventListener {
    
    func client(_ client: PubNub, didReceive status: PNStatus) {
        
        print("Status \(status.stringifiedCategory()) at time: \(Date().stringFormat)")
    }
    
    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        
        DispatchQueue.main.async {
            print("$$$$$$$$$$$$$$$$ Message received $$$$$$$$$$$$$$$$")
            print("message: \(message.debugDescription)")
            print("time: \(Date().stringFormat)")
            print("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$")
//            self.label.text = self.label.text?.appending(",\(message.data.message!) ") // this is bad because there might not initially be text, what is the behavior of appending when the label has no text?
            let currentText = self.label.text ?? ""
            let appendingText = message.data.message ?? "No text in message"
            self.label.text = currentText.appending(",\(appendingText)")
            self.label.setNeedsLayout() // don't forget to tell the view engine to update the label
        }
        
    }
    
    func client(_ client: PubNub, didReceivePresenceEvent event: PNPresenceEventResult) {
        // This most likely won't be used here, but in any relevant view controllers
    }
}

