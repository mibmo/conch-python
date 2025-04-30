{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.python;

  inherit (builtins) match;
  inherit (lib) types;
  inherit (lib.options) mkEnableOption mkOption mergeEqualOption;

  # don't question this behemoth (which might also be slightly wrong)
  semverPattern = ''(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-(([a-zA-Z-][a-zA-Z0-9-]*|[a-zA-Z0-9-]+[a-zA-Z-][a-zA-Z0-9-]*)|(0|[1-9][0-9]*))(\.(([a-zA-Z-][a-zA-Z0-9-]*|[a-zA-Z0-9-]+[a-zA-Z-][a-zA-Z0-9-]*)|(0|[1-9][0-9]*)))*)?(\+(([a-zA-Z-][a-zA-Z0-9-]*|[a-zA-Z0-9-]+[a-zA-Z-][a-zA-Z0-9-]*)|[0-9]+)(\.(([a-zA-Z-][a-zA-Z0-9-]*|[a-zA-Z0-9-]+[a-zA-Z-][a-zA-Z0-9-]*)|[0-9]+))*)?'';
  semverType = lib.types.mkOptionType {
    name = "semver";
    description = "semantic version";
    descriptionClass = "noun";
    check = v: types.str.check v && match semverPattern v != null;
    merge = mergeEqualOption;
  };
in
{
  options.python = {
    enable = mkEnableOption "Python development environment";
    package = mkOption {
      type = with types; package;
      default = pkgs.python3;
      defaultText = "whichever python package `version` chooses";
      description = ''
        Python package to use.

        Defaults to the latest version of Python 3
      '';
    };
    version = mkOption {
      type = semverType;
      default = null;
      description = ''
        Sets the Python package to the closest available version
        match within the same major and minor version.

        Overriden by `package`.
      '';
    };
    permitInsecurePythonVersion = mkOption {
      type = with types; bool;
      default = false;
      description = ''
        Permit using insecure Python versions.

        Stops the evaluation error when using e.g. the Python2 packages.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    shell.packages = [ cfg.package ];
  };
}
