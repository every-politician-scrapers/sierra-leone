#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class OfficeholderList < OfficeholderListBase
  decorator RemoveReferences
  decorator WikidataIdsDecorator::Links

  def holder_entries
    noko.xpath("//h2[.//span[contains(.,'List of attorneys')]]//following-sibling::ul[1]//li")
  end

  class Officeholder < OfficeholderNonTableBase
    def item
      noko.css('a/@wikidata').map(&:text).first
    end

    def itemLabel
      noko.css('a').map(&:text).map(&:tidy).first || noko.text.split('(').first.tidy
    end

    def raw_combo_date
      years = noko.text.scan(/\((.*?)\)/).flatten.last.gsub('c. ', '')
      years =~ /^\d{4}$/ ? "#{years} - #{years}" : years
    end
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url, klass: OfficeholderList).csv
