//
//  EUVatNumberValidator.swift
//  EUVatNumberValidation
//
//  Created by ALi on 2020. 04. 27..
//  Copyright © 2020. ALi. All rights reserved.
//

import Foundation
import Validator

struct EUVatNumberValidator: ValidationRule {
    
    let error: ValidationError
    
    func validate(input: String?) -> Bool {
        guard let euVatNumber = input else { return false }
        
        let generalFormatValidator = ValidationRulePattern(pattern: "^([A-Z]{2})(.*)$", error: error)
        guard generalFormatValidator.validate(input: euVatNumber) else { return false }
        
        guard let memberState = MemberState(rawValue: String(euVatNumber.prefix(2))) else { return false }
        
        switch memberState {
        case .AT:
            return ATVatNumberValidator().validate(euVatNumber)
        case .BE:
            return BEVatNumberValidator().validate(euVatNumber)
        case .BG:
            return BGVatNumberValidator().validate(euVatNumber)
        case .CY:
            return CYVatNumberValidator().validate(euVatNumber)
        case .CZ:
            return CZVatNumberValidator().validate(euVatNumber)
        case .DE:
            return DEVatNumberValidator().validate(euVatNumber)
        case .DK:
            return DKVatNumberValidator().validate(euVatNumber)
        case .EE:
            return EEVatNumberValidator().validate(euVatNumber)
        case .EL:
            return ELVatNumberValidator().validate(euVatNumber)
        case .ES:
            return ESVatNumberValidator().validate(euVatNumber)
        case .FI:
            return FIVatNumberValidator().validate(euVatNumber)
        case .FR:
            return FRVatNumberValidator().validate(euVatNumber)
        case .GB:
            return GBVatNumberValidator().validate(euVatNumber)
        case .HR:
            return HRVatNumberValidator().validate(euVatNumber)
        case .HU: 
            return HUVatNumberValidator().validate(euVatNumber)
        case .IE:
            return IEVatNumberValidator().validate(euVatNumber)
        case .IT:
            return ITVatNumberValidator().validate(euVatNumber)
        case .LT:
            return LTVatNumberValidator().validate(euVatNumber)
        case .LU:
            return LUVatNumberValidator().validate(euVatNumber)
        case .LV:
            return LVVatNumberValidator().validate(euVatNumber)
        case .MT:
            return MTVatNumberValidator().validate(euVatNumber)
        case .NL:
            return NLVatNumberValidator().validate(euVatNumber)
        case .PL:
            return PLVatNumberValidator().validate(euVatNumber)
        case .PT:
            return PTVatNumberValidator().validate(euVatNumber)
        case .RO:
            return ROVatNumberValidator().validate(euVatNumber)
        case .SE:
            return SEVatNumberValidator().validate(euVatNumber)
        case .SI:
            return SIVatNumberValidator().validate(euVatNumber)
        case .SK:
            return SKVatNumberValidator().validate(euVatNumber)
        }
    }
}

private enum MemberState: String {
    case AT, BE, BG, CY, CZ, DE, DK, EE, EL, ES, FI, FR, GB, HR, HU, IE, IT, LT, LU, LV, MT, NL, PL, PT, RO, SE, SI, SK
}

private protocol VatNumberValidating {
    func validate(_ euVatNumber: String) -> Bool
}

private protocol RegexChecking {}
private extension RegexChecking {
    @inline(__always) func isMatch(_ value: String?, pattern: String) -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: value)
    }
}

private protocol StandardChecksumCalculating: RegexChecking {
    var multipliers: [Int] { get }
    var pattern: String { get }
    var checksumLength: Int { get }
}

private extension StandardChecksumCalculating {
    func calculateSum(for euVatNumber: String?) -> Int? {
        guard isMatch(euVatNumber, pattern: pattern),
            let vatNumber = euVatNumber?.dropFirst(2) else {
            return nil
        }

        let digits = vatNumber.prefix(vatNumber.count - checksumLength).compactMap { Int(String($0)) }
        
        return digits.enumerated().reduce(0) {
            $0 + $1.element * multipliers[$1.offset]
        }
    }
    
