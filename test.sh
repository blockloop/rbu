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
	exp=infile.txt.2
	[ -f "$exp" ] && fail "expected $exp to not exist" && return
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
	exp=infile.txt.3
	[ -f "$exp" ] && fail "expected $exp to NOT exist" && return
	pass
}

function testShouldUseSpefiedDir() {
	uuidgen > infile.txt
	mkdir baks
	rbu -d baks -a infile.txt
	exp=infile.txt.1
	[ -f "$exp" ] && fail "expected $exp to NOT exist" && return
	exp=baks/infile.txt.1
	[ -f "$exp" ] && pass && return
	fail "expected $exp to NOT exist"
}

function testShouldCreateSpefiedDirIfItDoesNotExist() {
	uuidgen > infile.txt
	rbu -d baks -a infile.txt
	[ -d "baks" ] && pass && return
	fail "expected $exp to be created"
}

function testShouldErrorIfInfileIsDirectory() {
	mkdir baks
	if log="$(rbu baks &> /dev/stdout)"; then
		fail "expected exit > code 0"
	fi
	[[ "$log" == *is\ a\ directory* ]] && pass && return
	fail "expected '$log' to say infile is directory"
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
