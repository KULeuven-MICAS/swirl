#!/bin/bash

set -e

CURRENT_DIR=$(pwd)
WORK_DIR=$(dirname $0)
if [ $WORK_DIR != $CURRENT_DIR ]; then
  cd $WORK_DIR
fi

smoke_test_nopipe() {
  echo "Smoke test ..."
  DEFINES="+define+SMOKE_TEST=1+DATAW=8+PIPES=0" make clean questa-run
}

smoke_test_pipe() {
  echo "Smoke test ..."
  DEFINES="+define+SMOKE_TEST=1+DATAW=8+PIPES=1" make clean questa-run
}

smoke_test_2xpipe() {
  echo "Smoke test ..."
  DEFINES="+define+SMOKE_TEST=1+DATAW=8+PIPES=2" make clean questa-run
}

smoke_test_nobackpress_rndvalid() {
  echo "Smoke test ..."
  DEFINES="+define+SMOKE_TEST=1+DATAW=8+PIPES=2+RND_VALID=1" make clean questa-run
}

smoke_test_backpressure() {
  echo "Smoke test ..."
  DEFINES="+define+SMOKE_TEST=1+DATAW=8+PIPES=1+BACKPRESSURE=1" make clean questa-run
}

smoke_test_backpressure_2xpipe() {
  echo "Smoke test ..."
  DEFINES="+define+SMOKE_TEST=1+DATAW=8+PIPES=2+BACKPRESSURE=1" make clean questa-run
}

smoke_test_rndvalid() {
  echo "Smoke test ..."
  DEFINES="+define+SMOKE_TEST=1+DATAW=8+PIPES=1+BACKPRESSURE=1+RND_VALID=1" make clean questa-run
}

smoke_test_rndready() {
  echo "Smoke test ..."
  DEFINES="+define+SMOKE_TEST=1+DATAW=8+PIPES=1+BACKPRESSURE=1+RND_READY=1" make clean questa-run
}

smoke_test_rndhs() {
  echo "Smoke test ..."
  DEFINES="+define+SMOKE_TEST=1+DATAW=8+PIPES=1+BACKPRESSURE=1+RND_VALID=1+RND_READY=1" make clean questa-run
}

smoke_test_rndhs_2xpipe() {
  echo "Smoke test ..."
  DEFINES="+define+SMOKE_TEST=1+DATAW=8+PIPES=2+BACKPRESSURE=1+RND_VALID=1+RND_READY=1" make clean questa-run
}

rnd_test() {
  echo "Random test ..."
  DEFINES="+define+DATAW=8+PIPES=10+BACKPRESSURE=1+RND_VALID=1+RND_READY=1" make clean questa-run
}

usage()
{
    echo "Usage: $0 [options]"
    echo "  -smoke-nopipe: Run smoke test without pipeline"
    echo "  -smoke-pipe: Run smoke test with pipeline"
    echo "  -smoke-2xpipe: Run smoke test with 2x pipeline"
    echo "  -smoke-backpressure: Run smoke test with backpressure"
    echo "  -smoke-backpressure-2xpipe: Run smoke test with backpressure and 2x pipeline"
    echo "  -smoke-rndvalid: Run smoke test with random valid signal"
    echo "  -smoke-rndready: Run smoke test with random ready signal"
    echo "  -smoke-rndhs: Run smoke test with random valid and ready signal"
    echo "  -smoke-rndhs-2xpipe: Run smoke test with random valid and ready signal and 2x pipeline"
    echo "  -rnd: Run random test"
    echo "  -all: Run all tests"
}

while [ "$1" != "" ]; do
  case $1 in
    -smoke-nopipe ) smoke_test_nopipe
        ;;
    -smoke-pipe ) smoke_test_pipe
        ;;
    -smoke-2xpipe ) smoke_test_2xpipe
        ;;
    -smoke-nobackpress-rndvalid ) smoke_test_nobackpress_rndvalid
        ;;
    -smoke-backpressure ) smoke_test_backpressure
        ;;
    -smoke-backpressure-2xpipe ) smoke_test_backpressure_2xpipe
        ;;
    -smoke-rndvalid ) smoke_test_rndvalid
        ;;
    -smoke-rndready ) smoke_test_rndready
        ;;
    -smoke-rndhs ) smoke_test_rndhs
        ;;
    -smoke-rndhs-2xpipe ) smoke_test_rndhs_2xpipe
        ;;
    -rnd ) rnd_test
        ;;
    -all ) smoke_test_nopipe
           smoke_test_pipe
           smoke_test_2xpipe
           smoke_test_nobackpress_rndvalid
           smoke_test_backpressure
           smoke_test_backpressure_2xpipe
           smoke_test_rndvalid
           smoke_test_rndready
           smoke_test_rndhs
           smoke_test_rndhs_2xpipe
           rnd_test
        ;;
    -h | --help ) usage
        exit
        ;;
    * ) echo "Invalid option"
        exit 1
  esac
  shift

  cd $CURRENT_DIR
done