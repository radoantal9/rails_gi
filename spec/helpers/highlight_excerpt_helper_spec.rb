# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "highlight_excerpt", type: :helper do
  it "should: work" do
    pp helper.highlight_excerpt("checkbox, checkbox, number", "a")

  end
end
