<?php
// $Id$

/**
 * @file owh.profile, Drupal O installation profile.
 * 
 * This file is modeled after Open Atrium's 
 * installation profile (version 1.0-beta6).
 */

/**
 * Implementation of hook_profile_details().
 */
function owh_profile_details() {
  return array(
    'name' => 'Owh',
    'description' => 'Drupal O by StarsWithStripes.Org, '
                    .'originally modeled after the '
                    .'Obama White House website '
                    .'(whitehouse.gov, 2010).',
  );
}

/**
 * Implementation of hook_profile_modules().
 */
function owh_profile_modules() {
  $modules = array(
     // Drupal core
    'block',
    // 'comment',
    'dblog',
    'filter',
    'help',
    'menu',
    'node',
    // 'openid',
    'search',
    'system', 
    'taxonomy',
    'ping',
    // 'upload',
    'user',
    // 'throttle',
    'contact',
    // Admin
    'admin',
    // Views
    'views', 
    // CTools
    'ctools',
    // Context
    'context',
    // Date
    'date_api', 'date_timezone',
    // Features
    'features',
    // Image
    'imageapi', 'imageapi_gd', 'imagecache',
    // Token
    'token',
    // Transliteration
    // 'transliteration',
    // Ucreate
    // 'ucreate', // @TODO Revisit for user administration.
    // Path
    'path', 'pathauto',
  );

  // @TODO translation.
  /*
  // If language is not English we add the 'atrium_translate' module the first
  // To get some modules installed properly we need to have translations loaded
  // We also use it to check connectivity with the translation server on hook_requirements()
  if (_owh_language_selected()) {
    // We need locale before l10n_update because it adds fields to locale tables
    $modules[] = 'locale';
    $modules[] = 'l10n_update';
    $modules[] = 'atrium_translate';
  }
  // */

  return $modules;
}

/**
 * Returns an array list of owh features (and supporting) modules.
 */
function _owh_modules() {
  return array(
    // Strongarm
    'strongarm',
    // Calendar, date
    'date', 'date_popup', 
    // CCK
    'content', 'nodereference', 'number', 'text', 
    'optionwidgets', 'fieldgroup', 'userreference',
    // CCK related
    'filefield', 'imagefield',
    // Feeds
    'feeds',
    // jQuery
    'jquery_plugin', 'jquery_ui', 
    // Rotor Banner
    'rotor', 
    // Video Filter
    'video_filter',
    // Google Maps Embed
    'embed_gmap',
    // Nodequeue
    'nodequeue', 
    // AddThis
    'addthis',
    // Role Delegation
    'role_delegation',
    // Submit Again
    'submitagain',
    // Upload elements
    'upload_element',
    // Formats
    // @TODO Revisit input formats... 'codefilter', 'markdown',
    // DesignKit
    // @TODO 'color', 'designkit', 
    // VBO
    'views_bulk_operations', 'actions_permissions',
    // FCKeditor
    'fckeditor',
    // Taxonomy Manager
    'taxonomy_manager',
    // Google Analytics
    'googleanalytics', 
    // Text Resize
    /**
     * @TODO figure out what's going on with javascript in text_resize.
     * Initially, this was disabled in the install profile. Mysteriously,
     * the Admin Toolbar and collapsible CCK fieldgroups stopped working.
     * The thing that's so weird, is that these continued to work in 
     * Garland, Admin, Zen themes, just not in Whitehouse (and related 
     * subthemes). Enabling text_resize seems to fix this.
     * 
     * There must be a conflict in jQuery files somewhere among modules.
     * Enabling text_resize isn't a very stable fix. Revisit this 
     * and see if it's practical to build the fix into the theme. 
     */
    'text_resize', 
    // StarsWithStripes.Org
    'sws', 'sws_fields', 'sws_mgmt',
    'subtheme', 'whitehouse_subtheme',
    'related_posts', 'addthissubtheme','user1',
    'ax3','permission',
    // Drupal O features modules: 
    'button_block', 'events', 'footer_navigation', 
    'issues', 'news_clips', 'page', 'press_releases', 
    'sws_admin', 'twitter_feed', 
    'owh_default_settings', 'owh_views',
    // Front Page
    'addthis_frontpage',
    'buttonblock_frontpage',
    'featuredposts_frontpage',
    'featuredvideo_fontpage',
    'recentposts_frontpage',
    'twitter_frontpage',
    'upcomingevents_frontpage',
    'twocolslideshow_frontpage',
    //'whitehouseslideshow_frontpage',
  );
}

/**
 * Implementation of hook_profile_task_list().
 */
function owh_profile_task_list() {
  /* @TODO translation
  if (_owh_language_selected()) {
    $tasks['owh-translation-batch'] = st('Download and import translation');
  }
  // */
  $tasks['owh-modules-batch'] = st('Install Drupal O modules');
  $tasks['owh-configure-batch'] = st('Configure Drupal O');
  return $tasks;
}

/**
 * Implementation of hook_profile_tasks().
 */
