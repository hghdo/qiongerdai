Feature: device ping
In order to analyze App installation and usage.
Device collects usage data and send data back to server.

  Scenario: Device upload collected usage data
    Given collected usage data
    When data uploaded to server
    Then server received data
    And server parse data and update db