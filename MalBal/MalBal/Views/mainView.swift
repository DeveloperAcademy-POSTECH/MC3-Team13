import Charts
import SwiftUI
import AVKit

struct mainView: View {
    @StateObject var audioProcessing = mainViewModel()
    @StateObject var uploadingViewModel = UploadingViewModel()
    
    @State private var timeElapsed: TimeInterval = 0.0
    @State private var isModalVisible = false
    @State private var isPresentingPicker = false
    
    @State private var isPlaying: Bool = false
    @State private var isSelectedOnce: Bool = false
    
    @State private var videoURL: URL?
    @State private var audioURL: URL?
    @State private var isActive: Bool = false
    
    @State private var testTimer: Timer?

    let timer = Timer.publish(
        every: Constants.updateInterval,
        on: .main,
        in: .common
    ).autoconnect()
    
    @State private var isRecording = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.main2.edgesIgnoringSafeArea(.all)
                VStack {
                    VStack {
                        
                        Text(timeElapsed.formattedTimeString())
                            .font(.largeTitle)
                        
                        Chart(Array(audioProcessing.data.enumerated()), id: \.0) { index, magnitude in
                            BarMark(
                                x: .value("Frequency", String(index)),
                                y: .value("Magnitude", magnitude)
                            )
                            .foregroundStyle(
                                Color(
                                    hue: 0.3 - Double((magnitude / Constants.magnitudeLimit) / 5),
                                    saturation: 1,
                                    brightness: 1,
                                    opacity: 0.7
                                )
                            )
                        }
                        .onReceive(timer, perform: audioProcessing.updateData)
                        .chartYScale(domain: 0 ... Constants.magnitudeLimit)
                        .chartXAxis(.hidden)
                        .chartYAxis(.hidden)
                        .frame(height: 100)
                        .padding()
                        .background(
                            Color.main4
                        )
                        .cornerRadius(10)
                        
                        HStack {
                            Spacer()
                            
                            if let videoURL = videoURL {
                                Button("해석 먼저 해보자") {
                                    audioURL = uploadingViewModel.extractAudio(from: videoURL)
                                    print(audioURL)
                                }
                                
                                Button(action: {
                                    if !isSelectedOnce {
                                        isSelectedOnce.toggle()
                                        if let audioURL = audioURL {
                                            try! AVAudioSession.sharedInstance().setCategory(.playback, options: [])
                                            audioProcessing.replaying()
                                        }
                                    }
                                    if !audioProcessing.isPlaying {
                                        testTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
                                            timeElapsed += 0.1
                                        })
                                    }
                                    else {
                                        testTimer?.invalidate()
                                    }
                                    audioProcessing.playButtonTapped()
                                }) {
                                    Image(systemName: "\(audioProcessing.isPlaying ? "pause" : "play").circle.fill")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                }
                            }
                        }

                    }
                    .padding()
                    .background(Color.main4)
                    .cornerRadius(20)
                    
                    Spacer().frame(height: 50)
                    
                    HStack {
                        Spacer()
                        
                        Button(action: {print("EE")}) {
                            Image(systemName: "trash")
                                .resizable()
                                .frame(width: 40, height: 40)
                        }
                        
                        Spacer()
                        
                        VStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 20, height: 20)
                                        .opacity(isRecording ? 1.0 : 0.6)
                                )
                                .onTapGesture {
                                    audioProcessing.playButtonTapped()
                                    if !isRecording {
                                        testTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
                                            timeElapsed += 0.1
                                        })
                                    }
                                    else {
                                        testTimer?.invalidate()
                                    }
                                    isRecording.toggle()
                                    // Add your recording logic here
                                }
                        }
                        
                        Spacer()
                        Button(action: {isPresentingPicker = true}) {
                            Image(systemName: "square.and.arrow.down")
                                .resizable()
                                .frame(width: 40, height: 40)
                        }
                        .sheet(isPresented: $isPresentingPicker) {
                            VideoPickerView(videoURL: $videoURL)
                        }
                        
                        Spacer()
                    }
                    Spacer().frame(height: 80)
                    
                    Button(action: {uploadingViewModel.deleteM4AFilesInDocumentsDirectory()}) {
                        HStack {
                            // 가로로 긴 버튼을 만듭니다.
                            Text("분석하기")
                                .foregroundColor(.white)
                                .padding(.horizontal, 150)
                                .padding(.vertical, 20)
                                .background(Color.main3)
                                .cornerRadius(15)
                        }
                    }
                    
                    Spacer().frame(height: 80)
                    
                    NavigationLink(destination: ModalView()) {
                        Button(action: {
                            withAnimation {
                                isActive.toggle()
                            }
                        }) {
                            Text("연습 보관함")
                                .padding(.horizontal, 150)
                                .padding(.top, 50)
                                .padding(.bottom, 50)
                                .foregroundColor(.white)
                                .background(Color.main4)
                                .cornerRadius(20)
                        }
                    }
                }
                
            }
            .navigationTitle("MalPal")
        }
    }
}

