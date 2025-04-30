{
  description = "Python module for Conch";

  outputs =
    { ... }:
    {
      conchModules = rec {
        default = python;
        python = import ./module.nix;
      };
    };
}