function owh_profile_tasks(&$task, $url) {
  global $profile, $install_locale;
  
  // Just in case some of the future tasks adds some output
  $output = '';

  // Download and install translation if needed
  if ($task == 'profile') {
    // Rebuild the language list.
    // When running through the CLI, the static language list will be empty
    // unless we repopulate it from the ,newly available, database.
    language_list('name', TRUE);

    /* @TODO translation.
    if (_owh_language_selected() && module_exists('atrium_translate')) {
      module_load_install('atrium_translate');
      if ($batch = atrium_translate_create_batch($install_locale, 'install')) {
        $batch['finished'] = '_owh_translate_batch_finished';
        // Remove temporary variables and set install task
        variable_del('install_locale_batch_components');
        variable_set('install_task', 'owh-translation-batch');
        batch_set($batch);
        batch_process($url, $url);
        // Jut for cli installs. We'll never reach here on interactive installs.
        return;
      }
    }
    // */

    // If we reach here, means no language install, move on to the next task
    $task = 'owh-modules';
  }

  // We are running a batch task for this profile so basically do nothing and return page
  // @TODO check for any lingering references to 'intranet'
  if (in_array($task, array('owh-modules-batch', 'owh-translation-batch', 'owh-configure-batch'))) {
    include_once 'includes/batch.inc';
    $output = _batch_page();
  }
  
  // Install some more modules and maybe localization helpers too
  if ($task == 'owh-modules') {
    $modules = _owh_modules();
    $files = module_rebuild_cache();
    // Create batch
    foreach ($modules as $module) {
      $batch['operations'][] = array('_install_module_batch', array($module, $files[$module]->info['name']));
    }    
    $batch['finished'] = '_owh_profile_batch_finished';
    $batch['title'] = st('Installing @drupal', array('@drupal' => drupal_install_profile_name()));
    $batch['error_message'] = st('The installation has encountered an error.');

    // Start a batch, switch to 'owh-modules-batch' task. We need to
    // set the variable here, because batch_process() redirects.
    variable_set('install_task', 'owh-modules-batch');
    batch_set($batch);
    batch_process($url, $url);
    // @TODO Find out what an "interactive install" is. 
    // Just for cli installs. We'll never reach here on interactive installs.
    return;
  }

  // Run additional configuration tasks
  // @todo Review all the cache/rebuild options at the end, some of them may not be needed
  // @todo Review for localization, the time zone cannot be set that way either
  if ($task == 'owh-configure') {
    $batch['title'] = st('Configuring @drupal', array('@drupal' => drupal_install_profile_name()));
    $batch['operations'][] = array('_owh_configure', array());
    $batch['operations'][] = array('_owh_configure_check', array());
    $batch['finished'] = '_owh_configure_finished';
    variable_set('install_task', 'owh-configure-batch');
    batch_set($batch);
    batch_process($url, $url);
    // Jut for cli installs. We'll never reach here on interactive installs.
    return;
  }  

  return $output;
}

/**
 * Check whether we are installing in a language other than English
 */
function _owh_language_selected() {
  global $install_locale;
  return !empty($install_locale) && ($install_locale != 'en');
}

/**
 * Configuration. First stage.
 */
