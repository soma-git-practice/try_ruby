require 'irb'
# require 'minitest/autorun'


# ** 目標 **
# 
#  Deviseを読んでいる時にClassMethodsの中でクラスメソッドを呼んでいるコードに出会った。
#  何をしているのか知りたいから読む。
#  https://github.com/heartcombo/devise/blob/fec67f98f26fcd9a79072e4581b1bd40d0c7fa1d/lib/devise/models/authenticatable.rb#L220-L223


# ActiveSupportから必要な箇所を抜粋
# https://github.com/rails/rails/blob/31aec233a17a44cb4666aa074243f0961798ed46/activesupport/lib/active_support/concern.rb#L125-L140
module ActiveSupport
  module Concern
    def append_features(base)
      super
      base.extend const_get(:ClassMethods) if const_defined?(:ClassMethods)
    end
  end
end

# https://github.com/heartcombo/devise/blob/fec67f98f26fcd9a79072e4581b1bd40d0c7fa1d/lib/devise/models.rb#L15-L52
module Models
  def self.config(mod, *accessors)
    # class << mod; attr_accessor :available_configs; end
    def mod.available_configs
      @available_configs
    end
    def mod.available_configs=(val)
      @available_configs = val
    end

    mod.available_configs = accessors

    accessors.each do |accessor|
      mod.class_eval <<-METHOD, __FILE__, __LINE__ + 1
        def #{accessor}
          if defined?(@#{accessor})
            @#{accessor}
          elsif superclass.respond_to?(:#{accessor})
            superclass.#{accessor}
          else
            Devise.#{accessor} # @TODO 対応
          end
        end

        def #{accessor}=(value)
          @#{accessor} = value
        end
      METHOD
    end
  end
end

# https://github.com/heartcombo/devise/blob/fec67f98f26fcd9a79072e4581b1bd40d0c7fa1d/lib/devise/models/authenticatable.rb#L220-L223
module Authenticatable
  extend ActiveSupport::Concern

  module ClassMethods
    Models.config(self, :case_insensitive_keys)
  end
end

# https://github.com/heartcombo/devise/blob/fec67f98f26fcd9a79072e4581b1bd40d0c7fa1d/lib/devise/models.rb#L88
class User
  extend ActiveSupport::Concern
  include Authenticatable
end