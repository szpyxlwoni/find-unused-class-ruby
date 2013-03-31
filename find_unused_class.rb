require 'rubygems'
require 'css_parser'
require 'nokogiri'
require 'json'
include CssParser

@css_file = 'testfile.css'
@template_file = "testfile.html"

def load_css_file css_file
	parser = CssParser::Parser.new
	parser.load_file!(css_file, '.', :print)
	parser
end

def is_css_in_file selector, template_file
	page = Nokogiri::HTML(open(@template_file))
	(page.css selector).empty?
end

def find_unused_css_style config_json
	JSON.parse(File.open(config_json).read)['css'].each do |css_file|
		css_file_parser = load_css_file css_file
		flag = false
		css_file_parser.each_selector(:print) do |selector, declarations, specificity|
			next unless selector.start_with? '.'
			JSON.parse(File.open(config_json).read)['template'].each do |template_file|
				flag = true if is_css_in_file selector, template_file
			end
			puts css_file + ":" + selector if flag
		end
	end
end

find_unused_css_style "config.json"