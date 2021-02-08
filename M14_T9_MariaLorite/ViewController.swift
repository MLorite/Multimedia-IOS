//
//  ViewController.swift
//  M14_T9_MariaLorite
//
//  Created by user177266 on 11/14/20.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    let songs = ["Rozalen - Y Busqué",
                 "Manuel Carrasco - Que bonito es querer",
                 "Vanesa Martin - Inventas"]
    
    let image1 = UIImage(imageLiteralResourceName: "rozalen")
    let image2 = UIImage(imageLiteralResourceName: "manuel")
    let image3 = UIImage(imageLiteralResourceName: "vanesa")
    
    var images : [UIImage] = []
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var avanzaButton: UIButton!

    @IBOutlet weak var retrocedeButton: UIButton!
    
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var recorderButton: UIButton!
    @IBOutlet weak var playRecorderButton: UIButton!
    @IBOutlet var progressBar: UIProgressView!
    
    var player = AVAudioPlayer()
    var playerRecorder = AVAudioPlayer()
    var recorder : AVAudioRecorder!
    var file : URL!
    
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Array de imagenes
        images = [image1, image2, image3]
        
        //Funcion para establecer como empieza la vista
        initEnviroment()
        
        //Especifico la URL donde guardar una grabaciñon
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        file = path[0].appendingPathComponent("grabacion.m4a")
        
        //Funcion para especificar la grabación
        initRecorder()
    }
    
    // Función para establecer como empieza la vista
    func initEnviroment(){
        self.pauseButton.isHidden = true
        self.stopButton.isHidden = true
        indexGenerator()
        loadSong()
    }
    
    //precargar la cancion
    func loadSong(){
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: songs[index], ofType: "mp3")!)
        player = try! AVAudioPlayer(contentsOf: url)
        player.prepareToPlay()
        imageView.image = images[index]
        songTitleLabel.text = songs[index]
    }
    
    //Funcion para elegir una cancion aleatoriamente
    func indexGenerator(){
        if (index < 0) {
            index = songs.count - 1
        } else if index > songs.count - 1{
            index = 0
        }
    }
    
    //Inicializador de grabación
    func initRecorder(){
        let settings = [
            AVFormatIDKey : Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey : 44100,
            AVNumberOfChannelsKey : 2, //grabacion en estero
            AVEncoderAudioQualityKey : AVAudioQuality.high.rawValue //El valor en crudo de esta caracteristica
        ]
        recorder = try? AVAudioRecorder(url: file, settings: settings)
    }
    
    //Función que establece el progreso de la canción para meterlo en ProgressBar
    func getProgress()->Float{
        var theCurrentTime = 0.0
        var theCurrentDuration = 0.0
        if let currentTime = player.currentTime as? Double, let duration = player.duration as? Double {
            theCurrentTime = currentTime
            theCurrentDuration = duration
        }
        return Float(theCurrentTime / theCurrentDuration)
    }

    //Boton de STOP
    @IBAction func stop(_ sender: UIButton) {
        player.stop()
        //Sin este LoadSong la cancion no vuelve al inicio con el Stop.
        loadSong()
        self.pauseButton.isHidden = true
        self.stopButton.isHidden = true
        self.playButton.isEnabled = true
        
    }
    
    //Boton de PLAY
    @IBAction func play(_ sender: UIButton) {
        player.play()
        stopButton.isEnabled = true
        stopButton.isHidden = false
        pauseButton.isEnabled = true
        pauseButton.isHidden = false
        playButton.isEnabled = false
        
        DispatchQueue.global().async {
            var progreso : Float = 0.0
            while self.player.currentTime < self.player.duration {
                progreso = self.getProgress()
                DispatchQueue.main.async {
                    self.progressBar.setProgress(progreso, animated: true)
                }
            } 
        }
    }
    
    //Boton de PAUSE
    @IBAction func pause(_ sender: UIButton) {
        player.pause()
        pauseButton.isEnabled = false
        playButton.isEnabled = true
        stopButton.isEnabled = true
        
    }
    
    //Boton de Retroceder cancion
    @IBAction func retrocede(_ sender: UIButton) {
        index = index - 1
        indexGenerator()
        loadSong()
        //para que no deje de sonar la musica si tienes el play puesto
        if playButton.isEnabled == false {
            player.play()
        }
    }
    
    //Boton para Avanzar cancion
    @IBAction func avanza(_ sender: UIButton) {
        index = index + 1
        indexGenerator()
        loadSong()
        //para que no deje de sonar la musica si tienes el play puesto
        if playButton.isEnabled == false {
            player.play()
        }
    }
    
    //Boton para grabar cancion
    @IBAction func grabar(_ sender: UIButton) {
        if recorder.isRecording {
            recorder.stop()
            recorderButton.setTitle("", for: .normal)
            recorderButton.setTitleColor(.red, for: .normal)
            recorderButton.setImage(UIImage(systemName: "mic.fill"), for: .normal)
            playRecorderButton.setTitle("Reproducir grabacion", for: .normal)
        } else {
            recorder.record()
            recorderButton.setTitle(" Dejar Grabar", for: .normal)
            recorderButton.setTitleColor(.red, for: .normal)
            recorderButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        }
    }
    
    //Boton para reproducir grabacion
    @IBAction func playRecorder(_ sender: UIButton) {
            do {
                playerRecorder = try AVAudioPlayer(contentsOf: file)
                playerRecorder.play()
            } catch {
                playRecorderButton.setTitle("No hay grabaciones", for: .normal)
            }
    }
}

