require 'spec_helper'
require 'browser_descriptor'

describe BrowserDescriptor do
  specify "#default_db_paths" do
    subject.default_db_paths 'goatse.cx'
    expect(subject.default_db_paths).to eq('goatse.cx')
  end

  specify "#table" do
    subject.table 'lemon_party'
    expect(subject.table).to eq('lemon_party')
  end

  context 'valid column params' do
    specify "#column" do
      subject.column :foo, 'bar'
      expect(subject.column :foo).to eq('bar')
    end
  end

  context 'invalid column params' do
    specify "#column" do
      expect { subject.column }.to raise_error
      expect { subject.column(2, :many, 'params') }.to raise_error
    end
  end

  specify "#normalize" do
    subject.normalize(:lace_card) { |col| :dont_execute! }
  end

  specify "#normalizers" do
    subject.normalize(:bevis) { |col| :dont_execute! }
    expect(subject.normalizers[:bevis]).to be_instance_of(Proc)
  end
end
