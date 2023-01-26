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
 * Listens for the \core\event\user_updated event, then takes appropriate action.
 *
 * @package    profilefield_conditional
 * @category   event
 * @copyright  2014 Shamim Rezaie {@link http://foodle.org}
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

namespace profilefield_conditional\event;

use core\event\user_updated;
use core\task\manager as taskmanager;
use profilefield_conditional\task\unset_hidden_fields;

/**
 * Listens for the \core\event\user_updated event, then takes appropriate action.
 *
 * @package    profilefield_conditional
 * @category   event
 * @copyright  2014 Shamim Rezaie {@link http://foodle.org}
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */
class observe_user_updated {
    /**
     * Takes appropriate action.
     *
     * @param user_updated $event
     * @return void
     */
    public static function execute(user_updated $event): void {
        $unsethiddenfieldstask = new unset_hidden_fields();
        $unsethiddenfieldstask->set_custom_data($event->get_data());
        taskmanager::queue_adhoc_task($unsethiddenfieldstask);
    }
}
