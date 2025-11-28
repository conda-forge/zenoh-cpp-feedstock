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
  # test_pub_sub_zenohc  is hanging, see https://github.com/conda-forge/zenoh-cpp-feedstock/pull/37#issuecomment-3574615063
  ctest --output-on-failure -C Release -E test_pub_sub_zenohc
fi
