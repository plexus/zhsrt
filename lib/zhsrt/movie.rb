module Zhsrt
  class Movie
    extend Forwardable
    include Virtus.model

    def self.all
      YAML.load(ROOT.join('movies.yml').read).map(&method(:new))
    end

    def_delegators :omdb, :languages, :imdb_rating

    attribute :name_en, String
    attribute :name_zh, String
    attribute :year, Integer
    attribute :wikipedia_en, URI
    attribute :wikipedia_zh, URI
    attribute :location, String
    attribute :imdb_id, String
    attribute :srt_files, Hash[String => Array]

    DECODERS = {
      'gb'               => Analects::Encoding.method(:from_gb),
      'gb_traditional'   => Analects::Encoding.method(:from_gb),
      'big5'             => Analects::Encoding.method(:from_big5),
      'big5_simplified'  => Analects::Encoding.method(:from_big5),
      'utf8_traditional' => K,
      'utf8_simplified'  => K,
    }

    FILE_TYPES = {
      :traditional => ['big5' , 'gb_traditional'  , 'utf8_traditional'] ,
      :simplified  => ['gb'   , 'big5_simplified' , 'utf8_simplified' ] ,
    }

    def subs(type)
      FILE_TYPES[type].flat_map do |encoding|
        srt_files.fetch(encoding, []).map do |filename|
          SRT::File.parse(DECODERS[encoding].(ROOT.join('srt', encoding, filename).read))
        end
      end
    end

    def text(type)
      subs(type).flat_map(&:lines).map(&:text).join("\n")
    end

    def words(type)
      Analects::Tokenizer.new.tokenize(text type)
    end

    def omdb
      @omdb ||= Omdb.new(name_en, year)
    end

    def mandarin_only?
      languages == ["Mandarin"]
    end

  end
end
