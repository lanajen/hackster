/** Packages */
require('expose?React!react');
require('expose?ReactDOM!react-dom');
require('expose?hljs!highlight.js');

/** Components */
require('expose?Comments!./comments/app');
require('expose?ContestCsvExporter!./contest_csv_exporter/app');
require('expose?ContentTypeSelector!./content_type_selector/app');
require('expose?CourseWizard!./course_wizard/containers/Root');
require('expose?FlagButton!./flag_button/app');
require('expose?FollowButton!./follow_button/app');
require('expose?ImageUploader!./image_uploader/app');
require('expose?ListsDropdown!./lists_dropdown/app');
require('expose?MouserContest!./mouser_contest/app');
require('expose?NotificationDropdown!./notification_dropdown/app');
require('expose?ReactEditor!./draft/app');
require('expose?ReputationUpdateButton!./reputation_update_button/app');
require('expose?ReviewTool!./review_tool/containers/Root');
require('expose?TimeLeft!./time_left/app');
require('expose?ToolboxSelector!./toolbox_selector/containers/Root');

/* testing the badge */
require('expose?EmbedWidget!./embed_widgets/app');

/** Global Utils */
require('expose?Utils!./utils/Utils');
