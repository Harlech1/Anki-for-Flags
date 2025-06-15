import SwiftUI

struct FlashcardView: View {
    @StateObject private var viewModel = FlashcardViewModel()
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                headerView
                
                flagCardView
                
                if viewModel.isAnswerRevealed {
                    answerView
                    buttonsView
                } else {
                    revealButton
                }
                
                Spacer()
            }
            .padding()
            .background(Color(.systemBackground))
            .navigationTitle("Anki Flags")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        NavigationLink(value: "leitner") {
                            Label("Leitner Boxes", systemImage: "tray.2.fill")
                        }
                        
                        NavigationLink(value: "statistics") {
                            Label("Statistics", systemImage: "chart.bar.fill")
                        }
                        
                        Button(action: {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            showingResetAlert = true
                        }) {
                            Label("Reset Progress", systemImage: "arrow.counterclockwise.circle.fill")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title2)
                    }
                }
            }
            .navigationDestination(for: String.self) { destination in
                switch destination {
                case "leitner":
                    LeitnerBoxView(viewModel: viewModel)
                case "statistics":
                    StatisticsView(viewModel: viewModel)
                default:
                    EmptyView()
                }
            }
            .alert("Reset Progress", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                    impactFeedback.impactOccurred()
                    viewModel.resetSession()
                }
            } message: {
                Text("This will reset all your learning progress and statistics. This action cannot be undone.")
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Score: \(viewModel.score)")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Spacer()
                
                if let cardStat = viewModel.cardStats[viewModel.currentFlag.flagCode] {
                    Text("Box \(cardStat.leitnerBox)")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.purple)
                        .cornerRadius(12)
                }
                
                Spacer()
                
                Text("Cards: \(viewModel.totalCards)")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
            
            HStack {
                if viewModel.totalCards > 0 {
                    Text("Accuracy: \(String(format: "%.1f", viewModel.accuracyPercentage))%")
                        .font(.headline)
                        .foregroundColor(.green)
                }
                
                Spacer()
            }
        }
    }
    
    private var flagCardView: some View {
        VStack(spacing: 20) {
            Text("What country is this?")
                .font(.title2)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
            
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.clear)
                .frame(height: 200)
                .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: 5)
                .overlay(
                    Group {
                        if let image = UIImage(named: viewModel.currentFlag.flagCode) {
                            Image(uiImage: croppedImage(from: image))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(10)
                        } else {
                            VStack(spacing: 10) {
                                Image(systemName: "flag.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.blue)
                                Text(viewModel.currentFlag.countryName)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.center)
                                Text("Add flag images to Xcode project")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                )
        }
    }
    
    private var answerView: some View {
        VStack(spacing: 15) {
            Text("Answer:")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text(viewModel.currentFlag.countryName)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.blue.opacity(0.1))
                )
        }
    }
    
    private var revealButton: some View {
        Button(action: {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            withAnimation(.easeInOut(duration: 0.3)) {
                viewModel.revealAnswer()
            }
        }) {
            Text("Reveal Answer")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
        }
    }
    
    private var buttonsView: some View {
        VStack(spacing: 15) {
            Text("How well did you know this?")
                .font(.headline)
                .foregroundColor(.gray)
            
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    Button(action: {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                        impactFeedback.impactOccurred()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.markDifficulty(1)
                        }
                    }) {
                        Text("Again")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.markDifficulty(2)
                        }
                    }) {
                        Text("Hard")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.orange)
                            .cornerRadius(10)
                    }
                }
                
                HStack(spacing: 10) {
                    Button(action: {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.markDifficulty(3)
                        }
                    }) {
                        Text("Good")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.markDifficulty(4)
                        }
                    }) {
                        Text("Easy")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
            }
        }
    }
    
    private func croppedImage(from image: UIImage) -> UIImage {
        let cropInsets: CGFloat = 5.0
        let cropRect = CGRect(
            x: cropInsets,
            y: cropInsets,
            width: image.size.width - (cropInsets * 2),
            height: image.size.height - (cropInsets * 2)
        )
        
        guard let cgImage = image.cgImage?.cropping(to: cropRect) else {
            return image
        }
        
        return UIImage(cgImage: cgImage)
    }
}

#Preview {
    FlashcardView()
}