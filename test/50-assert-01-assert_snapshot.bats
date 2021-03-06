#!/usr/bin/env bats

load test_helper

#
# Literal matching
#

# Correctness
@test "assert_snapshot() <expected>: returns 0 if <expected> equals \`\$output'" {
  run echo 'a'
  run assert_snapshot
  run echo 'a'
  run assert_snapshot
  [ "${#lines[@]}" -eq 0 ]
}

@test "assert_snapshot() <expected>: returns 1 and displays details if <expected> does not equal \`\$output'" {
  run echo 'a'
  run assert_snapshot
  run echo 'b'
  run assert_snapshot
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 4 ]
  [ "${lines[0]}" == '-- output differs --' ]
  [ "${lines[1]}" == 'expected : a' ]
  [ "${lines[2]}" == 'actual   : b' ]
  [ "${lines[3]}" == '--' ]
}

# Output formatting
@test "assert_snapshot() <expected>: displays details in multi-line format if \`\$output' is longer than one line" {
  run echo 'a'
  run assert_snapshot
  run printf 'b 0\nb 1'
  run assert_snapshot
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 7 ]
  [ "${lines[0]}" == '-- output differs --' ]
  [ "${lines[1]}" == 'expected (1 lines):' ]
  [ "${lines[2]}" == '  a' ]
  [ "${lines[3]}" == 'actual (2 lines):' ]
  [ "${lines[4]}" == '  b 0' ]
  [ "${lines[5]}" == '  b 1' ]
  [ "${lines[6]}" == '--' ]
}

@test 'assert_snapshot() <expected>: displays details in multi-line format if <expected> is longer than one line' {
  run echo $'a 0\na 1'
  run assert_snapshot
  run echo 'b'
  run assert_snapshot
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 7 ]
  [ "${lines[0]}" == '-- output differs --' ]
  [ "${lines[1]}" == 'expected (2 lines):' ]
  [ "${lines[2]}" == '  a 0' ]
  [ "${lines[3]}" == '  a 1' ]
  [ "${lines[4]}" == 'actual (1 lines):' ]
  [ "${lines[5]}" == '  b' ]
  [ "${lines[6]}" == '--' ]
}

# Options
@test 'assert_snapshot() <expected>: performs literal matching by default' {
  run echo 'a'
  run assert_snapshot
  run assert_snapshot '*'
  [ "$status" -eq 1 ]
}


#
# Partial matching: `-p' and `--partial'
#

# Options
test_p_partial () {
  run echo 'b'
  run assert_snapshot
  run echo 'abc'
  run assert_snapshot "$1"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test 'assert_snapshot() -p <partial>: enables partial matching' {
  test_p_partial -p
}

@test 'assert_snapshot() --partial <partial>: enables partial matching' {
  test_p_partial --partial
}

# Correctness
@test "assert_snapshot() --partial <partial>: returns 0 if <partial> is a substring in \`\$output'" {
  run printf 'b'
  run assert_snapshot
  run printf 'a\nb\nc'
  run assert_snapshot --partial
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test "assert_snapshot() --partial <partial>: returns 1 and displays details if <partial> is not a substring in \`\$output'" {
  run echo 'a'
  run assert_snapshot
  run echo 'b'
  run assert_snapshot --partial
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 4 ]
  [ "${lines[0]}" == '-- output does not contain substring --' ]
  [ "${lines[1]}" == 'substring : a' ]
  [ "${lines[2]}" == 'output    : b' ]
  [ "${lines[3]}" == '--' ]
}

# Output formatting
@test "assert_snapshot() --partial <partial>: displays details in multi-line format if \`\$output' is longer than one line" {
  run printf 'a'
  run assert_snapshot
  run printf 'b 0\nb 1'
  run assert_snapshot --partial
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 7 ]
  [ "${lines[0]}" == '-- output does not contain substring --' ]
  [ "${lines[1]}" == 'substring (1 lines):' ]
  [ "${lines[2]}" == '  a' ]
  [ "${lines[3]}" == 'output (2 lines):' ]
  [ "${lines[4]}" == '  b 0' ]
  [ "${lines[5]}" == '  b 1' ]
  [ "${lines[6]}" == '--' ]
}

@test 'assert_snapshot() --partial <partial>: displays details in multi-line format if <partial> is longer than one line' {
  run echo $'a 0\na 1'
  run assert_snapshot
  run echo 'b'
  run assert_snapshot --partial
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 7 ]
  [ "${lines[0]}" == '-- output does not contain substring --' ]
  [ "${lines[1]}" == 'substring (2 lines):' ]
  [ "${lines[2]}" == '  a 0' ]
  [ "${lines[3]}" == '  a 1' ]
  [ "${lines[4]}" == 'output (1 lines):' ]
  [ "${lines[5]}" == '  b' ]
  [ "${lines[6]}" == '--' ]
}