function _owh_configure() {
  /* @TODO translation
  global $install_locale;

  // Disable the english locale if using a different default locale.
  if (!empty($install_locale) && ($install_locale != 'en')) {
    db_query("DELETE FROM {languages} WHERE language = 'en'");
  }
  // */

  /**
   * Permissions
   *
   * Note: There is deliberately no admin role. Out-of-the-box
   * nobody except user 1 can assign permissions or execute
   * PHP. The user1 module prevents Site Managers from editing
   * user 1's password and hijacking permissions. This lets 
   * site managers have access to approved admin pages without 
   * compromising security in a shared hosting environment.
   */
  // Create Content Manager and Site Manager roles.
  // Use rid 4 and 6 for backwards compatibility with older install profiles.
  db_query("INSERT INTO {role} VALUES "
         // already inserted by Drupal // ."(1, 'anonymous user'), " 
         // already inserted by Drupal // ."(2, 'authenticated user'), "
          ."(4,'site manager'), "
          ."(6,'content manager')");
  // Create permissions
  db_query("INSERT INTO {permission} (rid, perm, tid) VALUES "
     ."(1,'access site-wide contact form, access content, view addthis',0), "
     ."(2,'access site-wide contact form, access content, view addthis',0), "
     ."(6,'access site-wide contact form, view addthis, use admin toolbar, access comments, access fckeditor, flush imagecache, translate interface, access content, create bio content, create button content, create event content, create issue content, create legislation content, create news_clip content, create news_organization content, create page content, create photo content, create press_release content, create twitter_feed content, create video content, delete any bio content, delete any button content, delete any event content, delete any feed content, delete any feed_item content, delete any issue content, delete any legislation content, delete any news_clip content, delete any news_organization content, delete any page content, delete any photo content, delete any press_release content, "
."delete any tweet content, delete any twitter_feed content, delete any video content, delete own bio content, delete own button content, delete own event content, delete own feed content, delete own feed_item content, delete own issue content, delete own legislation content, delete own news_clip content, delete own news_contact content, delete own news_organization content, delete own page content, delete own photo content, delete own press_release content, delete own tweet content, delete own twitter_feed content, delete own video content, edit any bio content, edit any button content, edit any event content, edit any feed content, edit any feed_item content, edit any issue content, "
."edit any legislation content, edit any news_clip content, edit any news_organization content, edit any page content, edit any photo content, edit any press_release content, edit any tweet content, edit any twitter_feed content, edit any video content, edit own bio content, edit own button content, edit own event content, edit own feed content, edit own feed_item content, edit own issue content, edit own legislation content, edit own news_clip content, edit own news_contact content, edit own news_organization content, edit own page content, edit own photo content, edit own press_release content, edit own tweet content, edit own twitter_feed content, edit own video content, manipulate all queues, manipulate queues, administer sws, clear cache, manage content, change own username, access all views',0), " 
     ."(4,'administer taxonomy, access site-wide contact form, execute Add to Nodequeues (nodequeue_add_action), execute Change the author of a post (node_assign_owner_action), execute Delete comment (views_bulk_operations_delete_comment_action), execute Delete node (views_bulk_operations_delete_node_action), execute Delete term (views_bulk_operations_delete_term_action), execute Make post sticky (node_make_sticky_action), execute Make post unsticky (node_make_unsticky_action), execute Make sticky (node_mass_update), execute Modify node taxonomy terms (views_bulk_operations_taxonomy_action), execute Publish post (node_publish_action), execute Remove from Nodequeues (nodequeue_remove_action), execute Remove stickiness (node_mass_update), execute Unpublish (node_mass_update), execute Unpublish comment (comment_unpublish_action), execute Unpublish comment containing keyword(s) (comment_unpublish_by_keyword_action), execute Unpublish post (node_unpublish_action), execute Unpublish post containing keyword(s) (node_unpublish_by_keyword_action), view addthis, use admin toolbar, access comments, access fckeditor, manage features, flush imagecache, translate interface, access content, create bio content, create button content, "
."create event content, create issue content, create legislation content, create news_clip content, create news_organization content, create page content, create photo content, create press_release content, create twitter_feed content, create video content, delete any bio content, delete any button content, delete any event content, delete any feed content, delete any feed_item content, delete any issue content, delete any legislation content, delete any news_clip content, delete any news_contact content, delete any news_organization content, delete any page content, delete any photo content, delete any press_release content, delete any tweet content, delete any twitter_feed content, delete any video content, delete own bio content, delete own button content, "
."delete own event content, delete own feed content, delete own feed_item content, delete own issue content, delete own legislation content, delete own news_clip content, delete own news_contact content, delete own news_organization content, delete own page content, delete own photo content, delete own press_release content, delete own tweet content, delete own twitter_feed content, delete own video content, edit any bio content, edit any button content, edit any event content, edit any feed content, edit any feed_item content, edit any issue content, edit any legislation content, edit any news_clip content, edit any news_organization content, edit any page content, edit any photo content, "
."edit any press_release content, edit any tweet content, edit any twitter_feed content, edit any video content, edit own bio content, edit own button content, edit own event content, edit own feed content, edit own feed_item content, edit own issue content, edit own legislation content, edit own news_clip content, edit own news_contact content, edit own news_organization content, edit own page content, edit own photo content, edit own press_release content, edit own tweet content, edit own twitter_feed content, edit own video content, manipulate all queues, manipulate queues, administer sws, clear cache, manage content, access user profiles, administer users, change own username, access all views, manage subtheme, assign content manager role, assign site manager role, administer google analytics, administer site-wide contact form, assign site manager role, administer menu, administer site configuration',0)");

  // @TODO remove filter formats? include markup? 
  /*
  // Remove default input filter formats
  $result = db_query("SELECT * FROM {filter_formats} WHERE name IN ('%s', '%s')", 'Filtered HTML', 'Full HTML');
  while ($row = db_fetch_object($result)) {
    db_query("DELETE FROM {filter_formats} WHERE format = %d", $row->format);
    db_query("DELETE FROM {filters} WHERE format = %d", $row->format);
  }
  */
  //FCKEditor settings
  $adv = "a:39:{s:8:\"old_name\";s:8:\"Advanced\";s:4:\"name\";s:18:\"WhitehouseAdvanced\";s:15:\"allow_user_conf\";s:1:\"f\";s:7:\"filters\";a:1:{s:8:\"filter/0\";s:1:\"1\";}s:2:\"ss\";s:1:\"2\";s:8:\"min_rows\";s:1:\"1\";s:9:\"excl_mode\";s:1:\"0\";s:11:\"excl_fields\";s:0:\"\";s:10:\"excl_paths\";s:0:\"\";s:18:\"simple_incl_fields\";s:0:\"\";s:17:\"simple_incl_paths\";s:0:\"\";s:7:\"default\";s:1:\"t\";s:11:\"show_toggle\";s:1:\"t\";s:5:\"popup\";s:1:\"f\";s:4:\"skin\";s:7:\"default\";s:7:\"toolbar\";s:14:\"DrupalFiltered\";s:6:\"expand\";s:1:\"t\";s:5:\"width\";s:4:\"100%\";s:4:\"lang\";s:2:\"en\";s:9:\"auto_lang\";s:1:\"t\";s:10:\"enter_mode\";s:1:\"p\";s:16:\"shift_enter_mode\";s:2:\"br\";s:11:\"font_format\";s:35:\"p;div;pre;address;h1;h2;h3;h4;h5;h6\";s:13:\"format_source\";s:1:\"t\";s:13:\"format_output\";s:1:\"t\";s:8:\"css_mode\";s:5:\"theme\";s:8:\"css_path\";s:0:\"\";s:9:\"css_style\";s:5:\"theme\";s:11:\"styles_path\";s:0:\"\";s:11:\"filebrowser\";s:4:\"none\";s:11:\"quickupload\";s:1:\"f\";s:13:\"UserFilesPath\";s:5:\"%b%f/\";s:21:\"UserFilesAbsolutePath\";s:7:\"%d%b%f/\";s:15:\"theme_config_js\";s:1:\"f\";s:7:\"js_conf\";s:0:\"\";s:2:\"op\";s:14:\"Update profile\";s:13:\"form_build_id\";s:37:\"form-15f4b7a6a271678d06ac2ef8ce114a92\";s:10:\"form_token\";s:32:\"3a7e782fb59edc6fcf75aea938646356\";s:7:\"form_id\";s:28:\"fckeditor_profile_form_build\";}";
  $basic = "a:40:{s:8:\"old_name\";s:15:\"WhitehouseBasic\";s:4:\"name\";s:15:\"WhitehouseBasic\";s:4:\"rids\";a:3:{i:3;s:1:\"3\";i:6;s:1:\"6\";i:4;s:1:\"4\";}s:15:\"allow_user_conf\";s:1:\"f\";s:7:\"filters\";a:1:{s:8:\"filter/0\";s:1:\"1\";}s:2:\"ss\";s:1:\"2\";s:8:\"min_rows\";s:1:\"1\";s:9:\"excl_mode\";s:1:\"0\";s:11:\"excl_fields\";s:0:\"\";s:10:\"excl_paths\";s:0:\"\";s:18:\"simple_incl_fields\";s:0:\"\";s:17:\"simple_incl_paths\";s:0:\"\";s:7:\"default\";s:1:\"f\";s:11:\"show_toggle\";s:1:\"t\";s:5:\"popup\";s:1:\"f\";s:4:\"skin\";s:6:\"silver\";s:7:\"toolbar\";s:15:\"WhitehouseBasic\";s:6:\"expand\";s:1:\"t\";s:5:\"width\";s:4:\"100%\";s:4:\"lang\";s:2:\"en\";s:9:\"auto_lang\";s:1:\"t\";s:10:\"enter_mode\";s:1:\"p\";s:16:\"shift_enter_mode\";s:2:\"br\";s:11:\"font_format\";s:35:\"p;div;pre;address;h1;h2;h3;h4;h5;h6\";s:13:\"format_source\";s:1:\"t\";s:13:\"format_output\";s:1:\"t\";s:8:\"css_mode\";s:5:\"theme\";s:8:\"css_path\";s:0:\"\";s:9:\"css_style\";s:5:\"theme\";s:11:\"styles_path\";s:0:\"\";s:11:\"filebrowser\";s:4:\"none\";s:11:\"quickupload\";s:1:\"f\";s:13:\"UserFilesPath\";s:5:\"%b%f/\";s:21:\"UserFilesAbsolutePath\";s:7:\"%d%b%f/\";s:15:\"theme_config_js\";s:1:\"f\";s:7:\"js_conf\";s:0:\"\";s:2:\"op\";s:14:\"Update profile\";s:13:\"form_build_id\";s:37:\"form-1644eb912d09c97b1c69b5b290970409\";s:10:\"form_token\";s:32:\"4196108bdfbfe3bbed8bf07e2004abc9\";s:7:\"form_id\";s:28:\"fckeditor_profile_form_build\";}";
  db_query("INSERT INTO {fckeditor_role} VALUES ('WhitehouseBasic',4),('WhitehouseBasic',6)");
  db_query("INSERT INTO {fckeditor_settings} VALUES "
      ."('WhitehouseAdvanced', '%s'), ('WhitehouseBasic', '%s') ", $adv, $basic);

    // FCKeditor global settings
    $fck = db_result(db_query("SELECT name FROM {fckeditor_settings} WHERE name = 'FCKeditor Global Profile'"));
    $fckeditor_settings = "a:12:{s:8:\"old_name\";s:24:\"FCKeditor Global Profile\";s:4:\"rank\";a:1:{i:0;s:1:\"3\";}s:9:\"excl_mode\";s:1:\"0\";s:11:\"excl_fields\";s:937:\"edit-user-mail-welcome-body\r\nedit-user-mail-admin-body\r\nedit-user-mail-approval-body\r\nedit-user-mail-pass-body\r\nedit-user-mail-register-admin-created-body\r\nedit-user-mail-register-no-approval-required-body\r\nedit-user-mail-register-pending-approval-body\r\nedit-user-mail-password-reset-body\r\nedit-user-mail-status-activated-body\r\nedit-user-mail-status-blocked-body\r\nedit-user-mail-status-deleted-body\r\nedit-pages\r\nedit-pathauto-ignore-words\r\nedit-recipients\r\nedit-reply\r\nedit-description\r\nedit-synonyms\r\nedit-img-assist-textareas\r\nedit-img-assist-paths\r\nedit-nodewords-description\r\nedit-relatedlinks-fieldset-relatedlinks\r\nedit-allowed-values-php\r\nedit-allowed-values\r\nedit-update-notify-emails\r\nedit-googleanalytics-pages\r\nedit-googleanalytics-codesnippet-before\r\nedit-googleanalytics-codesnippet-after\r\nedit-piwik-pages\r\nedit-piwik-codesnippet\r\nedit-feedburner-useragents\r\nedit-webform-*\r\nedit-target\r\nedit-field-video-*-value\r\nedit-code\";s:10:\"excl_paths\";s:66:\"admin/*" . "/logintoboggan\r\nadmin/settings/actions/configure/*\r\nadmin/*\";s:18:\"simple_incl_fields\";s:155:\"edit-signature\r\nedit-site-mission\r\nedit-site-footer\r\nedit-site-offline-message\r\nedit-page-help\r\nedit-user-registration-help\r\nedit-user-picture-guidelines\r\n\";s:17:\"simple_incl_paths\";s:0:\"\";s:2:\"op\";s:21:\"Update global profile\";s:13:\"form_build_id\";s:37:\"form-f429c227a9bd83ac2fa7bfa709886a30\";s:10:\"form_token\";s:32:\"bf766b9bd8f818e979d55f3f4f28d24a\";s:7:\"form_id\";s:35:\"fckeditor_global_profile_form_build\";s:4:\"name\";s:24:\"FCKeditor Global Profile\";}";
    if ($fck) {
      db_query("UPDATE {fckeditor_settings} " 
            ."SET settings = '%s' "
            ."WHERE name = 'FCKeditor Global Profile' ", $fckeditor_settings);
    } else {
      db_query("INSERT INTO {fckeditor_settings} VALUES ('FCKeditor Global Profile', $fckeditor_settings)");
    }

  // Enable Site Managers to use Full HTMl input format
  db_query("UPDATE {filter_formats} SET roles = ',4,' WHERE name = 'Full HTML'");

  /* @TODO Add user pics for comments and supporter pages.
  // Create user picture directory
  $picture_path = file_create_path(variable_get('user_picture_path', 'pictures'));
  file_check_directory($picture_path, 1, 'user_picture_path');
  // */

  // Create keyword freetagging vocab for internal tagging
  $vocab = '';
  $vocab = array(
    'name' => 'Keywords',
    'multiple' => 0,
    'required' => 0,
    'hierarchy' => 0,
    'relations' => 0,
    'weight' => 3,
    'nodes' => array(
             'bio' => 1,
             'button' => 1,
             'event' => 1, 
             'issue' => 1, 
             'legislation' => 1, 
             'news_clip' => 1, 
             'page' => 1, 
             'photo' => 1, 
             'press_release' => 1, 
             'video' => 1,
      ), 
    'tags' => TRUE,
    'help' => t('Enter a comma separated list of keywords describing this post. '
               .'Keywords are not visible to the public. '
               .'They can be used internally to organize and manage website content.'),
  );
  taxonomy_save_vocabulary($vocab);

  // Create Event Categories freetagging vocab 
  $vocab = '';
  $vocab = array(
    'name' => 'Event Categories',
    'multiple' => 0,
    'required' => 0,
    'hierarchy' => 0,
    'relations' => 0,
    'weight' => 1,
    'nodes' => array('event' => 1),
    'tags' => TRUE,
    'help' => t('Help site visitors find what they\'re looking for in the events listing. '
               .'Enter a comma separated list of category names here. '
               .'Visitors can filter the events list for selected categories '
               .'and email customized lists to their friends.'),
  );
  taxonomy_save_vocabulary($vocab);

  /**
   * todo Add this when photo/video galler feature is ready
   *
  // Create Photo/Video Categories freetagging vocab 
  $vocab = '';
  $vocab = array(
    'name' => 'Photo/Video Categories',
    'multiple' => 0,
    'required' => 0,
    'hierarchy' => 0,
    'relations' => 0,
    'weight' => 2,
    'nodes' => array(
             'bio' => 1, 
             'event' => 1, 
             'issue' => 1, 
             'legislation' => 1, 
             'news_clip' => 1, 
             'page' => 1, 
             'photo' => 1, 
             'press_release' => 1, 
             'video' => 1,
    ),
    'tags' => TRUE,
    'help' => t('Help site visitors find what they\'re looking for in the photo/video gallery. '
               .'Enter a comma separated list of category names here. '
               .'Visitors can find photos and video attached to this post '
               .'by browsing category names.'),
  );
  taxonomy_save_vocabulary($vocab);
  // */


  // Rename Features and Secondary Links menus.
  db_query("UPDATE {menu_custom} "
          ."SET title = 'Main Menu', description = 'Main navigation menu. "
                      ."Menu items for any enabled features appear here.' "
          ." WHERE menu_name = 'features'"); 
  db_query("UPDATE {menu_custom} "
          ."SET title = 'Secondary Menu' "
          ." WHERE menu_name = 'secondary-links'"); 

  // Nodequeues
  db_query("INSERT INTO {nodequeue_queue} "
          ."VALUES (1,'Front Page Slideshow','',4,'','','nodequeue',1,1,0,'0',0,1),"
          ."(2,'Featured Posts','',6,'','','nodequeue',1,1,0,'0',0,1),"
          ."(3,'Featured Video','',1,'','','nodequeue',1,1,0,'0',0,1),"
          ."(4,'Front Page Main ','',1,'','','nodequeue',1,1,0,'0',0,1)");
  db_query("INSERT INTO {nodequeue_roles} VALUES (2,4),(1,4),(4,4)");
  db_query("INSERT INTO {nodequeue_subqueue} "
          ."VALUES (1,1,'1','Front Page Slideshow'),"
          ."(2,2,'2','Featured Posts'),"
          ."(3,3,'3','Featured Video'),"
          ."(4,4,'4','Front Page Main ')");
  db_query("INSERT INTO {nodequeue_types} "
          ."VALUES "
          ."(1,'photo'),(1,'page'),(1,'news_clip'),(1,'legislation'),(1,'issue'),(1,'event'),"
          ."(2,'press_release'),(2,'photo'),(2,'page'),(2,'news_clip'),(2,'legislation'),"
          ."(2,'issue'),(2,'event'),(2,'bio'),(2,'video'),"
          ."(3,'bio'),(3,'event'),(3,'issue'),(3,'legislation'),(3,'news_clip'),(3,'page'),"
          ."(3,'press_release'),(3,'video'),"
          ."(1,'bio'),"
          ."(4,'page'),"
          ."(1,'press_release'),(1,'video')");
  // Rename "nodequeue" "Queue"
  variable_set('nodequeue_tab_name', "Queue");

  // Performance settings
  variable_set('preprocess_css', TRUE);
  variable_set('preprocess_js', TRUE);

  // Set title of AddThis block to <none>
  db_query("INSERT INTO {blocks} (module, theme, title, cache) VALUES ('addthis','candidate','<none>',1)");
  
  // create and notify user number 2
  ax3_create_user2();
  // now disable ax3. we're done with it. 
  module_disable(array('ax3'));

  // Only site administrators can create users.
  variable_set('user_register', 0); 

  // Set errors to write to log, not print on screen (for security)
  variable_set('error_level', 0);

  // Set time zone
  // @TODO: This is not sufficient. We either need to display a message or
  // derive a default date API location.
  $tz_offset = date('Z');
  variable_set('date_default_timezone', $tz_offset);

  /* @TODO! Add promotional footer.
  // Set a default footer message.
  variable_set('site_footer', '&copy; 2009 '. l('Development Seed', 'http://www.developmentseed.org', array('absolute' => TRUE)));
  // */
}

