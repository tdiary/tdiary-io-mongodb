require 'spec_helper'

describe TDiary::IO::MongoDB do
  it 'is_a TDiary::IO::Base' do
    expect { TDiary::IO::MongoDB.is_a?(TDiary::IO::Base) }.to be_true
  end

  describe "#save_cgi_conf and #load_cgi_conf" do
    let(:conf) { DummyConf.new }

    it { expect(TDiary::IO::MongoDB.load_cgi_conf(conf)).to be_empty }

    context "given body" do
      before do
        TDiary::IO::MongoDB.save_cgi_conf(conf, 'foo')
      end

      it { expect(TDiary::IO::MongoDB.load_cgi_conf(conf)).to eq 'foo' }

      context "update" do
        before do
          TDiary::IO::MongoDB.save_cgi_conf(conf, 'bar')
        end
        it { expect(TDiary::IO::MongoDB.load_cgi_conf(conf)).to eq 'bar' }
      end
    end
  end

  describe "#transaction" do
    let(:io) { TDiary::IO::MongoDB.new(DummyTDiary.new) }
    let(:today) { Time.now.strftime( '%Y%m%d' ) }
    let(:diary) { DummyStyle.new('', "foo", "bar", '') }

    before do
      io.transaction( Time.now ) do |diaries|
        @diaries = diaries
        @diaries[today] = diary
        TDiary::TDiaryBase::DIRTY_DIARY
      end
    end

    subject { TDiary::IO::MongoDB::Diary.where(diary_id: today).first }

    it "insert diary" do
      expect(subject).to_not be_nil
      expect(subject[:title]).to eq "foo"
      expect(subject[:body]).to eq "bar"
    end

    it "restore diary" do
      io.transaction( Time.now ) do |diaries|
        @diaries = diaries
        expect(@diaries[today].title).to eq "foo"
        expect(@diaries[today].to_src).to eq "bar"
        TDiary::TDiaryBase::DIRTY_DIARY
      end
    end

    context "update diary" do
      let(:diary2) { DummyStyle.new('' , "bar", "foo", '') }

      before do
        io.transaction( Time.now ) do |diaries|
          @diaries = diaries
          @diaries[today] = diary2
          TDiary::TDiaryBase::DIRTY_DIARY
        end
      end

      subject { TDiary::IO::MongoDB::Diary.where(diary_id: today) }

      it "update contents of diary" do
        expect(subject).to_not be_nil
        expect(subject.count).to eq 1
        expect(subject.first[:title]).to eq "bar"
        expect(subject.first[:body]).to eq "foo"
      end
    end
  end
end
