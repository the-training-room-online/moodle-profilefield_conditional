@profilefield @profilefield_conditional
Feature: Automatically unset hidden fields
  In order to keep my profile consistent
  As a user
  My fields which become hidden when I change my selection in a conditional field should automatically be unset

  Background:
    # As a site administrator, create custom user profile fields, one of which is a conditional field upon which some of
    # the other fields depend; as well as a normal user to which this feature is applicable.
    #
    # The conditional field is created lastly, because, during its creation, it must refer to the other fields.

    Given I log in as "admin"
    And I navigate to "Users > Accounts > User profile fields" in site administration

    # Create first dependent text input field
    And I set the field "datatype" to "Text input"
    And I set the following fields to these values:
      | Short name | firstdependenttextinput    |
      | Name       | First dependent text input |
    And I click on "Save changes" "button"

    # Create second dependent text input field
    And I set the field "datatype" to "Text input"
    And I set the following fields to these values:
      | Short name | seconddependenttextinput    |
      | Name       | Second dependent text input |
    And I click on "Save changes" "button"

    # Create a dependent menu field
    And I set the field "datatype" to "Drop-down menu"
    And I set the following fields to these values:
      | Short name | dependentmenu  |
      | Name       | Dependent menu |
    And I set the field "Menu options (one per line)" to multiline:
    """
    Drills
    Hammers
    Screwdrivers
    Spanners
    """
    And I click on "Save changes" "button"

    # Create an independent text input field
    And I set the field "datatype" to "Text input"
    And I set the following fields to these values:
      | Short name | independenttextinput   |
      | Name       | Independent text input |
    And I click on "Save changes" "button"

    # Create an independent checkbox field
    And I set the field "datatype" to "Checkbox"
    And I set the following fields to these values:
      | Short name | independentcheckbox  |
      | Name       | Independent checkbox |
    And I click on "Save changes" "button"

    # Create a conditional field
    And I set the field "datatype" to "Conditional field"
    And I set the following fields to these values:
      | Short name | masterfield  |
      | Name       | Master field |
    And I set the field "Menu options (one per line)" to multiline:
      """
      Apples
      Bananas
      Cherries
      Dates
      """
    And I click on "Configure conditions" "button"
    And I click on "[data-field='profilefield_conditional_field_required_Apples_firstdependenttextinput']" "css_element"
    And I click on "[data-field='profilefield_conditional_field_hidden_Apples_seconddependenttextinput']" "css_element"
    And I click on "[data-field='profilefield_conditional_field_hidden_Apples_dependentmenu']" "css_element"
    And I click on "[data-field='profilefield_conditional_field_hidden_Bananas_firstdependenttextinput']" "css_element"
    And I click on "[data-field='profilefield_conditional_field_required_Bananas_seconddependenttextinput']" "css_element"
    And I click on "[data-field='profilefield_conditional_field_hidden_Bananas_dependentmenu']" "css_element"
    And I click on "[data-field='profilefield_conditional_field_hidden_Cherries_firstdependenttextinput']" "css_element"
    And I click on "[data-field='profilefield_conditional_field_hidden_Cherries_seconddependenttextinput']" "css_element"
    And I click on "[data-field='profilefield_conditional_field_required_Cherries_dependentmenu']" "css_element"
    And I click on "[data-field='profilefield_conditional_field_hidden_Dates_firstdependenttextinput']" "css_element"
    And I click on "[data-field='profilefield_conditional_field_hidden_Dates_seconddependenttextinput']" "css_element"
    And I click on "[data-field='profilefield_conditional_field_hidden_Dates_dependentmenu']" "css_element"
    And I click on "Apply" "button"
    And I click on "Save changes" "button"

    # Create a normal user
    And the following "user" exists:
      | username                              | bob             |
      | firstname                             | Robert          |
      | lastname                              | Robertson       |
      | email                                 | bob@example.com |
      | profile_field_masterfield             | Apples          |
      | profile_field_firstdependenttextinput | Granny Smith    |
      | profile_field_independenttextinput    | Snow White      |
      | profile_field_independentcheckbox     | 1               |

    And I log out

  @javascript
  Scenario: Successfully unset hidden fields for single conditional field
    Given I log in as "bob"
    And I follow "Profile" in the user menu
    And I should see "Master field"
    And I should see "Apples"
    And I should see "First dependent text input"
    And I should see "Granny Smith"
    And I should not see "Second dependent text input"
    And I should not see "Dependent menu"
    And I should see "Independent text input"
    And I should see "Snow White"
    And "input[name=profile_field_independentcheckbox][checked=checked]" "css_element" should exist

    When I click on "Edit profile" "link" in the "region-main" "region"
    And I expand all fieldsets
    And I select "Bananas" from the "profile_field_masterfield" singleselect
    And I set the field "profile_field_seconddependenttextinput" to "Cavendish"
    And I start watching to see if a new page loads
    And I click on "Update profile" "button"
    And a new page should have loaded since I started watching
    And I run all adhoc tasks
    And I reload the page

    # Make sure that this is not the "Edit profile" page by asserting that the "Update profile" button is not present.
    Then I should not see "Update profile"
    And I should see "Master field"
    And I should see "Bananas"
    And I should not see "First dependent text input"
    And I should see "Second dependent text input"
    And I should see "Cavendish"
    And I should not see "Dependent menu"
    And I should see "Independent text input"
    And I should see "Snow White"
    And "input[name=profile_field_independentcheckbox][checked=checked]" "css_element" should exist

    When I click on "Edit profile" "link" in the "region-main" "region"
    And I expand all fieldsets
    And I select "Cherries" from the "profile_field_masterfield" singleselect
    And I select "Drills" from the "profile_field_dependentmenu" singleselect
    And I start watching to see if a new page loads
    And I click on "Update profile" "button"
    And a new page should have loaded since I started watching
    And I run all adhoc tasks
    And I reload the page

    Then I should not see "Update profile"
    And I should see "Master field"
    And I should see "Cherries"
    And I should not see "First dependent text input"
    And I should not see "Second dependent text input"
    And I should see "Dependent menu"
    And I should see "Drills"
    And I should see "Independent text input"
    And I should see "Snow White"
    And "input[name=profile_field_independentcheckbox][checked=checked]" "css_element" should exist

    When I click on "Edit profile" "link" in the "region-main" "region"
    And I expand all fieldsets
    And I select "Dates" from the "profile_field_masterfield" singleselect
    And I start watching to see if a new page loads
    And I click on "Update profile" "button"
    And a new page should have loaded since I started watching
    And I run all adhoc tasks
    And I reload the page

    Then I should not see "Update profile"
    And I should see "Master field"
    And I should see "Dates"
    And I should not see "First dependent text input"
    And I should not see "Second dependent text input"
    And I should not see "Dependent menu"
    And I should see "Independent text input"
    And I should see "Snow White"
    And "input[name=profile_field_independentcheckbox][checked=checked]" "css_element" should exist
