require 'irb'
require 'minitest/autorun'


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

describe 'Authenticatable::ClassMethods' do
  it 'は、パブリックメソッドに available_configs を持つ' do
    _(Authenticatable::ClassMethods.public_methods.include?(:available_configs)).must_equal true
  end

  it 'は、パブリックメソッドに available_configs= を持つ' do
    _(Authenticatable::ClassMethods.public_methods.include?(:available_configs=)).must_equal true
  end

  it 'は、インスタンス変数 @available_configs に値を持っている' do
    _(Authenticatable::ClassMethods.instance_variable_get(:@available_configs)).must_equal %i(case_insensitive_keys)
  end


  it 'は、インスタンスメソッドに case_insensitive_keys を持つ' do
    _(Authenticatable::ClassMethods.instance_methods.include?(:case_insensitive_keys)).must_equal true
  end

  it 'は、インスタンスメソッドに case_insensitive_keys= を持つ' do
    _(Authenticatable::ClassMethods.instance_methods.include?(:case_insensitive_keys=)).must_equal true
  end
end

describe 'User' do
  it "は、Authenticatable::ClassMethodsモジュールがextendされる" do
    _(User.singleton_class.include?(Authenticatable::ClassMethods)).must_equal true
  end


  it 'は、パブリックメソッドに case_insensitive_keys を持つ' do
    _(User.public_methods.include?(:case_insensitive_keys)).must_equal true
  end

  it 'は、パブリックメソッドに case_insensitive_keys= を持つ' do
    _(User.public_methods.include?(:case_insensitive_keys=)).must_equal true
  end
end

# @TODO User.case_insensitive_keys と User.case_insensitive_keys=(val) の動作確認