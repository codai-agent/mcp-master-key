import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'MCP Master Key'**
  String get appTitle;

  /// The subtitle of the application
  ///
  /// In en, this message translates to:
  /// **'Unified Management Center for MCP Servers'**
  String get appSubtitle;

  /// No description provided for @common_ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get common_ok;

  /// No description provided for @common_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// No description provided for @common_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// No description provided for @common_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get common_delete;

  /// No description provided for @common_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get common_edit;

  /// No description provided for @common_add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get common_add;

  /// No description provided for @common_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get common_close;

  /// No description provided for @common_refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get common_refresh;

  /// No description provided for @common_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get common_loading;

  /// No description provided for @common_error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get common_error;

  /// No description provided for @common_success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get common_success;

  /// No description provided for @common_warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get common_warning;

  /// No description provided for @common_info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get common_info;

  /// No description provided for @common_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get common_confirm;

  /// No description provided for @common_yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get common_yes;

  /// No description provided for @common_no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get common_no;

  /// No description provided for @common_copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get common_copy;

  /// No description provided for @common_copied.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get common_copied;

  /// No description provided for @common_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get common_retry;

  /// No description provided for @common_previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get common_previous;

  /// No description provided for @common_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get common_next;

  /// No description provided for @common_start_install.
  ///
  /// In en, this message translates to:
  /// **'Start Install'**
  String get common_start_install;

  /// No description provided for @common_installing.
  ///
  /// In en, this message translates to:
  /// **'Installing...'**
  String get common_installing;

  /// No description provided for @tooltip_github.
  ///
  /// In en, this message translates to:
  /// **'GitHub Repository'**
  String get tooltip_github;

  /// No description provided for @tooltip_mcp_client.
  ///
  /// In en, this message translates to:
  /// **'MCP Host'**
  String get tooltip_mcp_client;

  /// No description provided for @tooltip_feedback.
  ///
  /// In en, this message translates to:
  /// **'Community & Feedback'**
  String get tooltip_feedback;

  /// No description provided for @tooltip_refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh Services'**
  String get tooltip_refresh;

  /// No description provided for @feedback_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Communication & Feedback'**
  String get feedback_dialog_title;

  /// No description provided for @feedback_report_bug.
  ///
  /// In en, this message translates to:
  /// **'Report Bug'**
  String get feedback_report_bug;

  /// No description provided for @nav_servers.
  ///
  /// In en, this message translates to:
  /// **'Server Management'**
  String get nav_servers;

  /// No description provided for @nav_install.
  ///
  /// In en, this message translates to:
  /// **'Install Server'**
  String get nav_install;

  /// No description provided for @nav_monitor.
  ///
  /// In en, this message translates to:
  /// **'Monitor'**
  String get nav_monitor;

  /// No description provided for @nav_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get nav_settings;

  /// No description provided for @servers_title.
  ///
  /// In en, this message translates to:
  /// **'MCP Servers'**
  String get servers_title;

  /// No description provided for @servers_empty.
  ///
  /// In en, this message translates to:
  /// **'No servers configured yet'**
  String get servers_empty;

  /// No description provided for @servers_empty_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Click the \'+\' button to add your first MCP server'**
  String get servers_empty_subtitle;

  /// No description provided for @servers_add.
  ///
  /// In en, this message translates to:
  /// **'Add Server'**
  String get servers_add;

  /// No description provided for @servers_install.
  ///
  /// In en, this message translates to:
  /// **'Install MCP Server'**
  String get servers_install;

  /// No description provided for @servers_start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get servers_start;

  /// No description provided for @servers_stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get servers_stop;

  /// No description provided for @servers_restart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get servers_restart;

  /// No description provided for @servers_starting.
  ///
  /// In en, this message translates to:
  /// **'Starting'**
  String get servers_starting;

  /// No description provided for @servers_stopping.
  ///
  /// In en, this message translates to:
  /// **'Stopping'**
  String get servers_stopping;

  /// No description provided for @servers_running.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get servers_running;

  /// No description provided for @servers_stopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get servers_stopped;

  /// No description provided for @servers_error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get servers_error;

  /// No description provided for @servers_show_config.
  ///
  /// In en, this message translates to:
  /// **'Show Config'**
  String get servers_show_config;

  /// No description provided for @servers_view_details.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get servers_view_details;

  /// No description provided for @servers_delete_server.
  ///
  /// In en, this message translates to:
  /// **'Delete Server'**
  String get servers_delete_server;

  /// No description provided for @servers_delete_confirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this server?'**
  String get servers_delete_confirm;

  /// No description provided for @servers_delete_success.
  ///
  /// In en, this message translates to:
  /// **'Server deleted successfully'**
  String get servers_delete_success;

  /// No description provided for @servers_start_success.
  ///
  /// In en, this message translates to:
  /// **'Server start request sent successfully'**
  String get servers_start_success;

  /// No description provided for @servers_stop_success.
  ///
  /// In en, this message translates to:
  /// **'Server stop request sent successfully'**
  String get servers_stop_success;

  /// No description provided for @servers_sort_by_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get servers_sort_by_name;

  /// No description provided for @servers_sort_by_status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get servers_sort_by_status;

  /// No description provided for @servers_sort_by_created.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get servers_sort_by_created;

  /// No description provided for @servers_starting_server.
  ///
  /// In en, this message translates to:
  /// **'Starting server: {serverName}...'**
  String servers_starting_server(String serverName);

  /// No description provided for @servers_stopping_server.
  ///
  /// In en, this message translates to:
  /// **'Stopping server: {serverName}...'**
  String servers_stopping_server(String serverName);

  /// No description provided for @servers_restarting_server.
  ///
  /// In en, this message translates to:
  /// **'Restarting server: {serverName}'**
  String servers_restarting_server(String serverName);

  /// No description provided for @servers_start_failed.
  ///
  /// In en, this message translates to:
  /// **'Start failed: {error}'**
  String servers_start_failed(String error);

  /// No description provided for @servers_stop_failed.
  ///
  /// In en, this message translates to:
  /// **'Stop failed: {error}'**
  String servers_stop_failed(String error);

  /// No description provided for @servers_restart_failed.
  ///
  /// In en, this message translates to:
  /// **'Restart failed: {error}'**
  String servers_restart_failed(String error);

  /// No description provided for @servers_restart_success.
  ///
  /// In en, this message translates to:
  /// **'Server restarted successfully: {serverName}'**
  String servers_restart_success(String serverName);

  /// No description provided for @servers_not_exist.
  ///
  /// In en, this message translates to:
  /// **'Server does not exist'**
  String get servers_not_exist;

  /// No description provided for @servers_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Load failed: {error}'**
  String servers_load_failed(String error);

  /// No description provided for @install_title.
  ///
  /// In en, this message translates to:
  /// **'Install MCP Server'**
  String get install_title;

  /// No description provided for @install_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Add new MCP servers to your collection'**
  String get install_subtitle;

  /// No description provided for @install_config_label.
  ///
  /// In en, this message translates to:
  /// **'Server Configuration'**
  String get install_config_label;

  /// No description provided for @install_config_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your MCP server configuration here...'**
  String get install_config_hint;

  /// No description provided for @install_config_empty.
  ///
  /// In en, this message translates to:
  /// **'Configuration cannot be empty'**
  String get install_config_empty;

  /// No description provided for @install_config_invalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid JSON configuration'**
  String get install_config_invalid;

  /// No description provided for @install_install.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get install_install;

  /// No description provided for @install_installing.
  ///
  /// In en, this message translates to:
  /// **'Installing...'**
  String get install_installing;

  /// No description provided for @install_success.
  ///
  /// In en, this message translates to:
  /// **'Server installed successfully!'**
  String get install_success;

  /// No description provided for @install_error.
  ///
  /// In en, this message translates to:
  /// **'Installation failed'**
  String get install_error;

  /// No description provided for @install_wizard_title.
  ///
  /// In en, this message translates to:
  /// **'MCP Server Installation Wizard'**
  String get install_wizard_title;

  /// No description provided for @install_wizard_auto_install_note.
  ///
  /// In en, this message translates to:
  /// **'• If using uvx/npx commands, packages will be installed automatically'**
  String get install_wizard_auto_install_note;

  /// No description provided for @install_wizard_manual_install_note.
  ///
  /// In en, this message translates to:
  /// **'• If using other commands, additional installation steps may be required'**
  String get install_wizard_manual_install_note;

  /// No description provided for @install_wizard_env_support_note.
  ///
  /// In en, this message translates to:
  /// **'• Supports environment variable configuration and command line arguments'**
  String get install_wizard_env_support_note;

  /// No description provided for @install_wizard_uvx_example.
  ///
  /// In en, this message translates to:
  /// **'UVX Example'**
  String get install_wizard_uvx_example;

  /// No description provided for @install_wizard_npx_example.
  ///
  /// In en, this message translates to:
  /// **'NPX Example'**
  String get install_wizard_npx_example;

  /// No description provided for @install_wizard_python_example.
  ///
  /// In en, this message translates to:
  /// **'Python Example'**
  String get install_wizard_python_example;

  /// No description provided for @install_wizard_manual_config_note.
  ///
  /// In en, this message translates to:
  /// **'Since your configuration doesn\'t use uvx/npx, manual installation source configuration is required.'**
  String get install_wizard_manual_config_note;

  /// No description provided for @install_wizard_auto_config_note.
  ///
  /// In en, this message translates to:
  /// **'The system will automatically download and install required packages, no additional configuration needed.'**
  String get install_wizard_auto_config_note;

  /// No description provided for @install_wizard_auto_install_supported.
  ///
  /// In en, this message translates to:
  /// **'Your configuration supports automatic installation, you can proceed to the next step directly.'**
  String get install_wizard_auto_install_supported;

  /// No description provided for @install_wizard_github_source.
  ///
  /// In en, this message translates to:
  /// **'GitHub Source'**
  String get install_wizard_github_source;

  /// No description provided for @install_wizard_github_source_desc.
  ///
  /// In en, this message translates to:
  /// **'Clone and install from GitHub repository'**
  String get install_wizard_github_source_desc;

  /// No description provided for @install_wizard_local_path.
  ///
  /// In en, this message translates to:
  /// **'Local Path'**
  String get install_wizard_local_path;

  /// No description provided for @install_wizard_local_path_desc.
  ///
  /// In en, this message translates to:
  /// **'Install from local file system'**
  String get install_wizard_local_path_desc;

  /// No description provided for @install_wizard_auto_analyze_note.
  ///
  /// In en, this message translates to:
  /// **'The system will automatically analyze repository structure and determine the best installation command.'**
  String get install_wizard_auto_analyze_note;

  /// No description provided for @install_wizard_step_configure.
  ///
  /// In en, this message translates to:
  /// **'Configure Server'**
  String get install_wizard_step_configure;

  /// No description provided for @install_wizard_step_analyze.
  ///
  /// In en, this message translates to:
  /// **'Analyze Installation'**
  String get install_wizard_step_analyze;

  /// No description provided for @install_wizard_step_options.
  ///
  /// In en, this message translates to:
  /// **'Installation Options'**
  String get install_wizard_step_options;

  /// No description provided for @install_wizard_step_execute.
  ///
  /// In en, this message translates to:
  /// **'Execute Installation'**
  String get install_wizard_step_execute;

  /// No description provided for @install_wizard_step_required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get install_wizard_step_required;

  /// No description provided for @install_wizard_step_auto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get install_wizard_step_auto;

  /// No description provided for @install_wizard_step_optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get install_wizard_step_optional;

  /// No description provided for @install_wizard_step_complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get install_wizard_step_complete;

  /// No description provided for @install_wizard_configure_title.
  ///
  /// In en, this message translates to:
  /// **'Configure MCP Server'**
  String get install_wizard_configure_title;

  /// No description provided for @install_wizard_configure_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Please fill in the basic information and configuration for the MCP server. The mcpServers configuration is required to determine startup commands and installation methods.'**
  String get install_wizard_configure_subtitle;

  /// No description provided for @install_wizard_server_name.
  ///
  /// In en, this message translates to:
  /// **'Server Name'**
  String get install_wizard_server_name;

  /// No description provided for @install_wizard_server_description.
  ///
  /// In en, this message translates to:
  /// **'Server Description (Optional)'**
  String get install_wizard_server_description;

  /// No description provided for @install_wizard_config_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Click here to enter MCP server configuration...'**
  String get install_wizard_config_placeholder;

  /// No description provided for @install_wizard_server_config_title.
  ///
  /// In en, this message translates to:
  /// **'MCP Server Configuration *'**
  String get install_wizard_server_config_title;

  /// No description provided for @install_wizard_server_name_example.
  ///
  /// In en, this message translates to:
  /// **'e.g., Hot News Server'**
  String get install_wizard_server_name_example;

  /// No description provided for @install_wizard_server_description_example.
  ///
  /// In en, this message translates to:
  /// **'Briefly describe the functionality of this MCP server'**
  String get install_wizard_server_description_example;

  /// No description provided for @install_wizard_analyze_config.
  ///
  /// In en, this message translates to:
  /// **'Analyze Configuration'**
  String get install_wizard_analyze_config;

  /// No description provided for @install_wizard_auto_install_ready.
  ///
  /// In en, this message translates to:
  /// **'Auto-installation ready'**
  String get install_wizard_auto_install_ready;

  /// No description provided for @install_wizard_auto_analysis.
  ///
  /// In en, this message translates to:
  /// **'Auto Analysis'**
  String get install_wizard_auto_analysis;

  /// No description provided for @install_wizard_install_command.
  ///
  /// In en, this message translates to:
  /// **'Installation Command (Optional)'**
  String get install_wizard_install_command;

  /// No description provided for @install_wizard_install_complete.
  ///
  /// In en, this message translates to:
  /// **'Installation complete! MCP server has been successfully added to your server list.'**
  String get install_wizard_install_complete;

  /// No description provided for @install_wizard_uvx_detected.
  ///
  /// In en, this message translates to:
  /// **'UVX command detected, the system will automatically use uv tool to install Python packages.'**
  String get install_wizard_uvx_detected;

  /// No description provided for @install_wizard_npx_detected.
  ///
  /// In en, this message translates to:
  /// **'NPX command detected, the system will automatically use npm to install Node.js packages.'**
  String get install_wizard_npx_detected;

  /// No description provided for @install_wizard_finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get install_wizard_finish;

  /// No description provided for @install_wizard_installation_complete.
  ///
  /// In en, this message translates to:
  /// **'Installation complete, you can start this server in the server list'**
  String get install_wizard_installation_complete;

  /// No description provided for @install_wizard_execution_title.
  ///
  /// In en, this message translates to:
  /// **'Installation Execution'**
  String get install_wizard_execution_title;

  /// No description provided for @install_wizard_execution_installing.
  ///
  /// In en, this message translates to:
  /// **'Installing MCP server, please wait...'**
  String get install_wizard_execution_installing;

  /// No description provided for @install_wizard_execution_ready.
  ///
  /// In en, this message translates to:
  /// **'Ready to start installation, click the \"Start Install\" button.'**
  String get install_wizard_execution_ready;

  /// No description provided for @install_wizard_execution_summary.
  ///
  /// In en, this message translates to:
  /// **'Installation Summary'**
  String get install_wizard_execution_summary;

  /// No description provided for @install_wizard_execution_logs.
  ///
  /// In en, this message translates to:
  /// **'Installation Logs'**
  String get install_wizard_execution_logs;

  /// No description provided for @install_wizard_success_title.
  ///
  /// In en, this message translates to:
  /// **'Installation Successful!'**
  String get install_wizard_success_title;

  /// No description provided for @install_wizard_success_message.
  ///
  /// In en, this message translates to:
  /// **'MCP server has been added to your server list and is ready to use.'**
  String get install_wizard_success_message;

  /// No description provided for @install_wizard_analysis_title.
  ///
  /// In en, this message translates to:
  /// **'Installation Strategy Analysis'**
  String get install_wizard_analysis_title;

  /// No description provided for @install_wizard_analysis_subtitle.
  ///
  /// In en, this message translates to:
  /// **'The system is analyzing your configuration to determine the best installation strategy.'**
  String get install_wizard_analysis_subtitle;

  /// No description provided for @install_wizard_strategy_detected.
  ///
  /// In en, this message translates to:
  /// **'Detected installation strategy: {strategy}'**
  String install_wizard_strategy_detected(String strategy);

  /// No description provided for @install_wizard_config_source_title.
  ///
  /// In en, this message translates to:
  /// **'Configure Installation Source'**
  String get install_wizard_config_source_title;

  /// No description provided for @install_wizard_config_source_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Since your configuration doesn\'t use uvx/npx, please select the installation source type and provide relevant information.'**
  String get install_wizard_config_source_subtitle;

  /// No description provided for @install_wizard_source_type.
  ///
  /// In en, this message translates to:
  /// **'Installation Source Type'**
  String get install_wizard_source_type;

  /// No description provided for @install_wizard_summary_server_name.
  ///
  /// In en, this message translates to:
  /// **'Server Name'**
  String get install_wizard_summary_server_name;

  /// No description provided for @install_wizard_summary_description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get install_wizard_summary_description;

  /// No description provided for @install_wizard_summary_strategy.
  ///
  /// In en, this message translates to:
  /// **'Installation Strategy'**
  String get install_wizard_summary_strategy;

  /// No description provided for @install_wizard_summary_source.
  ///
  /// In en, this message translates to:
  /// **'Installation Source'**
  String get install_wizard_summary_source;

  /// No description provided for @install_wizard_summary_unnamed.
  ///
  /// In en, this message translates to:
  /// **'Unnamed'**
  String get install_wizard_summary_unnamed;

  /// No description provided for @install_wizard_source_github.
  ///
  /// In en, this message translates to:
  /// **'GitHub Source'**
  String get install_wizard_source_github;

  /// No description provided for @install_wizard_source_local.
  ///
  /// In en, this message translates to:
  /// **'Local Path'**
  String get install_wizard_source_local;

  /// No description provided for @install_wizard_python_manual.
  ///
  /// In en, this message translates to:
  /// **'Python command detected, need to configure package installation source (GitHub or local path).'**
  String get install_wizard_python_manual;

  /// No description provided for @install_wizard_nodejs_manual.
  ///
  /// In en, this message translates to:
  /// **'Node.js command detected, need to configure package installation source (GitHub or local path).'**
  String get install_wizard_nodejs_manual;

  /// No description provided for @install_wizard_custom_manual.
  ///
  /// In en, this message translates to:
  /// **'Custom command detected, need to manually configure installation source and method.'**
  String get install_wizard_custom_manual;

  /// No description provided for @install_wizard_strategy_uvx.
  ///
  /// In en, this message translates to:
  /// **'UVX (Python Package Manager)'**
  String get install_wizard_strategy_uvx;

  /// No description provided for @install_wizard_strategy_npx.
  ///
  /// In en, this message translates to:
  /// **'NPX (Node.js Package Manager)'**
  String get install_wizard_strategy_npx;

  /// No description provided for @install_wizard_strategy_pip.
  ///
  /// In en, this message translates to:
  /// **'PIP (Python Installation)'**
  String get install_wizard_strategy_pip;

  /// No description provided for @install_wizard_strategy_npm.
  ///
  /// In en, this message translates to:
  /// **'NPM (Node.js Installation)'**
  String get install_wizard_strategy_npm;

  /// No description provided for @install_wizard_strategy_git.
  ///
  /// In en, this message translates to:
  /// **'Git Clone'**
  String get install_wizard_strategy_git;

  /// No description provided for @install_wizard_strategy_local.
  ///
  /// In en, this message translates to:
  /// **'Local Installation'**
  String get install_wizard_strategy_local;

  /// No description provided for @install_wizard_no_additional_config.
  ///
  /// In en, this message translates to:
  /// **'No additional configuration needed'**
  String get install_wizard_no_additional_config;

  /// No description provided for @install_wizard_additional_steps_required.
  ///
  /// In en, this message translates to:
  /// **'Additional installation steps required'**
  String get install_wizard_additional_steps_required;

  /// No description provided for @install_wizard_github_repo_url.
  ///
  /// In en, this message translates to:
  /// **'GitHub Repository URL'**
  String get install_wizard_github_repo_url;

  /// No description provided for @install_wizard_local_path_label.
  ///
  /// In en, this message translates to:
  /// **'Local Path'**
  String get install_wizard_local_path_label;

  /// No description provided for @monitor_title.
  ///
  /// In en, this message translates to:
  /// **'Hub Monitor'**
  String get monitor_title;

  /// No description provided for @monitor_hub_status.
  ///
  /// In en, this message translates to:
  /// **'Hub Status'**
  String get monitor_hub_status;

  /// No description provided for @monitor_hub_running.
  ///
  /// In en, this message translates to:
  /// **'Hub is running'**
  String get monitor_hub_running;

  /// No description provided for @monitor_hub_stopped.
  ///
  /// In en, this message translates to:
  /// **'Hub is not running'**
  String get monitor_hub_stopped;

  /// No description provided for @monitor_hub_port.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get monitor_hub_port;

  /// No description provided for @monitor_hub_mode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get monitor_hub_mode;

  /// No description provided for @monitor_hub_connected_servers.
  ///
  /// In en, this message translates to:
  /// **'Connected Servers'**
  String get monitor_hub_connected_servers;

  /// No description provided for @monitor_hub_available_tools.
  ///
  /// In en, this message translates to:
  /// **'Available Tools'**
  String get monitor_hub_available_tools;

  /// No description provided for @monitor_server_stats.
  ///
  /// In en, this message translates to:
  /// **'Server Statistics'**
  String get monitor_server_stats;

  /// No description provided for @monitor_servers_running.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get monitor_servers_running;

  /// No description provided for @monitor_servers_stopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get monitor_servers_stopped;

  /// No description provided for @monitor_servers_error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get monitor_servers_error;

  /// No description provided for @monitor_servers_total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get monitor_servers_total;

  /// No description provided for @monitor_connected_servers.
  ///
  /// In en, this message translates to:
  /// **'Connected Servers'**
  String get monitor_connected_servers;

  /// No description provided for @monitor_system_info.
  ///
  /// In en, this message translates to:
  /// **'System Information'**
  String get monitor_system_info;

  /// No description provided for @monitor_protocol_version.
  ///
  /// In en, this message translates to:
  /// **'Protocol Version'**
  String get monitor_protocol_version;

  /// No description provided for @monitor_app_version.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get monitor_app_version;

  /// No description provided for @monitor_runtime_mode.
  ///
  /// In en, this message translates to:
  /// **'Runtime Mode'**
  String get monitor_runtime_mode;

  /// No description provided for @monitor_no_servers.
  ///
  /// In en, this message translates to:
  /// **'No servers connected'**
  String get monitor_no_servers;

  /// No description provided for @monitor_refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get monitor_refresh;

  /// No description provided for @monitor_server_statistics.
  ///
  /// In en, this message translates to:
  /// **'Server Statistics'**
  String get monitor_server_statistics;

  /// No description provided for @monitor_total_label.
  ///
  /// In en, this message translates to:
  /// **'Total:'**
  String get monitor_total_label;

  /// No description provided for @monitor_installed.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get monitor_installed;

  /// No description provided for @monitor_connected_servers_title.
  ///
  /// In en, this message translates to:
  /// **'Connected Servers'**
  String get monitor_connected_servers_title;

  /// No description provided for @monitor_no_connected_servers.
  ///
  /// In en, this message translates to:
  /// **'No connected servers'**
  String get monitor_no_connected_servers;

  /// No description provided for @monitor_system_information.
  ///
  /// In en, this message translates to:
  /// **'System Information'**
  String get monitor_system_information;

  /// No description provided for @monitor_total_servers.
  ///
  /// In en, this message translates to:
  /// **'Total: {count} servers'**
  String monitor_total_servers(int count);

  /// No description provided for @server_monitor_title.
  ///
  /// In en, this message translates to:
  /// **'Server Monitor'**
  String get server_monitor_title;

  /// No description provided for @server_monitor_overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get server_monitor_overview;

  /// No description provided for @server_monitor_config.
  ///
  /// In en, this message translates to:
  /// **'Configuration'**
  String get server_monitor_config;

  /// No description provided for @server_monitor_logs.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get server_monitor_logs;

  /// No description provided for @server_monitor_stats.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get server_monitor_stats;

  /// No description provided for @server_monitor_status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get server_monitor_status;

  /// No description provided for @server_monitor_uptime.
  ///
  /// In en, this message translates to:
  /// **'Uptime'**
  String get server_monitor_uptime;

  /// No description provided for @server_monitor_pid.
  ///
  /// In en, this message translates to:
  /// **'Process ID'**
  String get server_monitor_pid;

  /// No description provided for @server_monitor_memory.
  ///
  /// In en, this message translates to:
  /// **'Memory Usage'**
  String get server_monitor_memory;

  /// No description provided for @server_monitor_env_vars.
  ///
  /// In en, this message translates to:
  /// **'Environment Variables'**
  String get server_monitor_env_vars;

  /// No description provided for @server_monitor_mcp_config.
  ///
  /// In en, this message translates to:
  /// **'MCP Server Configuration'**
  String get server_monitor_mcp_config;

  /// No description provided for @server_monitor_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get server_monitor_name;

  /// No description provided for @server_monitor_description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get server_monitor_description;

  /// No description provided for @server_monitor_install_type.
  ///
  /// In en, this message translates to:
  /// **'Install Type'**
  String get server_monitor_install_type;

  /// No description provided for @server_monitor_connection_type.
  ///
  /// In en, this message translates to:
  /// **'Connection Type'**
  String get server_monitor_connection_type;

  /// No description provided for @server_monitor_command.
  ///
  /// In en, this message translates to:
  /// **'Command'**
  String get server_monitor_command;

  /// No description provided for @server_monitor_args.
  ///
  /// In en, this message translates to:
  /// **'Arguments'**
  String get server_monitor_args;

  /// No description provided for @server_monitor_working_dir.
  ///
  /// In en, this message translates to:
  /// **'Working Directory'**
  String get server_monitor_working_dir;

  /// No description provided for @server_monitor_install_source.
  ///
  /// In en, this message translates to:
  /// **'Install Source'**
  String get server_monitor_install_source;

  /// No description provided for @server_monitor_version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get server_monitor_version;

  /// No description provided for @server_monitor_auto_start.
  ///
  /// In en, this message translates to:
  /// **'Auto Start'**
  String get server_monitor_auto_start;

  /// No description provided for @server_monitor_log_level.
  ///
  /// In en, this message translates to:
  /// **'Log Level'**
  String get server_monitor_log_level;

  /// No description provided for @server_monitor_current_status.
  ///
  /// In en, this message translates to:
  /// **'Current Status'**
  String get server_monitor_current_status;

  /// No description provided for @server_monitor_no_logs.
  ///
  /// In en, this message translates to:
  /// **'No logs available'**
  String get server_monitor_no_logs;

  /// No description provided for @server_monitor_no_logs_level.
  ///
  /// In en, this message translates to:
  /// **'No logs available for this level'**
  String get server_monitor_no_logs_level;

  /// No description provided for @server_monitor_auto_scroll.
  ///
  /// In en, this message translates to:
  /// **'Auto Scroll'**
  String get server_monitor_auto_scroll;

  /// No description provided for @server_monitor_log_level_all.
  ///
  /// In en, this message translates to:
  /// **'ALL'**
  String get server_monitor_log_level_all;

  /// No description provided for @server_monitor_log_level_error.
  ///
  /// In en, this message translates to:
  /// **'ERROR'**
  String get server_monitor_log_level_error;

  /// No description provided for @server_monitor_log_level_warn.
  ///
  /// In en, this message translates to:
  /// **'WARN'**
  String get server_monitor_log_level_warn;

  /// No description provided for @server_monitor_log_level_info.
  ///
  /// In en, this message translates to:
  /// **'INFO'**
  String get server_monitor_log_level_info;

  /// No description provided for @server_monitor_log_level_debug.
  ///
  /// In en, this message translates to:
  /// **'DEBUG'**
  String get server_monitor_log_level_debug;

  /// No description provided for @server_monitor_runtime_status.
  ///
  /// In en, this message translates to:
  /// **'Runtime Status'**
  String get server_monitor_runtime_status;

  /// No description provided for @server_monitor_time_tracking.
  ///
  /// In en, this message translates to:
  /// **'Time Tracking'**
  String get server_monitor_time_tracking;

  /// No description provided for @server_monitor_process_info.
  ///
  /// In en, this message translates to:
  /// **'Process Information'**
  String get server_monitor_process_info;

  /// No description provided for @server_monitor_tool_stats.
  ///
  /// In en, this message translates to:
  /// **'Tool Statistics'**
  String get server_monitor_tool_stats;

  /// No description provided for @server_monitor_connection_stats.
  ///
  /// In en, this message translates to:
  /// **'Connection Statistics'**
  String get server_monitor_connection_stats;

  /// No description provided for @server_monitor_performance_stats.
  ///
  /// In en, this message translates to:
  /// **'Performance Statistics'**
  String get server_monitor_performance_stats;

  /// No description provided for @server_monitor_config_stats.
  ///
  /// In en, this message translates to:
  /// **'Configuration Statistics'**
  String get server_monitor_config_stats;

  /// No description provided for @server_monitor_tools_count.
  ///
  /// In en, this message translates to:
  /// **'Tools Count'**
  String get server_monitor_tools_count;

  /// No description provided for @server_monitor_tools_list.
  ///
  /// In en, this message translates to:
  /// **'Tools List'**
  String get server_monitor_tools_list;

  /// No description provided for @server_monitor_connection_status.
  ///
  /// In en, this message translates to:
  /// **'Connection Status'**
  String get server_monitor_connection_status;

  /// No description provided for @server_monitor_error_info.
  ///
  /// In en, this message translates to:
  /// **'Error Information'**
  String get server_monitor_error_info;

  /// No description provided for @server_monitor_log_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load logs: {error}'**
  String server_monitor_log_load_failed(String error);

  /// No description provided for @server_monitor_log_filter.
  ///
  /// In en, this message translates to:
  /// **'Level Filter: '**
  String get server_monitor_log_filter;

  /// No description provided for @server_monitor_operation_failed.
  ///
  /// In en, this message translates to:
  /// **'Operation failed: {error}'**
  String server_monitor_operation_failed(String error);

  /// No description provided for @server_monitor_delete_confirm_title.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get server_monitor_delete_confirm_title;

  /// No description provided for @server_monitor_delete_confirm_content.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this server? This action cannot be undone.'**
  String get server_monitor_delete_confirm_content;

  /// No description provided for @server_monitor_logs_cleared.
  ///
  /// In en, this message translates to:
  /// **'Logs cleared'**
  String get server_monitor_logs_cleared;

  /// No description provided for @server_monitor_clear_logs_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to clear logs: {error}'**
  String server_monitor_clear_logs_failed(String error);

  /// No description provided for @server_monitor_export_logs_todo.
  ///
  /// In en, this message translates to:
  /// **'Log export feature is under development'**
  String get server_monitor_export_logs_todo;

  /// No description provided for @server_monitor_export_logs_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to export logs: {error}'**
  String server_monitor_export_logs_failed(String error);

  /// No description provided for @server_monitor_edit_todo.
  ///
  /// In en, this message translates to:
  /// **'Edit feature is under development'**
  String get server_monitor_edit_todo;

  /// No description provided for @server_card_details_title.
  ///
  /// In en, this message translates to:
  /// **'Server Details - {serverName}'**
  String server_card_details_title(String serverName);

  /// No description provided for @server_card_delete_failed.
  ///
  /// In en, this message translates to:
  /// **'Delete failed: {error}'**
  String server_card_delete_failed(String error);

  /// No description provided for @server_card_confirm_delete_title.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get server_card_confirm_delete_title;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @settings_general.
  ///
  /// In en, this message translates to:
  /// **'General Settings'**
  String get settings_general;

  /// No description provided for @settings_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language;

  /// No description provided for @settings_language_system.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get settings_language_system;

  /// No description provided for @settings_language_en.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settings_language_en;

  /// No description provided for @settings_language_zh.
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get settings_language_zh;

  /// No description provided for @settings_theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settings_theme;

  /// No description provided for @settings_theme_system.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get settings_theme_system;

  /// No description provided for @settings_theme_light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settings_theme_light;

  /// No description provided for @settings_theme_dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settings_theme_dark;

  /// No description provided for @settings_hub.
  ///
  /// In en, this message translates to:
  /// **'Hub Settings'**
  String get settings_hub;

  /// No description provided for @settings_hub_mode.
  ///
  /// In en, this message translates to:
  /// **'Running Mode'**
  String get settings_hub_mode;

  /// No description provided for @settings_hub_mode_sse.
  ///
  /// In en, this message translates to:
  /// **'SSE Mode (Single Client)'**
  String get settings_hub_mode_sse;

  /// No description provided for @settings_hub_mode_streamable.
  ///
  /// In en, this message translates to:
  /// **'Streamable Mode (Multi Client)'**
  String get settings_hub_mode_streamable;

  /// No description provided for @settings_hub_port.
  ///
  /// In en, this message translates to:
  /// **'Streamable Port'**
  String get settings_hub_port;

  /// No description provided for @settings_hub_port_desc.
  ///
  /// In en, this message translates to:
  /// **'Port used for multi-client mode: {port}'**
  String settings_hub_port_desc(String port);

  /// No description provided for @settings_hub_port_invalid.
  ///
  /// In en, this message translates to:
  /// **'Port must be between 1024-65535'**
  String get settings_hub_port_invalid;

  /// No description provided for @settings_startup.
  ///
  /// In en, this message translates to:
  /// **'Startup Settings'**
  String get settings_startup;

  /// No description provided for @settings_startup_auto.
  ///
  /// In en, this message translates to:
  /// **'Auto Start on Boot'**
  String get settings_startup_auto;

  /// No description provided for @settings_startup_auto_desc.
  ///
  /// In en, this message translates to:
  /// **'Automatically start application when system boots'**
  String get settings_startup_auto_desc;

  /// No description provided for @settings_startup_minimize.
  ///
  /// In en, this message translates to:
  /// **'Minimize to System Tray'**
  String get settings_startup_minimize;

  /// No description provided for @settings_startup_minimize_desc.
  ///
  /// In en, this message translates to:
  /// **'Minimize to system tray when closing window'**
  String get settings_startup_minimize_desc;

  /// No description provided for @settings_logs.
  ///
  /// In en, this message translates to:
  /// **'Log Settings'**
  String get settings_logs;

  /// No description provided for @settings_log_level.
  ///
  /// In en, this message translates to:
  /// **'Log Level'**
  String get settings_log_level;

  /// No description provided for @settings_log_level_desc.
  ///
  /// In en, this message translates to:
  /// **'Current level: {level}'**
  String settings_log_level_desc(String level);

  /// No description provided for @settings_log_level_debug.
  ///
  /// In en, this message translates to:
  /// **'Debug'**
  String get settings_log_level_debug;

  /// No description provided for @settings_log_level_info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get settings_log_level_info;

  /// No description provided for @settings_log_level_warn.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get settings_log_level_warn;

  /// No description provided for @settings_log_level_error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get settings_log_level_error;

  /// No description provided for @settings_log_retention.
  ///
  /// In en, this message translates to:
  /// **'Log Retention Days'**
  String get settings_log_retention;

  /// No description provided for @settings_log_retention_desc.
  ///
  /// In en, this message translates to:
  /// **'Automatically delete logs older than {days} days'**
  String settings_log_retention_desc(String days);

  /// No description provided for @settings_download.
  ///
  /// In en, this message translates to:
  /// **'Download Settings'**
  String get settings_download;

  /// No description provided for @settings_download_mirror.
  ///
  /// In en, this message translates to:
  /// **'Use China Mainland Mirrors'**
  String get settings_download_mirror;

  /// No description provided for @settings_download_mirror_desc.
  ///
  /// In en, this message translates to:
  /// **'Use Tsinghua and other domestic mirrors to accelerate package downloads'**
  String get settings_download_mirror_desc;

  /// No description provided for @settings_download_current_source.
  ///
  /// In en, this message translates to:
  /// **'Current Mirror Source'**
  String get settings_download_current_source;

  /// No description provided for @settings_download_mirror_advantages.
  ///
  /// In en, this message translates to:
  /// **'Mirror Advantages'**
  String get settings_download_mirror_advantages;

  /// No description provided for @settings_download_mirror_advantages_desc.
  ///
  /// In en, this message translates to:
  /// **'• Download speed increased by 5-10 times\n• Solve network connection issues\n• Support Python and NPM packages'**
  String get settings_download_mirror_advantages_desc;

  /// No description provided for @settings_download_official_pypi.
  ///
  /// In en, this message translates to:
  /// **'Official PyPI'**
  String get settings_download_official_pypi;

  /// No description provided for @settings_download_tsinghua_pypi.
  ///
  /// In en, this message translates to:
  /// **'Tsinghua PyPI Mirror'**
  String get settings_download_tsinghua_pypi;

  /// No description provided for @settings_download_official_npm.
  ///
  /// In en, this message translates to:
  /// **'Official NPM'**
  String get settings_download_official_npm;

  /// No description provided for @settings_download_taobao_npm.
  ///
  /// In en, this message translates to:
  /// **'Taobao NPM Mirror'**
  String get settings_download_taobao_npm;

  /// No description provided for @settings_maintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get settings_maintenance;

  /// No description provided for @settings_clear_cache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get settings_clear_cache;

  /// No description provided for @settings_clear_cache_desc.
  ///
  /// In en, this message translates to:
  /// **'Clear temporary files and cache data'**
  String get settings_clear_cache_desc;

  /// No description provided for @settings_clear_cache_button.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get settings_clear_cache_button;

  /// No description provided for @settings_export_config.
  ///
  /// In en, this message translates to:
  /// **'Export Configuration'**
  String get settings_export_config;

  /// No description provided for @settings_export_config_desc.
  ///
  /// In en, this message translates to:
  /// **'Export server configuration and application settings'**
  String get settings_export_config_desc;

  /// No description provided for @settings_export_config_button.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get settings_export_config_button;

  /// No description provided for @settings_about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settings_about;

  /// No description provided for @settings_version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settings_version;

  /// No description provided for @settings_version_desc.
  ///
  /// In en, this message translates to:
  /// **'MCP Hub v1.0.0'**
  String get settings_version_desc;

  /// No description provided for @settings_check_update.
  ///
  /// In en, this message translates to:
  /// **'Check for Updates'**
  String get settings_check_update;

  /// No description provided for @settings_check_update_desc.
  ///
  /// In en, this message translates to:
  /// **'Check if new version is available'**
  String get settings_check_update_desc;

  /// No description provided for @settings_check_update_button.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get settings_check_update_button;

  /// No description provided for @settings_open_source.
  ///
  /// In en, this message translates to:
  /// **'Open Source License'**
  String get settings_open_source;

  /// No description provided for @settings_open_source_desc.
  ///
  /// In en, this message translates to:
  /// **'View open source license information'**
  String get settings_open_source_desc;

  /// No description provided for @settings_mode_changed.
  ///
  /// In en, this message translates to:
  /// **'Server mode changed to: {mode}'**
  String settings_mode_changed(String mode);

  /// No description provided for @settings_mode_change_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to change server mode: {error}'**
  String settings_mode_change_failed(String error);

  /// No description provided for @settings_port_changed.
  ///
  /// In en, this message translates to:
  /// **'Streamable port changed to: {port}'**
  String settings_port_changed(String port);

  /// No description provided for @settings_port_change_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to change port: {error}'**
  String settings_port_change_failed(String error);

  /// No description provided for @settings_restart_required_title.
  ///
  /// In en, this message translates to:
  /// **'Restart Required'**
  String get settings_restart_required_title;

  /// No description provided for @settings_restart_required_content.
  ///
  /// In en, this message translates to:
  /// **'Server mode change requires restarting MCP Hub service to take effect.'**
  String get settings_restart_required_content;

  /// No description provided for @settings_restart_later.
  ///
  /// In en, this message translates to:
  /// **'Restart Later'**
  String get settings_restart_later;

  /// No description provided for @settings_restart_now.
  ///
  /// In en, this message translates to:
  /// **'Restart Now'**
  String get settings_restart_now;

  /// No description provided for @settings_hub_restarted.
  ///
  /// In en, this message translates to:
  /// **'MCP Hub service restarted successfully'**
  String get settings_hub_restarted;

  /// No description provided for @settings_hub_restart_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to restart Hub service: {error}'**
  String settings_hub_restart_failed(String error);

  /// No description provided for @settings_clear_cache_title.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get settings_clear_cache_title;

  /// No description provided for @settings_clear_cache_confirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all cache data? This action cannot be undone.'**
  String get settings_clear_cache_confirm;

  /// No description provided for @settings_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get settings_confirm;

  /// No description provided for @settings_cache_cleared.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared successfully'**
  String get settings_cache_cleared;

  /// No description provided for @settings_export_todo.
  ///
  /// In en, this message translates to:
  /// **'Configuration export feature is under development'**
  String get settings_export_todo;

  /// No description provided for @settings_already_latest.
  ///
  /// In en, this message translates to:
  /// **'Already the latest version'**
  String get settings_already_latest;

  /// No description provided for @settings_license_title.
  ///
  /// In en, this message translates to:
  /// **'Open Source License'**
  String get settings_license_title;

  /// No description provided for @settings_runtime_mode.
  ///
  /// In en, this message translates to:
  /// **'Runtime Mode'**
  String get settings_runtime_mode;

  /// No description provided for @settings_multi_client_support.
  ///
  /// In en, this message translates to:
  /// **'Support multiple concurrent client connections'**
  String get settings_multi_client_support;

  /// No description provided for @settings_app_behavior.
  ///
  /// In en, this message translates to:
  /// **'Application Behavior'**
  String get settings_app_behavior;

  /// No description provided for @settings_log_settings.
  ///
  /// In en, this message translates to:
  /// **'Log Settings'**
  String get settings_log_settings;

  /// No description provided for @settings_download_settings.
  ///
  /// In en, this message translates to:
  /// **'Download Settings'**
  String get settings_download_settings;

  /// No description provided for @settings_storage_management.
  ///
  /// In en, this message translates to:
  /// **'Storage Management'**
  String get settings_storage_management;

  /// No description provided for @settings_system_information.
  ///
  /// In en, this message translates to:
  /// **'System Information'**
  String get settings_system_information;

  /// No description provided for @settings_about_section.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settings_about_section;

  /// No description provided for @settings_single_client_mode.
  ///
  /// In en, this message translates to:
  /// **'Only allows single client connection'**
  String get settings_single_client_mode;

  /// No description provided for @settings_single_client_help.
  ///
  /// In en, this message translates to:
  /// **'Suitable for single application use, better performance, strong compatibility'**
  String get settings_single_client_help;

  /// No description provided for @settings_multi_client_help.
  ///
  /// In en, this message translates to:
  /// **'Suitable for multiple applications connecting simultaneously, supports session isolation, resource sharing'**
  String get settings_multi_client_help;

  /// No description provided for @splash_initializing.
  ///
  /// In en, this message translates to:
  /// **'Initializing...'**
  String get splash_initializing;

  /// No description provided for @sidebar_collapse.
  ///
  /// In en, this message translates to:
  /// **'Collapse Sidebar'**
  String get sidebar_collapse;

  /// No description provided for @sidebar_expand.
  ///
  /// In en, this message translates to:
  /// **'Expand Sidebar'**
  String get sidebar_expand;

  /// No description provided for @splash_init_runtime.
  ///
  /// In en, this message translates to:
  /// **'Initializing runtime environment...'**
  String get splash_init_runtime;

  /// No description provided for @splash_init_process.
  ///
  /// In en, this message translates to:
  /// **'Initializing process manager...'**
  String get splash_init_process;

  /// No description provided for @splash_init_database.
  ///
  /// In en, this message translates to:
  /// **'Initializing database...'**
  String get splash_init_database;

  /// No description provided for @splash_init_hub.
  ///
  /// In en, this message translates to:
  /// **'Starting MCP Hub server...'**
  String get splash_init_hub;

  /// No description provided for @splash_init_complete.
  ///
  /// In en, this message translates to:
  /// **'Initialization complete'**
  String get splash_init_complete;

  /// No description provided for @splash_init_error.
  ///
  /// In en, this message translates to:
  /// **'Initialization failed, continuing...'**
  String get splash_init_error;

  /// No description provided for @config_show_title.
  ///
  /// In en, this message translates to:
  /// **'Server Configuration'**
  String get config_show_title;

  /// No description provided for @config_copy_success.
  ///
  /// In en, this message translates to:
  /// **'Configuration copied to clipboard'**
  String get config_copy_success;

  /// No description provided for @quick_actions_title.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quick_actions_title;

  /// No description provided for @quick_actions_start_all.
  ///
  /// In en, this message translates to:
  /// **'Start All'**
  String get quick_actions_start_all;

  /// No description provided for @quick_actions_stop_all.
  ///
  /// In en, this message translates to:
  /// **'Stop All'**
  String get quick_actions_stop_all;

  /// No description provided for @quick_actions_refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh Status'**
  String get quick_actions_refresh;

  /// No description provided for @system_info_platform.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get system_info_platform;

  /// No description provided for @system_info_architecture.
  ///
  /// In en, this message translates to:
  /// **'Architecture'**
  String get system_info_architecture;

  /// No description provided for @system_info_dart_version.
  ///
  /// In en, this message translates to:
  /// **'Dart Version'**
  String get system_info_dart_version;

  /// No description provided for @system_info_flutter_version.
  ///
  /// In en, this message translates to:
  /// **'Flutter Version'**
  String get system_info_flutter_version;

  /// No description provided for @hub_monitor_title.
  ///
  /// In en, this message translates to:
  /// **'MCP Hub Monitor'**
  String get hub_monitor_title;

  /// No description provided for @hub_monitor_status.
  ///
  /// In en, this message translates to:
  /// **'MCP Hub Status'**
  String get hub_monitor_status;

  /// No description provided for @hub_monitor_running.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get hub_monitor_running;

  /// No description provided for @hub_monitor_stopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get hub_monitor_stopped;

  /// No description provided for @hub_monitor_port.
  ///
  /// In en, this message translates to:
  /// **'Service Port'**
  String get hub_monitor_port;

  /// No description provided for @hub_monitor_mode.
  ///
  /// In en, this message translates to:
  /// **'Running Mode'**
  String get hub_monitor_mode;

  /// No description provided for @hub_monitor_connected_servers.
  ///
  /// In en, this message translates to:
  /// **'Connected Servers'**
  String get hub_monitor_connected_servers;

  /// No description provided for @hub_monitor_available_tools.
  ///
  /// In en, this message translates to:
  /// **'Available Tools'**
  String get hub_monitor_available_tools;

  /// No description provided for @hub_monitor_service_address.
  ///
  /// In en, this message translates to:
  /// **'Service Address'**
  String get hub_monitor_service_address;

  /// No description provided for @hub_monitor_not_running.
  ///
  /// In en, this message translates to:
  /// **'Hub service is not running'**
  String get hub_monitor_not_running;

  /// No description provided for @hub_monitor_debug_info.
  ///
  /// In en, this message translates to:
  /// **'Debug Info'**
  String get hub_monitor_debug_info;

  /// No description provided for @hub_monitor_server_statistics.
  ///
  /// In en, this message translates to:
  /// **'Server Statistics'**
  String get hub_monitor_server_statistics;

  /// No description provided for @hub_monitor_connected_servers_list.
  ///
  /// In en, this message translates to:
  /// **'Connected Servers'**
  String get hub_monitor_connected_servers_list;

  /// No description provided for @hub_monitor_system_info.
  ///
  /// In en, this message translates to:
  /// **'System Information'**
  String get hub_monitor_system_info;

  /// No description provided for @hub_monitor_unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get hub_monitor_unknown;

  /// No description provided for @hub_monitor_count_unit.
  ///
  /// In en, this message translates to:
  /// **' servers'**
  String get hub_monitor_count_unit;

  /// No description provided for @hub_monitor_tools_unit.
  ///
  /// In en, this message translates to:
  /// **' tools'**
  String get hub_monitor_tools_unit;

  /// No description provided for @servers_quick_actions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get servers_quick_actions;

  /// No description provided for @servers_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search servers...'**
  String get servers_search_hint;

  /// No description provided for @servers_description_hint.
  ///
  /// In en, this message translates to:
  /// **'MCP servers added through installation wizard'**
  String get servers_description_hint;

  /// No description provided for @servers_status_running.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get servers_status_running;

  /// No description provided for @servers_status_stopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get servers_status_stopped;

  /// No description provided for @servers_status_starting.
  ///
  /// In en, this message translates to:
  /// **'Starting'**
  String get servers_status_starting;

  /// No description provided for @servers_status_stopping.
  ///
  /// In en, this message translates to:
  /// **'Stopping'**
  String get servers_status_stopping;

  /// No description provided for @servers_status_error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get servers_status_error;

  /// No description provided for @servers_status_installing.
  ///
  /// In en, this message translates to:
  /// **'Installing'**
  String get servers_status_installing;

  /// No description provided for @servers_status_uninstalling.
  ///
  /// In en, this message translates to:
  /// **'Uninstalling'**
  String get servers_status_uninstalling;

  /// No description provided for @servers_status_installed.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get servers_status_installed;

  /// No description provided for @servers_status_not_installed.
  ///
  /// In en, this message translates to:
  /// **'Not Installed'**
  String get servers_status_not_installed;

  /// No description provided for @servers_status_unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get servers_status_unknown;

  /// No description provided for @servers_more_options.
  ///
  /// In en, this message translates to:
  /// **'More Options'**
  String get servers_more_options;

  /// No description provided for @servers_no_servers.
  ///
  /// In en, this message translates to:
  /// **'No servers yet'**
  String get servers_no_servers;

  /// No description provided for @servers_no_servers_found.
  ///
  /// In en, this message translates to:
  /// **'No matching servers found'**
  String get servers_no_servers_found;

  /// No description provided for @servers_add_server_hint.
  ///
  /// In en, this message translates to:
  /// **'Click the floating button to start adding servers'**
  String get servers_add_server_hint;

  /// No description provided for @servers_load_error.
  ///
  /// In en, this message translates to:
  /// **'Load failed'**
  String get servers_load_error;

  /// No description provided for @servers_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get servers_retry;

  /// No description provided for @servers_starting_message.
  ///
  /// In en, this message translates to:
  /// **'Starting server: {serverName}...'**
  String servers_starting_message(String serverName);

  /// No description provided for @servers_stopping_message.
  ///
  /// In en, this message translates to:
  /// **'Stopping server: {serverName}...'**
  String servers_stopping_message(String serverName);

  /// No description provided for @servers_restarting_message.
  ///
  /// In en, this message translates to:
  /// **'Restarting server: {serverName}...'**
  String servers_restarting_message(String serverName);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
