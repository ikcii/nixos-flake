# This profile configures the base set of features for a graphical desktop system.
{ ... }:

{
  # --- Core Desktop Services ---
  security.polkit.enable = true;
  programs.dconf.enable = true;
  services.gvfs.enable = true;
  security.pam.services.swaylock = { }; # Because I'm using swaylock on all my desktop machines for now

  # --- Audio ---
  # Enable the PipeWire audio server and give it real-time permissions.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # --- GUI Program Defaults ---
  programs.light.enable = true;
}
