@api @files_sharing-app-required @issue-ocis-reva-34
Feature: share resources where the sharee receives the share in multiple ways

  Background:
    Given the administrator has set the default folder for received shares to "Shares"
    And auto-accept shares has been disabled
    And these users have been created with default attributes and without skeleton files:
      | username |
      | Alice    |
      | Brian    |

  Scenario Outline: Creating a new share with user who already received a share through their group
    Given using OCS API version "<ocs_api_version>"
    And group "grp1" has been created
    And user "Brian" has been added to group "grp1"
    And user "Alice" has uploaded file "filesForUpload/textfile.txt" to "/textfile0.txt"
    And user "Alice" has shared file "textfile0.txt" with group "grp1"
    And user "Brian" has accepted share "/textfile0.txt" offered by user "Alice"
    When user "Alice" shares file "/textfile0.txt" with user "Brian" using the sharing API
    Then the OCS status code should be "<ocs_status_code>"
    And the HTTP status code should be "200"
    When user "Brian" accepts share "/textfile0.txt" offered by user "Alice" using the sharing API
    Then the OCS status code should be "<ocs_status_code>"
    And the HTTP status code should be "200"
    And the fields of the last response to user "Alice" sharing with user "Brian" should include
      | share_with             | %username%              |
      | share_with_displayname | %displayname%           |
      | file_target            | /Shares/textfile0 (2).txt |
      | path                   | /Shares/textfile0 (2).txt |
      | permissions            | share,read,update       |
      | uid_owner              | %username%              |
      | displayname_owner      | %displayname%           |
      | item_type              | file                    |
      | mimetype               | text/plain              |
      | storage_id             | ANY_VALUE               |
      | share_type             | user                    |
    Examples:
      | ocs_api_version | ocs_status_code |
      | 1               | 100             |
      | 2               | 200             |

  @issue-ocis-reva-243
  Scenario Outline: Share of folder and sub-folder to same user - core#20645
    Given using OCS API version "<ocs_api_version>"
    And group "grp4" has been created
    And user "Brian" has been added to group "grp4"
    And user "Alice" has created folder "/PARENT"
    And user "Alice" has created folder "/PARENT/CHILD"
    And user "Alice" has uploaded file "filesForUpload/textfile.txt" to "/PARENT/parent.txt"
    And user "Alice" has uploaded file "filesForUpload/textfile.txt" to "/PARENT/CHILD/child.txt"
    When user "Alice" shares folder "/PARENT" with user "Brian" using the sharing API
    And user "Alice" shares folder "/PARENT/CHILD" with group "grp4" using the sharing API
    Then the OCS status code should be "<ocs_status_code>"
    And the HTTP status code should be "200"
    When user "Brian" accepts share "/PARENT" offered by user "Alice" using the sharing API
    Then the OCS status code should be "<ocs_status_code>"
    And the HTTP status code should be "200"
    And user "Brian" accepts share "/PARENT/CHILD" offered by user "Alice" using the sharing API
    And the OCS status code should be "<ocs_status_code>"
    And the HTTP status code should be "200"
    And user "Brian" should see the following elements
      | /Shares/PARENT/           |
      | /Shares/PARENT/parent.txt |
      | /Shares/CHILD/            |
      | /Shares/CHILD/child.txt   |
    Examples:
      | ocs_api_version | ocs_status_code |
      | 1               | 100             |
      | 2               | 200             |

  @issue-ocis-reva-243
  Scenario Outline: sharing subfolder when parent already shared
    Given using OCS API version "<ocs_api_version>"
    And group "grp1" has been created
    And user "Alice" has created folder "/test"
    And user "Alice" has created folder "/test/sub"
    And user "Alice" has shared folder "/test" with group "grp1"
    When user "Alice" shares folder "/test/sub" with user "Brian" using the sharing API
    Then the OCS status code should be "<ocs_status_code>"
    And the HTTP status code should be "200"
    When user "Brian" accepts share "/test/sub" offered by user "Alice" using the sharing API
    Then the OCS status code should be "<ocs_status_code>"
    And the HTTP status code should be "200"
    And as "Brian" folder "/Shares/sub" should exist
    Examples:
      | ocs_api_version | ocs_status_code |
      | 1               | 100             |
      | 2               | 200             |

  @issue-ocis-reva-243
  Scenario Outline: sharing subfolder when parent already shared with group of sharer
    Given using OCS API version "<ocs_api_version>"
    And group "grp0" has been created
    And user "Alice" has been added to group "grp0"
    And user "Alice" has created folder "/test"
    And user "Alice" has created folder "/test/sub"
    And user "Alice" has shared folder "/test" with group "grp0"
    When user "Alice" shares folder "/test/sub" with user "Brian" using the sharing API
    Then the OCS status code should be "<ocs_status_code>"
    And the HTTP status code should be "200"
    When user "Brian" accepts share "/test/sub" offered by user "Alice" using the sharing API
    Then the OCS status code should be "<ocs_status_code>"
    And the HTTP status code should be "200"
    And as "Brian" folder "/Shares/sub" should exist
    Examples:
      | ocs_api_version | ocs_status_code |
      | 1               | 100             |
      | 2               | 200             |

  @issue-ocis-reva-243
  Scenario Outline: multiple users share a file with the same name but different permissions to a user
    Given using OCS API version "<ocs_api_version>"
    And user "Carol" has been created with default attributes and without skeleton files
    And user "Brian" has uploaded file with content "First data" to "/randomfile.txt"
    And user "Carol" has uploaded file with content "Second data" to "/randomfile.txt"
    When user "Brian" shares file "randomfile.txt" with user "Alice" with permissions "read" using the sharing API
    And user "Alice" accepts share "/randomfile.txt" offered by user "Brian" using the sharing API
    And user "Alice" gets the info of the last share using the sharing API
    Then the fields of the last response about user "Brian" sharing with user "Alice" should include
      | uid_owner   | %username%             |
      | share_with  | %username%             |
      | file_target | /Shares/randomfile.txt |
      | item_type   | file                   |
      | permissions | read                   |
    When user "Carol" shares file "randomfile.txt" with user "Alice" with permissions "read,update" using the sharing API
    And user "Alice" accepts share "/randomfile.txt" offered by user "Carol" using the sharing API
    And user "Alice" gets the info of the last share using the sharing API
    Then the fields of the last response about user "Carol" sharing with user "Alice" should include
      | uid_owner   | %username%                 |
      | share_with  | %username%                 |
      | file_target | /Shares/randomfile (2).txt |
      | item_type   | file                       |
      | permissions | read,update                |
    And the content of file "/Shares/randomfile.txt" for user "Alice" should be "First data"
    And the content of file "/Shares/randomfile (2).txt" for user "Alice" should be "Second data"
    Examples:
      | ocs_api_version |
      | 1               |
      | 2               |

  @issue-ocis-reva-243
  Scenario Outline: multiple users share a folder with the same name to a user
    Given using OCS API version "<ocs_api_version>"
    And user "Carol" has been created with default attributes and without skeleton files
    And user "Brian" has created folder "/zzzfolder"
    And user "Brian" has created folder "zzzfolder/Brian"
    And user "Carol" has created folder "/zzzfolder"
    And user "Carol" has created folder "zzzfolder/Carol"
    When user "Brian" shares folder "zzzfolder" with user "Alice" with permissions "read,delete" using the sharing API
    And user "Alice" accepts share "/zzzfolder" offered by user "Brian" using the sharing API
    And user "Alice" gets the info of the last share using the sharing API
    Then the fields of the last response about user "Brian" sharing with user "Alice" should include
      | uid_owner   | %username%        |
      | share_with  | %username%        |
      | file_target | /Shares/zzzfolder |
      | item_type   | folder            |
      | permissions | read,delete       |
    When user "Carol" shares folder "zzzfolder" with user "Alice" with permissions "read,share" using the sharing API
    And user "Alice" accepts share "/zzzfolder" offered by user "Carol" using the sharing API
    And user "Alice" gets the info of the last share using the sharing API
    Then the fields of the last response about user "Carol" sharing with user "Alice" should include
      | uid_owner   | %username%            |
      | share_with  | %username%            |
      | file_target | /Shares/zzzfolder (2) |
      | item_type   | folder                |
      | permissions | read,share            |
    And as "Alice" folder "/Shares/zzzfolder/Brian" should exist
    And as "Alice" folder "/Shares/zzzfolder (2)/Carol" should exist
    Examples:
      | ocs_api_version |
      | 1               |
      | 2               |

  @skipOnEncryptionType:user-keys @encryption-issue-132 @skipOnLDAP
  Scenario Outline: share with a group and then add a user to that group that already has a file with the shared name
    Given using OCS API version "<ocs_api_version>"
    And user "Carol" has been created with default attributes and without skeleton files
    And these groups have been created:
      | groupname |
      | grp1      |
    And user "Brian" has been added to group "grp1"
    And user "Alice" has uploaded file with content "Shared content" to "lorem.txt"
    And user "Carol" has uploaded file with content "My content" to "lorem.txt"
    When user "Alice" shares file "lorem.txt" with group "grp1" using the sharing API
    And user "Brian" accepts share "/lorem.txt" offered by user "Alice" using the sharing API
    And the administrator adds user "Carol" to group "grp1" using the provisioning API
    And user "Carol" accepts share "/lorem.txt" offered by user "Alice" using the sharing API
    Then the content of file "Shares/lorem.txt" for user "Brian" should be "Shared content"
    And the content of file "lorem.txt" for user "Carol" should be "My content"
    And the content of file "Shares/lorem.txt" for user "Carol" should be "Shared content"
    Examples:
      | ocs_api_version |
      | 1               |
      | 2               |
