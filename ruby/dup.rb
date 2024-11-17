require 'irb'

# dupなし
a = 'abcdefg';
b = a;
b.gsub!(/a|b|c/, 'p');
puts a; # => pppdefg

# --------------------------

# dupあり
a = 'abcdefg';
b = a.dup;
b.gsub!(/a|b|c/, 'p');
puts a; # => abcdefg

#
# 変数を別の変数に代入して破壊的メソッドを使う時に使うメソッドなんだな。
# じゃあ、使う機会少なそうだ。
# ある処理のbeforeとafter両方の値を使いたい時に使えそうだ。
#
