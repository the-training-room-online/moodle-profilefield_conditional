<?php
// This file is part of Moodle - http://moodle.org/
//
// Moodle is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Moodle is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Moodle.  If not, see <http://www.gnu.org/licenses/>.

/**
 * Adhoc task for unsetting hidden fields.
 *
 * @package    profilefield_conditional
 * @category   task
 * @copyright  2014 Shamim Rezaie {@link http://foodle.org}
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

namespace profilefield_conditional\task;

use core\task\adhoc_task;
use dml_exception;
use stdClass;

defined('MOODLE_INTERNAL') || die();

global $CFG;
require_once($CFG->dirroot . '/user/profile/lib.php');

/**
 * Adhoc task for unsetting hidden fields.
 *
 * @package    profilefield_conditional
 * @category   task
 * @copyright  2014 Shamim Rezaie {@link http://foodle.org}
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */
class unset_hidden_fields extends adhoc_task {
    /**
     * @var stdClass User who has been updated.
     */
    private stdClass $user;

    /**
     * @var array All conditional fields.
     */
    private array $conditionalfields;

    /**
     * @var array Shortnames of all fields that should be hidden based on selected options of conditional fields.
     */
    private array $hiddenfields = [];

    /**
     * Find the user whose profile has been updated.
     *
     * Set the $user property to that value.
     *
     * @return void
     * @throws dml_exception
     */
    private function find_user(): void {
        global $DB;

        $userid = ($this->get_custom_data())->objectid;
        $this->user = $DB->get_record('user', ['id' => $userid]);
        profile_load_data($this->user);
    }

    /**
     * Find all conditional custom user profile fields.
     *
     * Set the $conditionalfields property to that value.
     *
     * @return void
     */
    private function find_conditional_fields(): void {
        $this->conditionalfields = array_filter(
            profile_get_custom_fields(),
            fn ($customfield) => $customfield->datatype === 'conditional'
        );
    }

    /**
     * Find the conditional configuration for the selected option based on the configuration of the conditional field.
     *
     * @param string $selectedoption
     * @param array $configuration
     * @return stdClass
     */
    private function find_selected_configuration(string $selectedoption, array $configuration): stdClass {
        return array_reduce(
            $configuration,
            function ($selectedconfig, $optionconfig) use ($selectedoption) {
                if (is_null($selectedconfig)) {
                    return $optionconfig->option === $selectedoption ? $optionconfig : null;
                }

                return $selectedconfig;
            }
        );
    }

    /**
     * Find all fields that should be hidden based on the selected options of the conditional custom user profile
     * fields.
     *
     * Set the $hiddenfields property to that value.
     *
     * @return void
     */
    private function find_hidden_fields(): void {
        foreach ($this->conditionalfields as $conditionalfield) {
            $selectedoption = $this->user->{'profile_field_' . $conditionalfield->shortname};
            $configuration = json_decode($conditionalfield->param5);
            $selectedconfig = $this->find_selected_configuration($selectedoption, $configuration);
            $this->hiddenfields += $selectedconfig->hiddenfields;
        }
    }

    /**
     * Ensure that fields that should be hidden based on the selected option of the given conditional field do not
     * contain data.
     *
     * @return void
     * @throws dml_exception
     */
    private function delete_data_of_hidden_fields(): void {
        global $DB;

        foreach ($this->hiddenfields as $hiddenfield) {
            $DB->delete_records('user_info_data', [
                'userid' => $this->user->id,
                'fieldid' => $DB->get_field('user_info_field', 'id', ['shortname' => $hiddenfield])
            ]);
        }
    }

    /**
     * {@inheritdoc}
     * @throws dml_exception
     */
    public function execute() {
        $this->find_user();
        $this->find_conditional_fields();
        $this->find_hidden_fields();
        $this->delete_data_of_hidden_fields();
    }
}
