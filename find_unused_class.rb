require 'rubygems'
require 'json'
require 'css_parser'
require 'nokogiri'
include CssParser

def load_css_file css_file
    parser = CssParser::Parser.new
    parser.load_file!(css_file, '.', :print)
    parser
end

def css_in_template_file? selector, template_file
    page = Nokogiri::HTML(open(template_file))
    (page.css selector).empty?
end

def css_in_all_template_file? selector
    JSON.parse(@config_json)['template'].each do |template_file|
        return true if css_in_template_file? selector, template_file
    end
    false
end

def iterator_each_class css_file
    (load_css_file css_file).each_selector(:print) do |selector, declarations, specificity|
        next unless selector.start_with? '.'
        puts css_file + ":" + selector if css_in_all_template_file? selector
    end
end

def find_unused_css_style config_json
    @config_json = File.open(config_json).read
    JSON.parse(@config_json)['css'].each do |css_file|
        iterator_each_class css_file
    end
end

find_unused_css_style "config.json"