Feature: device ping
In order to analyze App installation and usage.
Device collects usage data and send data back to server.

  Scenario: The first Ping of the device
    Given collected usage data
    When data uploaded to server
    Then server verify data format
    And server parse data and update db
    
  Scenario: Second Ping