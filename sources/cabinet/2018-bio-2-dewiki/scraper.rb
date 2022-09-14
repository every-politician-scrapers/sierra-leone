#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class MemberList
  class Members
    decorator RemoveReferences
    decorator UnspanAllTables
    decorator WikidataIdsDecorator::Links

    def member_container
      noko.xpath("//table[.//th[contains(.,'Foto')]]//tr[td]")
    end
  end

  class Member
    field :id do
      tds[2].css('a/@wikidata').first
    end

    field :name do
      (tds[2].css('a').first || tds[2]).text.tidy
    end

    field :positionID do
    end

    field :position do
      tds[0].text.split('(').first.tidy
    end

    field :startDate do
      raw = raw_start or return

      WikipediaDate::German.new(raw).to_s rescue binding.pry
    end

    field :endDate do
      raw = raw_end or return

      WikipediaDate::German.new(raw).to_s
    end

    private

    def tds
      noko.css('td')
    end

    def raw_combo_date
      tds[5].text.tidy.gsub('seit', '').gsub('?', '').gsub('.', '')
    end

    def combo_date
      raw_combo_date.split(/[—–-–]/).map(&:tidy)
    end

    def raw_end
      combo_date[1]
    end

    def raw_start
      rstart = combo_date[0].to_s
      return if rstart.empty?

      rstart += " #{raw_end.split[1]}" unless rstart.match /\D+/
      rstart += " #{raw_end.split[2]}" unless rstart.match /\d{4}/
      rstart
    end

  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url).csv
