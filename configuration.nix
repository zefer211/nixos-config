{ config, pkgs, inputs, ... }:

{
  imports = [
    # Inclui os resultados do escaneamento de hardware
    ./hardware-configuration.nix
  ];

  # Bootloader e inicialização
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Nome da máquina (Host)
  networking.hostName = "ultraviolence";
  networking.networkmanager.enable = true;

  # Fuso horário e Localização
  time.timeZone = "America/Fortaleza";
  i18n.defaultLocale = "pt_BR.UTF-8";

  # Configuração de Teclado (PT-BR sem dead keys)
  services.xserver.xkb = {
    layout = "br";
    variant = "nodeadkeys";
  };
  console.keyMap = "br-abnt2";

  # Serviços e Ambiente Gráfico
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Habilitar o Hyprland (Compositor Wayland)
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Tema escuro e personalização visual no GNOME/GTK (barra superior preta)
  programs.dconf.enable = true;
  programs.dconf.profiles.user.databases = [
    {
      settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          gtk-theme = "Orchis-Dark";
          icon-theme = "Tela-circle-dark";
          cursor-theme = "Bibata-Modern-Classic";
        };
      };
    }
  ];

  # Habilitar suporte a Flatpak e AppImage
  services.flatpak.enable = true;
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  # Habilitar suporte a Bluetooth e Áudio
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Shell Fish habilitado em todo o sistema
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting "🖤 Welcome to the Ultraviolence Kingdom."
    '';
  };

  # Configuração do usuário robson
  users.users.robson = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "bluetooth" ];
    shell = pkgs.fish;
  };

  # Permitir software proprietário
  nixpkgs.config.allowUnfree = true;

  # Pacotes do sistema (incluindo OnlyOffice e Caelestia Shell via Flake Inputs)
  environment.systemPackages = with pkgs; [
    nano
    git
    fastfetch
    spotify
    firefox
    killall
    wireplumber
    brightnessctl
    gnome-console
    yt-dlp
    ani-cli
    vlc
    mpv
    mpvpaper
    gpu-screen-recorder
    gpu-screen-recorder-gtk
    kitty
    awww
    wofi
    gnome-tweaks
    gnome-extension-manager
    orchis-theme
    bibata-cursors
    gnomeExtensions.appindicator
    onlyoffice-desktopeditors
    inputs.caelestia.packages.${pkgs.stdenv.hostPlatform.system}.default
    qbittorrent # <--- Corrigido para minúsculo
  ];

  programs.gpu-screen-recorder.enable = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  security.sudo.wheelNeedsPassword = false;

  # Configuração para Limpeza Automática e Limite de Gerações
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  
  # Mantém apenas as últimas 5 gerações no bootloader/sistema
  system.autoUpgrade.enable = false; # Mantenha false se preferir atualizar manualmente pelo alias
  boot.loader.systemd-boot.configurationLimit = 5;

  environment.shellAliases = {
    nixconfig = "sudo nano /etc/nixos/configuration.nix";
    rebuild = "sudo nixos-rebuild switch --flake /etc/nixos/#ultraviolence";
    dangerous = "sudo nixos-rebuild switch --flake /etc/nixos/#ultraviolence";
    cruel-world = "clear";
    honeymoon = "fastfetch";
    west-coast = "ping google.com";
    greedy = "spotify --uri=spotify:track:3L32C3L4aC5SjJ8i9x0gV3";
    lust4life = "sudo nano ~/.config/hypr/hyprland.lua";
    
    # Atualiza os inputs, atualiza o sistema, limpa gerações antigas deixando só 5 e roda o garbage collector manual
    petal = "cd /etc/nixos && sudo nix flake update && sudo nixos-rebuild switch --upgrade --flake /etc/nixos/#ultraviolence && sudo nix profile wipe-history --older-than 5d && sudo nix-collect-garbage --delete-older-than 5d";
    
    flake = "sudo nano /etc/nixos/flake.nix";
  };

  # GNOME Software habilitado
  services.gnome.gnome-software.enable = true;

  swapDevices = [ {
    device = "/var/lib/swapfile";
    size = 8240;
    priority = 1;
  } ];

  zramSwap = {
    enable = true;
    priority = 100;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  system.stateVersion = "26.05";
}