/**
 * Configuration. Second stage.
 */
function _owh_configure_check() {
  // This isn't actually necessary as there are no node_access() entries,
  // but we run it to prevent the "rebuild node access" message from being
  // shown on install.
  node_access_rebuild();

  // Rebuild key tables/caches
  drupal_flush_all_caches();

  // Set default theme. This must happen after drupal_flush_all_caches(), which
  // will run system_theme_data() without detecting themes in the install
  // profile directory.
  _owh_system_theme_data();
  db_query("UPDATE {blocks} SET status = 0, region = ''"); // disable all DB blocks
  db_query("UPDATE {system} SET status = 0 WHERE type = 'theme' and name ='%s'", 'garland');
  db_query("UPDATE {system} SET status = 0 WHERE type = 'theme' and name ='%s'", 'whitehouse');
  db_query("UPDATE {system} SET status = 0 WHERE type = 'theme' and name ='%s'", 'candidate');
  variable_set('theme_default', 'candidate');

  // In Aegir install processes, we need to init strongarm manually as a
  // separate page load isn't available to do this for us.
  if (function_exists('strongarm_init')) {
    strongarm_init();
  }

  // @TODO revisit site_offline. Password reset (login link) doesn't work if site is offline.
  // Put site offline for initial set up.
  // variable_set('site_offline', TRUE);

  // Note: This wasn't working earlier in the process. 
  // Works here. Seems like maybe programatically creating 
  // content should be near the end, so this may be a good place
  // for this step. 
  // 
  // node 1
  // Stub out About page with instructional video.
  $node = new stdClass();
  $node->uid = 1;
  $node->type = 'page';
  $node->title = 'About'; // TODO handle for translation. 
  $node->field_video_url[0]['value'] = 'http://vimeo.com/11840891';
  $node->field_video_size[0]['value'] = 'width:445 height:364';
  $node->field_video_align[0]['value'] = 'center';
  $node->format = 1;
  $node->status = 1;
  $node->menu = array(
    'module' => 'menu',
    'options' => array('attributes' => array('title' => 'About')),
    'parent_depth_limit' => 8,
    'link_title' => 'About', // TODO handle for translation.
    'weight' => -50,
    'parent' => 'features:0',
    'menu_name' => 'features',
  );
  $node->path = '';
  $node->pathauto_perform_alias = 1;
  // save
  node_save($node);

  // node 2
  // Welcome page with instructional video.
  $node = new stdClass();
  $node->uid = 1;
  $node->type = 'page';
  $node->title = 'Welcome'; // TODO handle for translation. 
  $node->body = '<h1>Additional Video Tutorials:</h1>
    <a href="http://www.youtube.com/watch?v=stcqiY5WayY" style="cursor:pointer; text-transform:none;">Getting Started: Contact Us</a><br/>
    <a href="http://blip.tv/file/3648773" style="cursor:pointer; text-transform:none;">Getting Started: Sign Up Forms</a><br/>
    <a href="http://blip.tv/file/3642936" style="cursor:pointer; text-transform:none;">Getting Started: Front Page</a><br/>'; 
  $node->field_video_url[0]['value'] = 'http://www.youtube.com/watch?v=NWfDhVVrryA';
  $node->field_video_size[0]['value'] = 'width:445 height:364';
  $node->field_video_align[0]['value'] = 'center';
  $node->format = 2; // full html for videos embeded in body
  $node->status = 1;
  $node->path = '';
  $node->pathauto_perform_alias = 1;
  // save
  node_save($node);

  // Add welcome video (node) to Front Page Main queue
  $qid = 4;
  $sqid = 4;
  $queue = nodequeue_load($qid);
  $subqueue = nodequeue_load_subqueue($sqid);
  $nid = 2;
  nodequeue_subqueue_add($queue, $subqueue, $nid);

  /**
   *
  // node 3
  // Front Page video with instructional video.
  $node = new stdClass();
  $node->uid = 1;
  $node->type = 'page';
  $node->title = 'Setting up your Front Page';// TODO handle for translation. 
  $node->field_video_url[0]['value'] = 'http://blip.tv/file/3642936';
  $node->field_video_size[0]['value'] = 'width:445 height:364';
  $node->field_video_align[0]['value'] = 'center';
  $node->format = 1;
  $node->status = 1;
  $node->path = '';
  $node->pathauto_perform_alias = 1;
  // save
  node_save($node);

  // Add Featured Video queue
  $qid = 3;
  $sqid = 3;
  $queue = nodequeue_load($qid);
  $subqueue = nodequeue_load_subqueue($sqid);
  $nid = 3;
  nodequeue_subqueue_add($queue, $subqueue, $nid);
  // */

  /*
   * todo This seems to resolve funny date issues like 
   * Views showing the wrong time.  
   * 
   * It would be better to propt user to select timezone 
   * rather than set everything to Eastern Time. 
   * 
   * Open Atrium appears to be improving it's install-profile
   * time zone set up stuff too. Keep an eye on that and 
   * see where it goes. 
   */
  $form_state['values']['date_default_timezone'] = -14400;
  $form_state['values']['configurable_timezones'] = 0;
  $form_state['values']['date_first_day'] = 0;  $form_state['values']['date_default_timezone_name'] = 'America/New_York';
  drupal_execute('system_date_time_settings', $form_state);

  // Revert key components that are overridden by others on install.
  // Note that this comes after all other processes have run, as some cache
  // clears/rebuilds actually set variables or other settings that would count
  // as overrides.
  $revert = array(
    'button_block' => array(),
    'events' => array(),
    'footer_navigation' => array(),
    'front_page' => array(),
    'issues' => array(),
    'legislation' => array(),
    'news_clips' => array(),
    'page' => array(),
    'press_releases' => array(),
    'staff' => array(),
    'sws_admin' => array(),
    'twitter_feed' => array(),
    'owh_default_settings' => array(),
  );
  features_revert($revert);

}

