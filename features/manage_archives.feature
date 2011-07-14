Feature: Manage Archives
In order to manage archives crawled from internet
As a administrator
I want to manage archives

  Scenario: Audit new archives
    Given New archives need to be audited
    When Admin selecte one archive to audit
    Then Admin can edit the archive
    When Admin approved the archive that he is auditing
    Then Archive should be available to public users
    When Admin disapprove the archive
    Then Archive should be unavailable 
  @wip
  Scenario: Administrate Archives List
    Given I have un-verified archives titled Pizza
    When I go to the admin-list of archives
    Then I should see "Pizza"
  @wip
  Scenario: Admininstrator Verify an Archive
    Given I have un-verified archives titled Pizza
    And I am on the admin-list of archives
    When I follow "Manage Archive"
    Then I should see "Edit Thumbnail"
    And I should see "Verify Archive"
    When I follow "Verify Archive"
    Then I go to the list of archives
    And I should see "Pizza"