    func validateChecksum(for euVatNumber: String?, with sum: Int) -> Bool {
        if let lastChar = euVatNumber?.suffix(checksumLength), let checkSum = Int(String(lastChar)) {
            return sum == checkSum
        }
        
        return false
    }
}

private struct ATVatNumberValidator: VatNumberValidating, RegexChecking {
    
    private let multipliers = [1,2,1,2,1,2,1]
    
    func validate(_ euVatNumber: String) -> Bool {
        guard isMatch(euVatNumber, pattern: "^(AT)U(\\d{8})$") else { return false }
        
        let digits = euVatNumber.dropFirst(3).prefix(7).compactMap { Int(String($0)) }

        var sum = digits.enumerated().reduce(0) {
            let temp = $1.element * multipliers[$1.offset]
            return $0 + temp/10 + temp%10
        }

        sum = (10 - (sum + 4) % 10) % 10
        
        if let lastDigit = euVatNumber.last, let checksum = Int(String(lastDigit)) {
            return sum == checksum
        }
        
        return false
    }
}

private struct BEVatNumberValidator: VatNumberValidating, RegexChecking {
    
    func validate(_ euVatNumber: String) -> Bool {
        guard isMatch(euVatNumber, pattern: "^(BE)(0?\\d{9})$") else { return false }
        
        let vatNumber = "0\(euVatNumber.suffix(9))"
        guard vatNumber.prefix(2) != "00",
            let number = Int(vatNumber.prefix(8)),
            let checkSum = Int(vatNumber.suffix(2)) else { return false }
        
        return checkSum == 97 - number % 97
    }
}

private struct BGVatNumberValidator: VatNumberValidating, RegexChecking {
    
    private struct Multipliers {
        static let physical = [2,4,8,5,10,9,7,3,6]
        static let foreigner = [21,19,17,13,11,9,7,3,1]
        static let miscellaneous = [4,3,2,7,6,5,4,3,2]
    }

    func validate(_ euVatNumber: String) -> Bool {
        guard isMatch(euVatNumber, pattern: "^(BG)(\\d{9,10})$") else { return false }
        
        let vatNumber = String(euVatNumber.dropFirst(2))
        return euVatNumber.count == 2+9
            ? checkNineLengthVat(vatNumber)
            : isPhysicalPerson(vatNumber) || isForeigner(vatNumber) || miscellaneousVAT(vatNumber)
    }
    
    func checkNineLengthVat(_ vatNumber: String) -> Bool {

        let digits = vatNumber.compactMap { Int(String($0)) }
        
        guard digits.count == 9, let expect = digits.last else { return false }

        let sum = digits.dropLast().enumerated().reduce(0) {
            $0 + $1.element * ($1.offset + 1)
        }

        let total = sum % 11
        if total != 10 {
            return total == expect
        }

        let sum2 = digits.dropLast().enumerated().reduce(0) {
            $0 + $1.element * ($1.offset + 3)
        }

        let total2 = (sum2 % 11) % 10

        return total2 == expect
    }
    
    func isPhysicalPerson(_ vatNumber: String) -> Bool {
        guard isMatch(vatNumber, pattern: "^\\d\\d[0-5]\\d[0-3]\\d\\d{4}$"),
            let month = Int(String(vatNumber.dropFirst(2).prefix(2))) else {
                
            return false
        }

        let digits = vatNumber.compactMap { Int(String($0)) }
        
        if ((month > 0 && month < 13) || (month > 20 && month < 33) || (month > 40 && month < 53)) {

            var sum = digits.prefix(9).enumerated().reduce(0) {
                $0 + $1.element * Multipliers.physical[$1.offset]
            }
            
            sum = (sum % 11) % 10

            return sum == digits.last
        }
        
        return false
    }
    
    func isForeigner(_ vatNumber: String) -> Bool {

        let digits = vatNumber.compactMap { Int(String($0)) }
        let sum = digits.prefix(9).enumerated().reduce(0) {
            $0 + $1.element * Multipliers.foreigner[$1.offset]
        }

        if let checkSum = digits.last {
            return sum % 10 == checkSum
        }
        
        return false
    }
    
