#!/bin/sh

cd ./install
rm -rf build
mkdir build
cd build

cmake ${CMAKE_ARGS} -GNinja $SRC_DIR \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_TESTING:BOOL=ON \
      -DZENOHCXX_ZENOHC:BOOL=ON \
      -DZENOHCXX_ZENOHPICO:BOOL=OFF \
      -DZENOHCXX_EXAMPLES_PROTOBUF:BOOL=OFF

cmake --build . --config Release
cmake --build . --config Release --target install
cmake --build . --config Release --target tests


if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
  # Best-effort raise locked-memory (memlock) limit.
  # CI/container may ignore or cap this, so we don't hard-fail.
  if [[ "${target_platform}" == linux-* ]] && command -v prlimit >/dev/null 2>&1; then
    prlimit --pid="$$" --memlock=unlimited || echo "prlimit memlock failed (CI cap?)"
  fi
  ctest --output-on-failure -C Release 
fi
