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
    @IBAction func microphoneTouchesBegan(_ sender: UIButton) {
        startRecording()
    }
    
    @IBAction func microphoneTouchesEnded(_ sender: UIButton) {
        // end session
        recognitionRequest.endAudio()
        session = nil
    }
    
    // MARK: - Recording
    private var audioEngine: AVAudioEngine!
    private var inputNode: AVAudioInputNode!
    private var session: AVAudioSession!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest!
    
    func startRecording() {
        // Start a session and get an AVAudioEngine
        session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSession.Category.record, mode: .spokenAudio, options: [])
        }
        catch {
            print(error)
            return
        }
        audioEngine = AVAudioEngine()
        
        inputNode = audioEngine.inputNode
        
        // create a request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest.shouldReportPartialResults = true

        // start a recognition task
        guard let recognizer = SFSpeechRecognizer() else {
            // A recognizer is not supported for the current locale
            return
        }
        if !recognizer.isAvailable {
            // The recognizer is not available right now
            return
        }
        
        recognizer.recognitionTask(with: recognitionRequest) { (result, error) in
            guard let result = result else {
                // Recognition failed, so check error for details and handle it
                return
            }
            if result.isFinal {
                let word = result.bestTranscription.formattedString.components(separatedBy: " ").first ?? "Error"
                self.wordLabel.text = word
                self.request(word: word)
            }
        }
        
        // set up the audio buffers
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)}
        
        // prepare and start the audio engine
        audioEngine.prepare()
        try! audioEngine.start()
    }
    
    // MARK: - API
    private let KEY = "89c4577f743ced6ed32ce6da1b86da4e"
    private let APP_ID = "d556f7cd"
    private let BASE_URL = "https://od-api.oxforddictionaries.com/api/v1"
    private let language = "en"
    
    private func request(word: String) {
        var request = URLRequest(url: URL(string: "https://od-api.oxforddictionaries.com:443/api/v1/entries/\(language)/\(word.lowercased())")!)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(APP_ID, forHTTPHeaderField: "app_id")
        request.addValue(KEY, forHTTPHeaderField: "app_key")
        
        let session = URLSession.shared
        _ = session.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data {
                print("1", try! JSON(data: data)["results"])
                let v = try! JSON(data: data)["results"].arrayValue[0]["lexicalEntries"].arrayValue[0]["entries"].arrayValue[0]["senses"].arrayValue[0]["definitions"].arrayValue[0].stringValue
                DispatchQueue.main.async {
                    self.resultLabel.text = v
                }
            } else {
                print(error!)
            }
        }).resume()
    }
}

