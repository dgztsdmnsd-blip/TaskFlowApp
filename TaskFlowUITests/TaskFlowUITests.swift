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
    
    func backlogTests(app: XCUIApplication) {
        // Attendre que la tab bar existe
        let tabBar3 = app.tabBars.firstMatch
        XCTAssertTrue(tabBar3.waitForExistence(timeout: 10), app.debugDescription)
        
        // Tap Backlob
        let backlogTab = app.tabBars.buttons["mainview.backlog"].firstMatch
        XCTAssertTrue(backlogTab.waitForExistence(timeout: 10), app.debugDescription)
        backlogTab.tap()
    }
    
    
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
    
    
    func removePlusTardTest(app: XCUIApplication) {
        // Attendre que la tab bar existe
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 10), app.debugDescription)
        
        // Tap Projects
        let usersTab = tabBar.buttons["mainview.users"]
        XCTAssertTrue(usersTab.waitForExistence(timeout: 10), tabBar.debugDescription)
        usersTab.tap()
    }
    
    
}
