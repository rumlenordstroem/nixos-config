{ inputs, config, lib, pkgs, ... }:
{
  # Empty for now
  userContent = ''''; # Empty for now

  # Chrome styling
  userChrome = with config.lib.stylix.colors; /* css */ ''
    * {
      font-family: monospace;
      font-size: 14;
    }

    :root {
      --sfwindow: #${base01};
      --sfsecondary: #${base00};
      --text: #${base05};
      --tab-min-height: 33px !important;
      --tab-min-width: 60px !important;
      --urlbar-min-height: 25px !important;
      --uc-navbar-height: 33px !important;
    }

    /* TABS: height */
    #tabbrowser-tabs,
    #tabbrowser-tabs>#tabbrowser-arrowscrollbox,
    .tabbrowser-tabs .tabbrowser-tab {
      min-height: var(--tab-min-height) !important;
      max-height: var(--tab-min-height) !important;
    }

    /* affecting #nav-bar height */
    #search-container,
    #urlbar-container {
      padding: calc((var(--uc-navbar-height) - var(--urlbar-min-height)) / 2) 0 !important;
    }

    /* (optional) the blue little icon when you drag tabs, in case you want extra slim tabs */
    /* .tab-drop-indicator {
    /* default icon, height="29" */
    /* background: url(chrome://browser/skin/tabbrowser/tab-drag-indicator.svg) no-repeat center; */
    /* replacement icon, height="18" */

    /*
    ┌─┐┌─┐┬  ┌─┐┬─┐┌─┐
    │  │ ││  │ │├┬┘└─┐
    └─┘└─┘┴─┘└─┘┴└─└─┘
    */

    #toolbar-menubar {
      color: var(--text) !important;
    }

    /* Tabs colors  */
    #tabbrowser-tabs:not([movingtab])>#tabbrowser-arrowscrollbox>.tabbrowser-tab>.tab-stack>.tab-background[multiselected='true'],
    #tabbrowser-tabs:not([movingtab])>#tabbrowser-arrowscrollbox>.tabbrowser-tab>.tab-stack>.tab-background[selected='true'] {
      background-image: none !important;
      background-color: var(--toolbar-bgcolor) !important;
    }

    #tabbrowser-tab:is([visuallyselected], [multiselected]) {
      background-color: var(--toolbar-bgcolor) !important;
    }

    .tab-background:is([selected], [multiselected]) {
      background-color: var(--toolbar-bgcolor) !important;
    }

    /* Inactive tabs color */
    #navigator-toolbox {
      background-color: var(--sfwindow) !important;
    }

    .tab-text {
      color: var(--text) !important;
    }

    /* Icon color */
    .toolbarbutton-icon {
      color: var(--text) !important;
    }

    .close-icon {
      color: var(--text) !important;
    }

    .tab-icon-image {
      fill: var(--text) !important;
    }

    /* Window colors  */
    :root {
      --toolbar-color: var(--text) !important;
      --toolbar-bgcolor: var(--sfsecondary) !important;
      --tabs-border-color: var(--sfsecondary) !important;
      --lwt-sidebar-background-color: var(--sfwindow) !important;
      --lwt-toolbar-field-focus: var(--sfsecondary) !important;
    }

    /* Sidebar color  */
    #sidebar-box,
    .sidebar-placesTree {
      background-color: var(--sfwindow) !important;
    }

    /* Context menu */
    menupopup, panel {
      --panel-color: var(--text) !important;
      --panel-background: var(--sfwindow) !important;
      --panel-shadow: 0 !important;
      --panel-border-color: #${base04} !important;
      --panel-border-radius: 0px !important;
      --arrowpanel-background: var(--sfwindow) !important;
      --arrowpanel-menuitem-border-radius: 0px !important;
    }

    /*

    ┌┬┐┌─┐┬  ┌─┐┌┬┐┌─┐
     ││├┤ │  ├┤  │ ├┤
    ─┴┘└─┘┴─┘└─┘ ┴ └─┘
    ┌─┐┌─┐┌┬┐┌─┐┌─┐┌┐┌┌─┐┌┐┌┌┬┐┌─┐
    │  │ ││││├─┘│ ││││├┤ │││ │ └─┐
    └─┘└─┘┴ ┴┴  └─┘┘└┘└─┘┘└┘ ┴ └─┘

    */

    /* Tabs elements  */
    /*
    .tabbrowser-tab:not([pinned]) .tab-icon-image {
      display: none !important;
    }
    */

    .titlebar-buttonbox-container {
      display: none;
    }

    .titlebar-spacer {
      display: none !important;
    }

    #nav-bar {
      border-top: 0 !important;
    }

    #nav-bar:not([tabs-hidden='true']) {
      box-shadow: none;
    }

    #tabbrowser-tabs[haspinnedtabs]:not([positionpinnedtabs]) > #tabbrowser-arrowscrollbox > .tabbrowser-tab:nth-child(1 of :not([pinned], [hidden])) {
      margin-inline-start: 0px !important;
    }

    #tabbrowser-tabs {
      margin-inline-start: 0 !important;
      padding-inline-start: 0 !important;
      border-inline-start: 0 !important;
    }

    :root {
      --toolbarbutton-border-radius: 0 !important;
      --tab-border-radius: 0 !important;
      --tab-block-margin: 0 !important;
    }

    .tab-background {
      border-right: 0px solid rgba(0, 0, 0, 0) !important;
      margin-left: 0px !important;
    }

    .tabbrowser-tab:is([visuallyselected], [multiselected])>.tab-stack>.tab-background {
      box-shadow: none !important;
    }

    .tabbrowser-tab[last-visible-tab='true'] {
      padding-inline-end: 0 !important;
    }

    .tabbrowser-tab {
      padding: 0px !important;
    }

    #tabs-newtab-button {
      padding-left: 0 !important;
    }

    /* Url Bar  */
    #urlbar-input-container {
      color: var(--text) !important;
      background-color: var(--sfsecondary) !important;
      border: 1px solid rgba(0, 0, 0, 0) !important;
    }

    #urlbar-background {
      background-color: var(--sfwindow) !important;
    }

    #urlbar-container {
      margin-left: 0 !important;
    }

    #urlbar[focused='true']>#urlbar-background {
      box-shadow: none !important;
    }

    #navigator-toolbox {
      border: none !important;
    }

    .urlbarView {
      margin-inline: 0px !important;
      width: 100% !important;
      background-color: var(--sfsecondary) !important;
    }

    .urlbarView-title {
      color: var(--text) !important;
    }

    .urlbarView-url {
      color: #${base04} !important;
    }

    .urlbarView-body-inner {
      border: none !important
    }

    .urlbarView-row-inner {
      border-radius: 0px !important;
    }

    .urlbarView-row[selected],
    .urlbarView-row:hover {
      color: var(--text) !important;
      background-color: #${base02} !important;
    }

    /* Tool bar  */
    .bookmark-item .toolbarbutton-icon {
      display: none;
    }

    toolbarbutton.bookmark-item:not(.subviewbutton) {
      min-width: 1.6em;
    }

    #toolbarbutton {
      padding: 0px !important;
    }

    #nav-bar-customization-target > :is(toolbarbutton, toolbaritem):first-child {
      padding-inline-start: 0px !important;
    }

    /*
    .toolbaritem-combined-buttons {
      display: none;
    }
    */

    /* Toolbar  */
    #PersonalToolbar,
    #browser-window-close-button,
    #tracking-protection-icon-container,
    #urlbar-zoom-button,
    #star-button-box,
    #pageActionButton,
    #pageActionSeparator,
    #firefox-view-button,
    #save-to-pocket-button,
    #alltabs-button,
    .tab-secondary-label {
      display: none !important;
    }

    /* For context menu options see https://github.com/stonecrusher/simpleMenuWizard */

    /* Disable elements in context menu */
    #context-navigation,
    #context-sep-navigation,
    #context-savepage,
    #context-pocket,
    #context-sendpagetodevice,
    #context-selectall,
    #context-sep-selectall,
    #context-viewsource,
    #context-inspect-a11y,
    #context-sendlinktodevice,
    #context-openlinkinusercontext-menu,
    #context-bookmarklink,
    #context-savelink,
    #context-savelinktopocket,
    #context-sendlinktodevice,
    #context-searchselect,
    #context-sendimage,
    #context-print-selection {
      display: none !important;
    }

    /* Tap context menu */
    #context_bookmarkTab,
    #context_moveTabOptions,
    #context_sendTabToDevice,
    #context_reopenInContainer,
    #context_selectAllTabs,
    #context_selectAllTabs + menuseparator,
    #context_closeTabOptions {
      display: none !important;
    }

    /* Hamburger menu */
    #appMenu-fxa-status2,
    #appMenu-fxa-separator {
      display: none !important;
    }
    #statuspanel {
      display: none !important;
    }
  '';
}
