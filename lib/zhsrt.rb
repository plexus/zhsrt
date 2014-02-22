# -*- coding: utf-8 -*-
require 'json'
require 'open-uri'
require 'cgi'
require 'pathname'
require 'analects'
require 'virtus'
require 'yaml'
require 'forwardable'
require 'uri'
require 'srt'

module Zhsrt
  ROOT = Pathname(__FILE__).dirname.parent
  K = ->(_) {_}

  def self.movie_list
    ROOT.join('movies.txt').each_line.map do |s|
      [
        s.sub(/,[\s\d'’]*$/,'')[/\s(.*)/,1],
        s[/\d{4}/]
      ]
    end
  end

end

require 'zhsrt/omdb'
require 'zhsrt/movie'
