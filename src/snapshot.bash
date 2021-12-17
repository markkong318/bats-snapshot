# Fail and display details if `$output' does not match the expected
# output. The expected output can be specified either by the first
# parameter or on the standard input.
#
# By default, literal matching is performed. The assertion fails if the
# expected output does not equal `$output'. Details include both values.
#
# Option `--partial' enables partial matching. The assertion fails if
# the expected substring cannot be found in `$output'.
#
# Option `--regexp' enables regular expression matching. The assertion
# fails if the extended regular expression does not match `$output'. An
# invalid regular expression causes an error to be displayed.
#
# It is an error to use partial and regular expression matching
# simultaneously.
#
# Globals:
#   output
# Options:
#   -p, --partial - partial matching
#   -e, --regexp - extended regular expression matching
# Arguments:
#   $1 - [=STDIN] expected output
# Returns:
#   0 - expected matches the actual output
#   1 - otherwise
# Inputs:
#   STDIN - [=$1] expected output
# Outputs:
#   STDERR - details, on failure
#            error message, on error
assert_snapshot() {
  dir="$BATS_TEST_DIRNAME/__snapshot__"

  if [ ! -e $dir ]; then
    mkdir $dir
  fi

  file="$BATS_TEST_DIRNAME/__snapshot__/$(basename ${BATS_TEST_FILENAME%.*})-$(printf %02d $BATS_TEST_NUMBER)-$BATS_TEST_NAME.snap"

  if [ ! -e $file ]; then
    if [ -z $status ]; then
       echo "0" >> $file
     else
       echo "$status" >> $file
     fi
#    [[ -z $status ]] && echo 0 || echo "$status" >> $file
    echo "$output" >> $file
    return
  fi


  snapshot_status=$(head -n 1 $file)
  if [[ $status != "$snapshot_status" ]]; then
    batslib_print_kv_single_or_multi 8 \
        'expected' "$snapshot_status" \
        'actual'   "$status" \
      | batslib_decorate 'status do not equal' \
      | fail
      return 1
  fi

  snapshot_output=$(tail -n +2 $file)
  assert_output "$@" "$snapshot_output"
}
