//
//  ForgotPassword.swift
//  TaskFlow
//
//  Created by luc banchetti on 03/03/2026.
//

import Testing
import Foundation
@testable import TaskFlow

@MainActor
struct RegisterIntegrationTests {

    @Test
    func register_createMode_success() async {
        let vm = RegisterViewModel(mode: .create)


        vm.firstName = "Luc"
        vm.lastName = "Banchetti"
        vm.email = "banchetti.luc@gmail.com"
        vm.password = "PassTemp123!"
        vm.password2 = "PassTemp123!"

        await vm.submit()

        #expect(vm.isSuccess == true)
        #expect(vm.errorMessage == nil)
        #expect(vm.isLoading == false)
    }
}
