import Foundation
import SwiftUI
import CoreData

class FlashcardViewModel: ObservableObject {
    @Published var currentFlag: FlagCountry
    @Published var isAnswerRevealed = false
    @Published var score = 0
    @Published var totalCards = 0
    @Published var correctAnswers = 0
    @Published var cardStats: [String: CardStats] = [:]
    
    let flagDataManager = FlagDataManager.shared
    private let coreDataStack = CoreDataStack.shared
    private var usedFlags: Set<String> = []
    
    init() {
        currentFlag = FlagDataManager.shared.getRandomFlag()
        loadCardStats()
        currentFlag = getNextDueCard()
    }
    
    private func loadCardStats() {
        let request = NSFetchRequest<NSManagedObject>(entityName: "CardStatEntity")
        
        do {
            let entities = try coreDataStack.context.fetch(request)
            cardStats.removeAll()
            
            for entity in entities {
                guard let flagCode = entity.value(forKey: "flagCode") as? String else { continue }
                
                let stats = CardStats(
                    flagCode: flagCode,
                    totalReviews: entity.value(forKey: "totalReviews") as? Int ?? 0,
                    correctReviews: entity.value(forKey: "correctReviews") as? Int ?? 0,
                    lastReviewDate: entity.value(forKey: "lastReviewDate") as? Date ?? Date(),
                    easeFactor: entity.value(forKey: "easeFactor") as? Double ?? 2.5,
                    interval: entity.value(forKey: "interval") as? Int ?? 1,
                    repetitions: entity.value(forKey: "repetitions") as? Int ?? 0,
                    nextReviewDate: entity.value(forKey: "nextReviewDate") as? Date ?? Date(),
                    leitnerBox: entity.value(forKey: "leitnerBox") as? Int ?? 1
                )
                cardStats[stats.flagCode] = stats
            }
            print("Loaded \(cardStats.count) card stats from Core Data")
        } catch {
            print("Failed to load card stats from Core Data: \(error)")
        }
    }
    
    private func saveCardStats() {
        coreDataStack.save()
    }
    
    private func saveCardStat(_ cardStat: CardStats) {
        // Find existing entity or create new one
        let request = NSFetchRequest<NSManagedObject>(entityName: "CardStatEntity")
        request.predicate = NSPredicate(format: "flagCode == %@", cardStat.flagCode)
        
        do {
            let entities = try coreDataStack.context.fetch(request)
            let entity: NSManagedObject
            
            if let existingEntity = entities.first {
                entity = existingEntity
            } else {
                guard let entityDescription = NSEntityDescription.entity(forEntityName: "CardStatEntity", in: coreDataStack.context) else {
                    print("Failed to create entity description")
                    return
                }
                entity = NSManagedObject(entity: entityDescription, insertInto: coreDataStack.context)
            }
            
            // Set values
            entity.setValue(cardStat.flagCode, forKey: "flagCode")
            entity.setValue(cardStat.totalReviews, forKey: "totalReviews")
            entity.setValue(cardStat.correctReviews, forKey: "correctReviews")
            entity.setValue(cardStat.lastReviewDate, forKey: "lastReviewDate")
            entity.setValue(cardStat.easeFactor, forKey: "easeFactor")
            entity.setValue(cardStat.interval, forKey: "interval")
            entity.setValue(cardStat.repetitions, forKey: "repetitions")
            entity.setValue(cardStat.nextReviewDate, forKey: "nextReviewDate")
            entity.setValue(cardStat.leitnerBox, forKey: "leitnerBox")
            
            // Update local copy
            cardStats[cardStat.flagCode] = cardStat
            
            // Save to Core Data
            coreDataStack.save()
            
        } catch {
            print("Failed to save card stat: \(error)")
        }
    }
    
