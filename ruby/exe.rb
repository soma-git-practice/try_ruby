require 'irb'
require 'minitest/autorun'

class User
  attr_accessor :name, :age, :weight

  def self.column_names
    %w(name age weight)
  end

  def update(hash = {})
    hash.keys.each{|k| send("#{k}=", hash[k])}
  end
end

User.column_names.each do |column_name|
  User.define_method("update_#{column_name}") do |value|
    update(column_name => value)
  end
end

class ModelReplicaTest < Minitest::Spec
  it 'User.column_name' do
    assert_equal %w(name age weight), User.column_names
  end

  it 'user.update' do
    obj = User.new
    obj.update(name: '太郎', age: 1000, weight: '60000kg')
    assert_equal '太郎', obj.name
    assert_equal 1000, obj.age
    assert_equal '60000kg', obj.weight
  end

  it 'single column update' do
    obj = User.new

    obj.update_name '田中'
    assert_equal '田中', obj.name

    obj.update_age 50
    assert_equal 50, obj.age

    obj.update_weight '7000kg'
    assert_equal '7000kg', obj.weight
  end
end