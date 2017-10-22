#!/usr/bin/env bash

# COLORS
NC='\033[0m'       # Text Reset
RED='\033[0;31m'   # Red
GREEN='\033[0;32m' # Green


tests="$(grep -E '^function test(.*)' test.sh | awk '{print $2}' | grep -E -o '\w+')"
PATH=$PWD:$PATH
pushd "$(mktemp -d -t tmp.XXXXXXXXX)" > /dev/null
function finish {
	popd &> /dev/null
}
trap finish EXIT

# this is not exactly a test of rbu directly but ensures that the README.md has
# the usage updated and correct
function testShouldHaveUsageInREADME() {
	readme="$(dirname "$(which rbu)")/README.md"
	if [[ "$(cat "$readme")" == *"$(rbu -h)"* ]]; then
		pass
	else
		fail "README.md does not contain all of 'rbu -h'"
	fi
}

function testShouldAlwaysCreateFirstBackup() {
	uuidgen > infile.txt
	rbu infile.txt
	exp=infile.txt.1
	[ -f $exp ] && pass && return
	fail "expected $exp"
}

function testShouldNotBackupIdenticalFiles() {
	uuidgen > infile.txt
	cp infile.txt infile.txt.1
	rbu infile.txt > /dev/null
	[ -f infile.txt.2 ] && \
		fail "expected infile.txt.2 to not exist" && \
		return
	pass
}

function testShouldBackupChangedFiles() {
	uuidgen > infile.txt
	uuidgen > infile.txt.1
	rbu infile.txt > /dev/null
	exp=infile.txt.2
	[ -f "$exp" ] && pass && return
	fail "expected $exp to not exist"
}

function testShouldBackupIdenticalFilesWithFlag() {
	uuidgen > infile.txt
	cp infile.txt infile.txt.1
	rbu -a infile.txt
	exp=infile.txt.2
	[ -f "$exp" ] && pass && return
	fail "expected $exp to exist"
}

function testShouldNotExceedMax() {
	uuidgen > infile.txt
	for _ in $(seq 3); do
		rbu -m 2 -a infile.txt
	done
	[ -f infile.txt.3 ] && \
		fail "expected infile.txt.3 to NOT exist" && \
		return
	pass
}

function testShouldUseSpecifiedDir() {
	uuidgen > infile.txt
	mkdir baks
	rbu -d baks -a infile.txt

	[ -f infile.txt.1 ] && \
		fail "expected infile.txt.1 to NOT exist" && \
		return

	[ -f baks/infile.txt.1 ] && pass && return
	fail "expected baks/infile.txt.1 to NOT exist"
}

function testShouldCreateSpecifiedDirIfItDoesNotExist() {
	uuidgen > infile.txt
	rbu -d baks -a infile.txt
	[ -d "baks" ] && pass && return
	fail "expected $exp to be created"
}

function testShouldErrorIfInfileIsDirectory() {
	mkdir baks
	if log="$(rbu baks &> /dev/stdout)"; then
		fail "expected exit code 1"
	fi
	[[ "$log" == *is\ a\ directory* ]] && pass && return
	fail "expected '$log' to say infile is directory"
}

function testShouldErrorWhenNoFileSpecified() {
	if log="$(rbu -m 10 &> /dev/stdout)"; then
		fail "expected exit code 1"
	fi
	[[ "$log" == *Usage* ]] && pass && return
	fail "expected '$log' to say infile is directory"
}

function testShouldMoveDotOneToDotTwo() {
	uuidgen > infile.txt
	uuidone="$(uuidgen | tee infile.txt.1)"

	rbu infile.txt

	[ ! -f "infile.txt.2" ] && \
		fail "expected infile.txt.2 to exist" && \
		return
	[ "$(cat infile.txt.2)" == "$uuidone" ] && \
		pass && \
		return

	fail "expected infile.txt.1 to have been moved to infile.txt.2"
}

function pass() {
	echo -e "${GREEN}OK${NC}"
}

function fail() {
	echo -e "${RED}FAIL${NC}: $1"
}

for t in $tests; do
	pushd "$(mktemp -d -t tmp.XXXXXXXXX)" > /dev/null
	echo -n "$t: "
	eval "$t"
	popd > /dev/null
done