    func miscellaneousVAT(_ vatNumber: String) -> Bool {

        let digits = vatNumber.compactMap { Int(String($0)) }
        var sum = digits.prefix(9).enumerated().reduce(0) {
            $0 + $1.element * Multipliers.miscellaneous[$1.offset]
        }

        // Establish check digit.
        sum = 11 - sum % 11
        if (sum == 10) { return false }
        if (sum == 11) { sum = 0 }

        if let checkSum = digits.last {
            return sum == checkSum
        }
        
        return false
    }
}

private struct CYVatNumberValidator: VatNumberValidating, RegexChecking {
    
    func validate(_ euVatNumber: String) -> Bool {
        guard isMatch(euVatNumber, pattern: "^(CY)([0-9]\\d{7}[A-Z])$") else {
            return false
        }
        
        let vatNumber = String(euVatNumber.dropFirst(2))
        guard vatNumber.prefix(2) != "12" else { return false }
        
        let digits = vatNumber.prefix(8).compactMap { Int(String($0)) }

        let sum = digits.prefix(8).enumerated().reduce(0) {
            var temp = $1.element
            if $1.offset % 2 == 0 {
                switch temp {
                case 0: temp = 1
                case 1: temp = 0
                case 2: temp = 5
                case 3: temp = 7
                case 4: temp = 9
                default: temp = 2*temp + 3
                }
            }
            
            return $0 + temp
        }
        
        if let checkCharacterCode = UnicodeScalar((sum % 26) + 65), let checkSumCharacter = euVatNumber.last {
            return Character(checkCharacterCode) == checkSumCharacter
        }

        return false
    }
}

private struct DEVatNumberValidator: VatNumberValidating, RegexChecking {
    
    let multipliers = [9,7,3,1,9,7,3]

    func validate(_ euVatNumber: String) -> Bool {
        guard isMatch(euVatNumber, pattern: "^(DE)([1-9]\\d{8})$") else {
            return false
        }
        
        let vatNumber = String(euVatNumber.dropFirst(2))
        let digits = vatNumber.compactMap { Int(String($0)) }

        var product = 10
        var sum = 0

        _ = digits.prefix(8).forEach {
            sum = ($0 + product) % 10
            if (sum == 0) {
                sum = 10
            }
            product = (2 * sum) % 11
        }

        let checkDigit = (11 - product == 10) ? 0 : 11 - product

        if let checkSum = digits.last {
            return checkDigit == checkSum;
        }
        
        return false
    }
}

private struct DKVatNumberValidator: VatNumberValidating, StandardChecksumCalculating {
    
    let multipliers = [2,7,6,5,4,3,2,1]
    let pattern = "^(DK)(\\d{8})$"
    let checksumLength = 0

    func validate(_ euVatNumber: String) -> Bool {
        
        guard let sum = calculateSum(for: euVatNumber) else { return false }

        return sum % 10 == 0
    }
}

private struct EEVatNumberValidator: VatNumberValidating, StandardChecksumCalculating {
    
    let multipliers = [3,7,1,3,7,1,3,7]
    let pattern = "^(EE)(10\\d{7})$"
    let checksumLength = 1

    func validate(_ euVatNumber: String) -> Bool {
        
        guard var sum = calculateSum(for: euVatNumber) else { return false }

        sum = 10 - sum % 10
        if (sum == 10) {
            sum = 0
        }
        
        return validateChecksum(for: euVatNumber, with: sum)
    }
}

private struct ELVatNumberValidator: VatNumberValidating, StandardChecksumCalculating {
    
    let multipliers = [256,128,64,32,16,8,4,2]
    let pattern = "^(EL)(\\d{9})$"
    let checksumLength = 1

    func validate(_ euVatNumber: String) -> Bool {
        
        guard var sum = calculateSum(for: euVatNumber) else { return false }
        
        sum = (sum % 11) % 10

        return validateChecksum(for: euVatNumber, with: sum)
    }
}

private struct FIVatNumberValidator: VatNumberValidating, StandardChecksumCalculating {
    
    let multipliers = [7,9,10,5,8,4,2]
    let pattern = "^(FI)(\\d{8})$"
    let checksumLength = 1

