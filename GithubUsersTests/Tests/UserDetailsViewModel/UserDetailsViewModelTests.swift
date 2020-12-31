//
//  UserDetailsViewModelTests.swift
//  GithubUsersTests
//
//  Created by Hasaan Ali on 30/12/2020.
//  Copyright © 2020 Hasaan Ali. All rights reserved.
//

@testable import GithubUsers
import XCTest

class UserDetailsViewModelTests: XCTestCase {

    var mockApiClient = MockGithubApiClient()
    var mockCoreDataManager = MockCoreDataManager()
    var testDetailsViewModelDelegate = TestUserDetailsViewModelDelegate()

    let id = 1
    let login = "user1login"
    let avatarUrl = "user1url"
    let defaultNotes = "user1notes"
    let image = CommonTestData.image

    enum UserType {
        case DefaultUser
        case NotesUser
        case InvertedUser(note: String)
    }

    /// Behaves like setup method
    func createUserDetailsViewModel(userType: UserType, unfilteredIndex: Int, visibleIndex: Int) -> UserDetailsViewModel {
        let visibleIndexPath = IndexPath(row: visibleIndex, section: 0)

        var userCellVM: UserCellViewModelProtocol
        switch userType {
        case .DefaultUser:
            let user = User(id: id, login: login, avatarUrl: avatarUrl, image: image)
            userCellVM = DefaultUserCellViewModel(user: user, unfilteredIndex: unfilteredIndex)
        case .NotesUser:
            let user = NotesUser(id: id, login: login, avatarUrl: avatarUrl, notes: defaultNotes, image: image)
            userCellVM = NotesUserCellViewModel(notesUser: user, unfilteredIndex: unfilteredIndex)
        case .InvertedUser(let notes):
            let user = InvertedUser(id: id, login: login, avatarUrl: avatarUrl, image: image, notes: notes)
            userCellVM = InvertedUserCellViewModel(invertedUser: user, unfilteredIndex: unfilteredIndex)
        }

        mockApiClient = MockGithubApiClient()
        mockCoreDataManager = MockCoreDataManager()
        testDetailsViewModelDelegate = TestUserDetailsViewModelDelegate()

        let userdetailsVM = UserDetailsViewModel(cellViewModel: userCellVM, indexPath: visibleIndexPath,
                                                 apiClient: mockApiClient, coredataManager: mockCoreDataManager)
        userdetailsVM.delegate = testDetailsViewModelDelegate

        return userdetailsVM
    }

    func createUserDetailsFrom(userDetailsVM: UserDetailsViewModel, following: Int, followers: Int) -> UserDetails {
        let userp = userDetailsVM.currentCellViewModel.userp
        var userDetails = UserDetails(id: userp.id, login: userp.login, avatarUrl: userp.avatarUrl)
        userDetails.followers = followers
        userDetails.following = following
        // add any other data we'll receive/decode from real API
        return userDetails
    }

    //MARK:- Fetching details - successful

    func testLoadsDetailsForDefaultUser() {
        let userdetailsVM = createUserDetailsViewModel(userType: .DefaultUser, unfilteredIndex: 0, visibleIndex: 0)
        let userDetails = createUserDetailsFrom(userDetailsVM: userdetailsVM, following: 31, followers: 32)
        mockApiClient.fetchDetailsApiResult = Result.success(userDetails)

        userdetailsVM.fetchDetails()

        verifyLoadsDetailsFor(detailsVM: userdetailsVM, following: userDetails.following, followers: userDetails.followers)
    }

    func testLoadsDetailsForNotesUser() {
        let userdetailsVM = createUserDetailsViewModel(userType: .NotesUser, unfilteredIndex: 0, visibleIndex: 0)
        let userDetails = createUserDetailsFrom(userDetailsVM: userdetailsVM, following: 3, followers: 322)
        mockApiClient.fetchDetailsApiResult = Result.success(userDetails)

        userdetailsVM.fetchDetails()

        verifyLoadsDetailsFor(detailsVM: userdetailsVM, following: userDetails.following, followers: userDetails.followers)
    }

    func testLoadsDetailsForInvertedUserWithNotes() {
        let userdetailsVM = createUserDetailsViewModel(userType: .InvertedUser(note: defaultNotes), unfilteredIndex: 0, visibleIndex: 0)
        let userDetails = createUserDetailsFrom(userDetailsVM: userdetailsVM, following: 323, followers: 6572)
        mockApiClient.fetchDetailsApiResult = Result.success(userDetails)

        userdetailsVM.fetchDetails()

        verifyLoadsDetailsFor(detailsVM: userdetailsVM, following: userDetails.following, followers: userDetails.followers)
    }

