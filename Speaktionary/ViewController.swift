//
//  ViewController.swift
//  Speaktionary
//
//  Created by Rick Wierenga on 23/09/2018.
//  Copyright © 2018 Rick Wierenga. All rights reserved.
//

import UIKit
import Speech
import AVFoundation

class ViewController: UIViewController {
    // MARK: - Private properties
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var waveView: UIView!
    @IBOutlet weak var microphoneButton: MicrophoneButton!
    
    // MARK: - View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // check auth
        switch SFSpeechRecognizer.authorizationStatus() {
        case .authorized:
            self.microphoneButton.isEnabled = true
            
        case .denied:
            self.microphoneButton.isEnabled = false
            showAlert(withMessage: "Please enable microphone access in settings")
            
        case .restricted:
            self.microphoneButton.isEnabled = false
            showAlert(withMessage: "Please enable microphone access in settings")

        case .notDetermined:
            self.microphoneButton.isEnabled = false
            // request auth
            SFSpeechRecognizer.requestAuthorization { [weak self] (authStatus) in
                guard self != nil else { return }
                
                OperationQueue.main.addOperation {
                    switch authStatus {
                    case .authorized:
                        self!.microphoneButton.isEnabled = true
                    case .denied:
                        self!.microphoneButton.isEnabled = false
                        self!.showAlert(withMessage: "Please enable microphone access in settings")
                    case .restricted:
                        self!.microphoneButton.isEnabled = false
                        self!.showAlert(withMessage: "Please enable microphone access in settings")
                    case .notDetermined:
                        self!.microphoneButton.isEnabled = false
                        self!.showAlert(withMessage: "Please enable microphone access in settings")
                    }
                }
            }
        }
    }
    
    // MARK: - Alert Helpers
    func showAlert(withMessage message: String) {
        let ac = UIAlertController(title: "Microphone Error", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(ac, animated: true)
    }
    
    // MARK: - IBActions
    @IBAction func microphoneTouchesBegan(_ sender: MicrophoneButton) {
        // start session
    }
    
    @IBAction func microphoneTouchesEnded(_ sender: MicrophoneButton) {
        // end session
    }
    
    // MARK: - Recording
    
    
    
    
    
    // MARK: - API
    
    
    
    
}
