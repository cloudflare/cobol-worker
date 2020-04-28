set -e

mkdir -p build

export EM_ARGS="-O3"
EM_ARGS+=" -s INITIAL_MEMORY=64KB"
EM_ARGS+=" -s TOTAL_STACK=10KB"
EM_ARGS+=" -s ASSERTIONS=0"
EM_ARGS+=" -s ALLOW_MEMORY_GROWTH=1"
EM_ARGS+=" -s FILESYSTEM=0"
EM_ARGS+=" -s ENVIRONMENT='web'"

export EM_OUT=/build/out.js

docker run \
  -e EM_OUT \
  -e EM_ARGS \
  -v /tmp/cobol-worker:/root/.emscripten_cache/ \
  -v $PWD:/worker \
  -v $PWD/build:/build \
  xtuc/cobaul \
  /worker/src/worker.cob

sed -i.bu 's/import\.meta/({})/' build/out.js
echo "$(cat src/pre.js);$(cat build/out.js)" > build/out.js
