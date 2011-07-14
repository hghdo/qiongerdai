Given /^New archives need to be audited$/ do
  Archive.create!(:title => 'archive 1', :url => 'url 1', :desc => 'desc 1', :content => 'content 1', :analyzed => true, :ok => false)
  Archive.create!(:title => 'archive 2', :url => 'url 2',:desc => 'desc 2', :content => 'content 2', :analyzed => true, :ok => false)
end

When /^Admin selecte one archive to audit$/ do
  visit admin_archives_path
  assert page.has_content?('archive 1') 
  assert page.has_content?('archive 2')  
  @arc=Archive.find_by_url('url 1')
  visit admin_archive_path(@arc)
end

Then /^Admin can edit the archive$/ do
  #visit admin_archive_path(@arc)
  assert page.has_content?('Edit Thumbnail')
  assert page.has_content?('Verify Archive')
end

When /^Admin approved the archive that he is auditing$/ do
  click_link('Verify Archive')
end

Given /^I have archives titled (.+)$/ do |titles|
  Archive.create!(:title => titles, :desc => titles, :content => titles, :ok => true)
end

Given /^I have un-verified archives (.+)$/ do |titled|
  Archive.create!(:title => titled, :desc => titled, :content => titled,:analyzed => true, :ok => false)
end
