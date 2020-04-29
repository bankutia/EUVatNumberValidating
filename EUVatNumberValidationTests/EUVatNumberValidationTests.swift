//
//  EUVatNumberValidationTests.swift
//  EUVatNumberValidationTests
//
//  Created by ALi on 2020. 04. 27..
//  Copyright © 2020. ALi. All rights reserved.
//
//  based on:
//  https://formvalidation.io/guide/validators/vat
//


import XCTest
import Validator
@testable import EUVatNumberValidation

struct dummyError: ValidationError {
    var message = "Something wrong..."
}

class EUVatNumberValidationTests: XCTestCase {
    
    var validator: EUVatNumberValidator!
    
    override func setUp() {
        validator = EUVatNumberValidator.init(error: dummyError())
    }
    
    func testGeneralFormatCheckingWorks() {
        XCTAssertFalse(validator.validate(input: "1234"))
        XCTAssertFalse(validator.validate(input: "XY675437864237"))
    }
    
    func testHungarianValidatorWorks() {
        XCTAssertTrue(validator.validate(input: "HU12892312"))
        XCTAssertFalse(validator.validate(input: "HU12892313"))
        XCTAssertFalse(validator.validate(input: "HU,dfmsbn,smb"))
    }
    
    
    func testGreekValidatorWorks() {
        XCTAssertTrue(validator.validate(input: "EL023456780"))
        XCTAssertTrue(validator.validate(input: "EL094259216"))
        XCTAssertFalse(validator.validate(input: "EL123456781"))
        XCTAssertFalse(validator.validate(input: "EL,dfmsbn,smb"))
    }
    
    
    func testGermanValidatorWorks() {
        XCTAssertTrue(validator.validate(input: "DE136695976"))
        XCTAssertFalse(validator.validate(input: "DE136695978"))
        XCTAssertFalse(validator.validate(input: "DE,dfmsbn,smb"))
    }
    
    
    func testFrenchValidatorWorks() {
        XCTAssertTrue(validator.validate(input: "FR10490018553"))
        XCTAssertTrue(validator.validate(input: "FRK7399859412"))
        XCTAssertTrue(validator.validate(input: "FR40303265045"))
        XCTAssertTrue(validator.validate(input: "FR23334175221"))
        XCTAssertTrue(validator.validate(input: "FRK7399859412"))
        XCTAssertTrue(validator.validate(input: "FR4Z123456782"))
        XCTAssertFalse(validator.validate(input: "FR84323140391"))
        XCTAssertFalse(validator.validate(input: "FR,dfmsbn,smb"))
    }
    
    
    func testFinishValidatorWorks() {
        XCTAssertTrue(validator.validate(input: "FI20774740"))
        XCTAssertFalse(validator.validate(input: "FI20774741"))
        XCTAssertFalse(validator.validate(input: "FI,dfmsbn,smb"))
    }
    
    
    func testEstonianValidatorWorks() {
        XCTAssertTrue(validator.validate(input: "EE100931558"))
        XCTAssertTrue(validator.validate(input: "EE100594102"))
        XCTAssertFalse(validator.validate(input: "EE100594103"))
        XCTAssertFalse(validator.validate(input: "EE,dfmsbn,smb"))
    }
    
    
    func testDanishValidatorWorks() {
        XCTAssertTrue(validator.validate(input: "DK34308527"))
        XCTAssertFalse(validator.validate(input: "DK13585627"))
        XCTAssertFalse(validator.validate(input: "DK,dfmsbn,smb"))
    }
    
    
    func testCzechValidatorWorks() {
        XCTAssertTrue(validator.validate(input: "CZ25123891"))
        XCTAssertTrue(validator.validate(input: "CZ7103192745"))
        XCTAssertTrue(validator.validate(input: "CZ06853820"))
        XCTAssertTrue(validator.validate(input: "CZ640903926"))
        XCTAssertFalse(validator.validate(input: "CZ25123890"))
        XCTAssertFalse(validator.validate(input: "CZ1103492745"))
        XCTAssertFalse(validator.validate(input: "CZ590312123"))
        XCTAssertFalse(validator.validate(input: "CZ,dfmsbn,smb"))
    }
    
    
    func testCypriotValidatorWorks() {
        XCTAssertTrue(validator.validate(input: "CY10259033P"))
        XCTAssertFalse(validator.validate(input: "CY10259033Z"))
        XCTAssertFalse(validator.validate(input: "CY,dfmsbn,smb"))
    }
    
    
    func testCroatianValidatorWorks() {
        XCTAssertTrue(validator.validate(input: "HR33392005961"))
        XCTAssertFalse(validator.validate(input: "HR33392005962"))
        XCTAssertFalse(validator.validate(input: "HR,dfmsbn,smb"))
    }
    
    
    func testBulgarianValidatorWorks() {
        XCTAssertTrue(validator.validate(input: "BG175074752"))
        XCTAssertTrue(validator.validate(input: "BG7523169263"))
        XCTAssertFalse(validator.validate(input: "BG752316926387362"))
        XCTAssertTrue(validator.validate(input: "BG8032056031"))
        XCTAssertTrue(validator.validate(input: "BG7542011030"))
        XCTAssertTrue(validator.validate(input: "BG7111042925"))
        XCTAssertFalse(validator.validate(input: "BG175074753"))
        XCTAssertFalse(validator.validate(input: "BG7111042922"))
        XCTAssertFalse(validator.validate(input: "BG,dfmsbn,smb"))
    }
    
    
    func testBelgianValidatorWorks() {
        XCTAssertTrue(validator.validate(input: "BE0428759497"))
        XCTAssertTrue(validator.validate(input: "BE428759497"))
        XCTAssertFalse(validator.validate(input: "BE0028759497"))
        XCTAssertFalse(validator.validate(input: "BE431150351"))
        XCTAssertFalse(validator.validate(input: "BE,dfmsbn,smb"))
    }
    
    
    func testAustrianValidatorWorks() {
        XCTAssertTrue(validator.validate(input: "ATU13585627"))
        XCTAssertFalse(validator.validate(input: "AT012345678"))
        XCTAssertFalse(validator.validate(input: "ATU13585626"))
        XCTAssertFalse(validator.validate(input: "AT,dfmsbn,smb"))
    }
    
    
    func testLuxembourgValidatorWorks() {
        XCTAssertTrue(validator.validate(input: "LU15027442"))
        XCTAssertFalse(validator.validate(input: "LU15027443"))
        XCTAssertFalse(validator.validate(input: "LU,dfmsbn,smb"))
    }
    
    
    func testMalteseValidatorWorks() {
        XCTAssertTrue(validator.validate(input: "MT11679112"))
        XCTAssertFalse(validator.validate(input: "MT11679113"))
        XCTAssertFalse(validator.validate(input: "MT,dfmsbn,smb"))
    }
    
    
    func testItalianValidatorWorks() {
        XCTAssertTrue(validator.validate(input: "IT00743110157"))
        XCTAssertFalse(validator.validate(input: "IT00743110159"))
        XCTAssertFalse(validator.validate(input: "IT,dfmsbn,smb"))
    }
    
    
    func testDutchValidatorWorks() {
        XCTAssertTrue(validator.validate(input: "NL004495445B01"))
        XCTAssertFalse(validator.validate(input: "NL123456789B90"))
        XCTAssertFalse(validator.validate(input: "NL,dfmsbn,smb"))
    }
    
    
    func testPolishValidatorWorks() {
        XCTAssertTrue(validator.validate(input: "PL8567346215"))
        XCTAssertFalse(validator.validate(input: "PL8567346216"))
        XCTAssertFalse(validator.validate(input: "PL,dfmsbn,smb"))
    }
    
    
    func testPortugueseValidatorWorks() {
        XCTAssertTrue(validator.validate(input: "PT501964843"))
        XCTAssertFalse(validator.validate(input: "PT501964842"))
        XCTAssertFalse(validator.validate(input: "PT,dfmsbn,smb"))
    }
    
    
    func testRomanianValidatorWorks() {
        XCTAssertTrue(validator.validate(input: "RO160796"))
        XCTAssertFalse(validator.validate(input: "RO18547291"))
        XCTAssertFalse(validator.validate(input: nil))
        XCTAssertFalse(validator.validate(input: "RO,dfmsbn,smb"))
    }
    
    
    func testSlovakValidatorWorks() {
        XCTAssertTrue(validator.validate(input: "SK2022749619"))
        XCTAssertTrue(validator.validate(input: "SK2021871291"))
        XCTAssertFalse(validator.validate(input: "SK2022749618"))
        XCTAssertFalse(validator.validate(input: "SK,dfmsbn,smb"))
    }
    
    
    func testSwedishValidatorWorks() {
        XCTAssertTrue(validator.validate(input: "SE123456789701"))
        XCTAssertFalse(validator.validate(input: "SE123456789101"))
        XCTAssertFalse(validator.validate(input: "SE,dfmsbn,smb"))
    }
    
    
    func testBritishValidatorWorks() {
        XCTAssertTrue(validator.validate(input: "GB980780684"))
        XCTAssertFalse(validator.validate(input: "GB802311781"))
        XCTAssertFalse(validator.validate(input: "GB,dfmsbn,smb"))
    }
    
    
    func testSlovenianValidatorWorks() {
        XCTAssertTrue(validator.validate(input: "SI50223054"))
        XCTAssertFalse(validator.validate(input: "SI50223055"))
        XCTAssertFalse(validator.validate(input: "SI,dfmsbn,smb"))
    }
    
    
    func testLatvianValidatorWorks() {
        XCTAssertTrue(validator.validate(input: "LV40003521600"))
        XCTAssertTrue(validator.validate(input: "LV16117519997"))
        XCTAssertFalse(validator.validate(input: "LV40003521601"))
        XCTAssertTrue(validator.validate(input: "LV40003076407"))
        XCTAssertFalse(validator.validate(input: "LV,dfmsbn,smb"))
    }
    
    
    func testIrishValidatorWorks() {
//        XCTAssertTrue(validator.validate(input: "IE6433435F"))
//        XCTAssertTrue(validator.validate(input: "IE6433435OA"))
        XCTAssertTrue(validator.validate(input: "IE8D79739I"))
        XCTAssertTrue(validator.validate(input: "IE8E86432H"))
        XCTAssertFalse(validator.validate(input: "IE8D79738J"))
        XCTAssertFalse(validator.validate(input: "IE,dfmsbn,smb"))
    }
    
    
    func testLithuanianValidatorWorks() {
        XCTAssertTrue(validator.validate(input: "LT100000000013"))
        XCTAssertTrue(validator.validate(input: "LT119511515"))
        XCTAssertTrue(validator.validate(input: "LT886076811"))
        XCTAssertTrue(validator.validate(input: "LT100001919017"))
        XCTAssertTrue(validator.validate(input: "LT100004801610"))
        XCTAssertFalse(validator.validate(input: "LT100001919018"))
        XCTAssertFalse(validator.validate(input: "LT,dfmsbn,smb"))
    }
    
    
    func testSpanishValidatorWorks() {
        XCTAssertTrue(validator.validate(input: "ES54362315K"))
        XCTAssertTrue(validator.validate(input: "ESX2482300W"))
        XCTAssertTrue(validator.validate(input: "ESX5253868R"))
        XCTAssertTrue(validator.validate(input: "ESM1234567L"))
        XCTAssertTrue(validator.validate(input: "ESJ99216582"))
        XCTAssertTrue(validator.validate(input: "ESB58378431"))
        XCTAssertTrue(validator.validate(input: "ESB64717838"))
        XCTAssertTrue(validator.validate(input: "ESR5000274J"))
        XCTAssertTrue(validator.validate(input: "ESQ5000274J"))
        XCTAssertTrue(validator.validate(input: "ESB78640570"))
        XCTAssertTrue(validator.validate(input: "ES50222711A"))
        XCTAssertFalse(validator.validate(input: "ESJ99216583"))
        XCTAssertFalse(validator.validate(input: "ES54362315Z"))
        XCTAssertFalse(validator.validate(input: "ESX2482300A"))
        XCTAssertFalse(validator.validate(input: "ES,dfmsbn,smb"))
    }
    
}
