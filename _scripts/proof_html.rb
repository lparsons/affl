#!/usr/bin/env ruby
# frozen_string_literal: true

# Validates generated HTML and site hyperlinks (internal and external)
begin
  require 'html-proofer'
rescue LoadError => e
  warn "⚠️ html-proofer or libcurl is not available (#{e.message}); skipping HTML proofing locally."
  exit 0
end

options = {
  assume_extension: '.html',
  directory_index_files: ['index.html'],
  disable_external: false,
  allow_hash_href: true,
  check_internal_hash: false,
  check_external_hash: false,
  enforce_https: false,
  ignore_empty_alt: true,
  ignore_files: [%r{^vendor/}, %r{^node_modules/}],
  swap_urls: {
    %r{^/affl/} => '/',
    %r{^/affl$} => '/'
  },
  typhoeus: {
    headers: { 'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36' },
    ssl_verifypeer: true,
    connecttimeout: 10,
    timeout: 30
  }
}

puts '🔍 Running HTMLProofer on ./_site (validating internal & external URLs)...'

begin
  HTMLProofer.check_directory('./_site', options).run
  puts '✅ HTMLProofer validation passed successfully!'
rescue StandardError => e
  warn "❌ HTMLProofer found errors:\n#{e.message}"
  exit 1
end