    func validate(_ euVatNumber: String) -> Bool {
        
        guard var sum = calculateSum(for: euVatNumber) else { return false }
        
        sum = 11 - sum % 11
        if sum > 9 {
            sum = 0
        }

        return validateChecksum(for: euVatNumber, with: sum)
    }
}

private struct FRVatNumberValidator: VatNumberValidating, RegexChecking {
    
    func validate(_ euVatNumber: String) -> Bool {

        if isMatch(euVatNumber, pattern: "^(FR)([A-HJ-NP-Z]\\d{10})$") ||
            isMatch(euVatNumber, pattern: "^(FR)(\\d[A-HJ-NP-Z]\\d{9})$") ||
            isMatch(euVatNumber, pattern: "^(FR)([A-HJ-NP-Z]{2}\\d{9})$") {
            return true
        }

        guard isMatch(euVatNumber, pattern: "^(FR)(\\d{11})$") else {
            return false
        }
        
        let vatNumber = String(euVatNumber.dropFirst(2))
        
        guard var sum = Int(String(vatNumber.dropFirst(2))) else { return false }
        
        sum = (100*sum + 12) % 97
        
        if let checkSum = Int(String(vatNumber.prefix(2))) {
            return sum == checkSum
        }
        
        return false
    }
}

private struct HRVatNumberValidator: VatNumberValidating, RegexChecking {
    
    func validate(_ euVatNumber: String) -> Bool {
        guard isMatch(euVatNumber, pattern: "^(HR)(0?\\d{11})$") else {
            return false
        }
        
        let vatNumber = String(euVatNumber.dropFirst(2))
        let digits = vatNumber.compactMap { Int(String($0)) }

        var product = 10
        var sum = 0
        
        digits.prefix(10).forEach {
            sum = ($0 + product) % 10
            if sum == 0 {
                sum = 10
            }
            product = (2 * sum) % 11
        }
        
        if let checkSum = digits.last {
            return (product + checkSum) % 10 == 1
        }
        
        return false
    }
}

private struct HUVatNumberValidator: VatNumberValidating, StandardChecksumCalculating {
    
    let multipliers = [9,7,3,1,9,7,3]
    let pattern = "^(HU)(\\d{8})$"
    let checksumLength = 1

    func validate(_ euVatNumber: String) -> Bool {
        
        guard var sum = calculateSum(for: euVatNumber) else { return false }

        sum = 10 - sum % 10
        if (sum == 10) {
            sum = 0
        }

        return validateChecksum(for: euVatNumber, with: sum)
    }
}

private struct ITVatNumberValidator: VatNumberValidating, RegexChecking {
    
    let multipliers = [1,2,1,2,1,2,1,2,1,2]

    func validate(_ euVatNumber: String) -> Bool {
        guard isMatch(euVatNumber, pattern: "^(IT)(\\d{11})$") else {
            return false
        }
        
        let vatNumber = String(euVatNumber.dropFirst(2))
        let digits = vatNumber.compactMap { Int(String($0)) }
        
        guard let leadingPart = Int(String(vatNumber.prefix(7))), leadingPart != 0,
            let trailingPart = Int(String(vatNumber.dropLast().suffix(3))),
            trailingPart > 0, trailingPart <= 201 || trailingPart == 999 || trailingPart == 888 else { return false }

        var sum = digits.prefix(10).enumerated().reduce(0) {
            let temp = $1.element * multipliers[$1.offset]
            if temp > 9 {
                return $0 + temp / 10 + temp % 10
            } else {
                return $0 + temp
            }
        }
        
        sum = 10 - sum % 10
        if (sum > 9) {
            sum = 0
        }

        if let checkSum = digits.last {
            return sum == checkSum
        }
        
        return false
    }
}

private struct LUVatNumberValidator: VatNumberValidating, RegexChecking {
    
    func validate(_ euVatNumber: String) -> Bool {
        guard isMatch(euVatNumber, pattern: "^(LU)(\\d{8})$") else {
            return false
        }
        
        let vatNumber = String(euVatNumber.dropFirst(2))
        
        guard let checkSum = Int(String(vatNumber.suffix(2))), let sum = Int(String(vatNumber.prefix(6))) else {
            return false
        }
        
        return  sum % 89 == checkSum
    }
}