/**
 * Finish configuration batch
 * 
 * @todo Handle error condition
 */
function _owh_configure_finished($success, $results) {
  variable_set('owh_install', 1);

  // @TODO translation
  // Get out of this batch and let the installer continue. If loaded translation,
  // we skip the locale remaining batch and move on to the next.
  // However, if we didn't make it with the translation file, or they downloaded
  // an unsupported language, we let the standard locale do its work.
  if (variable_get('owh_translate_done', 0)) {
    variable_set('install_task', 'finished');
  }
  else {
    variable_set('install_task', 'profile-finished');
  } 
}

/**
 * Finished callback for the modules install batch.
 *
 * Advance installer task to language import.
 */
function _owh_profile_batch_finished($success, $results) {
  variable_set('install_task', 'owh-configure');
}

/**
 * Finished callback for the first locale import batch.
 *
 * Advance installer task to the configure screen.
 */
function _owh_translate_batch_finished($success, $results) {
  /* @TODO! translation
  include_once 'includes/locale.inc';
  // Let the installer now we've already imported locales
  variable_set('atrium_translate_done', 1);
  variable_set('install_task', 'intranet-modules');
  _locale_batch_language_finished($success, $results);
  // */
}

/**
 * Alter some forms implementing hooks in system module namespace
 * This is a trick for hooks to get called, otherwise we cannot alter forms
 */

