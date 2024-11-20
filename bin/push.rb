#!/bin/bash

new_version=$(bin/bump.rb 1 | tail -n 1)
echo $new_version
echo gem build
gem build
echo gem push ops_backups-$new_version.gem
gem push ops_backups-$new_version.gem
