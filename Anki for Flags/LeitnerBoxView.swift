import SwiftUI

struct LeitnerBoxView: View {
    @ObservedObject var viewModel: FlashcardViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(1...5, id: \.self) { boxNumber in
                    leitnerBoxSection(boxNumber: boxNumber)
                }
                
                newCardsSection
            }
            .padding()
        }
        .navigationTitle("Leitner Boxes")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private func leitnerBoxSection(boxNumber: Int) -> some View {
        let cardsInBox = viewModel.cardStats.values.filter { $0.leitnerBox == boxNumber }
        let boxColor = colorForBox(boxNumber)
        let boxTitle = titleForBox(boxNumber)
        
        return DisclosureGroup(
            content: {
                if cardsInBox.isEmpty {
                    Text("No cards in this box")
                        .foregroundColor(.gray)
                        .italic()
                        .padding(.vertical, 8)
                } else {
                    LazyVStack(spacing: 8) {
                        ForEach(cardsInBox.sorted { $0.nextReviewDate < $1.nextReviewDate }, id: \.flagCode) { cardStat in
                            cardRow(for: cardStat)
                        }
                    }
                    .padding(.top, 8)
                }
            },
            label: {
                HStack {
                    Circle()
                        .fill(boxColor)
                        .frame(width: 12, height: 12)
                    
                    Text(boxTitle)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text("\(cardsInBox.count)")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(boxColor)
                        .cornerRadius(12)
                }
                .padding(.vertical, 4)
            }
        )
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var newCardsSection: some View {
        let newCards = viewModel.flagDataManager.flagCountries.filter { flag in
            !viewModel.cardStats.keys.contains(flag.flagCode)
        }
        
        return DisclosureGroup(
            content: {
                if newCards.isEmpty {
                    Text("All cards have been introduced!")
                        .foregroundColor(.gray)
                        .italic()
                        .padding(.vertical, 8)
                } else {
                    LazyVStack(spacing: 8) {
                        ForEach(newCards.prefix(20), id: \.flagCode) { flag in
                            newCardRow(for: flag)
                        }
                        if newCards.count > 20 {
                            Text("... and \(newCards.count - 20) more")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                    .padding(.top, 8)
                }
            },
            label: {
                HStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 12, height: 12)
                    
                    Text("New Cards")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text("\(newCards.count)")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.vertical, 4)
            }
        )
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func cardRow(for cardStat: CardStats) -> some View {
        HStack(spacing: 12) {
            // Flag image
            Group {
                if let image = UIImage(named: cardStat.flagCode) {
                    Image(uiImage: croppedImage(from: image))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Text("?")
                                .font(.caption)
                                .foregroundColor(.gray)
                        )
                }
            }
            .frame(width: 45, height: 30)
            .cornerRadius(6)
            
            // Country name
            Text(flagName(for: cardStat.flagCode))
                .font(.body)
                .lineLimit(1)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                // Accuracy
                Text("\(String(format: "%.0f", cardStat.accuracy * 100))%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(accuracyColor(cardStat.accuracy))
                
                // Next review info
                if cardStat.isDue() {
                    Text("Due now")
                        .font(.caption2)
                        .foregroundColor(.red)
                        .fontWeight(.medium)
                } else {
                    Text(timeUntilReview(cardStat.nextReviewDate))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
    
    private func newCardRow(for flag: FlagCountry) -> some View {
        HStack(spacing: 12) {
            // Flag image
            Group {
                if let image = UIImage(named: flag.flagCode) {
                    Image(uiImage: croppedImage(from: image))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Text("?")
                                .font(.caption)
                                .foregroundColor(.gray)
                        )
                }
            }
            .frame(width: 45, height: 30)
            .cornerRadius(6)
            
            // Country name
            Text(flag.countryName)
                .font(.body)
                .lineLimit(1)
            
            Spacer()
            
            Text("New")
                .font(.caption)
                .foregroundColor(.blue)
                .fontWeight(.medium)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
    
    private func colorForBox(_ boxNumber: Int) -> Color {
        switch boxNumber {
        case 1: return .red
        case 2: return .orange
        case 3: return .yellow
        case 4: return .green
        case 5: return .blue
        default: return .gray
        }
    }
    
    private func titleForBox(_ boxNumber: Int) -> String {
        switch boxNumber {
        case 1: return "Box 1 - Learning (Daily)"
        case 2: return "Box 2 - Familiar (Every Few Days)"
        case 3: return "Box 3 - Known (Weekly)"
        case 4: return "Box 4 - Well Known (Bi-weekly)"
        case 5: return "Box 5 - Mastered (Monthly)"
        default: return "Box \(boxNumber)"
        }
    }
    
    private func accuracyColor(_ accuracy: Double) -> Color {
        if accuracy >= 0.8 { return .green }
        else if accuracy >= 0.6 { return .orange }
        else { return .red }
    }
    
    private func timeUntilReview(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        if let days = calendar.dateComponents([.day], from: now, to: date).day {
            if days <= 0 {
                return "Due now"
            } else if days == 1 {
                return "Tomorrow"
            } else if days < 7 {
                return "\(days) days"
            } else if days < 30 {
                let weeks = days / 7
                return "\(weeks)w"
            } else {
                let months = days / 30
                return "\(months)mo"
            }
        }
        return ""
    }
    
    private func flagName(for flagCode: String) -> String {
        return viewModel.flagDataManager.flagCountries.first { $0.flagCode == flagCode }?.countryName ?? flagCode
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
    LeitnerBoxView(viewModel: FlashcardViewModel())
}