    func verifyLoadsDetailsFor(detailsVM: UserDetailsViewModel, following: Int?, followers: Int?) {
        wait(for: [testDetailsViewModelDelegate.onLoadDetailsSuccessExpec], timeout: 0.1)

        XCTAssertNotNil(testDetailsViewModelDelegate.lastUserDetails)

        // actual
        let actualUserDetails = testDetailsViewModelDelegate.lastUserDetails!
        // expected
        let userp = detailsVM.currentCellViewModel.userp

        // data
        XCTAssertEqual(actualUserDetails.id, userp.id)
        XCTAssertEqual(actualUserDetails.login, userp.login)
        XCTAssertEqual(actualUserDetails.avatarUrl, userp.avatarUrl) // not necessarily true in api tests
        XCTAssertEqual(actualUserDetails.image, userp.image)
        XCTAssertEqual(actualUserDetails.notes, detailsVM.notes)
        XCTAssertEqual(actualUserDetails.following, following)
        XCTAssertEqual(actualUserDetails.followers, followers)
    }

    func testLoadDetailsNetworkError() {
        XCTFail("not implemented")
    }

    func testLoadDetailsDecodingError() {
        XCTFail("not implemented")
    }

    //MARK:- Saving notes

    //MARK: Default & Notes users
    func testSavingNewNotesToDefaultUser() {
        let userdetailsVM = createUserDetailsViewModel(userType: .DefaultUser, unfilteredIndex: 5, visibleIndex: 5)

        let actualUserBeforeSave = userdetailsVM.currentCellViewModel.userp as! User // .DefaultUser above
        let actualUserCellVMBeforeSave = userdetailsVM.currentCellViewModel as! DefaultUserCellViewModel

        let newNotes = "somenewnotes"
        userdetailsVM.save(notes: newNotes)

        let expectedUser = NotesUser(user: actualUserBeforeSave, withNotes: newNotes) // TODO test separately
        let expectedUserCellVM = NotesUserCellViewModel(notesUser: expectedUser,
                                                        unfilteredIndex: actualUserCellVMBeforeSave.unfilteredIndex)

        // force-unwrap because it must have been set in createUserDetailsViewModel
        let testDelegate = userdetailsVM.delegate as! TestUserDetailsViewModelDelegate

        assert(testDelegate.calledOnCellViewModelChanged)
        XCTAssertNotNil(testDelegate.lastCellViewModelChangedTo)
        XCTAssertNotNil(testDelegate.lastCellViewModelChangedTo as? NotesUserCellViewModel)

        // Verify cellViewModel properties
        let actualUserCellVM = testDelegate.lastCellViewModelChangedTo as! NotesUserCellViewModel
        XCTAssertEqual(actualUserCellVM.unfilteredIndex, expectedUserCellVM.unfilteredIndex)

        XCTAssertNotNil(actualUserCellVM.userp as? NotesUser)
        let actualUser = actualUserCellVM.userp as! NotesUser
        XCTAssertEqual(actualUser, expectedUser)
    }

    func testSavingEmptyNotesToDefaultUser() {
        let userdetailsVM = createUserDetailsViewModel(userType: .DefaultUser, unfilteredIndex: 5, visibleIndex: 5) //non-forth index
        let actualUserBeforeSave = userdetailsVM.currentCellViewModel.userp as! User // .DefaultUser above
        let actualUserCellVMBeforeSave = userdetailsVM.currentCellViewModel as! DefaultUserCellViewModel

        let newNotes = ""
        userdetailsVM.save(notes: newNotes)

        // force-unwrap because it must have been set in createUserDetailsViewModel
        let testDelegate = userdetailsVM.delegate as! TestUserDetailsViewModelDelegate
        XCTAssertFalse(testDelegate.calledOnCellViewModelChanged)

        // Verify cellViewModel properties
        XCTAssertNotNil(userdetailsVM.currentCellViewModel as? DefaultUserCellViewModel)
        let actualUserCellVM = userdetailsVM.currentCellViewModel as! DefaultUserCellViewModel
        XCTAssertEqual(actualUserCellVM.unfilteredIndex, actualUserCellVMBeforeSave.unfilteredIndex)

        XCTAssertNotNil(actualUserCellVM.userp as? User)
        let actualUser = actualUserCellVM.userp as! User
        XCTAssertEqual(actualUser, actualUserBeforeSave)
    }

