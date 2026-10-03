#!/usr/bin/env ruby
# frozen_string_literal: true

require 'html-proofer'

options = {
  disable_external: true,
  allow_hash_href: true,
  enforce_https: false,
  ignore_empty_alt: true,
  swap_urls: {
    %r{^/affl} => ''
  }
}

puts '🔍 Running HTMLProofer on ./_site ...'

begin
  HTMLProofer.check_directory('./_site', options).run
  puts '✅ HTMLProofer validation passed successfully!'
rescue StandardError => e
  puts "❌ HTMLProofer found errors:\n#{e.message}"
  exit 1
end
