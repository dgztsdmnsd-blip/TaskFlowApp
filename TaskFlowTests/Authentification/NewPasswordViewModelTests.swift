//
//  NewPasswordViewModelTests.swift
//  TaskFlow
//
//  Created by luc banchetti on 27/02/2026.
//
//  Tests Automatiques Modification du password
//

import Testing
@testable import TaskFlow

@MainActor
struct NewPasswordViewModelTests {

    // OK si le mot de passe et confimation identique avec plus de 8 char
    @Test
    func isFormValid_whenPasswordsMatchAndMinLength_returnsTrue() {
        let vm = NewPasswordViewModel(token: "token")
        vm.password = "abcdefgh"
        vm.password2 = "abcdefgh"

        #expect(vm.isFormValid == true)
    }

    // KO si le mot de passe et confimation différentes
    @Test
    func isFormValid_whenPasswordsDifferent_returnsFalse() {
        let vm = NewPasswordViewModel(token: "token")
        vm.password = "abcdefhg"
        vm.password2 = "abcdeghg"

        #expect(vm.isFormValid == false)
    }

    // KO si le mot de passe et confimation identique avec moins de 8 char
    @Test
    func isFormValid_whenTooShort_returnsFalse() {
        let vm = NewPasswordViewModel(token: "token")
        vm.password = "abc"
        vm.password2 = "abc"

        #expect(vm.isFormValid == false)
    }
    
    // KO si password vide
    @Test
    func isFormValid_whenPasswordEmpty_returnsFalse() {
        let vm = NewPasswordViewModel(token: "token")
        vm.password = ""
        vm.password2 = ""

        #expect(vm.isFormValid == false)
    }
}
