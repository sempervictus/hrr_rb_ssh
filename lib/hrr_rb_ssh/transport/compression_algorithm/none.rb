# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'

module HrrRbSsh
  class Transport
    class CompressionAlgorithm
      name_list = [
        'none'
      ]

      class None
        def initialize
          @logger = HrrRbSsh::Logger.new self.class.name
        end

        def deflate data
          data
        end

        def inflate data
          data
        end
      end

      @@list ||= Hash.new
      name_list.each do |name|
        @@list[name] = None
      end
    end
  end
end