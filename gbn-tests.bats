#!/usr/bin/env bats

setup() {
	# Create isolated temp workspace per test
	TMPDIR_BASE=$(mktemp -d "${BATS_TMPDIR}/gbn.XXXXXX")
	cp gbn $TMPDIR_BASE
	cd "$TMPDIR_BASE"
	chmod +x ./gbn

	# Init repo and configure
	git init -q
	git config user.email test@example.com
	git config user.name "GBN Test"

}

teardown() {
	# Return to previous dir and clean temp
	cd "$BATS_TEST_DIRNAME"
	rm -rf "$TMPDIR_BASE"
}

# Helper: assert stdout contains pattern (basic)
assert_output_contains() {
	local pattern="$1"
	[[ "$output" == *"$pattern"* ]]
}

@test "status lists indexed porcelain entries" {
	echo "alpha" > a.txt
	git add a.txt
	echo "beta" > b.txt
	# Untracked file c
	echo "gamma" > "c file.txt"

	run ./gbn status
	[ "$status" -eq 0 ]

	# Should print lines with indices and file names
	assert_output_contains "a.txt"
	assert_output_contains "b.txt"
	assert_output_contains "c file.txt"
}

@test "add by single index stages file" {
	echo foo > foo.txt
	echo bar > bar.txt

	# Get indices from status
	run ./gbn status
	[ "$status" -eq 0 ]

	# Expect untracked entries; choose index for foo.txt
	# Find line number prefix before foo.txt
	idx=$(printf "%s" "$output" | awk '/foo.txt/ {print $1}')

	run ./gbn add "$idx"
	[ "$status" -eq 0 ]

	# Verify staged
	run git status --porcelain
	[ "$status" -eq 0 ]
	assert_output_contains "A  foo.txt"
}

@test "add by range and comma list" {
	echo one > one.txt
	echo two > two.txt
	echo three > three.txt

	run ./gbn status
	[ "$status" -eq 0 ]

	# Capture indices for three files in order of appearance
	i1=$(printf "%s" "$output" | awk '/one.txt/ {print $1}')
	i2=$(printf "%s" "$output" | awk '/two.txt/ {print $1}')
	i3=$(printf "%s" "$output" | awk '/three.txt/ {print $1}')

	# Construct a range i1-i2 and add i3 via comma
	run ./gbn add "${i1}-${i2},${i3}"
	[ "$status" -eq 0 ]

	run git status --porcelain
	[ "$status" -eq 0 ]
	assert_output_contains "A  one.txt"
	assert_output_contains "A  two.txt"
	assert_output_contains "A  three.txt"
}

@test "diff --staged shows changes for selected indices" {
	echo hello > staged.txt
	git add staged.txt
	echo world >> staged.txt

	# Determine index for staged.txt from status
	run ./gbn status
	[ "$status" -eq 0 ]
	idx=$(printf "%s" "$output" | awk '/staged.txt/ {print $1; exit}')

	run ./gbn diff --staged "$idx"
	[ "$status" -eq 0 ]
	# --staged shows what's staged (hello), not working tree changes (world)
	assert_output_contains "+hello"
}

@test "restore --staged with --yes resets staged entry" {
	# Need an initial commit for restore --staged to work
	echo init > init.txt
	git add init.txt
	git commit -qm "initial"

	echo content > x.txt
	git add x.txt
	echo more >> x.txt

	run ./gbn status
	[ "$status" -eq 0 ]
	idx=$(printf "%s" "$output" | awk '/x.txt/ {print $1; exit}')

	run ./gbn restore --staged --yes "$idx"
	[ "$status" -eq 0 ]

	# After restore --staged, staged diff should be empty for x.txt
	run git diff --staged --name-only
	[ "$status" -eq 0 ]
	[ -z "$output" ]
}

@test "restore dry-run prints command without executing" {
	# Need an initial commit for restore --staged to work
	echo init > init.txt
	git add init.txt
	git commit -qm "initial"

	echo stuff > y.txt
	git add y.txt
	echo changed >> y.txt

	run ./gbn status
	[ "$status" -eq 0 ]
	idx=$(printf "%s" "$output" | awk '/y.txt/ {print $1; exit}')

	run ./gbn restore --staged -n "$idx"
	[ "$status" -eq 0 ]
	assert_output_contains "Dry run: git restore --staged -- y.txt"

	# Ensure staged diff still exists (not restored)
	run git diff --staged --name-only
	[ "$status" -eq 0 ]
	assert_output_contains "y.txt"
}

@test "checkout restores file from HEAD by index" {
	echo base > z.txt
	git add z.txt
	git commit -qm "add z"

	echo change >> z.txt

	run ./gbn status
	[ "$status" -eq 0 ]
	idx=$(printf "%s" "$output" | awk '/z.txt/ {print $1}')

	run ./gbn checkout "$idx"
	[ "$status" -eq 0 ]

	# Working tree should match HEAD
	run git diff -- z.txt
	[ "$status" -eq 0 ]
	[ -z "$output" ]
}

@test "rm --cached removes from index only by index" {
	echo tracked > t.txt
	git add t.txt
	git commit -qm "track t"

	# Stage a rename/add so porcelain lists file
	echo change >> t.txt
	git add t.txt

	run ./gbn status
	[ "$status" -eq 0 ]
	idx=$(printf "%s" "$output" | awk '/t.txt/ {print $1}')

	run ./gbn rm --cached --yes "$idx"
	[ "$status" -eq 0 ]

	# File remains in working tree, not in index (porcelain should show ??)
	run git status --porcelain
	[ "$status" -eq 0 ]
	assert_output_contains "?? t.txt"
}
