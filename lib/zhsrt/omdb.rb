module Zhsrt
  class Omdb
    attr_reader :title, :year

    def initialize(title, year)
      @title, @year = title, year
    end

    def omdb_cache_path
      ROOT.join "omdb/#{year}_#{title.gsub(/\W/, '_')}.json"
    end

    def omdb
      @omdb ||= begin
                  unless omdb_cache_path.exist?
                    json = open("http://www.omdbapi.com/?t=#{CGI.escape(title)}&y=#{CGI.escape(year)}").read
                    File.write( omdb_cache_path, json )
                  end
                  JSON.parse omdb_cache_path.read
                end
    end

    def languages
      omdb["Language"].split(',').map(&:strip)
    end

    def imdb_rating
      omdb["imdbRating"].to_f
    end

  end
end
