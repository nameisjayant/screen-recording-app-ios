import AVFoundation
import AVKit

/// Front camera feed for the face cam bubble.
///
/// The broadcast extension can't use the camera, so the face cam is a view on screen that the screen
/// recording picks up. When you leave RecQuest it moves into Picture in Picture so it stays on screen over
/// other apps. Whether the camera keeps streaming there is up to iOS: it needs multitasking camera access
/// (`AVCaptureSession.isMultitaskingCameraAccessSupported`); otherwise the bubble holds its last frame
/// until you come back.
final class FaceCamController {
    let displayLayer = AVSampleBufferDisplayLayer()

    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "RecQuest.faceCam")
    private let frameReceiver: FaceCamFrameReceiver
    private let playbackDelegate = FaceCamPlaybackDelegate()
    private var pictureInPicture: AVPictureInPictureController?
    private var isConfigured = false
    private(set) var isRunning = false

    init() {
        displayLayer.videoGravity = .resizeAspectFill
        frameReceiver = FaceCamFrameReceiver(renderer: displayLayer.sampleBufferRenderer)
    }

    var isAuthorized: Bool { AVCaptureDevice.authorizationStatus(for: .video) == .authorized }

    func requestAccess() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: true
        case .notDetermined: await AVCaptureDevice.requestAccess(for: .video)
        default: false
        }
    }

    func start() {
        guard !isRunning, isAuthorized else { return }
        isRunning = true
        configureIfNeeded()
        activateAudioSession(true)
        setUpPictureInPicture()
        // AVCaptureSession is thread-safe; start/stop run off the main thread because they block.
        nonisolated(unsafe) let session = session
        sessionQueue.async { session.startRunning() }
    }

    func stop() {
        guard isRunning else { return }
        isRunning = false
        pictureInPicture?.stopPictureInPicture()
        pictureInPicture = nil
        nonisolated(unsafe) let session = session
        sessionQueue.async { session.stopRunning() }
        displayLayer.sampleBufferRenderer.flush(removingDisplayedImage: true, completionHandler: nil)
        activateAudioSession(false)
    }

    // MARK: - Private

    private func configureIfNeeded() {
        guard !isConfigured else { return }
        isConfigured = true

        session.beginConfiguration()
        session.sessionPreset = .medium
        if session.isMultitaskingCameraAccessSupported {
            session.isMultitaskingCameraAccessEnabled = true
        }
        if let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
           let input = try? AVCaptureDeviceInput(device: camera),
           session.canAddInput(input) {
            session.addInput(input)
        }
        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(frameReceiver, queue: DispatchQueue(label: "RecQuest.faceCam.frames"))
        if session.canAddOutput(output) {
            session.addOutput(output)
            if let connection = output.connection(with: .video) {
                if connection.isVideoRotationAngleSupported(90) { connection.videoRotationAngle = 90 }
                if connection.isVideoMirroringSupported {
                    connection.automaticallyAdjustsVideoMirroring = false
                    connection.isVideoMirrored = true
                }
            }
        }
        session.commitConfiguration()
    }

    private func setUpPictureInPicture() {
        guard pictureInPicture == nil, AVPictureInPictureController.isPictureInPictureSupported() else { return }
        let source = AVPictureInPictureController.ContentSource(sampleBufferDisplayLayer: displayLayer,
                                                                playbackDelegate: playbackDelegate)
        let controller = AVPictureInPictureController(contentSource: source)
        controller.canStartPictureInPictureAutomaticallyFromInline = true
        pictureInPicture = controller
    }

    /// Picture in Picture needs an active playback session; mixing keeps the user's music and the recording's app audio playing.
    private func activateAudioSession(_ isActive: Bool) {
        let audioSession = AVAudioSession.sharedInstance()
        if isActive {
            try? audioSession.setCategory(.playback, mode: .moviePlayback, options: [.mixWithOthers])
            try? audioSession.setActive(true)
        } else {
            try? audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        }
    }
}

/// Receives camera frames on the capture queue and shows them right away.
private nonisolated final class FaceCamFrameReceiver: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, @unchecked Sendable {
    private let renderer: AVSampleBufferVideoRenderer

    init(renderer: AVSampleBufferVideoRenderer) {
        self.renderer = renderer
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if let attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, createIfNecessary: true),
           CFArrayGetCount(attachments) > 0 {
            let attachment = unsafeBitCast(CFArrayGetValueAtIndex(attachments, 0), to: CFMutableDictionary.self)
            CFDictionarySetValue(attachment,
                                 Unmanaged.passUnretained(kCMSampleAttachmentKey_DisplayImmediately).toOpaque(),
                                 Unmanaged.passUnretained(kCFBooleanTrue).toOpaque())
        }
        if renderer.status == .failed { renderer.flush() }
        renderer.enqueue(sampleBuffer)
    }
}

/// A live feed: always "playing", no timeline to scrub.
private nonisolated final class FaceCamPlaybackDelegate: NSObject, AVPictureInPictureSampleBufferPlaybackDelegate {
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, setPlaying playing: Bool) {}

    func pictureInPictureControllerTimeRangeForPlayback(_ pictureInPictureController: AVPictureInPictureController) -> CMTimeRange {
        CMTimeRange(start: .negativeInfinity, duration: .positiveInfinity)
    }

    func pictureInPictureControllerIsPlaybackPaused(_ pictureInPictureController: AVPictureInPictureController) -> Bool {
        false
    }

    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController,
                                    didTransitionToRenderSize newRenderSize: CMVideoDimensions) {}

    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController,
                                    skipByInterval skipInterval: CMTime,
                                    completion completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}
