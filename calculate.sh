#!/usr/bin/env bash

yabtar.rb all.blktrace yabtar_result.json;

combine-results.rb fio_result.json yabtar_result.json breakdown.json > breakdown.csv;
