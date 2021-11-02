# bats-snapshot

`bats-snapshot` is a helper library providing snapshot assertions for
Bats. This package is based on `bats-assert`

Dependencies:
- [`bats-support`][bats-support] (formerly `bats-core`) - output
  formatting
- [`bats-assert`][bats-assert] (formerly `bats-core`) - assertions

## Install

In bats test
```
load '../node_modules/bats-support/load'
load '../node_modules/bats-assert/load'
load '../node_modules/bats-snapshot/load'
```

## Usage

### `assert_snapshot`

Fail if the output is not the same as snapshot

In first time calling, it will save the status and output into `./__snapshot__`. In the second time, it will load the snapshot and try to match the current status and output

```bash
@test 'assert()' {
  run echo 'foo'
  assert_snapshot
}
```

On failure, the failed expression is displayed.

```
   -- output differs --
   expected : foo
   actual   : bar
   --
```

#### Partial matching

Partial matching can be enabled with the `--partial` option (`-p` for
short). When used, the assertion fails if the expected *substring* is
not found in `$output`.

```bash
@test 'assert_snapshot() partial matching' {
  run echo 'SUCCESS'
  assert_snapshot
  run echo 'ERROR: no such file or directory'
  assert_snapshot --partial
}
```

On failure, the substring and the output are displayed.

```
-- output does not contain substring --
substring : SUCCESS
output    : ERROR: no such file or directory
--
```

This option and regular expression matching (`--regexp` or `-e`) are
mutually exclusive. An error is displayed when used simultaneously.

#### Regular expression matching

Regular expression matching can be enabled with the `--regexp` option
(`-e` for short). When used, the assertion fails if the *extended
regular expression* does not match `$output`.

*Note: The anchors `^` and `$` bind to the beginning and the end of the
entire output (not individual lines), respectively.*

```bash
@test 'assert_snapshot() regular expression matching' {
  run echo '^Foobar v[0-9]+\.[0-9]+\.[0-9]$'
  assert_snapshot
  run echo 'Foobar 0.1.0'
  assert_snapshot --regexp 
}
```

On failure, the regular expression and the output are displayed.

```
-- regular expression does not match output --
regexp : ^Foobar v[0-9]+\.[0-9]+\.[0-9]$
output : Foobar 0.1.0
--
```

An error is displayed if the specified extended regular expression is
invalid.

This option and partial matching (`--partial` or `-p`) are mutually
exclusive. An error is displayed when used simultaneously.

