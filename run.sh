#!/bin/bash
cd "$(dirname $(readlink -f $0))"
love `dirname $0`/source
