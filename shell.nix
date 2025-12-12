{ pkgs ? import <nixpkgs> {} }:

let
  arduino-core = pkgs.arduino-core-unwrapped;
in

pkgs.mkShell {
  buildInputs = with pkgs; [
    arduino-cli
    arduino-core
    avrdude
    arduino
    libudev-zero
    gnumake
    pkgs.pkgsCross.avr.buildPackages.gcc
    screen
  ];

  shellHook = ''
    export ARDUINO_DIR=${arduino-core}/share/arduino
    export ARDUINO_CORE_PATH=${arduino-core}/share/arduino/hardware/arduino/avr
    export ARDUINO_BOOTLOADER_PATH=${arduino-core}/share/arduino/hardware/arduino/avr/bootloaders
    export ARDUINO_VAR_PATH=${arduino-core}/share/arduino/hardware/arduino/avr/variants
    export PATH="$PATH:${pkgs.arduino-core}/share/arduino/"
    export PATH="$PATH:${pkgs.arduino}/share/arduino/hardware/tools/avr/bin/"
    
    mkdir -p /tmp/arduino-cli
    mkdir -p /tmp/arduino-cli/staging
    mkdir -p /tmp/arduino-cli/sketchbook
    mkdir -p /tmp/arduino-cli/packages
    
    if [ ! -d "/tmp/arduino-cli/packages/arduino/hardware/avr" ]; then
      echo "Installing Arduino AVR core..."
      mkdir -p /tmp/arduino-cli/packages/arduino/hardware/avr
      ln -sf ${arduino-core}/share/arduino/hardware/arduino/avr/* /tmp/arduino-cli/packages/arduino/hardware/avr/
    fi
  '';
}
