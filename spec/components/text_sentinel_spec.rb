# encoding: utf-8

require 'spec_helper'
require 'text_sentinel'
require 'iconv'

describe TextSentinel do


  context "entropy" do


    it "returns 0 for an empty string" do
      TextSentinel.new("").entropy.should == 0
    end

    it "returns 0 for a nil string" do
      TextSentinel.new(nil).entropy.should == 0
    end

    it "returns 1 for a string with many leading spaces" do
      TextSentinel.new((" " * 10) + "x").entropy.should == 1
    end

    it "returns 1 for one char, even repeated" do
      TextSentinel.new("a" * 10).entropy.should == 1
    end

    it "returns an accurate count of many chars" do
      TextSentinel.new("evil trout is evil").entropy.should == 10
    end

  end

  context "cleaning up" do

    it "strips leading or trailing whitespace" do
      TextSentinel.new("   \t  test \t  ").text.should == "test"
    end

    it "allows utf-8 chars" do
      TextSentinel.new("йȝîûηыეமிᚉ⠛").text.should == "йȝîûηыეமிᚉ⠛"
    end

    context "interior spaces" do

      let(:spacey_string) { "hello     there's weird     spaces here." }

      it "ignores intra spaces by default" do
        TextSentinel.new(spacey_string).text.should == spacey_string
      end

      it "fixes intra spaces when enabled" do
        TextSentinel.new(spacey_string, remove_interior_spaces: true).text.should == "hello there's weird spaces here."
      end      

    end

  end

  context "validity" do

    let(:valid_string) { "This is a cool topic about Discourse" }

    it "allows a valid string" do
      TextSentinel.new(valid_string).should be_valid
    end

    it "doesn't allow all caps topics" do
      TextSentinel.new(valid_string.upcase).should_not be_valid
    end

    it "enforces the minimum entropy" do
      TextSentinel.new(valid_string, min_entropy: 16).should be_valid
    end

    it "enforces the minimum entropy" do      
      TextSentinel.new(valid_string, min_entropy: 17).should_not be_valid
    end

    it "doesn't allow a long alphanumeric string with no spaces" do
      TextSentinel.new("jfewjfoejwfojeojfoejofjeo38493824jfkjewfjeoifijeoijfoejofjeojfoewjfo834988394032jfiejoijofijeojfeojfojeofjewojfojeofjeowjfojeofjeojfoe3898439849032jfeijfwoijfoiewj",
                      max_word_length: 30).should_not be_valid
    end

    it "doesn't except junk symbols as a string" do
      TextSentinel.new("[[[").should_not be_valid
      TextSentinel.new("<<<").should_not be_valid
      TextSentinel.new("{{$!").should_not be_valid        
    end


  end


end