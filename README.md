# NerdPress

NerdPress is ebook publishing software written for programmers, designers, and others comfortable with the command line.

## Features

* Generate a new ebook project from the command line.
* Export your book to HTML, PDF, EPUB and MOBI formats.
* Manage and store project files in a simple directory structure.
* Use Markdown and HTML to write sections of your ebook.
* Modify the look and feel of exported versions using CSS and Sass.
* Built to make syntax highlighting and inline code and code block styling a top priority.
* Uses a modular design that lets developers make the changes they need.

## Default Dependencies

Certain tasks rely on external dependencies for proper execution:

* DocRaptor - PDF generation
* ???? - EPUB generation
* ???? - MOBI generation

These dependencies are isolated as Ruby classes within the architecture so that developers are able to swap them out for other equivalent services as needed.

## Installation

Add the gem to an existing project simply  by adding a Gemfile (either via `bundle init`) or by creating one by hand:

```bash
$:> cd new_ebook
$:> bundle init
Writing new Gemfile to /home/user/projects/new_ebook/Gemfile
```

Then add the following line to the Gemfile:

```ruby
gem 'nerdpress'
```

Alternately, you can install the gem globally (or within a gemset depending on how you manage Rubies on your workstation) and use the command line generator to create a new empty project directory.

```bash
$:> gem install nerdpress
$:> nerdpress new new_ebook
```

Both cases use Bundler to manage NerdPress and its dependencies, so:

```bash
$:> bundle install
```

TODO: revisit invocations and outputs after command line generator is working.

## Usage

A NerdPress project is just a local directory that follows a prescribed structure.

```
.
├── images/
├── sections/
├── stylesheets/
├── .gitignore
├── config.yml
└── Gemfile
```

The main text of your book can be written as a sorted set of Markdown and HTML files in the `sections/` directory. NerdPress will automatically recognize any files with common extensions for Markdown or HTML:

```bash
$:> cd new_ebook
$:> ls -1 sections/
 01_copyright.md
 02_welcome.html
 03_getting_started.markdown
 04_learning_the_ropes.htm
 05_finding_your_feet.mdn
 06_advanced_topics.xhtml
 07_big_conclusion.mdown
```

Assets in your `images/` directory can be referenced from within text sections. NerdPress can identify GIFs, JPEGs, PNGs and SVGs.

```markdown
![](images/diagram.png)
```

When exporting to one of the supported formats, the tool will look for a single stylesheet named for that format by default:

* HTML - `styles/html.(css|scss|sass)`
* PDF - `styles/pdf.(css|scss|sass)`
* EPUB - `styles/epub.(css|scss|sass)`
* MOBI - `styles/mobi.(css|scss|sass)`

Projects that follow these conventions require no additional configuration. Some of these settings can, however, be overridden in the `config.yml` file.

The gem includes commands for exporting the project in one of a number of formats:

```bash
# Build supported ebook formats
$:> nerdpress build epub mobi

# Build HTML and PDF formats
$:> nerdpress build html pdf

# Build all supported formats
$:> nerdpress build

# Same
$:> nerdpress build all
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/chriskottom/nerdpress.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Thanks

Work on this gem and the Rake-based ebook toolchain that came before it was heavily influenced by some of my favorite book-authoring Rubyists:

* Avdi Grimm and [Quarto](https://github.com/avdi/quarto)
* Pat Shaughnessy and his blog post [My eBook build process and some PDF, EPUB and MOBI tips](http://patshaughnessy.net/2012/11/27/my-ebook-build-process-and-some-pdf-epub-and-mobi-tips)
