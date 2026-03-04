import Foundation

public struct TLE {
    public let name: String
    public let line1: String
    public let line2: String
    
    public let epoch: Date
    public let inclination: Double // degrees
    public let raan: Double // Right Ascension of Ascending Node, degrees
    public let eccentricity: Double
    public let argPerigee: Double // degrees
    public let meanAnomaly: Double // degrees
    public let meanMotion: Double // revolutions per day
    
    public init?(name: String, line1: String, line2: String) {
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.line1 = line1
        self.line2 = line2
        
        guard line1.count >= 68, line2.count >= 68 else { return nil }
        
        // Parse Epoch (Line 1: 19-32)
        // Format: YYDDD.DDDDDDDD
        let epochYearStr = String(line1[line1.index(line1.startIndex, offsetBy: 18)...line1.index(line1.startIndex, offsetBy: 19)])
        let epochDayStr = String(line1[line1.index(line1.startIndex, offsetBy: 20)...line1.index(line1.startIndex, offsetBy: 31)])
        
        guard let epochYearShort = Int(epochYearStr), let epochDay = Double(epochDayStr) else { return nil }
        
        let epochYear = epochYearShort < 57 ? 2000 + epochYearShort : 1900 + epochYearShort
        
        // Convert year and day of year to Date
        var components = DateComponents()
        components.year = epochYear
        components.day = 1
        let calendar = Calendar(identifier: .gregorian)
        guard let startOfYear = calendar.date(from: components) else { return nil }
        let timeInterval = (epochDay - 1.0) * 24 * 60 * 60
        self.epoch = startOfYear.addingTimeInterval(timeInterval)
        
        // Parse Inclination (Line 2: 09-16)
        let incStr = String(line2[line2.index(line2.startIndex, offsetBy: 8)...line2.index(line2.startIndex, offsetBy: 15)]).trimmingCharacters(in: .whitespaces)
        guard let inclination = Double(incStr) else { return nil }
        self.inclination = inclination
        
        // Parse RAAN (Line 2: 18-25)
        let raanStr = String(line2[line2.index(line2.startIndex, offsetBy: 17)...line2.index(line2.startIndex, offsetBy: 24)]).trimmingCharacters(in: .whitespaces)
        guard let raan = Double(raanStr) else { return nil }
        self.raan = raan
        
        // Parse Eccentricity (Line 2: 27-33) - implied decimal point
        let eccStr = "0." + String(line2[line2.index(line2.startIndex, offsetBy: 26)...line2.index(line2.startIndex, offsetBy: 32)]).trimmingCharacters(in: .whitespaces)
        guard let eccentricity = Double(eccStr) else { return nil }
        self.eccentricity = eccentricity
        
        // Parse Arg of Perigee (Line 2: 35-42)
        let argStr = String(line2[line2.index(line2.startIndex, offsetBy: 34)...line2.index(line2.startIndex, offsetBy: 41)]).trimmingCharacters(in: .whitespaces)
        guard let argPerigee = Double(argStr) else { return nil }
        self.argPerigee = argPerigee
        
        // Parse Mean Anomaly (Line 2: 44-51)
        let maStr = String(line2[line2.index(line2.startIndex, offsetBy: 43)...line2.index(line2.startIndex, offsetBy: 50)]).trimmingCharacters(in: .whitespaces)
        guard let meanAnomaly = Double(maStr) else { return nil }
        self.meanAnomaly = meanAnomaly
        
        // Parse Mean Motion (Line 2: 53-63)
        let mmStr = String(line2[line2.index(line2.startIndex, offsetBy: 52)...line2.index(line2.startIndex, offsetBy: 62)]).trimmingCharacters(in: .whitespaces)
        guard let meanMotion = Double(mmStr) else { return nil }
        self.meanMotion = meanMotion
    }
}
