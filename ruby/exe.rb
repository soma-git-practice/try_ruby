require 'irb'
require 'minitest/autorun'

module Devise
  def self.add_module(module_name)
    Mapping.add_module module_name
  end

  class Mapping
    def self.add_module(module_name)
      class_eval <<-METHOD, __FILE__, __LINE__ + 1
        def #{module_name}?
          @moodules.include?(#{module_name})
        end
      METHOD
    end

    attr_reader :modules

    def initialize
      @modules = []
    end

    def modules=(value)
      @modules += [*value]
    end
  end
end

class TestDevise < Minitest::Spec
  after do
    if Devise::Mapping.public_instance_methods.include?(:devise_hoge?)
      Devise::Mapping.remove_method(:devise_hoge?)
    end
  end

  it 'Devise default' do
    assert_equal false, Devise::Mapping.public_instance_methods.include?(:devise_hoge?)
  end

  it 'Devise#add_module' do
    Devise::Mapping.add_module :devise_hoge
    assert_equal true, Devise::Mapping.public_instance_methods.include?(:devise_hoge?)
  end

  it '#Devise::Mapping default' do
    obj = Devise::Mapping.new
    obj.modules = %w(devise_hoge)
    assert_equal false, obj.public_methods.include?(:devise_hoge?)
  end

  it 'Devise::Mapping#add_module' do
    Devise::Mapping.add_module :devise_hoge
    obj = Devise::Mapping.new
    obj.modules = %w(devise_hoge)
    assert_equal true, obj.public_methods.include?(:devise_hoge?)
  end
end