/**
 * @TODO: This might be impolite/too aggressive. We should at least check that
 * other install profiles are not present to ensure we don't collide with a
 * similar form alter in their profile.
 *
 * Set Open Atrium as default install profile.
 */
function system_form_install_select_profile_form_alter(&$form, $form_state) {
  foreach($form['profile'] as $key => $element) {
    $form['profile'][$key]['#value'] = 'owh';
  }
}

/**
 * Set English as default language.
 * 
 * If no language selected, the installation crashes. I guess English should be the default 
 * but it isn't in the default install. @todo research, core bug?
 */
function system_form_install_select_locale_form_alter(&$form, $form_state) {
  $form['locale']['en']['#value'] = 'en';
}

/**
 * Alter the install profile configuration form and provide timezone location options.
 */
function system_form_install_configure_form_alter(&$form, $form_state) {
  $form['site_information']['site_name']['#default_value'] = 'Drupal O';
  $form['site_information']['site_mail']['#default_value'] = 'admin@'. $_SERVER['HTTP_HOST'];
  $form['admin_account']['account']['name']['#default_value'] = 'superuser'; // @TODO does this work? 
  $form['admin_account']['account']['mail']['#default_value'] = 'admin@'. $_SERVER['HTTP_HOST'];

  if (function_exists('date_timezone_names') && function_exists('date_timezone_update_site')) {
    $form['server_settings']['date_default_timezone']['#access'] = FALSE;
    $form['server_settings']['#element_validate'] = array('date_timezone_update_site');
    $form['server_settings']['date_default_timezone_name'] = array(
      '#type' => 'select',
      '#title' => t('Default time zone'),
      '#default_value' => NULL,
      '#options' => date_timezone_names(FALSE, TRUE),
      '#description' => t('Select the default site time zone. If in doubt, choose the timezone that is closest to your location which has the same rules for daylight saving time.'),
      '#required' => TRUE,
    );
  }
}

