require 'open-uri'
require 'nokogiri'
require 'csv'

require_relative 'scrapper'
require_relative 'controller'

controller = Controller.new
controller.import_from_web
