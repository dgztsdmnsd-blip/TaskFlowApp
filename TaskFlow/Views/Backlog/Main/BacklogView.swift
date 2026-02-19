//
//  BacklogView.swift
//  TaskFlow
//
//  Created by luc banchetti on 05/02/2026.
//

import SwiftUI

struct BacklogView: View {

    // State
    @StateObject private var vm: ProjectListViewModel
    @EnvironmentObject private var sessionVM: SessionViewModel

    @State private var tags: [TagResponse] = []
    @State private var selectedTag: TagResponse? = nil
    @State private var isFiltering = false

    // Init
    init(etatUS: StoryStatus = .inProgress) {
        _vm = StateObject(wrappedValue: ProjectListViewModel())
    }

    init(vm: ProjectListViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }

    // Body
    var body: some View {
        VStack {

            // Filtre actif info
            tagsFilterInfo

            // Barre des tags
            tagsFilterBar

            if isFiltering {
                ProgressView("Filtrage…")
                    .padding(.top, 8)
            }

            content
        }
        .background(BackgroundView(ecran: .general))
        .task {
            guard !ProcessInfo.isRunningPreviews else { return }
            await vm.fetchActiveProjects()
            await loadTags()
        }
        .onReceive(NotificationCenter.default.publisher(for: .projectListShouldRefresh)) { _ in
            Task { await vm.fetchActiveProjects() }
        }
        .onReceive(NotificationCenter.default.publisher(for: .userStoryDidChange)) { _ in
            Task {
                if let selectedTag {
                    filterByTag(selectedTag)   // conserve filtre
                } else {
                    await vm.fetchActiveProjects()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .tagsDidChange)) { _ in
            Task {
                await loadTags()
            }
        }
    }

    // Content
    @ViewBuilder
    private var content: some View {

        if vm.isLoading {
            ProgressView()

        } else if let error = vm.errorMessage {
            Text(error)
                .foregroundColor(.red)
                .font(.caption)

        } else {
            ZStack {

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

    // API
    private func loadTags() async {
        do {
            tags = try await TagsService.shared.listTags()
        } catch {
            print("Erreur chargement tags:", error)
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

                // Tags API
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

    // Filter Logic
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

                print("TAG FILTER RESULT")
                print("projects:", impact.projects.map(\.id))
                print("stories:", impact.userStories.map(\.id))

            } catch {
                print("Erreur filtrage tag:", error)
            }
        }
    }
}
