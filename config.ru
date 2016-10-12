#!/usr/bin/env rackup
# encoding: utf-8

$stdout.sync = true
require File.expand_path("../site.rb", __FILE__)
run Giftionary