#
# Regular expression matching: `-e' and `--regexp'
#

# Options
test_r_regexp () {
  run echo 'abc'
  run assert_snapshot "$1" '^a'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test 'assert_snapshot() -e <regexp>: enables regular expression matching' {
  test_r_regexp -e
}

@test 'assert_snapshot() --regexp <regexp>: enables regular expression matching' {
  test_r_regexp --regexp
}

# Correctness
@test "assert_snapshot() --regexp <regexp>: returns 0 if <regexp> matches \`\$output'" {
  run printf 'a\nb\nc'
  run assert_snapshot
  run printf 'a\nb\nc'
  run assert_snapshot --regexp '.*b.*'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test "assert_snapshot() --regexp <regexp>: returns 1 and displays details if <regexp> does not match \`\$output'" {
  run echo 'b'
  run assert_snapshot
  run echo 'b'
  run assert_snapshot --regexp '.*a.*'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 4 ]
  [ "${lines[0]}" == '-- regular expression does not match output --' ]
  [ "${lines[1]}" == 'regexp : .*a.*' ]
  [ "${lines[2]}" == 'output : b' ]
  [ "${lines[3]}" == '--' ]
}

# Output formatting
@test "assert_snapshot() --regexp <regexp>: displays details in multi-line format if \`\$output' is longer than one line" {
  run printf 'b 0\nb 1'
  run assert_snapshot
  run printf 'b 0\nb 1'
  run assert_snapshot --regexp '.*a.*'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 7 ]
  [ "${lines[0]}" == '-- regular expression does not match output --' ]
  [ "${lines[1]}" == 'regexp (1 lines):' ]
  [ "${lines[2]}" == '  .*a.*' ]
  [ "${lines[3]}" == 'output (2 lines):' ]
  [ "${lines[4]}" == '  b 0' ]
  [ "${lines[5]}" == '  b 1' ]
  [ "${lines[6]}" == '--' ]
}

@test 'assert_snapshot() --regexp <regexp>: displays details in multi-line format if <regexp> is longer than one line' {
  run echo 'b'
  run assert_snapshot
  run echo 'b'
  run assert_snapshot --regexp $'.*a\nb.*'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 7 ]
  [ "${lines[0]}" == '-- regular expression does not match output --' ]
  [ "${lines[1]}" == 'regexp (2 lines):' ]
  [ "${lines[2]}" == '  .*a' ]
  [ "${lines[3]}" == '  b.*' ]
  [ "${lines[4]}" == 'output (1 lines):' ]
  [ "${lines[5]}" == '  b' ]
  [ "${lines[6]}" == '--' ]
}

# Error handling
@test 'assert_snapshot() --regexp <regexp>: returns 1 and displays an error message if <regexp> is not a valid extended regular expression' {
  run assert_snapshot
  run assert_snapshot --regexp '[.*'
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- ERROR: assert_output --' ]
  [ "${lines[1]}" == "Invalid extended regular expression: \`[.*'" ]
  [ "${lines[2]}" == '--' ]
}


#
# Common
#

@test "assert_snapshot(): \`--partial' and \`--regexp' are mutually exclusive" {
  run assert_snapshot
  run assert_snapshot --partial --regexp
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[0]}" == '-- ERROR: assert_output --' ]
  [ "${lines[1]}" == "\`--partial' and \`--regexp' are mutually exclusive" ]
  [ "${lines[2]}" == '--' ]
}

@test "assert_snapshot(): \`--' stops parsing options" {
  run echo '-p'
  run assert_snapshot -- '-p'
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
}

@test "assert_snapshot() status: return 1 if status is not match" {
  run exit 1
  run assert_snapshot
  run exit 0
  run assert_snapshot
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 4 ]
  [ "${lines[0]}" == '-- status do not equal --' ]
  [ "${lines[1]}" == 'expected : 1' ]
  [ "${lines[2]}" == 'actual   : 0' ]
  [ "${lines[3]}" == '--' ]
}

@test "assert_snapshot() status: return 1 if status is not match" {
  run exit 0
  run assert_snapshot
  run exit 1
  run assert_snapshot
  [ "$status" -eq 1 ]
  [ "${#lines[@]}" -eq 4 ]
  [ "${lines[0]}" == '-- status do not equal --' ]
  [ "${lines[1]}" == 'expected : 0' ]
  [ "${lines[2]}" == 'actual   : 1' ]
  [ "${lines[3]}" == '--' ]
}
