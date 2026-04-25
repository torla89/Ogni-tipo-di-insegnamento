import Flutter
import UIKit
import MediaPlayer
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

  private var playerChannel: FlutterMethodChannel?
  private var nowPlayingChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Configura audio session per background
    do {
      try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
      try AVAudioSession.sharedInstance().setActive(true)
    } catch {
      print("AVAudioSession error: \(error)")
    }

    // Configura Remote Command Center (tasti del Control Center)
    let commandCenter = MPRemoteCommandCenter.shared()

    commandCenter.playCommand.isEnabled = true
    commandCenter.playCommand.addTarget { [weak self] _ in
      self?.playerChannel?.invokeMethod("play", arguments: nil)
      return .success
    }

    commandCenter.pauseCommand.isEnabled = true
    commandCenter.pauseCommand.addTarget { [weak self] _ in
      self?.playerChannel?.invokeMethod("pause", arguments: nil)
      return .success
    }

    commandCenter.togglePlayPauseCommand.isEnabled = true
    commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
      self?.playerChannel?.invokeMethod("togglePlayPause", arguments: nil)
      return .success
    }

    commandCenter.changePlaybackPositionCommand.isEnabled = true
    commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
      if let e = event as? MPChangePlaybackPositionCommandEvent {
        let posMs = Int(e.positionTime * 1000)
        self?.playerChannel?.invokeMethod("seekTo", arguments: posMs)
      }
      return .success
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    // Canale per ricevere comandi da Flutter e aggiornare NowPlaying
    nowPlayingChannel = FlutterMethodChannel(
      name: "com.ognitipodiinsegnamento/nowplaying",
      binaryMessenger: engineBridge.pluginRegistry.registrar(forPlugin: "NowPlaying")!.messenger()
    )

    // Canale per inviare comandi play/pausa a Flutter
    playerChannel = FlutterMethodChannel(
      name: "com.ognitipodiinsegnamento/player_control",
      binaryMessenger: engineBridge.pluginRegistry.registrar(forPlugin: "PlayerControl")!.messenger()
    )

    nowPlayingChannel?.setMethodCallHandler { call, result in
      if call.method == "update" {
        if let args = call.arguments as? [String: Any] {
          let title = args["title"] as? String ?? ""
          let isPlaying = args["isPlaying"] as? Bool ?? false
          let positionMs = args["positionMs"] as? Int ?? 0
          let durationMs = args["durationMs"] as? Int ?? 0

          var nowPlayingInfo = [String: Any]()
          nowPlayingInfo[MPMediaItemPropertyTitle] = title
          nowPlayingInfo[MPMediaItemPropertyArtist] = "Ellero Balzani"
          nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = "Ogni tipo di insegnamento"
          nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = Double(positionMs) / 1000.0
          nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = Double(durationMs) / 1000.0
          nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0

          // Logo dell'app come artwork
          if let image = UIImage(named: "AppIcon") {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(
              boundsSize: image.size
            ) { _ in image }
          }

          MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        }
        result(nil)
      } else if call.method == "clear" {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        result(nil)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }
}