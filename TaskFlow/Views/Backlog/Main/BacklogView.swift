//
//  BacklogView.swift
//  TaskFlow
//
//  Created by luc banchetti on 05/02/2026.
//
//  Écran Backlog.
//  Affiche les projets actifs et permet le filtrage par tags.
//

import SwiftUI

struct BacklogView: View {

    // ViewModel principal de la liste projets
    @StateObject private var vm: ProjectListViewModel

    // Session utilisateur globale
    @EnvironmentObject private var sessionVM: SessionViewModel

    // State (UI)
    @State private var tags: [TagResponse] = []
    @State private var selectedTag: TagResponse? = nil
    @State private var isFiltering = false

    // Initialisation
    init(etatUS: StoryStatus = .inProgress) {
        _vm = StateObject(wrappedValue: ProjectListViewModel())
    }

    init(vm: ProjectListViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }

    // Body
    var body: some View {
        VStack {

            // Info filtre actif
            tagsFilterInfo

            // Barre des tags
            tagsFilterBar

            // Indicateur filtrage
            if isFiltering {
                ProgressView("Filtrage…")
                    .padding(.top, 8)
            }

            // Contenu principal
            content
        }
        .background(BackgroundView(ecran: .general))

        // Chargement initial
        .task {
            await vm.fetchActiveProjects()
            await loadTags()
        }
        // Notifications
        // Rafraîchissement projets
        .onReceive(NotificationCenter.default.publisher(for: .projectListShouldRefresh)) { _ in
            Task { await vm.fetchActiveProjects() }
        }
        // Mise à jour User Stories
        .onReceive(NotificationCenter.default.publisher(for: .userStoryDidChange)) { _ in
            Task {
                if let selectedTag {
                    filterByTag(selectedTag)   // conserve filtre
                } else {
                    await vm.fetchActiveProjects()
                }
            }
        }
        // Mise à jour Tags
        .onReceive(NotificationCenter.default.publisher(for: .tagsDidChange)) { _ in
            Task { await loadTags() }
        }
    }
    
    // Content
    @ViewBuilder
    private var content: some View {

        if vm.isLoading {

            // Chargement API
            ProgressView()

        } else if let error = vm.errorMessage {

            // Message d’erreur
            Text(error)
                .foregroundColor(.red)
                .font(.caption)

        } else {

            ZStack {

                // Liste projets
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(vm.projects) { project in
                            BacklogProjetsView(
                                project: project,
                                isOwner: project.owner.id == sessionVM.currentUser?.id,
                                filteredStories: vm.filteredStories
                            )
                            .padding()
                        }
                    }
                }

                // État vide après filtrage
                if vm.projects.isEmpty {
                    VStack(spacing: 12) {

                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)

                        Text("Aucun résultat pour ce tag")
                            .font(.headline)

                        Text("Essayez un autre filtre")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                    .transition(.opacity)
                }
            }
        }
    }

    // Chargement des tags disponibles
    private func loadTags() async {
        do {
            tags = try await TagsService.shared.listTags()
        } catch {
            if AppConfig.version == .dev {
                print("Erreur chargement tags:", error)
            }
        }
    }

    // Tags Filter Bar
    private var tagsFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {

                // Reset filtre
                TagFilterChip(
                    title: "Tous",
                    isSelected: selectedTag == nil
                ) {
                    selectedTag = nil

                    Task {
                        await vm.fetchActiveProjects()

                        await MainActor.run {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                vm.isTagFilterActive = false
                                vm.filteredStories = nil
                            }
                        }
                    }
                }

                // Tags dynamiques API
                ForEach(tags) { tag in
                    TagFilterChip(
                        title: tag.tagName,
                        color: Color(hex: tag.couleur),
                        isSelected: selectedTag?.id == tag.id
                    ) {
                        selectedTag = tag
                        filterByTag(tag)
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    // Filter Info
    private var tagsFilterInfo: some View {
        Group {
            if let activeTag = selectedTag {

                HStack(spacing: 8) {

                    Image(systemName: "line.3.horizontal.decrease.circle.fill")
                        .foregroundColor(.secondary)

                    Text("Filtré par :")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    TagBadgeMiniView(tag: activeTag)

                    Spacer()

                    // Bouton reset filtre
                    Button {
                        selectedTag = nil
                        Task {
                            await vm.fetchActiveProjects()

                            await MainActor.run {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    vm.isTagFilterActive = false
                                    vm.filteredStories = nil
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 6)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    // Filtrage projets / stories par tag
    private func filterByTag(_ tag: TagResponse) {
        Task {
            isFiltering = true
            defer { isFiltering = false }

            do {
                let impact = try await TagsService.shared.fetchTagImpact(tagId: tag.id)

                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        vm.isTagFilterActive = true
                        vm.projects = impact.projects
                        vm.filteredStories = impact.userStories
                    }
                }

                if AppConfig.version == .dev {
                    print("TAG FILTER RESULT")
                    print("projects:", impact.projects.map(\.id))
                    print("stories:", impact.userStories.map(\.id))
                }

            } catch {
                if AppConfig.version == .dev {
                    print("Erreur filtrage tag:", error)
                }
            }
        }
    }
}
