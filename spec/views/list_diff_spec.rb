require 'spec_helper'

describe "list_diff view", :js => true  do
  it "Compares and shows proper shared items" do
    visit '/list_diff'
    find('#btnCompare').click
    # puts find_field('textarea-list-shared').value
    find_field('textarea-list-shared').value.should eq "y\nz"
  end
end
