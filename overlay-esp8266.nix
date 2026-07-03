final: prev: {
  gcc-xtensa-lx106-elf-bin = prev.callPackage ./pkgs/esp8266/gcc-xtensa-lx106-elf-bin.nix { };
  esp8266-nonos-sdk = prev.callPackage ./pkgs/esp8266/esp8266-nonos-sdk/esp8266-nonos-sdk.nix { };

  python3 = prev.python3.override {
	packageOverrides = pyFinal: pyPrev: let
		stubConflict = pkg: pkg.overrideAttrs (oldAttrs: {
			pythonCatchConflictsPhase = "echo 'A HACK: SKIPPING pythonCatchConflictsPhase'";
		});
	in {
		pyparsing = pyPrev.pyparsing.overrideAttrs (oldAttrs: rec {
			pname = "pyparsing";
			version = "2.3.1";
			name = "${pname}-${version}";
			src = pyPrev.fetchPypi {
				inherit pname version;
				sha256 = "sha256-ZskmiGJkGrysSpa6dFBuWUyITj9XaQppbSGtghDtZno=";
			};

			doCheck = false;
			checkInputs = [];
			nativeCheckInputs = [];

			#buildInputs = (oldAttrs.buildInputs or []) ++ [ self.setuptools ];
		});
		cryptography = pyPrev.cryptography.overrideAttrs (oldAttrs: {
			doCheck = false;
			checkInputs = [];
			nativeCheckInputs = [];
			passthru = (oldAttrs.passthru or {}) // { tests = {}; };

			pythonCatchConflictsPhase = "echo 'A HACK: SKIPPING pythonCatchConflictsPhase'";
		});

		pytest-forked = stubConflict pyPrev.pytest-forked;
		filelock = stubConflict pyPrev.filelock;
		execnet = stubConflict pyPrev.execnet;
		pytest-xdist = stubConflict pyPrev.pytest-xdist;
		hypothesis = stubConflict pyPrev.hypothesis;
		pytest-subtests = stubConflict pyPrev.pytest-subtests;
		tzdata = stubConflict pyPrev.tzdata;
	};

  };
  python = final.python3;

  pythonPackages = final.python3.pkgs;
  python3Packages = final.python3.pkgs;
  python39Packages = final.python3.pkgs;

  esp8266-rtos-sdk = final.callPackage ./pkgs/esp8266/esp8266-rtos-sdk/esp8266-rtos-sdk.nix { };
}