private struct MTVatNumberValidator: VatNumberValidating, StandardChecksumCalculating {
    
    let multipliers = [3,4,6,7,8,9]
    let pattern = "^(MT)([1-9]\\d{7})$"
    let checksumLength = 2

    func validate(_ euVatNumber: String) -> Bool {
        
        guard var sum = calculateSum(for: euVatNumber) else { return false }

        sum = 37 - sum % 37
        if (sum == 10) {
            sum = 0
        }

        return validateChecksum(for: euVatNumber, with: sum)
    }
}

private struct NLVatNumberValidator: VatNumberValidating, StandardChecksumCalculating {
    
    let multipliers = [9,8,7,6,5,4,3,2]
    let pattern = "^(NL)(\\d{9})B\\d{2}$"
    let checksumLength = 4

    func validate(_ euVatNumber: String) -> Bool {

        guard var sum = calculateSum(for: euVatNumber) else { return false }
        
        sum = sum % 11
        if (sum > 9) {
            sum = 0
        }

        if let checkSum = Int(String(euVatNumber.dropLast(3).suffix(1))) {
            return sum == checkSum
        }
        
        return false
    }
}

private struct PLVatNumberValidator: VatNumberValidating, StandardChecksumCalculating {
    
    let multipliers = [6,5,7,2,3,4,5,6,7]
    let pattern = "^(PL)(\\d{10})$"
    let checksumLength = 1

    func validate(_ euVatNumber: String) -> Bool {
        
        guard var sum = calculateSum(for: euVatNumber) else { return false }

        sum = sum % 11
        if (sum > 9) {
            sum = 0
        }

        return validateChecksum(for: euVatNumber, with: sum)
    }
}

private struct PTVatNumberValidator: VatNumberValidating, StandardChecksumCalculating {
    
    let multipliers = [9,8,7,6,5,4,3,2]
    let pattern = "^(PT)(\\d{9})$"
    let checksumLength = 1

    func validate(_ euVatNumber: String) -> Bool {

        guard var sum = calculateSum(for: euVatNumber) else { return false }
        
        sum = 11 - sum % 11
        if (sum > 9) {
            sum = 0
        }

        return validateChecksum(for: euVatNumber, with: sum)
    }
}

private struct ROVatNumberValidator: VatNumberValidating, StandardChecksumCalculating {
    
    let multipliers = [7,5,3,2,1,7,5,3,2]
    let pattern = "^(RO)([1-9]\\d{1,9})$"
    let checksumLength = 1

    func validate(_ euVatNumber: String) -> Bool {
        
        guard var sum = calculateSum(for: euVatNumber) else {
            return false
        }

        sum = (10*sum % 11) % 10

        return validateChecksum(for: euVatNumber, with: sum)
    }
}

private struct SKVatNumberValidator: VatNumberValidating, RegexChecking {
    
    func validate(_ euVatNumber: String) -> Bool {
        guard isMatch(euVatNumber, pattern: "^(SK)([1-9]\\d[2346-9]\\d{7})$") else {
            return false
        }
        
        let vatNumber = String(euVatNumber.dropFirst(2))

        guard let sum = Int(vatNumber) else { return false }
        
        return (sum % 11) == 0
    }
}

private struct CZVatNumberValidator: VatNumberValidating, RegexChecking {
    
    let multipliers = [8,7,6,5,4,3,2,1,0,9,10]

    func validate(_ euVatNumber: String) -> Bool {
        guard isMatch(euVatNumber, pattern: "^(CZ)(\\d{8,10})(\\d{3})?$") else {
            return false
        }

        let vatNumber = String(euVatNumber.dropFirst(2))
        return isLegalEntities(vatNumber) || isIndividualType(vatNumber)
    }
    