    private func getNextDueCard() -> FlagCountry {
        // 1. Check for due cards by Leitner box priority (lower boxes = more frequent)
        let dueCards = cardStats.values.filter { $0.isDue() }
        
        if !dueCards.isEmpty {
            // Sort by Leitner box (lower box number = higher priority)
            let sortedDue = dueCards.sorted { first, second in
                if first.leitnerBox != second.leitnerBox {
                    return first.leitnerBox < second.leitnerBox
                }
                // Within same box, prioritize older due dates
                return first.nextReviewDate < second.nextReviewDate
            }
            
            if let firstDue = sortedDue.first,
               let flag = flagDataManager.flagCountries.first(where: { $0.flagCode == firstDue.flagCode }) {
                return flag
            }
        }
        
        // 2. Introduce new cards (70% chance when no due cards)
        let newCards = flagDataManager.flagCountries.filter { flag in
            !cardStats.keys.contains(flag.flagCode)
        }
        
        if !newCards.isEmpty && (dueCards.isEmpty || Double.random(in: 0...1) < 0.7) {
            return newCards.randomElement() ?? flagDataManager.getRandomFlag()
        }
        
        // 3. Fallback to any available card
        return flagDataManager.getRandomFlag()
    }
    
    func nextCard() {
        currentFlag = getNextDueCard()
        isAnswerRevealed = false
        totalCards += 1
    }
    
    func revealAnswer() {
        isAnswerRevealed = true
    }
    
    func markDifficulty(_ difficulty: Int) {
        if !isAnswerRevealed {
            return
        }
        
        let flagCode = currentFlag.flagCode
        var stats = cardStats[flagCode] ?? CardStats(flagCode: flagCode)
        
        stats.totalReviews += 1
        stats.lastReviewDate = Date()
        
        // Map our 4-button system to SuperMemo's 0-5 quality scale
        let quality: Int
        switch difficulty {
        case 1: quality = 0  // Again -> Complete blackout
        case 2: quality = 2  // Hard -> Incorrect but remembered
        case 3: quality = 4  // Good -> Correct with hesitation
        case 4: quality = 5  // Easy -> Perfect response
        default: quality = 0
        }
        
        // Apply SuperMemo algorithm
        if quality < 3 {
            // Failed recall - reset to beginning (Leitner box 1)
            stats.repetitions = 0
            stats.leitnerBox = 1
            stats.interval = 1
        } else {
            // Successful recall
            stats.correctReviews += 1
            correctAnswers += 1
            stats.repetitions += 1
            
            // Move up in Leitner system
            stats.leitnerBox = min(5, stats.leitnerBox + 1)
            
            // Calculate new interval using SuperMemo formula
            if stats.repetitions == 1 {
                stats.interval = 1
            } else if stats.repetitions == 2 {
                stats.interval = 6
            } else {
                // I(n) = I(n-1) * EF
                stats.interval = Int(Double(stats.interval) * stats.easeFactor)
            }
            
            // Award points
            score += (difficulty == 4) ? 10 : 5
        }
        
        // Update Easiness Factor using SuperMemo formula
        // EF' = EF + (0.1 - (5-q) * (0.08 + (5-q) * 0.02))
        let newEF = stats.easeFactor + (0.1 - Double(5 - quality) * (0.08 + Double(5 - quality) * 0.02))
        stats.easeFactor = max(1.3, newEF)  // Minimum EF is 1.3
        
        // Calculate next review date
        let calendar = Calendar.current
        stats.nextReviewDate = calendar.date(byAdding: .day, value: stats.interval, to: Date()) ?? Date()
        
        cardStats[flagCode] = stats
        saveCardStat(stats)
        nextCard()
    }
    
    func resetSession() {
        score = 0
        totalCards = 0
        correctAnswers = 0
        
        // Clear Core Data
        let request = NSFetchRequest<NSManagedObject>(entityName: "CardStatEntity")
        do {
            let entities = try coreDataStack.context.fetch(request)
            for entity in entities {
                coreDataStack.context.delete(entity)
            }
            coreDataStack.save()
        } catch {
            print("Failed to clear Core Data: \(error)")
        }
        
        cardStats.removeAll()
        usedFlags.removeAll()
        currentFlag = flagDataManager.getRandomFlag()
        isAnswerRevealed = false
    }
    
    var accuracyPercentage: Double {
        return totalCards > 0 ? (Double(correctAnswers) / Double(totalCards)) * 100 : 0
    }
}
