import SwiftUI

struct StatisticsView: View {
    @ObservedObject var viewModel: FlashcardViewModel
    
    var body: some View {
        List {
            Section("Overall Performance") {
                LabeledContent("Total Score", value: String(viewModel.score))
                LabeledContent("Cards Reviewed", value: String(viewModel.totalCards))
                LabeledContent("Accuracy", value: String(format: "%.1f%%", viewModel.accuracyPercentage))
                LabeledContent("Countries Learned", value: String(viewModel.cardStats.count))
            }
            
            if !viewModel.cardStats.isEmpty {
                Section("Recent Performance") {
                    let recentCards = Array(viewModel.cardStats.values.sorted { $0.lastReviewDate > $1.lastReviewDate }.prefix(10))
                    
                    if recentCards.isEmpty {
                        Text("No cards reviewed yet")
                            .foregroundColor(.gray)
                            .italic()
                    } else {
                        ForEach(recentCards, id: \.flagCode) { stat in
                            LabeledContent {
                                HStack {
                                    Text("\(stat.correctReviews)/\(stat.totalReviews)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Text(String(format: "%.0f%%", stat.accuracy * 100))
                                        .font(.caption)
                                        .foregroundColor(accuracyColor(stat.accuracy))
                                        .fontWeight(.medium)
                                }
                            } label: {
                                HStack {
                                    if let image = UIImage(named: stat.flagCode) {
                                        Image(uiImage: croppedImage(from: image))
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 30, height: 20)
                                            .cornerRadius(4)
                                    }
                                    
                                    Text(flagName(for: stat.flagCode))
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private func accuracyColor(_ accuracy: Double) -> Color {
        if accuracy >= 0.8 { return .green }
        else if accuracy >= 0.6 { return .orange }
        else { return .red }
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
    
    private func flagName(for flagCode: String) -> String {
        return FlagDataManager.shared.flagCountries.first { $0.flagCode == flagCode }?.countryName ?? flagCode
    }
}

#Preview {
    NavigationStack {
        StatisticsView(viewModel: FlashcardViewModel())
    }
}