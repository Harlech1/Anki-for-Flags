import Foundation

struct FlagCountry {
    let flagCode: String
    let countryName: String
}

struct CardStats: Codable {
    var flagCode: String
    var totalReviews: Int = 0
    var correctReviews: Int = 0
    var lastReviewDate: Date = Date()
    var easeFactor: Double = 2.5  // SuperMemo starts at 2.5
    var interval: Int = 1         // Days between reviews
    var repetitions: Int = 0      // Successful repetitions
    var nextReviewDate: Date = Date()
    var leitnerBox: Int = 1       // Leitner box (1-5)
    
    var accuracy: Double {
        return totalReviews > 0 ? Double(correctReviews) / Double(totalReviews) : 0.0
    }
    
    func isDue() -> Bool {
        return nextReviewDate <= Date()
    }
    
    func daysSinceLastReview() -> Int {
        return Calendar.current.dateComponents([.day], from: lastReviewDate, to: Date()).day ?? 0
    }
}

class FlagDataManager: ObservableObject {
    static let shared = FlagDataManager()
    
    let flagCountries: [FlagCountry] = [
        FlagCountry(flagCode: "ac", countryName: "Antigua and Barbuda"),
        FlagCountry(flagCode: "ae", countryName: "United Arab Emirates"),
        FlagCountry(flagCode: "af", countryName: "Afghanistan"),
        FlagCountry(flagCode: "ag", countryName: "Algeria"),
        FlagCountry(flagCode: "aj", countryName: "Azerbaijan"),
        FlagCountry(flagCode: "al", countryName: "Albania"),
        FlagCountry(flagCode: "am", countryName: "Armenia"),
        FlagCountry(flagCode: "an", countryName: "Andorra"),
        FlagCountry(flagCode: "ao", countryName: "Angola"),
        FlagCountry(flagCode: "ar", countryName: "Argentina"),
        FlagCountry(flagCode: "as", countryName: "Australia"),
        FlagCountry(flagCode: "au", countryName: "Austria"),
        FlagCountry(flagCode: "ba", countryName: "Bahrain"),
        FlagCountry(flagCode: "bb", countryName: "Barbados"),
        FlagCountry(flagCode: "bc", countryName: "Botswana"),
        FlagCountry(flagCode: "be", countryName: "Belgium"),
        FlagCountry(flagCode: "bf", countryName: "Bahamas"),
        FlagCountry(flagCode: "bg", countryName: "Bangladesh"),
        FlagCountry(flagCode: "bh", countryName: "Belize"),
        FlagCountry(flagCode: "bk", countryName: "Bosnia and Herzegovina"),
        FlagCountry(flagCode: "bl", countryName: "Bolivia"),
        FlagCountry(flagCode: "bm", countryName: "Myanmar"),
        FlagCountry(flagCode: "bn", countryName: "Benin"),
        FlagCountry(flagCode: "bo", countryName: "Belarus"),
        FlagCountry(flagCode: "bp", countryName: "Solomon Islands"),
        FlagCountry(flagCode: "br", countryName: "Brazil"),
        FlagCountry(flagCode: "bt", countryName: "Bhutan"),
        FlagCountry(flagCode: "bu", countryName: "Bulgaria"),
        FlagCountry(flagCode: "bx", countryName: "Brunei"),
        FlagCountry(flagCode: "by", countryName: "Burundi"),
        FlagCountry(flagCode: "ca", countryName: "Canada"),
        FlagCountry(flagCode: "cb", countryName: "Cambodia"),
        FlagCountry(flagCode: "cd", countryName: "Chad"),
        FlagCountry(flagCode: "ce", countryName: "Sri Lanka"),
        FlagCountry(flagCode: "cg-flag.jpg", countryName: "Democratic Republic of the Congo"),
        FlagCountry(flagCode: "ch", countryName: "China"),
        FlagCountry(flagCode: "ci", countryName: "Chile"),
        FlagCountry(flagCode: "cm", countryName: "Cameroon"),
        FlagCountry(flagCode: "cn", countryName: "Comoros"),
        FlagCountry(flagCode: "co", countryName: "Colombia"),
        FlagCountry(flagCode: "congo", countryName: "Republic of the Congo"),
        FlagCountry(flagCode: "cs", countryName: "Costa Rica"),
        FlagCountry(flagCode: "ct", countryName: "Central African Republic"),
        FlagCountry(flagCode: "cu", countryName: "Cuba"),
        FlagCountry(flagCode: "cv", countryName: "Cape Verde"),
        FlagCountry(flagCode: "cy", countryName: "Cyprus"),
        FlagCountry(flagCode: "da", countryName: "Denmark"),
        FlagCountry(flagCode: "dj", countryName: "Djibouti"),
        FlagCountry(flagCode: "do", countryName: "Dominica"),
        FlagCountry(flagCode: "dr", countryName: "Dominican Republic"),
        FlagCountry(flagCode: "ec", countryName: "Ecuador"),
        FlagCountry(flagCode: "eg", countryName: "Egypt"),
        FlagCountry(flagCode: "ei", countryName: "Ireland"),
        FlagCountry(flagCode: "ek", countryName: "Equatorial Guinea"),
        FlagCountry(flagCode: "en", countryName: "Estonia"),
        FlagCountry(flagCode: "er", countryName: "Eritrea"),
        FlagCountry(flagCode: "es", countryName: "El Salvador"),
        FlagCountry(flagCode: "et", countryName: "Ethiopia"),
        FlagCountry(flagCode: "ez", countryName: "Czech Republic"),
        FlagCountry(flagCode: "fi", countryName: "Finland"),
        FlagCountry(flagCode: "fj", countryName: "Fiji"),
        FlagCountry(flagCode: "fm", countryName: "Micronesia"),
        FlagCountry(flagCode: "fr", countryName: "France"),
        FlagCountry(flagCode: "ga", countryName: "Gambia"),
        FlagCountry(flagCode: "gb", countryName: "Gabon"),
        FlagCountry(flagCode: "gg", countryName: "Georgia"),
        FlagCountry(flagCode: "gh", countryName: "Ghana"),
        FlagCountry(flagCode: "gj", countryName: "Grenada"),
        FlagCountry(flagCode: "gm", countryName: "Germany"),
        FlagCountry(flagCode: "gr", countryName: "Greece"),
        FlagCountry(flagCode: "gt", countryName: "Guatemala"),
        FlagCountry(flagCode: "gv", countryName: "Guinea"),
        FlagCountry(flagCode: "gy", countryName: "Guyana"),
        FlagCountry(flagCode: "ha", countryName: "Haiti"),
        FlagCountry(flagCode: "ho", countryName: "Honduras"),
        FlagCountry(flagCode: "hr", countryName: "Croatia"),
        FlagCountry(flagCode: "hu", countryName: "Hungary"),
        FlagCountry(flagCode: "ic", countryName: "Iceland"),
        FlagCountry(flagCode: "in", countryName: "India"),
        FlagCountry(flagCode: "id", countryName: "Indonesia"),
        FlagCountry(flagCode: "ir", countryName: "Iran"),
        FlagCountry(flagCode: "is", countryName: "Israel"),
        FlagCountry(flagCode: "it", countryName: "Italy"),
        FlagCountry(flagCode: "iv", countryName: "Côte d'Ivoire"),
        FlagCountry(flagCode: "iz", countryName: "Iraq"),
        FlagCountry(flagCode: "ja", countryName: "Japan"),
        FlagCountry(flagCode: "jm", countryName: "Jamaica"),
        FlagCountry(flagCode: "jo", countryName: "Jordan"),
        FlagCountry(flagCode: "ke", countryName: "Kenya"),
        FlagCountry(flagCode: "kg", countryName: "Kyrgyzstan"),
        FlagCountry(flagCode: "kn", countryName: "North Korea"),
        FlagCountry(flagCode: "kr", countryName: "Kiribati"),
        FlagCountry(flagCode: "ks", countryName: "South Korea"),
        FlagCountry(flagCode: "ku", countryName: "Kuwait"),
        FlagCountry(flagCode: "kz", countryName: "Kazakhstan"),
        FlagCountry(flagCode: "la", countryName: "Laos"),
        FlagCountry(flagCode: "le", countryName: "Lebanon"),
        FlagCountry(flagCode: "lg", countryName: "Latvia"),
        FlagCountry(flagCode: "lh", countryName: "Lithuania"),
        FlagCountry(flagCode: "li", countryName: "Liberia"),
        FlagCountry(flagCode: "ly", countryName: "Libya"),
        FlagCountry(flagCode: "ls", countryName: "Liechtenstein"),
        FlagCountry(flagCode: "lt", countryName: "Lesotho"),
        FlagCountry(flagCode: "lu", countryName: "Luxembourg"),
        FlagCountry(flagCode: "ma", countryName: "Madagascar"),
        FlagCountry(flagCode: "md", countryName: "Moldova"),
        FlagCountry(flagCode: "mg", countryName: "Mongolia"),
        FlagCountry(flagCode: "mi", countryName: "Malawi"),
        FlagCountry(flagCode: "mj", countryName: "Montenegro"),
        FlagCountry(flagCode: "mk", countryName: "North Macedonia"),
        FlagCountry(flagCode: "ml", countryName: "Mali"),
        FlagCountry(flagCode: "mn", countryName: "Monaco"),
        FlagCountry(flagCode: "mo", countryName: "Morocco"),
        FlagCountry(flagCode: "mp", countryName: "Mauritius"),
        FlagCountry(flagCode: "mr", countryName: "Mauritania"),
        FlagCountry(flagCode: "mt", countryName: "Malta"),
        FlagCountry(flagCode: "mu", countryName: "Oman"),
        FlagCountry(flagCode: "mv", countryName: "Maldives"),
        FlagCountry(flagCode: "mx", countryName: "Mexico"),
        FlagCountry(flagCode: "my", countryName: "Malaysia"),
        FlagCountry(flagCode: "mz", countryName: "Mozambique"),
        FlagCountry(flagCode: "ng", countryName: "Niger"),
        FlagCountry(flagCode: "nh", countryName: "Vanuatu"),
        FlagCountry(flagCode: "ni", countryName: "Nigeria"),
        FlagCountry(flagCode: "nl", countryName: "Netherlands"),
        FlagCountry(flagCode: "no", countryName: "Norway"),
        FlagCountry(flagCode: "np", countryName: "Nepal"),
        FlagCountry(flagCode: "nr", countryName: "Nauru"),
        FlagCountry(flagCode: "ns", countryName: "Suriname"),
        FlagCountry(flagCode: "nu", countryName: "Nicaragua"),
        FlagCountry(flagCode: "nz", countryName: "New Zealand"),
        FlagCountry(flagCode: "od", countryName: "South Sudan"),
        FlagCountry(flagCode: "pa", countryName: "Paraguay"),
        FlagCountry(flagCode: "palestine", countryName: "Palestine"),
        FlagCountry(flagCode: "pe", countryName: "Peru"),
        FlagCountry(flagCode: "pk", countryName: "Pakistan"),
        FlagCountry(flagCode: "pl", countryName: "Poland"),
        FlagCountry(flagCode: "pm", countryName: "Panama"),
        FlagCountry(flagCode: "po", countryName: "Portugal"),
        FlagCountry(flagCode: "pp", countryName: "Papua New Guinea"),
        FlagCountry(flagCode: "ps", countryName: "Palau"),
        FlagCountry(flagCode: "pu", countryName: "Guinea-Bissau"),
        FlagCountry(flagCode: "qa", countryName: "Qatar"),
        FlagCountry(flagCode: "ri", countryName: "Serbia"),
        FlagCountry(flagCode: "rm", countryName: "Marshall Islands"),
        FlagCountry(flagCode: "ro", countryName: "Romania"),
        FlagCountry(flagCode: "rp", countryName: "Philippines"),
        FlagCountry(flagCode: "rs", countryName: "Russia"),
        FlagCountry(flagCode: "rw", countryName: "Rwanda"),
        FlagCountry(flagCode: "sa", countryName: "Saudi Arabia"),
        FlagCountry(flagCode: "sc", countryName: "Saint Kitts and Nevis"),
        FlagCountry(flagCode: "se", countryName: "Seychelles"),
        FlagCountry(flagCode: "sf", countryName: "South Africa"),
        FlagCountry(flagCode: "sg", countryName: "Senegal"),
        FlagCountry(flagCode: "si", countryName: "Slovenia"),
        FlagCountry(flagCode: "sl", countryName: "Sierra Leone"),
        FlagCountry(flagCode: "sm", countryName: "San Marino"),
        FlagCountry(flagCode: "sn", countryName: "Singapore"),
        FlagCountry(flagCode: "so", countryName: "Somalia"),
        FlagCountry(flagCode: "sp", countryName: "Spain"),
        FlagCountry(flagCode: "st", countryName: "Saint Lucia"),
        FlagCountry(flagCode: "su", countryName: "Sudan"),
        FlagCountry(flagCode: "sw", countryName: "Sweden"),
        FlagCountry(flagCode: "sy", countryName: "Syria"),
        FlagCountry(flagCode: "sz", countryName: "Switzerland"),
        FlagCountry(flagCode: "td", countryName: "Trinidad and Tobago"),
        FlagCountry(flagCode: "th", countryName: "Thailand"),
        FlagCountry(flagCode: "ti", countryName: "Tajikistan"),
        FlagCountry(flagCode: "tn", countryName: "Tonga"),
        FlagCountry(flagCode: "to", countryName: "Togo"),
        FlagCountry(flagCode: "tp", countryName: "São Tomé and Príncipe"),
        FlagCountry(flagCode: "ts", countryName: "Tunisia"),
        FlagCountry(flagCode: "tt", countryName: "East Timor"),
        FlagCountry(flagCode: "tu", countryName: "Turkey"),
        FlagCountry(flagCode: "tv", countryName: "Tuvalu"),
        FlagCountry(flagCode: "tx", countryName: "Turkmenistan"),
        FlagCountry(flagCode: "tz", countryName: "Tanzania"),
        FlagCountry(flagCode: "ug", countryName: "Uganda"),
        FlagCountry(flagCode: "uk", countryName: "United Kingdom"),
        FlagCountry(flagCode: "up", countryName: "Ukraine"),
        FlagCountry(flagCode: "us", countryName: "United States"),
        FlagCountry(flagCode: "uv", countryName: "Burkina Faso"),
        FlagCountry(flagCode: "uy", countryName: "Uruguay"),
        FlagCountry(flagCode: "uz", countryName: "Uzbekistan"),
        FlagCountry(flagCode: "vc", countryName: "Saint Vincent and the Grenadines"),
        FlagCountry(flagCode: "ve", countryName: "Venezuela"),
        FlagCountry(flagCode: "vm", countryName: "Vietnam"),
        FlagCountry(flagCode: "vt", countryName: "Holy See"),
        FlagCountry(flagCode: "wa", countryName: "Namibia"),
        FlagCountry(flagCode: "ws", countryName: "Samoa"),
        FlagCountry(flagCode: "wz", countryName: "Eswatini"),
        FlagCountry(flagCode: "ym", countryName: "Yemen"),
        FlagCountry(flagCode: "za", countryName: "Zambia"),
        FlagCountry(flagCode: "zi", countryName: "Zimbabwe")
    ]
    
    private init() {}
    
    func getFlagImage(for flagCode: String) -> String {
        return flagCode
    }
    
    func getRandomFlag() -> FlagCountry {
        return flagCountries.randomElement() ?? flagCountries[0]
    }
}