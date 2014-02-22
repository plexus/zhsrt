module Zhsrt
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
end


    # def wp_langlinks_cache_path
    #   ROOT.join "wp_langlinks/#{year}_#{title.gsub(/\W/, '_')}_lang.json"
    # end

    # def chinese_title
    #   translated_title("zh")
    # end

    # def wp_langlinks
    #   unless wp_langlinks_cache_path.exist?
    #     File.write(
    #       wp_langlinks_cache_path,
    #       JSON.pretty_generate(WpApi.request(
    #         titles: title,
    #         prop: 'langlinks'
    #       ))
    #     )
    #   end
    #   JSON.parse wp_langlinks_cache_path.read
    # end

    # def translated_title(lang)
    #   return unless wp_langlinks["langlinks"]
    #   (wp_langlinks["langlinks"].select {|ll| ll["lang"] == lang}.first ||
    #     wp_langlinks["langlinks"].select {|ll| ll["lang"] =~ /^#{lang}/}.first || {})["*"]
    # end
