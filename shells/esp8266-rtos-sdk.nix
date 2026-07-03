{
  pkgs-old }:

pkgs-old.mkShell {
  name = "esp8266-rtos-sdk-shell";

  buildInputs = with pkgs-old; [
    esp8266-rtos-sdk
  ];
}