    func testSavingNewNotesToNotesUser() {
        let userdetailsVM = createUserDetailsViewModel(userType: .NotesUser, unfilteredIndex: 5, visibleIndex: 5)

        let actualUserBeforeSave = userdetailsVM.currentCellViewModel.userp as! NotesUser // .NotesUser above
        let actualUserCellVMBeforeSave = userdetailsVM.currentCellViewModel as! NotesUserCellViewModel

        let newNotes = "somenewnotes"
        XCTAssertNotEqual(newNotes, defaultNotes)

        userdetailsVM.save(notes: newNotes)

        let expectedUser = NotesUser(notesUser: actualUserBeforeSave, withNotes: newNotes) // TODO test separately
        let expectedUserCellVM = NotesUserCellViewModel(notesUser: expectedUser,
                                                        unfilteredIndex: actualUserCellVMBeforeSave.unfilteredIndex)

        // force-unwrap because it must have been set in createUserDetailsViewModel
        let testDelegate = userdetailsVM.delegate as! TestUserDetailsViewModelDelegate

        assert(testDelegate.calledOnCellViewModelChanged)
        XCTAssertNotNil(testDelegate.lastCellViewModelChangedTo)
        XCTAssertNotNil(testDelegate.lastCellViewModelChangedTo as? NotesUserCellViewModel)

        // Verify cellViewModel properties
        let actualUserCellVM = testDelegate.lastCellViewModelChangedTo as! NotesUserCellViewModel
        XCTAssertEqual(actualUserCellVM.unfilteredIndex, expectedUserCellVM.unfilteredIndex)

        XCTAssertNotNil(actualUserCellVM.userp as? NotesUser)
        let actualUser = actualUserCellVM.userp as! NotesUser
        XCTAssertEqual(actualUser, expectedUser)
    }

    func testSavingSameNotesToNotesUser() {
        let userdetailsVM = createUserDetailsViewModel(userType: .NotesUser, unfilteredIndex: 5, visibleIndex: 5) //non-forth index
        let actualUserBeforeSave = userdetailsVM.currentCellViewModel.userp as! NotesUser // .DefaultUser above
        let actualUserCellVMBeforeSave = userdetailsVM.currentCellViewModel as! NotesUserCellViewModel

        let newNotes = defaultNotes
        userdetailsVM.save(notes: newNotes)

        // force-unwrap because it must have been set in createUserDetailsViewModel
        let testDelegate = userdetailsVM.delegate as! TestUserDetailsViewModelDelegate
        XCTAssertFalse(testDelegate.calledOnCellViewModelChanged)

        // Verify cellViewModel properties
        XCTAssertNotNil(userdetailsVM.currentCellViewModel as? NotesUserCellViewModel)
        let actualUserCellVM = userdetailsVM.currentCellViewModel as! NotesUserCellViewModel
        XCTAssertEqual(actualUserCellVM.unfilteredIndex, actualUserCellVMBeforeSave.unfilteredIndex)

        XCTAssertNotNil(actualUserCellVM.userp as? NotesUser)
        let actualUser = actualUserCellVM.userp as! NotesUser
        XCTAssertEqual(actualUser, actualUserBeforeSave)
    }

    func testSavingClearedNotesToNotesUser() {
        let userdetailsVM = createUserDetailsViewModel(userType: .NotesUser, unfilteredIndex: 5, visibleIndex: 5) //non-forth index
        let actualUserBeforeSave = userdetailsVM.currentCellViewModel.userp as! NotesUser // .NotesUser above
        let actualUserCellVMBeforeSave = userdetailsVM.currentCellViewModel as! NotesUserCellViewModel

        let newNotes = ""
        userdetailsVM.save(notes: newNotes)

        let expectedUser = User(notesUser: actualUserBeforeSave)
        let expectedUserCellVM = DefaultUserCellViewModel(user: expectedUser,
                                                        unfilteredIndex: actualUserCellVMBeforeSave.unfilteredIndex)

        // force-unwrap because it must have been set in createUserDetailsViewModel
        let testDelegate = userdetailsVM.delegate as! TestUserDetailsViewModelDelegate

        assert(testDelegate.calledOnCellViewModelChanged)
        XCTAssertNotNil(testDelegate.lastCellViewModelChangedTo)
        XCTAssertNotNil(testDelegate.lastCellViewModelChangedTo as? DefaultUserCellViewModel)

        // Verify cellViewModel properties
        let actualUserCellVM = testDelegate.lastCellViewModelChangedTo as! DefaultUserCellViewModel
        XCTAssertEqual(actualUserCellVM.unfilteredIndex, expectedUserCellVM.unfilteredIndex)

        XCTAssertNotNil(actualUserCellVM.userp as? User)
        let actualUser = actualUserCellVM.userp as! User
        XCTAssertEqual(actualUser, expectedUser)
    }

    //MARK: Inverted users

    // empty -> empty
    func testSavingEmptyNotesToInvertedUserWithEmptyNotes() {
        verifySavingSameNotesToInvertedUser(sameInitialAndNewNotes: "")
    }

