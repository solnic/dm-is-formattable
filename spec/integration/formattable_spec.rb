require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

if HAS_SQLITE3 || HAS_MYSQL || HAS_POSTGRES
  describe 'DataMapper::Is::Formattable' do
    
    before :all do
      
      class Page
        include DataMapper::Resource
        property :id, Serial
        property :name, String
        is :formattable
        auto_migrate!
      end
      
    end

    it 'should format with textile by default' do
      page = Page.new(:content_original => '*strong text* and _emphasized text_')
      page.save
      page.content_formatted.should eql('<p><strong>strong text</strong> and <em>emphasized text</em></p>')
    end
    
    it 'should update source and result fields' do
      page = Page.new(:content_original => '*strong text* and _emphasized text_')
      page.save
      page.content_original = '*strong text only*'
      page.save
      page.content_formatted.should eql('<p><strong>strong text only</strong></p>')
    end
    
  end
end