    func isLegalEntities(_ vatNumber: String) -> Bool {

        guard isMatch(vatNumber, pattern: "^\\d{8}$") || isMatch(vatNumber, pattern: "^6\\d{8}$") else { return false }
        
        var sum = vatNumber.prefix(7).compactMap({ Int(String($0)) }).enumerated().reduce(0) {
            $0 + $1.element * multipliers[$1.offset]
        }

        sum = (11 - sum % 11) % 10

        if let lastChar = vatNumber.last, let checksum = Int(String(lastChar)) {
            return sum == checksum
        }
        
        return false
    }
    
    func extractNumber(from string: String, at position: Int, length: Int) -> Int {
        Int(String(string.dropFirst(position).prefix(length))) ?? 0
    }
    
    func isIndividualType(_ vatNumber: String) -> Bool {
        
        guard isMatch(vatNumber, pattern: "^\\d{2}[0-3|5-8]\\d[0-3]\\d\\d{4}$") else { return false }

        let sum = extractNumber(from: vatNumber, at: 0, length: 2)
            + extractNumber(from: vatNumber, at: 2, length: 2)
                + extractNumber(from: vatNumber, at: 4, length: 2)
                + extractNumber(from: vatNumber, at: 6, length: 2)
                + extractNumber(from: vatNumber, at: 8, length: 2)
        
        guard let vatAsANumber = Int(String(vatNumber)) else { return false }
        
        return (sum % 11 == 0) && (vatAsANumber % 11 == 0)
    }
}

private struct SEVatNumberValidator: VatNumberValidating, RegexChecking {
    
    func validate(_ euVatNumber: String) -> Bool {
        guard isMatch(euVatNumber, pattern: "^(SE)(\\d{10}01)$") else {
            return false
        }
        
        let vatNumber = euVatNumber.dropFirst(2)
        
        let sumEven = vatNumber.prefix(9).enumerated()
            .compactMap({ $0.offset % 2 == 0 ? Int(String($0.element)) : nil })
            .reduce(0) { $0 + $1 / 5 + (2 * $1) % 10 }

        let sumOdd = vatNumber.prefix(9).enumerated()
            .compactMap({ $0.offset % 2 == 1 ? Int(String($0.element)) : nil })
            .reduce(0, +)

        let checkDigit = (10 - (sumOdd + sumEven) % 10) % 10

        if let checkSum = Int(String(vatNumber.dropLast(2).suffix(1))) {
            return checkDigit == checkSum
        }

        return false
    }
}

private struct GBVatNumberValidator: VatNumberValidating, RegexChecking {
    
    let multipliers = [8,7,6,5,4,3,2]
    
    func validate(_ euVatNumber: String) -> Bool {
        guard isMatch(euVatNumber, pattern: "^(GB)?(\\d{9})$")
            || isMatch(euVatNumber, pattern: "^(GB)?(\\d{12})$")
            || isMatch(euVatNumber, pattern: "^(GB)?(GD\\d{3})$")
            || isMatch(euVatNumber, pattern: "^(GB)?(HA\\d{3})$") else {
                return false
        }
        
        let vatNumber = String(euVatNumber.dropFirst(2))
        
        if vatNumber.prefix(2) == "GD" {
            if let numberPart = Int(String(vatNumber.suffix(3))), numberPart < 500 {
                return true
            }
            
            return false
        }
        
        if vatNumber.prefix(2) == "HA" {
            if let numberPart = Int(String(vatNumber.suffix(3))), numberPart >= 500 {
                return true
            }
            
            return false
        }
        
        guard vatNumber.prefix(1) != "0", let vatAsANumber = Int(String(vatNumber.prefix(7))) else { return false }
        
        let sum = vatNumber.prefix(7).compactMap({ Int(String($0)) }).enumerated().reduce(0) {
            $0 + $1.element * multipliers[$1.offset]
        }
        
        var checkDigit = sum
        while (checkDigit > 0) {
            checkDigit -= 97
        }
        checkDigit = abs(checkDigit)
        guard let checksum = Int(String(vatNumber.dropFirst(7).prefix(2))) else { return false }
        
        if checkDigit == checksum, vatAsANumber < 9_990_001, (vatAsANumber < 100_000 || vatAsANumber > 999_999),
            (vatAsANumber < 9_490_001 || vatAsANumber > 9_700_000) {
            return true
        }
        
        checkDigit = checkDigit >= 55 ? checkDigit - 55 : checkDigit + 42
        return checkDigit == checksum && sum > 1_000_000
    }
}

