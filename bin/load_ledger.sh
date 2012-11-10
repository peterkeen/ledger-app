#!/bin/bash

export PATH=$PATH:/usr/local/bin:../bin

DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $DIR/..

foreman run load



