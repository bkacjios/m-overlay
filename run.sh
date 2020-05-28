#!/bin/bash
"$(dirname $(readlink -f $0))"
sudo love `dirname $0`/source
