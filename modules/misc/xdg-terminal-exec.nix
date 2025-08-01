{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.xdg.terminal-exec;
in
{
  options = {
    xdg.terminal-exec = {
      enable = lib.mkEnableOption ''
        xdg-terminal-exec, the
        [proposed](https://gitlab.freedesktop.org/xdg/xdg-specs/-/merge_requests/46)
        Default Terminal Execution Specification'';

      package = lib.mkPackageOption pkgs "xdg-terminal-exec" { nullable = true; };

      settings = lib.mkOption {
        type = with lib.types; attrsOf (listOf str);
        default = { };
        example = {
          default = [ "kitty.desktop" ];
          GNOME = [
            "com.raggesilver.BlackBox.desktop"
            "org.gnome.Terminal.desktop"
          ];
        };
        description = ''
          Configuration options for the Default Terminal Execution Specification.

          The keys are the desktop environments that are matched (case-insensitively) against {env}`XDG_CURRENT_DESKTOP`,
          or `default` which is used when the current desktop environment is not found in the configuration.
          The values are a list of terminals' [desktop file IDs](https://specifications.freedesktop.org/desktop-entry-spec/latest/ar01s02.html#desktop-file-id) to try in order of decreasing priority.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.mkIf (cfg.package != null) [ cfg.package ];

    xdg.configFile = lib.mapAttrs' (
      desktop: terminals:
      # Map desktop name such as GNOME to `.config/gnome-xdg-terminals.list`,
      # default to `.config/xdg-terminals.list`.
      lib.nameValuePair (
        "${if desktop == "default" then "" else "${lib.toLower desktop}-"}xdg-terminals.list"
      ) { text = lib.concatLines terminals; }
    ) cfg.settings;
  };

  meta.maintainers = with lib.maintainers; [ nukdokplex ];
}
