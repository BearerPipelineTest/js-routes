require "active_support/core_ext/string/strip"
require "fileutils"
require 'spec_helper'

describe JsRoutes do
  describe "generated js" do
    subject do
      JsRoutes.generate(
        module_type: 'UMD',
        include: /book|inboxes|inbox_message/,
      )
    end

    it "should include a comment in the header" do
      app_class = "App"

      is_expected.to include("File generated by js-routes #{JsRoutes::VERSION}")
      is_expected.to include("Based on Rails #{ActionPack.version} routes of #{app_class}")
    end

    it "should call route function for each route" do
      is_expected.to include("inboxes_path: __jsr.r(")
    end
    it "should have correct function without arguments signature" do
      is_expected.to include('inboxes_path: __jsr.r({"format":[]}')
    end
    it "should have correct function with arguments signature" do
      is_expected.to include('inbox_message_path: __jsr.r({"inbox_id":[true],"id":[true],"format":[]}')
    end
    it "should have correct function signature with unordered hash" do
      is_expected.to include('inbox_message_attachment_path: __jsr.r({"inbox_id":[true],"message_id":[true],"id":[true],"format":[]}')
    end

    it "should have correct function comment with options argument" do
      is_expected.to include(<<-DOC.rstrip)
  /**
   * Generates rails route to
   * /inboxes(.:format)
   * @param {object | undefined} options
   * @returns {string} route path
   */
  inboxes_path: __jsr.r
DOC
    end
    it "should have correct function comment with arguments" do
      is_expected.to include(<<-DOC.rstrip)
  /**
   * Generates rails route to
   * /inboxes/:inbox_id/messages/:message_id/attachments/new(.:format)
   * @param {any} inbox_id
   * @param {any} message_id
   * @param {object | undefined} options
   * @returns {string} route path
   */
  new_inbox_message_attachment_path: __jsr.r
  DOC
    end

    it "routes should be sorted in alphabetical order" do
      expect(subject.index("book_path")).to be <= subject.index("inboxes_path")
    end
  end

  describe ".generate!" do

    let(:name) { Rails.root.join('app', 'assets', 'javascripts', 'routes.js') }

    before(:each) do
      FileUtils.rm_f(name)
      JsRoutes.generate!({:file => name})
    end

    after(:each) do
      FileUtils.rm_f(name)
    end

    after(:all) do
      FileUtils.rm_f("#{File.dirname(__FILE__)}/../routes.js") # let(:name) is not available here
    end

    it "should not generate file before initialization" do
      expect(File.exists?(name)).to be_falsey
    end
  end
end
