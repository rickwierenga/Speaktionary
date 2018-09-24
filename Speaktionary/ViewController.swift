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
                // Print the speech that has been recognized so far
                self.wordLabel.text = result.bestTranscription.formattedString
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
    
    
    
    
}

/*
 audioEngine = AVAudioEngine()
 // Start a session
 session = AVAudioSession.sharedInstance()
 do {
 try session.setCategory(AVAudioSession.Category.record, mode: .spokenAudio, options: [])
 }
 catch {
 print(error)
 return
 }
 
 let inputNode = audioEngine.inputNode
 
 // Set up the request
 recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
 recognitionRequest.shouldReportPartialResults = true // should return results before session is finsihed
 //--
 // Check for availability
 guard let recognizer = SFSpeechRecognizer() else {
 return // not available
 }
 if !recognizer.isAvailable {
 return // not available
 }
 
 // Start the recognition task
 recognizer.recognitionTask(with: recognitionRequest) { (result, error) in
 guard let result = result else {
 return // no result
 }
 
 if result.isFinal {
 print(result.bestTranscription.formattedString)
 }
 }
 //--
 
 // Prepare the recognition task
 let recordingFormat = inputNode.outputFormat(forBus: 0)
 
 // Set up and append buffers (memory region)
 audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
 self.recognitionRequest?.append(buffer)}
 
 
 // Start the audio engine
 do {
 audioEngine = AVAudioEngine()
 audioEngine.prepare()
 try audioEngine.start()
 }
 catch {
 print(error)
 return
 }
 */
