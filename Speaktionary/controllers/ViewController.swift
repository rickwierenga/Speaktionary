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
import CoreData

class ViewController: UIViewController {
    // MARK: - Private properties
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var waveView: UIView!
    @IBOutlet weak var microphoneButton: MicrophoneButton!

    private var initialWaveViewHeight: CGFloat!

    private lazy var managedContext: NSManagedObjectContext = {
        // swiftlint:disable force_cast
        return (UIApplication.shared.delegate as! AppDelegate).managedContext
    }()

    public var word: STWord?

    // MARK: - View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // set to reference later
        initialWaveViewHeight = waveView.frame.height

        // check authorization
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
            requestAuthentication()
        @unknown default:
            fatalError()
        }

        // load word if it was added by the saved table view controller.
        if let word = word {
            wordLabel.text = word.entry!
            resultLabel.text = word.definition ?? "no definition saved"
        }
    }

    // MARK: - Alert Helpers
    func showAlert(withMessage message: String) {
        let alertController = UIAlertController(title: "Microphone Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true)
    }

    // MARK: - IBActions
    @IBAction func microphoneTouchesBegan(_ sender: UIButton) {
        startRecording()
    }

    @IBAction func microphoneTouchesEnded(_ sender: UIButton) {
        // end session
        recognitionRequest.endAudio()
        audioEngine.stop()
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
        } catch {
            print(error)
            return
        }
        audioEngine = AVAudioEngine()

        inputNode = audioEngine.inputNode

        // create a request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest.shouldReportPartialResults = true

        // update classifications
        updateClassification(with: recognitionRequest)

        // set up the audio buffers
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0,
                             bufferSize: 1024,
                             format: recordingFormat) { (buffer: AVAudioPCMBuffer, _) in
            // append buffer to recogniztion request. The request knows what memory to use
            self.recognitionRequest?.append(buffer)

            // test if channel data is present.
            guard let channelData = buffer.floatChannelData else {
                    return
            }

            // get channel data
            let channelDataValue = channelData.pointee
            let channelDataValueArray = stride(from: 0,
                                               to: Int(buffer.frameLength),
                                               by: buffer.stride).map { channelDataValue[$0] }

            // calculate value
            let average = channelDataValueArray.map({ $0 * $0 }).reduce(0, +) / Float(buffer.frameLength)
            let rms = sqrt(average)
            let avgPower = 20 * log10(rms)
            let meterLevel = self.scaledPower(power: avgPower)

            // set the wave views height
            let newHeight = (CGFloat(meterLevel) + 1)  * self.initialWaveViewHeight
            DispatchQueue.main.async {
                self.waveView.frame = CGRect(
                    x: self.waveView.frame.minX,
                    y: self.view.frame.maxY - newHeight,
                    width: self.waveView.frame.width,
                    height: newHeight
                )
                self.microphoneButton.updateConstraints()
            }
        }

        // prepare and start the audio engine
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {}
    }

    private func updateClassification(with recognitionRequest: SFSpeechAudioBufferRecognitionRequest) {
        // start a recognition task
        guard let recognizer = SFSpeechRecognizer() else {
            // A recognizer is not supported for the current locale
            return
        }
        if !recognizer.isAvailable {
            // The recognizer is not available right now
            return
        }

        // Update the UI
        // swiftlint:disable todo
        // TODO: This might an activity controller.
        resultLabel.text = "Loading..."

        recognizer.recognitionTask(with: recognitionRequest) { (result, error) in
            guard let result = result else {
                // Recognition failed, so check error for details and handle it
                self.wordLabel.text = "Please Retry"
                self.resultLabel.text = error?.localizedDescription
                return
            }

            if result.isFinal, let entry = result.bestTranscription.formattedString.components(separatedBy: " ").first {
                // create a word object
                let word = STWord(entry: entry, entity: STWord.entity(), insertInto: self.managedContext)

                // tell STWord to fetch the defition. Once ready, set the definition to the resultLabel
                self.wordLabel.text = word.entry
                word.fetchMeaning({ definition in
                    self.resultLabel.text = word.definition
                    word.definition = definition
                })

                // save to core data
                do {
                    try self.managedContext.save()
                } catch {
                    print("error saving to core data", error)
                }
            }
        }
    }

    fileprivate func scaledPower(power: Float) -> Float {
        guard power.isFinite else { return 0.0 }

        // Make sure the power has a reasonable value.
        if power < -80.0 {
            return 0.0
        } else if power >= 1.0 {
            return 1.0
        } else {
            // Perform the scaling.
            return (80.0 - abs(power)) / 80.0
        }
    }

    // MARK: - Privacy
    func requestAuthentication() {
        SFSpeechRecognizer.requestAuthorization { [unowned self] (authStatus) in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.microphoneButton.isEnabled = true
                case .denied:
                    self.microphoneButton.isEnabled = false
                    self.showAlert(withMessage: "Please enable microphone access in settings")
                case .restricted:
                    self.microphoneButton.isEnabled = false
                    self.showAlert(withMessage: "Please enable microphone access in settings")
                case .notDetermined:
                    self.microphoneButton.isEnabled = false
                    self.showAlert(withMessage: "Please enable microphone access in settings")
                @unknown default:
                    fatalError()
                }
            }
        }
    }
}
