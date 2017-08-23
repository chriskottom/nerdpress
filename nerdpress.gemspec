# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nerdpress/version'

Gem::Specification.new do |spec|
  spec.name          = 'nerdpress'
  spec.version       = NerdPress::VERSION
  spec.authors       = ['chriskottom']
  spec.email         = ['chris@chriskottom.com']

  spec.summary       = %q{A programmer-friendly ebook toolchain}
  spec.description = <<-EOF
    NerdPress is a drop-in library that lets programmers write and
    publish their own ebooks using the tools most familiar to them -
    a text editor and the command line. It supports editing content in
    HTML and Markdown, styling in CSS and Sass, syntax highlighting for
    all major programming languages, and simple export in several
    common formats.
  EOF
  spec.homepage      = 'https://github.com/chriskottom/nerdpress'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'bin'
  spec.executables   = %w(nerdpress)
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'minitest', '~> 5.10'
  spec.add_development_dependency 'simplecov', '~> 0.14'

  spec.add_dependency 'thor', '~> 0.19'
  spec.add_dependency 'github-markup', '~> 1.6.1'
  spec.add_dependency 'commonmarker', '~> 0.16'
  spec.add_dependency 'sass', '~> 3.5'
  spec.add_dependency 'nokogiri', '~> 1.8'
end