private struct SIVatNumberValidator: VatNumberValidating, StandardChecksumCalculating {
    
    let multipliers = [8,7,6,5,4,3,2]
    let pattern = "^(SI)([1-9]\\d{7})$"
    let checksumLength = 1

    func validate(_ euVatNumber: String) -> Bool {
        
        guard var sum = calculateSum(for: euVatNumber) else { return false }

        sum = 11 - sum % 11
        if (sum == 10) {
            sum = 0
        }

        return validateChecksum(for: euVatNumber, with: sum)
    }
}

private struct LVVatNumberValidator: VatNumberValidating, RegexChecking {
    
    let multipliers = [9,1,4,8,3,10,2,5,7,6]

    func validate(_ euVatNumber: String) -> Bool {
        guard isMatch(euVatNumber, pattern: "^(LV)(\\d{11})$") else {
            return false
        }

        let vatNumber = euVatNumber.dropFirst(2)

        if isMatch(String(vatNumber.prefix(1)), pattern: "^[0-3]") {
            return isMatch(String(vatNumber.prefix(4)), pattern: "^[0-3][0-9][0-1][0-9]")
        }
        
        var sum = vatNumber.prefix(10).compactMap({ Int(String($0)) }).enumerated().reduce(0) {
            $0 + $1.element * multipliers[$1.offset]
        }

        if sum % 11 == 4, vatNumber.prefix(1) == "9" {
            sum -= 45
        }

        if (sum % 11 == 4) {
            sum = 4 - sum % 11
        } else if (sum % 11 > 4) {
            sum = 14 - sum % 11
        } else if (sum % 11 < 4) {
            sum = 3 - sum % 11
        }

        if let checksum = Int(String(vatNumber.suffix(1))) {
            return sum == checksum
        }
        
        return false
    }
}

private struct IEVatNumberValidator: VatNumberValidating, RegexChecking {
    
    let multipliers = [8,7,6,5,4,3,2]
    
    func validate(_ euVatNumber: String) -> Bool {
        guard isMatch(euVatNumber, pattern: "^(IE)(\\d{7}[A-W])$")
            || isMatch(euVatNumber, pattern: "^(IE)([7-9][A-Z\\*\\+)]\\d{5}[A-W])$")
            || isMatch(euVatNumber, pattern: "^(IE)(\\d{7}[A-W][AH])$") else {
                return false
        }
        
        let vatNumber = String(euVatNumber.dropFirst(2))

        var tempVatNumber = vatNumber

        if (isMatch(vatNumber, pattern: "^\\d[A-Z*+].*")) {

            tempVatNumber = "0"
                + String(vatNumber.dropFirst(2).prefix(5))
                + String(vatNumber.prefix(1))
                + String(vatNumber.dropFirst(7).prefix(1))
        }

        var sum = tempVatNumber.prefix(7).compactMap({ Int(String($0)) }).enumerated().reduce(0) {
            $0 + $1.element * multipliers[$1.offset]
        }
        
        if isMatch(tempVatNumber, pattern: "^\\d{7}[A-Z][AH]$") {
            sum += tempVatNumber.suffix(1) == "H" ? 72 : 9
        }

        sum = sum % 23
        let charCode = UnicodeScalar(sum + 64)
        let checksum = sum != 0 && charCode != nil ? Character(charCode!) : Character("W")

        return String(checksum) == String(tempVatNumber.dropFirst(7).prefix(1))
    }
}

private struct LTVatNumberValidator: VatNumberValidating, RegexChecking {
    
    struct Multipliers {
        static let short = [3,4,5,6,7,8,9,1]
        static let med = [1,2,3,4,5,6,7,8,9,1,2]
        static let alt = [3,4,5,6,7,8,9,1,2,3,4]
    }
    
