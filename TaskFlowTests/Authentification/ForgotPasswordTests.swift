//
//  ForgotPasswordTests.swift
//  TaskFlow
//
//  Created by luc banchetti on 03/03/2026.
//

import Testing
import Foundation
@testable import TaskFlow

@Suite(.serialized)
@MainActor
struct ForgotPasswordTests {

    @Test
    func sendCode_withValidEmail_setsGoToCode() async {
        let vm = ForgotPasswordViewModel()

        vm.email = "banchetti.luc@gmail.com"

        await vm.sendCode()

        #expect(vm.goToCode == true)
        #expect(vm.errorMessage == nil)
        #expect(vm.isLoading == false)
    }
}
