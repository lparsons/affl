#!/usr/bin/env ruby
# frozen_string_literal: true

require 'html-proofer'

options = {
  assume_extension: '.html',
  directory_index_files: ['index.html'],
  disable_external: true,
  allow_hash_href: true,
  check_internal_hash: false,
  check_external_hash: false,
  enforce_https: false,
  ignore_empty_alt: true,
  ignore_urls: [%r{^https?://}],
  swap_urls: {
    %r{^/affl/} => '/',
    %r{^/affl$} => '/'
  }
}

puts '🔍 Running HTMLProofer on ./_site ...'

begin
  HTMLProofer.check_directory('./_site', options).run
  puts '✅ HTMLProofer validation passed successfully!'
rescue StandardError => e
  warn "❌ HTMLProofer found errors:\n#{e.message}"
  exit 1
end