/**
 * Reimplementation of system_theme_data(). The core function's static cache
 * is populated during install prior to active install profile awareness.
 * This workaround makes enabling themes in profiles/[profile]/themes possible.
 */
function _owh_system_theme_data() {
  global $profile;
  $profile = 'owh';

  $themes = drupal_system_listing('\.info$', 'themes');
  $engines = drupal_system_listing('\.engine$', 'themes/engines');

  $defaults = system_theme_default();

  $sub_themes = array();
  foreach ($themes as $key => $theme) {
    $themes[$key]->info = drupal_parse_info_file($theme->filename) + $defaults;

    if (!empty($themes[$key]->info['base theme'])) {
      $sub_themes[] = $key;
    }

    $engine = $themes[$key]->info['engine'];
    if (isset($engines[$engine])) {
      $themes[$key]->owner = $engines[$engine]->filename;
      $themes[$key]->prefix = $engines[$engine]->name;
      $themes[$key]->template = TRUE;
    }

    // Give the stylesheets proper path information.
    $pathed_stylesheets = array();
    foreach ($themes[$key]->info['stylesheets'] as $media => $stylesheets) {
      foreach ($stylesheets as $stylesheet) {
        $pathed_stylesheets[$media][$stylesheet] = dirname($themes[$key]->filename) .'/'. $stylesheet;
      }
    }
    $themes[$key]->info['stylesheets'] = $pathed_stylesheets;

    // Give the scripts proper path information.
    $scripts = array();
    foreach ($themes[$key]->info['scripts'] as $script) {
      $scripts[$script] = dirname($themes[$key]->filename) .'/'. $script;
    }
    $themes[$key]->info['scripts'] = $scripts;

    // Give the screenshot proper path information.
    if (!empty($themes[$key]->info['screenshot'])) {
      $themes[$key]->info['screenshot'] = dirname($themes[$key]->filename) .'/'. $themes[$key]->info['screenshot'];
    }
  }

  foreach ($sub_themes as $key) {
    $themes[$key]->base_themes = system_find_base_themes($themes, $key);
    // Don't proceed if there was a problem with the root base theme.
    if (!current($themes[$key]->base_themes)) {
      continue;
    }
    $base_key = key($themes[$key]->base_themes);
    foreach (array_keys($themes[$key]->base_themes) as $base_theme) {
      $themes[$base_theme]->sub_themes[$key] = $themes[$key]->info['name'];
    }
    // Copy the 'owner' and 'engine' over if the top level theme uses a
    // theme engine.
    if (isset($themes[$base_key]->owner)) {
      if (isset($themes[$base_key]->info['engine'])) {
        $themes[$key]->info['engine'] = $themes[$base_key]->info['engine'];
        $themes[$key]->owner = $themes[$base_key]->owner;
        $themes[$key]->prefix = $themes[$base_key]->prefix;
      }
      else {
        $themes[$key]->prefix = $key;
      }
    }
  }

  // Extract current files from database.
  system_get_files_database($themes, 'theme');
  db_query("DELETE FROM {system} WHERE type = 'theme'");
  foreach ($themes as $theme) {
    $theme->owner = !isset($theme->owner) ? '' : $theme->owner;
    db_query("INSERT INTO {system} (name, owner, info, type, filename, status, throttle, bootstrap) VALUES ('%s', '%s', '%s', '%s', '%s', %d, %d, %d)", $theme->name, $theme->owner, serialize($theme->info), 'theme', $theme->filename, isset($theme->status) ? $theme->status : 0, 0, 0);
  }
}
