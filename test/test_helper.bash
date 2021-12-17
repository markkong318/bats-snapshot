setup() {
  export TEST_MAIN_DIR="${BATS_TEST_DIRNAME}/.."
  export TEST_DEPS_DIR="${TEST_MAIN_DIR}/node_modules"
  export TEST_SNAPSHOT_DIR="${BATS_TEST_DIRNAME}/__snapshot__"

  # Load dependencies.
  load "${TEST_DEPS_DIR}/bats-support/load.bash"
  load "${TEST_DEPS_DIR}/bats-assert/load.bash"

  # Load library.
  load '../load'
}

teardown() {
#  rm -rf $TEST_SNAPSHOT_DIR
}
