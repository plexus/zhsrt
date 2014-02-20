# -*- coding: utf-8 -*-
require 'json'
require 'open-uri'
require 'cgi'
require 'pathname'
require 'analects'

module Zhsrt
  ROOT = Pathname(__FILE__).dirname.parent

  def self.movie_list
    ROOT.join('movies.txt').each_line.map do |s|
      [
        s.sub(/,[\s\d'’]*$/,'')[/\s(.*)/,1],
        s[/\d{4}/]
      ]
    end
  end

  class WpApi
    def self.request(params)
      new(params).request["query"]["pages"].values.first
    end

    DEFAULTS = {action: 'query', format: 'json', continue: '', redirects: 'true'}

    attr_reader :params

    def initialize(params)
      @params = DEFAULTS.merge(params)
    end

    def get_params
      @params.map {|k,v| [k,v].map(&:to_s).map(&CGI.method(:escape)).join('=') }.join('&')
    end

    def url
      "https://en.wikipedia.org/w/api.php?#{get_params}"
    end

    def request
      result = JSON.parse(open(url).read)
      if result["continue"]
        result = result.merge(self.class.new(params.merge(result["continue"])).request)
      end
      result
    end
  end

  class Movie < Struct.new(:title, :year)
    def self.all
      Zhsrt.movie_list.map{|title, year| self.new(title, year)}
    end

    def languages
      omdb["Language"].split(',').map(&:strip)
    end

    def imdb_rating
      omdb["imdbRating"].to_f
    end

    def omdb_cache_path
      ROOT.join "omdb/#{year}_#{title.gsub(/\W/, '_')}.json"
    end

    def wp_langlinks_cache_path
      ROOT.join "wp_langlinks/#{year}_#{title.gsub(/\W/, '_')}_lang.json"
    end

    def omdb
      unless omdb_cache_path.exist?
        File.write(
          omdb_cache_path,
          open("http://www.omdbapi.com/?t=#{CGI.escape(title)}&y=#{CGI.escape(year)}").read
        )
      end
      JSON.parse omdb_cache_path.read
    end

    def wp_langlinks
      unless wp_langlinks_cache_path.exist?
        File.write(
          wp_langlinks_cache_path,
          JSON.pretty_generate(WpApi.request(
            titles: title,
            prop: 'langlinks'
          ))
        )
      end
      JSON.parse wp_langlinks_cache_path.read
    end

    def translated_title(lang)
      return unless wp_langlinks["langlinks"]
      (wp_langlinks["langlinks"].select {|ll| ll["lang"] == lang}.first ||
        wp_langlinks["langlinks"].select {|ll| ll["lang"] =~ /^#{lang}/}.first || {})["*"]
    end

    def chinese_title
      translated_title("zh")
    end

    def mandarin_only?
      languages == ["Mandarin"]
    end

  end
end
