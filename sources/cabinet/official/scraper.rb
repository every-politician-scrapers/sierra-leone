#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class MemberList
  class Member
    field :name do
      tds[1].text.tidy
    end

    field :position do
      tds[0].text.tidy
    end

    private

    def tds
      noko.css('td')
    end
  end

  class Members
    def member_container
      noko.css('#tablepress-1').xpath('.//tr[td]')
    end
  end
end

file = Pathname.new 'official.html'
puts EveryPoliticianScraper::FileData.new(file).csv
