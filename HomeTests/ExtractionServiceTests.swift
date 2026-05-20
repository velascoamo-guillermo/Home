// HomeTests/ExtractionServiceTests.swift
import Testing
import Foundation
@testable import Home

@Suite("ExtractionService") @MainActor struct ExtractionServiceTests {

    @Test("parses well-formed Claude JSON response")
    func parseWellFormed() throws {
        let json = """
        {
          "visitDate": "2025-03-15",
          "diagnosis": "Mild otitis externa",
          "testResults": {"WBC": "6.5 K/uL", "RBC": "7.2 M/uL"},
          "medications": ["Otomax otic suspension", "Apoquel 16mg"],
          "recommendations": "Follow up in 2 weeks if no improvement."
        }
        """
        let result = try ExtractionService.parseResponse(json)
        #expect(result.diagnosis == "Mild otitis externa")
        #expect(result.medications.count == 2)
        #expect(result.testResults["WBC"] == "6.5 K/uL")
        #expect(result.recommendations == "Follow up in 2 weeks if no improvement.")
    }

    @Test("returns nil visitDate when missing from response")
    func missingDate() throws {
        let json = """
        {
          "visitDate": null,
          "diagnosis": "Healthy",
          "testResults": {},
          "medications": [],
          "recommendations": ""
        }
        """
        let result = try ExtractionService.parseResponse(json)
        #expect(result.visitDate == nil)
    }

    @Test("buildPrompt includes pet name")
    func promptIncludesPetName() {
        let prompt = ExtractionService.buildPrompt(petName: "Luna")
        #expect(prompt.contains("Luna"))
    }
}
