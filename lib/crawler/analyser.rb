module Analyser
  class GeneralAnalyzer
    def initialize(source)
      @source=source
    end

    def links(url,response,queue)
      response
      page.links.each { |link| body }
    end

    #
    # Converts relative URL *link* into an absolute URL based on the
    # location of the page
    #
    def to_absolute(link)
      return nil if link.nil?

      # remove anchor
      link = URI.encode(URI.decode(link.to_s.gsub(/#[a-zA-Z0-9_-]*$/,'')))

      relative = URI(link)
      absolute = @url.merge(relative)

      absolute.path = '/' if absolute.path.empty?

      return absolute
    end


  end

  def self.included(base)
    base.extend         ClassMethods
    base.class_eval do
      
    end
    base.send :include, InstanceMethods
  end # self.included

  module ClassMethods

  end # ClassMethods

  module InstanceMethods

  end # InstanceMethods

end
