require 'irb'
require 'minitest/autorun'
require 'active_support/concern'
require 'active_support/core_ext/module/attribute_accessors'

# ** 目標 **
# 
#  Deviseを読んでいる時にClassMethodsの中でクラスメソッドを呼んでいるコードに出会った。
#  何をしているのか知りたいから読む。
#  https://github.com/heartcombo/devise/blob/fec67f98f26fcd9a79072e4581b1bd40d0c7fa1d/lib/devise/models/authenticatable.rb#L220-L223

# https://github.com/heartcombo/devise/blob/fec67f98f26fcd9a79072e4581b1bd40d0c7fa1d/lib/devise.rb#L89-L91
module Devise
  mattr_accessor :request_keys
  @@request_keys = [:devise_value]

  mattr_accessor :case_insensitive_keys
  @@case_insensitive_keys = [:devise_value]

  mattr_accessor :hoge
  @@case_insensitive_keys = [:hoge]
end

# https://github.com/heartcombo/devise/blob/fec67f98f26fcd9a79072e4581b1bd40d0c7fa1d/lib/devise/models.rb#L15-L52
module Devise
  module Models
    def self.config(mod, *accessors)
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
              Devise.#{accessor}
            end
          end
  
          def #{accessor}=(value)
            @#{accessor} = value
          end
        METHOD
      end
    end
  end
end

# https://github.com/heartcombo/devise/blob/fec67f98f26fcd9a79072e4581b1bd40d0c7fa1d/lib/devise/models/authenticatable.rb#L220-L223
module Authenticatable
  extend ActiveSupport::Concern

  module ClassMethods
    Devise::Models.config(self, :request_keys, :case_insensitive_keys, :hoge)
  end
end

# https://github.com/heartcombo/devise/blob/fec67f98f26fcd9a79072e4581b1bd40d0c7fa1d/lib/devise/models.rb#L88
class User
  include Authenticatable
  self.case_insensitive_keys = [:gmail]
end

class Qser < User
  self.hoge = [:im_happy]
end

describe 'Authenticatable::ClassMethods' do
  it 'は、パブリックメソッドに available_configs を持つ' do
    _(Authenticatable::ClassMethods.public_methods.include?(:available_configs)).must_equal true
  end

  it 'は、パブリックメソッドに available_configs= を持つ' do
    _(Authenticatable::ClassMethods.public_methods.include?(:available_configs=)).must_equal true
  end

  it 'は、インスタンス変数 @available_configs に値を持っている' do
    _(Authenticatable::ClassMethods.instance_variable_get(:@available_configs)).must_equal %i(request_keys case_insensitive_keys hoge)
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

  describe '#request_keys' do
    it 'モデルクラスで設定しない場合Devise共通の値を取得することになる' do
      _(User.request_keys).must_equal Devise.request_keys
    end
  end

  describe '#case_insensitive_keys' do
    it 'モデルクラスで設定する場合モデルクラス自体のインスタンス変数の値を取得することになる' do
      _(User.case_insensitive_keys).must_equal [:gmail]
    end
  end
end

describe Qser do
  describe '#case_insensitive_keys' do
    it 'モデルクラスで設定しない場合スーパークラス自体のインスタンス変数の値を取得することになる' do
      _(Qser.case_insensitive_keys).must_equal User.case_insensitive_keys
    end

    it 'モデルクラスで設定する場合モデルクラス自体のインスタンス変数の値を取得することになる' do
      _(Qser.hoge).must_equal [:im_happy]
    end
  end
end