    // some -> some
    func testSavingSameNotesToInvertedUserWithSomeNotes() {
        verifySavingSameNotesToInvertedUser(sameInitialAndNewNotes: "abcxyz123")
    }

    func verifySavingSameNotesToInvertedUser(sameInitialAndNewNotes: String) {
        let userdetailsVM = createUserDetailsViewModel(userType: .InvertedUser(note: sameInitialAndNewNotes), unfilteredIndex: 3, visibleIndex: 3) //forth index
        let actualUserBeforeSave = userdetailsVM.currentCellViewModel.userp as! InvertedUser // .DefaultUser above
        let actualUserCellVMBeforeSave = userdetailsVM.currentCellViewModel as! InvertedUserCellViewModel


        userdetailsVM.save(notes: sameInitialAndNewNotes)

        // force-unwrap because it must have been set in createUserDetailsViewModel
        let testDelegate = userdetailsVM.delegate as! TestUserDetailsViewModelDelegate
        XCTAssertFalse(testDelegate.calledOnCellViewModelChanged)

        // Verify cellViewModel properties
        XCTAssertNotNil(userdetailsVM.currentCellViewModel as? InvertedUserCellViewModel)
        let actualUserCellVM = userdetailsVM.currentCellViewModel as! InvertedUserCellViewModel
        XCTAssertEqual(actualUserCellVM.unfilteredIndex, actualUserCellVMBeforeSave.unfilteredIndex)

        XCTAssertNotNil(actualUserCellVM.userp as? InvertedUser)
        let actualUser = actualUserCellVM.userp as! InvertedUser
        XCTAssertEqual(actualUser, actualUserBeforeSave)
    }

    // empty -> some
    func testSavingSomeNotesToInvertedUserWithEmptyNotes() {
        verifySavingDifferentNotesToInvertedUser(initialNotes: "", newNotes: "somenewnotes")
    }

    // some -> empty
    func testSavingEmptyNotesToInvertedUserWithSomeNotes() {
        verifySavingDifferentNotesToInvertedUser(initialNotes: "someintialnotes", newNotes: "")
    }

    // some -> somenew
    func testSavingSomeNewNotesToInvertedUserWithSomeNotes() {
        verifySavingDifferentNotesToInvertedUser(initialNotes: "someintialnotes", newNotes: "somenewnotes")
    }


    func verifySavingDifferentNotesToInvertedUser(initialNotes: String, newNotes: String) {
        XCTAssertNotEqual(initialNotes, newNotes, "this method should be used only for changing notes scenarios")
        let userdetailsVM = createUserDetailsViewModel(userType: .InvertedUser(note: initialNotes), unfilteredIndex: 3, visibleIndex: 3) //forth index
        let actualUserBeforeSave = userdetailsVM.currentCellViewModel.userp as! InvertedUser // .DefaultUser above
        let actualUserCellVMBeforeSave = userdetailsVM.currentCellViewModel as! InvertedUserCellViewModel


        userdetailsVM.save(notes: newNotes)


        let expectedUser = actualUserBeforeSave.changing(notes: newNotes)
        let expectedUserCellVM = InvertedUserCellViewModel(invertedUser: expectedUser,
                                                        unfilteredIndex: actualUserCellVMBeforeSave.unfilteredIndex)

        // force-unwrap because it must have been set in createUserDetailsViewModel
        let testDelegate = userdetailsVM.delegate as! TestUserDetailsViewModelDelegate

        assert(testDelegate.calledOnCellViewModelChanged)
        XCTAssertNotNil(testDelegate.lastCellViewModelChangedTo)
        XCTAssertNotNil(testDelegate.lastCellViewModelChangedTo as? InvertedUserCellViewModel)

        // Verify cellViewModel properties
        let actualUserCellVM = testDelegate.lastCellViewModelChangedTo as! InvertedUserCellViewModel
        XCTAssertEqual(actualUserCellVM.unfilteredIndex, expectedUserCellVM.unfilteredIndex)

        XCTAssertNotNil(actualUserCellVM.userp as? InvertedUser)
        let actualUser = actualUserCellVM.userp as! InvertedUser
        XCTAssertEqual(actualUser, expectedUser)
    }


    func testUserDetailsVMKeepsCorrectPositioningInfo() {
//        let userdetailsVM = createUserDetailsViewModel(userType: .DefaultUser, positionInData: 23, visiblePosition: 23)
        //        assert(<#T##condition: Bool##Bool#>, <#T##message: String##String#>)
    }

    /**
     TODO:
     assert notes change is updated in db
     assert the tappped/visible index path is unchanged (e.g in all tests or separate test)
     loading details for user without image (e.g not fetched yet)
     loading details for user with image

     test basics: login, url

     verify details delegate is called when loads details is success
     when network error
     when decoding error

     */
}
