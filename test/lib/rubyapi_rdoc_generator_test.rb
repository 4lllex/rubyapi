# frozen_string_literal: true

require "test_helper"

class RubyAPIRDocGeneratorTest < ActiveSupport::TestCase
  test "namespaced superclass association" do
    document "namespaced_superclass.rb"
    object = RubyObject.find_by!(constant: "Namespaced::Child")

    assert_equal "Namespaced::Parent", object.superclass_constant
    assert_equal RubyObject.find_by!(constant: "Namespaced::Parent"), object.superclass
  end

  test "method source location" do
    document "lib/source_location.rb"
    method = RubyMethod.find_by!(constant: "SourceLocation#example")

    assert_equal "test:lib/source_location.rb:4", method.source_location
  end

  test ":include: and rdoc-ref: directives" do
    document "directives.rb"
    object = RubyObject.find_by!(constant: "Directives")

    assert_includes object.description, "<p>Included documentation from the source root.</p>"
    assert_includes object.description, '<a href="/test/o/language/bsearch_rdoc">binary search guide</a>'
  end

  private

  def document(filename)
    root = Rails.root.join("test/fixtures/doc")
    Dir.chdir(root) do
      opts = RDoc::Options.load_options.tap do |options|
        options.generator = RubyAPIRDocGenerator
        options.generator_options = [ RubyRelease.new(version: "test", signatures: false) ]
        options.root = root.to_s
        options.files = [ filename ]
        options.op_dir = Rails.root.join("tmp/rdoc_test").to_s
        options.visibility = :private
        options.verbosity = 0
        options.template = ""
      end
      RDoc::RDoc.new.document(opts)
    end
  end
end
