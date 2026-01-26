//
//  ProfileView.swift
//  TaskFlow
//
//  Created by luc banchetti on 23/01/2026.
//
//  Vue affichant le profil utilisateur.
//  Elle est présentée en sheet depuis MainView
//  et consomme un ProfileViewModel injecté.
//

import SwiftUI

@MainActor
struct ProfileView: View {

    // Permet de fermer la sheet (dismiss)
    @Environment(\.dismiss) private var dismiss

    // ViewModel du profil.
    @StateObject private var vm: ProfileViewModel

    // Initialiseur custom pour accepter un ViewModel externe
    init(viewModel: ProfileViewModel) {
        _vm = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ZStack {

                /// Etats de la vue
                if vm.isLoading {
                    // Chargement en cours
                    ProgressView()

                } else if let error = vm.errorMessage {
                    // Erreur métier ou réseau
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)

                } else if let profile = vm.profile {
                    /// Contenu du profil
                    Form {

                        // Section identité utilisateur
                        Section("Identité") {
                            profileRow(label: "Prénom", value: profile.firstName)
                            profileRow(label: "Nom", value: profile.lastName)
                            profileRow(label: "Email", value: profile.email)
                        }

                        // Section informations de compte
                        Section("Compte") {
                            profileRow(
                                label: "Profil",
                                value: profile.profil == "MGR"
                                    ? "Manager"
                                    : "Utilisateur"
                            )

                            profileRow(
                                label: "Statut",
                                value: profile.status == "ACTIVE"
                                    ? "Actif"
                                    : "Inactif"
                            )
                        }

                        // Section dates importantes
                        Section("Dates") {
                            profileRow(
                                label: "Création",
                                value: profile.creationDateFormatted
                            )

                            // Date de sortie optionnelle
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

            // Bouton de fermeture de la sheet
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
            // On charge le profil uniquement s’il n’est pas déjà présent.
            if vm.profile == nil {
                Task {
                    await vm.fetchProfile()
                }
            }
        }
    }

    /// Affichage d'une ligne
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

    /// ViewModel mocké pour les previews SwiftUI
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
