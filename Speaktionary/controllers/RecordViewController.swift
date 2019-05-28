//
//  RecordViewController.swift
//  Speaktionary
//
//  Created by Rick Wierenga on 23/09/2018.
//  Copyright © 2018 Rick Wierenga. All rights reserved.
//

import AVFoundation
import CoreData
import Speech
import UIKit

class RecordViewController: UIViewController {
    public var word: STWord? {
        didSet {
            fatalError("implement")
        }
    }

    // MARK: UI
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var waveView: UIView!
    @IBOutlet weak var microphoneButton: MicrophoneButton!

    private var initialWaveViewHeight: CGFloat!

    // MARK: Audio
    private var audioEngine: AVAudioEngine!
    private var inputNode: AVAudioInputNode!
    private var session: AVAudioSession!

    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest!

    // MARK: CoreData
    private lazy var managedContext: NSManagedObjectContext = {
        // swiftlint:disable force_cast
        return (UIApplication.shared.delegate as! AppDelegate).managedContext
    }()

    // MARK: - View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set to reference later.
        initialWaveViewHeight = waveView.frame.height

        // Load word if it was added by the saved table view controller.
        if let word = word {
            wordLabel.text = word.entry!
            resultLabel.text = word.definitionString()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        checkAuthentication(forStatus: SFSpeechRecognizer.authorizationStatus())
    }

    // MARK: - IBActions
    @IBAction func microphoneTouchesBegan(_ sender: UIButton) {
        startRecording()
    }

    @IBAction func microphoneTouchesEnded(_ sender: UIButton) {
        recognitionRequest.endAudio()
        audioEngine.stop()
    }

    // MARK: - Recording
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
            // A recognizer is not supported for the current locale.
            return
        }
        if !recognizer.isAvailable {
            // The recognizer is not available right now.
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
                let word = STWord(entry: entry, entity: STWord.entity(), insertInto: self.managedContext)
                self.wordLabel.text = word.entry
                word.getDefinition({ result in
                    switch result {
                    case let .definitions(definitions):
                        self.resultLabel.text = definitions.joined(separator: "\n\n")

                    case let .error(error):
                        self.presentAlert(withTitle: "Error Fetching Definition",
                                          message: error.localizedDescription)

                    case .notFound:
                        self.presentAlert(withTitle: "Not Found",
                                          message: "Could not find definition in Oxford Dictionaries.")
                    }
                })

                do {
                    try self.managedContext.save()
                } catch {
                    self.presentAlert(withTitle: "Error Auto-Saving Word", message: error.localizedDescription)
                    print("error saving to core data", error)
                }
            }
        }
    }

    fileprivate func scaledPower(power: Float) -> Float {
        guard power.isFinite else { return 0.0 }

        // Make sure the power has a reasonable value. If the value is not in the
        // right domain, return a default value.
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
    private func checkAuthentication(forStatus status: SFSpeechRecognizerAuthorizationStatus) {
        switch status {
        case .authorized:
            self.microphoneButton.isEnabled = true

        case .denied:
            self.microphoneButton.isEnabled = false
            presentAlert(withTitle: "Access to microphone was denied",
                         message: "Tru enabling microphone access in settings again.")

        case .restricted:
            self.microphoneButton.isEnabled = false
            presentAlert(withTitle: "Access to microphone is restricted",
                         message: "Tru enabling microphone access in settings again.")

        case .notDetermined:
            self.microphoneButton.isEnabled = false
            requestAuthentication()
        @unknown default:
            fatalError()
        }
    }

    private func requestAuthentication() {
        SFSpeechRecognizer.requestAuthorization { [unowned self] (authStatus) in
            OperationQueue.main.addOperation {
                self.checkAuthentication(forStatus: authStatus)
            }
        }
    }
}
