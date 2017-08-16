module MarkupHelpers
  MARKDOWN_FILE = "#{ File.dirname(__FILE__) }/../fixtures/project/sections/section2.md"
  SAMPLE_MARKDOWN = File.read(MARKDOWN_FILE)

  SAMPLE_HTML =<<~HTML
  <h1>Section 2</h1>
  <ul>
  <li>Item 1</li>
  <li>Item 2</li>
  <li>Item 3</li>
  </ul>
  <pre lang="ruby"><code>require 'foo'
  bar = 'bat'
  </code></pre>
  HTML
end
