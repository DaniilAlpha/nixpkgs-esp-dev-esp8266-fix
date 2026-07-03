{
  rev ? "c965e03d2b7418b085c394dc98c6a0d3371c2abd",
  sha256 ? "sha256-84vTz0xMUPp2bhedcJTiwAGlP8mIwt8R9XE6bf0tCC4=",
  extraPythonPackages ? (pythonPackages: [ ]),
  stdenv,
  fetchFromGitHub,

  python3,

  # Tools for using ESP8266_RTOS_SDK.
  git,
  wget,
  gnumake,
  flex,
  bison,
  gperf,
  pkg-config,
  ncurses5,

  cmake,
  ninja,

  gcc-xtensa-lx106-elf-bin,
  esptool,
} : let
  customPython = (
    python3.withPackages (
      pythonPackages:
      with pythonPackages;
      [
        # This list is from `requirements.txt` in the ESP8266_RTOS_SDK
        # checkout.
        setuptools
        click
        pyserial
        future
	cryptography

	pyparsing

        pyelftools
      ]
      ++ (extraPythonPackages pythonPackages)
    )
  );
in
stdenv.mkDerivation rec {
  pname = "esp8266-rtos-sdk";
  version = rev;

  src = fetchFromGitHub {
    owner = "espressif";
    repo = "ESP8266_RTOS_SDK";
    rev = rev;
    sha256 = sha256;
    fetchSubmodules = true;
  };

  setupHook = ./setup-hook.sh;

  propagatedBuildInputs = [
    # This is in propagatedBuildInputs so that downstream derivations will run
    # the Python setup hook and get PYTHONPATH set up correctly.
    customPython

    gcc-xtensa-lx106-elf-bin
    esptool

    # Tools required to use ESP8266_RTOS_SDK.
    git
    wget
    gnumake

    flex
    bison
    gperf
    pkg-config

    cmake
    ninja

    ncurses5
  ];

  # We are including cmake and ninja so that downstream derivations (eg. shells)
  # get them in their environment, but we don't actually want any of their build
  # hooks to run, since we aren't building anything with them right now.
  dontUseCmakeConfigure = true;
  dontUseNinjaBuild = true;
  dontUseNinjaInstall = true;
  dontUseNinjaCheck = true;

  #preBuild = ''
  #  export PYTHONPATH="$PYTHONPATH":"${pyparsing-2-3-1}/${python3.sitePackages}"
  #'';

  installPhase = ''
    mkdir -p $out
    cp -rv . $out/

    # Link the Python environment in so that:
    # - In shell derivations, the Python setup hook will add the site-packages
    #   directory to PYTHONPATH.
    ln -s ${customPython} $out/python-env
    ln -s ${customPython}/lib $out/lib
  '';

  meta.broken = false;
}
