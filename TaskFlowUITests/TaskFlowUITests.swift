//
//  TaskFlowUITests.swift
//  TaskFlowUITests
//
//  Created by luc banchetti on 04/03/2026.
//

import XCTest

final class TaskFlowUITests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    
     @MainActor
     func testLaunchPerformance() throws {
         // This measures how long it takes to launch your application.
         measure(metrics: [XCTApplicationLaunchMetric()]) {
         XCUIApplication().launch()
         }
     }
     
     @MainActor
     func testForgotPassword() throws {
         let app = XCUIApplication()
         app.launch()
         
         // attente login
         let loginTitle = app.staticTexts["Bienvenue sur TaskFlow"]
         XCTAssertTrue(loginTitle.waitForExistence(timeout: 5))
         
         // Tap du bouton Connexion
         let registerButton = app.buttons["Connexion"]
         registerButton.tap()
         
         // Tap du bouton Mot de passe oublié
         let passwordButton = app.buttons["Mot de passe oublié ?"]
         passwordButton.tap()
         
         // attendre écran Taskflow
         let passwordTitle = app.staticTexts["Mot de passe oublié"]
         XCTAssertTrue(passwordTitle.waitForExistence(timeout: 10))
         
         // Remplir l'email
         let email = app.textFields["password.email"]
         XCTAssertTrue(email.waitForExistence(timeout: 10), app.debugDescription)
         email.tap()
         email.typeText("banchetti.luc@gmail.com")
         
         // Tap du bouton Envoyer le code
         let codeButton = app.buttons["Envoyer le code"]
         codeButton.tap()
         
         // attendre écran Valider le code
         let validerTitle = app.staticTexts["Validation du code"]
         XCTAssertTrue(validerTitle.waitForExistence(timeout: 10))
     }
     
     
     @MainActor
     func testGoToRegister() throws {
         let app = XCUIApplication()
         app.launch()
         
         // attente login
         let loginTitle = app.staticTexts["Bienvenue sur TaskFlow"]
         XCTAssertTrue(loginTitle.waitForExistence(timeout: 5))
         
         // Tap du bouton inscription
         let registerButton = app.buttons["Inscription"]
         registerButton.tap()
         
         // attendre écran register
         let sectionIdentite = app.staticTexts["Identité"]
         XCTAssertTrue(sectionIdentite.waitForExistence(timeout: 10))
     }
    
     
    @MainActor
    func testHappyFlow() throws {
        
        let app = XCUIApplication()
        app.launchArguments += ["-UITests", "-disableAnimations"]
        app.launch()
        
        // Test de la connexion
        loginTest(app: app)
        
        // Clic sur plus tard
        removePlusTardTest(app: app)
        
        // Test du module projet
        projectsTests(app: app)
        
        // Tests du module utilisateur
        usersTests(app: app)
        
        // Test du module backlog
        backlogTests(app: app)
        
        // Test du profil et deconnexion
        profileTests(app: app)
    }
    
    
    // Connexion
    func loginTest(app: XCUIApplication) {
        // attente login
        let loginTitle = app.staticTexts["Bienvenue sur TaskFlow"]
        XCTAssertTrue(loginTitle.waitForExistence(timeout: 5))
        
        // Tap du bouton Connexion
        let registerButton = app.buttons["Connexion"]
        registerButton.tap()
        
        // Remplir l'email
        let email = app.textFields["login.email"]
        XCTAssertTrue(email.waitForExistence(timeout: 10), app.debugDescription)
        email.tap()
        email.typeText("banchetti.luc@gmail.com")
        
        // Remplir le password
        let password = app.secureTextFields["login.password"]
        XCTAssertTrue(password.waitForExistence(timeout: 10))
        password.tap()
        password.typeText("PassTemp123!")
        
        // Tap connexion
        let submit = app.buttons["login.connexion"]
        XCTAssertTrue(submit.waitForExistence(timeout: 10))
        submit.tap()
        
        // attente login
        let backlogTitle = app.staticTexts["Backlog"]
        XCTAssertTrue(backlogTitle.waitForExistence(timeout: 5))
    }
    
    
    // Tab Utilisateurs
    func usersTests (app: XCUIApplication) {
        // Attendre que la tab bar existe
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 10), app.debugDescription)
        
        // Tap Users
        let usersTab = tabBar.buttons["mainview.users"]
        XCTAssertTrue(usersTab.waitForExistence(timeout: 10), tabBar.debugDescription)
        usersTab.tap()
        
        // Attente que la liste users redevienne interactive
        let loading = app.activityIndicators.firstMatch
        if loading.exists {
            _ = loading.waitForExistence(timeout: 5)
        }
        
        // sélectionner le premier utilisateur
        if app.tables.count > 0 {
            let table = app.tables.firstMatch
            XCTAssertTrue(table.waitForExistence(timeout: 10), app.debugDescription)
            
            let firstCell = table.cells.firstMatch
            XCTAssertTrue(firstCell.waitForExistence(timeout: 10), app.debugDescription)
            firstCell.tap()
            
        } else {
            let collection = app.collectionViews.firstMatch
            XCTAssertTrue(collection.waitForExistence(timeout: 10), app.debugDescription)
            
            let firstCell = collection.cells.firstMatch
            XCTAssertTrue(firstCell.waitForExistence(timeout: 10), app.debugDescription)
            firstCell.tap()
        }

        // Attribution de projet
        let AttribuerButton = app.buttons["user.attribuer"]
        XCTAssertTrue(AttribuerButton.waitForExistence(timeout: 10))
        AttribuerButton.tap()
        
        // Detail du projet
        let attribTitle = app.staticTexts["Projets"]
        XCTAssertTrue(attribTitle.waitForExistence(timeout: 5))
        
        // Fermeture de l'écran
        let attribButton = app.buttons["attribuer.close"].firstMatch
        XCTAssertTrue(attribButton.waitForExistence(timeout: 10), app.debugDescription)
        attribButton.tap()
    }
    
    
    // Tab projets
    func projectsTests(app: XCUIApplication) {
        // Attendre que la tab bar existe
        let tabBar2 = app.tabBars.firstMatch
        XCTAssertTrue(tabBar2.waitForExistence(timeout: 10), app.debugDescription)
        
        // Tap Projects
        let projectsTab = app.tabBars.buttons["mainview.projects"].firstMatch
        XCTAssertTrue(projectsTab.waitForExistence(timeout: 10), app.debugDescription)
        projectsTab.tap()
        
        // Create Modifier
        let CreateButton = app.buttons["project.create"]
        XCTAssertTrue(CreateButton.waitForExistence(timeout: 10))
        CreateButton.tap()
        
        let unique = UUID().uuidString.prefix(5)
        
        // titre projet
        let titreProjet = app.textFields["project.titre"]
        XCTAssertTrue(titreProjet.waitForExistence(timeout: 10), app.debugDescription)
        titreProjet.tap()
        titreProjet.typeText("Projet \(unique)")
        
        // description projet
        let descProjet = app.textViews["project.texte"].firstMatch
        XCTAssertTrue(descProjet.waitForExistence(timeout: 10), app.debugDescription)
        descProjet.tap()
        descProjet.tap()
        descProjet.typeText("Description du projet")
        
        // Création du projet
        let CloseButton = app.buttons["project.creation"]
        XCTAssertTrue(CloseButton.waitForExistence(timeout: 10))
        CloseButton.tap()
        
        // Attente que l'écran "Création de projet" disparaisse
        XCTAssertFalse(app.staticTexts["Création de projet"].waitForExistence(timeout: 10))
        
        // Attente que la liste projets redevienne interactive
        let loading = app.activityIndicators.firstMatch
        if loading.exists {
            _ = loading.waitForExistence(timeout: 5)
        }
        
        // sélectionner le premier projet
        if app.tables.count > 0 {
            let table = app.tables.firstMatch
            XCTAssertTrue(table.waitForExistence(timeout: 10), app.debugDescription)
            
            let firstCell = table.cells.firstMatch
            XCTAssertTrue(firstCell.waitForExistence(timeout: 10), app.debugDescription)
            firstCell.tap()
            
        } else {
            let collection = app.collectionViews.firstMatch
            XCTAssertTrue(collection.waitForExistence(timeout: 10), app.debugDescription)
            
            let firstCell = collection.cells.firstMatch
            XCTAssertTrue(firstCell.waitForExistence(timeout: 10), app.debugDescription)
            firstCell.tap()
        }
        
        // Detail du projet
        let projectDetailTitle = app.staticTexts["Détail du projet"]
        XCTAssertTrue(projectDetailTitle.waitForExistence(timeout: 5))
        
        // Tap Modifier
        let updateStatusButton = app.buttons["project.status"].firstMatch
        XCTAssertTrue(updateStatusButton.waitForExistence(timeout: 10), app.debugDescription)
        updateStatusButton.tap()
        
        // Tap Modifier
        let projModButton = app.buttons["project.modifier"].firstMatch
        XCTAssertTrue(projModButton.waitForExistence(timeout: 10), app.debugDescription)
        projModButton.tap()
        
        // Detail du projet
        let projectModTitle = app.staticTexts["Modifier le projet"]
        XCTAssertTrue(projectModTitle.waitForExistence(timeout: 5))
        
        // Fermeture de l'écran
        let projModCloseButton = app.buttons["project.mod.close"].firstMatch
        XCTAssertTrue(projModCloseButton.waitForExistence(timeout: 10), app.debugDescription)
        projModCloseButton.tap()
    }
    
    
    // Tab Backlog
    func backlogTests(app: XCUIApplication) {
        // Attendre que la tab bar existe
        let tabBar3 = app.tabBars.firstMatch
        XCTAssertTrue(tabBar3.waitForExistence(timeout: 10), app.debugDescription)
        
        // Tap Backlob
        let backlogTab = app.tabBars.buttons["mainview.backlog"].firstMatch
        XCTAssertTrue(backlogTab.waitForExistence(timeout: 10), app.debugDescription)
        backlogTab.tap()
        
        userStoryCreationTest(app: app)
        
        taskCreationTest(app: app)
        
        tagCreationTest(app: app)
        
        // Fermeture de l'écran
        let projModCloseButton = app.buttons["us.detail.close"].firstMatch
        XCTAssertTrue(projModCloseButton.waitForExistence(timeout: 10), app.debugDescription)
        projModCloseButton.tap()
    }
    
    
    // Création et sélection de la User Story
    func userStoryCreationTest(app: XCUIApplication) {
        // Tap Modifier
        let newUSButton = app.buttons["add.userstory"].firstMatch
        XCTAssertTrue(newUSButton.waitForExistence(timeout: 10), app.debugDescription)
        newUSButton.tap()
        
        let unique = UUID().uuidString.prefix(5)
        
        // titre US
        let titreUS = app.textFields["us.titre"]
        XCTAssertTrue(titreUS.waitForExistence(timeout: 10), app.debugDescription)
        titreUS.tap()
        let usTitle = "US \(unique)"
        titreUS.typeText(usTitle)
        
        // description US
        let descUS = app.textViews["us.desc"].firstMatch
        XCTAssertTrue(descUS.waitForExistence(timeout: 10), app.debugDescription)
        descUS.tap()
        descUS.tap()
        descUS.typeText("Description de la US")
        
        // Création de la US
        let CloseButton = app.buttons["us.enregistrer"]
        XCTAssertTrue(CloseButton.waitForExistence(timeout: 10))
        CloseButton.tap()
        
        // Vérifie que la carte apparait dans le backlog
        let createdStoryCard = app.otherElements["backlog.story.title.\(usTitle)"].firstMatch
        XCTAssertTrue(createdStoryCard.waitForExistence(timeout: 10), app.debugDescription)
        
        // Ouvre la story
        createdStoryCard.tap()
        
        // Detail de la US
        let usDetTitle = app.staticTexts["User Story"]
        XCTAssertTrue(usDetTitle.waitForExistence(timeout: 5))
    }
    
    
    // Création de la tâche
    func taskCreationTest(app: XCUIApplication) {
        let unique = UUID().uuidString.prefix(5)
        
        // Création de la tâche
        let TaskaddButton = app.buttons["us.task.ajouter"]
        XCTAssertTrue(TaskaddButton.waitForExistence(timeout: 10))
        TaskaddButton.tap()
        
        // Test Titre de l'écran tâche
        let taskaddTitle = app.staticTexts["Nouvelle tâche"]
        XCTAssertTrue(taskaddTitle.waitForExistence(timeout: 5))
        
        // titre de la tâche
        let titreTask = app.textFields["task.titre"]
        XCTAssertTrue(titreTask.waitForExistence(timeout: 10), app.debugDescription)
        titreTask.tap()
        let taskTitle = "Task \(unique)"
        titreTask.typeText(taskTitle)
        
        // description de la tâche
        let descTask = app.textViews["task.desc"].firstMatch
        XCTAssertTrue(descTask.waitForExistence(timeout: 10), app.debugDescription)
        descTask.tap()
        descTask.tap()
        descTask.typeText("Description de la tâche")
        
        // type Task
        let typeTask = app.textViews["task.type"].firstMatch
        XCTAssertTrue(typeTask.waitForExistence(timeout: 10), app.debugDescription)
        typeTask.tap()
        typeTask.tap()
        typeTask.typeText("Type de la tâche")
        
        // Enregistrement de la tâche
        let TaskSaveButton = app.buttons["task.save"]
        XCTAssertTrue(TaskSaveButton.waitForExistence(timeout: 10))
        TaskSaveButton.tap()
    }
    
    
    // Création du Tag
    func tagCreationTest(app: XCUIApplication) {
        let unique = UUID().uuidString.prefix(5)
        
        // Ajout d'un tag à la US
        let TagaddButton = app.buttons["us.tag.ajouter"]
        XCTAssertTrue(TagaddButton.waitForExistence(timeout: 10))
        TagaddButton.tap()
        
        // Test Titre de l'écran de sélection des tags
        let tagSelTitle = app.staticTexts["Sélectionner un tag"]
        XCTAssertTrue(tagSelTitle.waitForExistence(timeout: 5))
        
        // Création du tag
        let TagNewButton = app.buttons["tag.nouveau"]
        XCTAssertTrue(TagNewButton.waitForExistence(timeout: 10))
        TagNewButton.tap()
        
        // Test Titre de création du tag
        let tagNewTitle = app.staticTexts["Créer Tag"]
        XCTAssertTrue(tagNewTitle.waitForExistence(timeout: 5))
        
        // titre de la tâche
        let tagName = app.textFields["tag.name"]
        XCTAssertTrue(tagName.waitForExistence(timeout: 10), app.debugDescription)
        tagName.tap()
        tagName.typeText("\(unique)")
        
        let TagCreationButton = app.buttons["tag.creer"]
        XCTAssertTrue(TagCreationButton.waitForExistence(timeout: 10))
        TagCreationButton.tap()
        
        // Fermeture du tag
        let TagCloseButton = app.buttons["tag.close"]
        XCTAssertTrue(TagCloseButton.waitForExistence(timeout: 10))
        TagCloseButton.tap()
    }
    
    
    // Enlève l'écran d'enregistrement de password
    func removePlusTardTest(app: XCUIApplication) {
        // Attendre que la tab bar existe
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 10), app.debugDescription)
        
        // Tap Projects
        let usersTab = tabBar.buttons["mainview.users"]
        XCTAssertTrue(usersTab.waitForExistence(timeout: 10), tabBar.debugDescription)
        usersTab.tap()
    }
    
    
    // Profil utilisateur
    func profileTests(app: XCUIApplication) {
        
        // Tap Profile
        let profileButton = app.buttons["mainview.profile"]
        XCTAssertTrue(profileButton.waitForExistence(timeout: 10))
        profileButton.tap()
        profileButton.tap()
        
        // attente Profile
        let profileTitle = app.staticTexts["Mon profil"]
        XCTAssertTrue(profileTitle.waitForExistence(timeout: 10))
        
        // Tap Modifier
        let profileModButton = app.buttons["profile.modifier"]
        XCTAssertTrue(profileModButton.waitForExistence(timeout: 10))
        profileModButton.tap()
        
        // attente Profile Edit
        let profileEditTitle = app.staticTexts["Modifier mon profil"]
        XCTAssertTrue(profileEditTitle.waitForExistence(timeout: 5))
        
        // Tap Modifier
        let RegisterDecoButton = app.buttons["register.close"]
        XCTAssertTrue(RegisterDecoButton.waitForExistence(timeout: 10))
        RegisterDecoButton.tap()
        
        // Tap Deconnexion
        let profileDecoButton = app.buttons["profile.deconnexion"]
        XCTAssertTrue(profileDecoButton.waitForExistence(timeout: 10))
        profileDecoButton.tap()
    }
    
    
}
