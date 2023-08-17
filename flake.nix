{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgs = forAllSystems (system: nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (system: {
        default = pkgs.${system}.poetry2nix.mkPoetryApplication { projectDir = self; };
      });

      devShells = forAllSystems (system: {
        default = pkgs.${system}.mkShellNoCC {
          packages = with pkgs.${system}; [
            # (poetry2nix.mkPoetryEnv {
            #   projectDir = fetchFromGitHub {
            #     owner = "stan-dev";
            #     repo = "pystan";
            #     rev = "3.7.0";
            #     hash = "sha256-lhBug5jKCcvdiPR1GMx08J+ZuYwaPKhV6lFTUS/2Av8=";  # lib.fakeSha256;
            #   };
            # })

            #poetry

            (with python3Packages; buildPythonPackage rec {
              pname = "pystan";
              version = "3.7.0";
              src = fetchPypi {
                inherit pname version;
                sha256 = "sha256-4RMyH0XX90QSsPvRwqM+CSyc9Sse5sFf6yjVO2gDqtc=";
              };
              # doCheck = false;
              propagatedBuildInputs = [
                aiohttp
                #httpstan = "~4.10"
                (buildPythonPackage rec {
                  pname = "httpstan";
                  version = "4.10.1";
                  format = "pyproject";
                  src = fetchFromGitHub {  # source not available on PyPI
                    owner = "stan-dev";
                    repo = pname;
                    rev = version;
                    hash = "sha256-OrEwyEZzwDmUcZrCowYIONf3tPGQaB2Cp5BKGCZIlNQ=";  # lib.fakeSha256;
                  };
                  # doCheck = false;
                  nativeBuildInputs = [
                    poetry-core
                  ];
                  propagatedBuildInputs = [
                    aiohttp
                    appdirs
                    webargs
                    marshmallow
                    numpy
                    setuptools  # gets used at runtime
                  ];
                  # need to patch conftest to use @pytest_asyncio.fixture if we want to run tests...
                  # nativeCheckInputs = [
                  #   pytestCheckHook
                  #   # apispec
                  #   pytest-asyncio
                  # ];
                  # pytestFlagsArray = [
                  #   "--ignore=tests/test_openapi_spec.py"
                  # ];
                  # # ] ++ apispec.optional-dependencies.yaml
                  # #   ++ apispec.optional-dependencies.validation;
                })
                # pysimdjson
                (buildPythonPackage rec {
                  pname = "pysimdjson";
                  version = "5.0.2";
                  src = fetchPypi {
                    inherit pname version;
                    sha256 = "sha256-gwEPB/nKOORVe2GGCs/rCol7QW8G9zGC/6/6lL23OU0=";
                  };
                  # doCheck = false;
                  propagatedBuildInputs = [
                  ];
                })
                numpy
                clikit
              ];
            })
          ];
        };
      });
    };
}
