#!/usr/bin/env ruby

require 'open-uri'
require 'nokogiri'

def scrape_goodreads(uri, page, min_likes, max_pages)
  $stderr.puts "Fetching page #{page} of #{uri}"
  html = URI.open("#{uri}?page=#{page}")
  doc = Nokogiri::HTML(html)

  likes = 0

  doc.css(".quote").each do |quote|
    likes = quote.at_css(".quoteFooter .right .smallText").text.to_i
    if likes > 0 && likes < min_likes
      $stderr.puts
      return
    end

    text = ""
    quote.at_css(".quoteText").traverse do |node|
      if node.text? && node.text =~ /\S/
        text += node.text.lstrip.gsub(/\s+$/, " ")
      end
      if node.name == "br"
        text += "\n"
      end
    end

    $stderr.print "."
    puts text
    puts "%"
  end

  $stderr.puts

  if likes >= min_likes && page < max_pages
    scrape_goodreads(uri, page + 1, min_likes, max_pages)
  end
end

uri = ARGV.shift
min_likes, max_pages = ARGV.map(&:to_i)

scrape_goodreads uri, 1, min_likes || 1000, max_pages || 10
