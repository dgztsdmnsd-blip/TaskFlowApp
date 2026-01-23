//
//  ProfileView.swift
//  TaskFlow
//
//  Created by luc banchetti on 23/01/2026.
//

import SwiftUI

@MainActor
struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var vm: ProfileViewModel

    init(viewModel: ProfileViewModel) {
            _vm = StateObject(wrappedValue: viewModel)
        }

    var body: some View {
        NavigationStack {
            ZStack {
                if vm.isLoading {
                    ProgressView()
                } else if let error = vm.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                } else if let profile = vm.profile {
                    
                    Form {
                        Section("Identité") {
                            profileRow(label: "Prénom", value: profile.firstName)
                            profileRow(label: "Nom", value: profile.lastName)
                            profileRow(label: "Email", value: profile.email)
                        }
                        
                        Section("Compte") {
                            profileRow(label: "Profil", value: profile.profil=="MGR" ? "Manager":"Utilisateur")
                            profileRow(label: "Statut", value: profile.status=="ACTIVE" ? "Actif":"Inactif")
                        }
                        
                        Section("Dates") {
                            profileRow(
                                label: "Création",
                                value: profile.creationDateFormatted
                            )
                            
                            if let exit = profile.exitDate {
                                profileRow(label: "Sortie", value: exit)
                            } else {
                                profileRow(label: "Sortie", value: "-")
                            }
                            
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Mon profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.app.fill")
                            .foregroundStyle(.blue)
                    }
                }
            }
        }
        .onAppear {
            if vm.profile == nil {
                Task {
                    await vm.fetchProfile()
                }
            }
        }
    }


    private func profileRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.body)
        }
        .padding(.vertical, 4)
    }
}

extension ProfileViewModel {

    static func preview() -> ProfileViewModel {
        let vm = ProfileViewModel()
        vm.profile = ProfileResponse(
            id: 1,
            email: "john.doe@example.com",
            firstName: "John",
            lastName: "Doe",
            status: "ACTIVE",
            profil: "UTIL",
            creationDate: String("01/01/2026"),
            exitDate: nil
        )
        return vm
    }
}


#Preview {
    ProfileView(viewModel: ProfileViewModel.preview())
}
