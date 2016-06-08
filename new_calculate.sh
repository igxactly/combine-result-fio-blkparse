#!/usr/bin/env bash

yabtago all.blktrace yabtago_result.json;

combine-results.rb fio_result.json yabtago_result.json breakdown_yabtago.json > breakdown_yabtago.csv;