    func validate(_ euVatNumber: String) -> Bool {
        guard isMatch(euVatNumber, pattern: "^(LT)(\\d{9}|\\d{12})$") else { return false }

        let vatNumber = String(euVatNumber.dropFirst(2))
        return vatNumber.count == 9 ? check9DigitVat(vatNumber) : check12DigitVat(vatNumber)
    }
    
    func check9DigitVat(_ vat: String) -> Bool {
        guard vat.count == 9, vat.dropFirst(7).prefix(1) == "1" else { return false }

        let digits = vat.prefix(8).compactMap { Int(String($0)) }
        
        var total = digits.enumerated().reduce(0) {
            $0 + $1.element * (1 + $1.offset)
        }
        
        if (total % 11 == 10) {
            total = digits.enumerated().reduce(0) {
                $0 + $1.element * Multipliers.short[$1.offset]
            }
        }

        total = (total % 11) % 10

        if let checksum = Int(String(vat.suffix(1))) {
            return checksum == total
        }
        
        return false
    }
    
    func check12DigitVat(_ vat: String) -> Bool {
        guard vat.count == 12, vat.dropFirst(10).prefix(1) == "1" else { return false }
        
        let digits = vat.prefix(11).compactMap { Int(String($0)) }


        var total = digits.enumerated().reduce(0) {
            $0 + $1.element * Multipliers.med[$1.offset]
        }
        
        if (total % 11 == 10) {
            total = digits.enumerated().reduce(0) {
                $0 + $1.element * Multipliers.alt[$1.offset]
            }
        }

        total = (total % 11) % 10

        if let checksum = Int(String(vat.suffix(1))) {
            return checksum == total
        }
        
        return false
    }
}

private struct ESVatNumberValidator: VatNumberValidating, RegexChecking {
    
    let multipliers = [2,1,2,1,2,1,2]
    let checksumCharacters = "TRWAGMYFPDXBNJZSQVHLCKE"

    func validate(_ euVatNumber: String) -> Bool {
        if isMatch(euVatNumber, pattern: "^(ES)([A-Z]\\d{8})$") {
            var sum = euVatNumber.dropFirst(3).prefix(7).compactMap({ Int(String($0)) }).enumerated().reduce(0) {
                let temp = $1.element * multipliers[$1.offset]
                return $0 + (temp > 9 ? temp/10 + temp%10 : temp)
            }
            
            sum = (10 - sum % 10) % 10
            
            if let checksum = Int(String(euVatNumber.suffix(1))) {
                return checksum == sum
            }
            
            return false
        }
        
        if isMatch(euVatNumber, pattern: "^(ES)([A-HN-SW]\\d{7}[A-J])$") {
            var sum = euVatNumber.dropFirst(3).prefix(7).compactMap({ Int(String($0)) }).enumerated().reduce(0) {
                let temp = $1.element * multipliers[$1.offset]
                return $0 + (temp > 9 ? temp/10 + temp%10 : temp)
            }
            
            // Now calculate the check digit itself.
            sum = 10 - sum % 10
            if let charCode = UnicodeScalar(sum + 64) {
                return String(euVatNumber.suffix(1)) == String(Character(charCode))
            }
            
            return false
        }
        
        if isMatch(euVatNumber, pattern: "^(ES)([0-9YZ]\\d{7}[A-Z])$") {
            var vatNumber = String(euVatNumber.dropFirst(2))
            if vatNumber.prefix(1) == "Y" {
                vatNumber = "1" + vatNumber.dropFirst(1)
            }
            if vatNumber.prefix(1) == "Z" {
                vatNumber = "2" + vatNumber.dropFirst(1)
            }

            if let vatAsANumber = Int(String(vatNumber.prefix(8))) {
                let index = vatAsANumber % 23
                return checksumCharacters.dropFirst(index).prefix(1) == vatNumber.suffix(1)
            }
            
            return false
        }
        
        if isMatch(euVatNumber, pattern: "^(ES)([KLMX]\\d{7}[A-Z])$") {
            if let vatAsANumber = Int(String(euVatNumber.dropFirst(3).prefix(7))) {
                let index = vatAsANumber % 23
                return checksumCharacters.dropFirst(index).prefix(1) == euVatNumber.suffix(1)
            }
            
            return false
        }
        
        return false
    }
}

