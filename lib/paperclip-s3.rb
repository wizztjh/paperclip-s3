require 'paperclip'
require 'paperclip-s3/version'
require 'paperclip-s3/railtie'


module Paperclip
  module S3
    def self.extended base
      Paperclip.interpolates(:s3_sg_url) { |attachment, style|
         "#{ attachment.s3_protocol}://s3-ap-southeast-1.amazonaws.com/#{attachment.bucket_name}/#{attachment.path(style).gsub(%r{^/},
         "")}"
      }
      
      Paperclip.interpolates(:s3_eu_url) { |attachment, style|
        "#{attachment.s3_protocol}://s3-eu-west-1.amazonaws.com/#{attachment.bucket_name}/#{attachment.path(style).gsub(%r{^/}, "")}"
      }
    end
    # Use Paperclip::S3::Glue to keep the original gem style
    module Glue
      def self.included base
        base.extend ClassMethods
      end
    end
    
    module ClassMethods
      # Extends the paperclips has_attached_file method
      # It will use S3 Storage. The credentials will be read from the environment
      def has_attached_file(name, options = {})
        s3_protocol = !!ENV["S3_PROTOCOL"] ? ENV["S3_PROTOCOL"] : "http"
        options[:storage] = :s3
        options[:path]    ||= "/:class-:attachment/:id/:style-:basename.:extension"
        options[:bucket]  ||= ENV["S3_BUCKET"]
        options[:s3_protocol] ||= s3_protocol
        options[:s3_credentials] ||= {
                                        :access_key_id => ENV['S3_KEY'],
                                        :secret_access_key => ENV['S3_SECRET']
                                    }
        options[:url]  ||= ENV["S3_URL"]
        super(name, options)
      end
    end
  end
end