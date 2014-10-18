@pushd %~dp0
@ruby -S -x "%~f0" "%*"
@goto end

#! ruby -Ku
# -*- coding: utf-8 -*-
require 'erb'

$src_file = ARGV[0]

puts "generate enum method"
puts "src :" + $src_file

unless File.exists?($src_file)
  puts "error  please enum header file to argment"
  raise
end

src = File.read($src_file)
enum_name = src.scan(/struct +(\w+?)\s*?{/m).flatten[0]
elements  = src.scan(/enum.*?{(.*?)};/m).flatten[0]
                 .split(',')
                 .map{|x| x.strip}
                 .map{|x| x.sub(/^k/, '')}
elements2 = elements.map{|x| x.gsub(/(.)([A-Z])/, '\1_\2').downcase}

comment_begin = "// begin generate code [enum_generator.bat] ===="
comment_end   = "// end   generate code [enum_generator.bat] ===="

regexp_begin  = Regexp.escape(comment_begin)
regexp_end    = Regexp.escape(comment_end)
text = src
text = text.sub(/#{regexp_begin}.*#{regexp_end}\n/m, "")
text = text.sub(/^};/, "$insert_code};")

#===========================================
code = <<EOS
<%= comment_begin %>
  int Value;
  $enum_name()                    : Value(k$first_element){}
  $enum_name(int v)               : Value(v){}
  $enum_name(const $enum_name& v) : Value(v.Value){}
  $enum_name(const char* v){Value = FromS(v);}

  enum {Count = <%= elements.size %>};
  operator int() const {return Value;}

% elements.each {|x|
  static $enum_name <%= x %>() {return $enum_name(k<%= x %>);}
% }

% elements.each {|x|
  bool Is<%= x %>() const {return Value == k<%= x %>;}
% }

% elements.each {|x|
  bool Not<%= x %>() const {return Value != k<%= x %>;}
% }
    
  $enum_name& operator=(int v) {Value = v; return *this;}

  bool operator ==(const $enum_name& v) const {return Value == v.Value;}
  bool operator ==(int v)               const {return Value == v;}
  bool operator !=(const $enum_name& v) const {return Value == v.Value;}
  bool operator !=(int v)               const {return Value == v;}

  bool Contains(int v)         const {return v >= 0 && v < Count;}
  bool Contains(const char* v) const {return Map()->count(0) != 0 || Map2()->count(0) != 0;}

  typedef std::array<$enum_name, Count> Array_;
  static const Array_* Array()
  {
    static const Array_ array = {
% elements.take(elements.size-1).each {|x|
      <%= x %>(),
% }
      <%= elements[-1] %>()
    };
    return &array;
  }

  typedef std::array<int, Count> ArrayI_;
  static const ArrayI_* ArrayI()
  {
    static const ArrayI_ array = {
% elements.take(elements.size-1).each {|x|
      k<%= x %>,
% }
      k<%= elements[-1] %>
    };
    return &array;
  }

  typedef std::map<std::string, $enum_name> Map_;
  static const Map_* Map()
  {
    static const Map_ map = {
% elements.take(elements.size-1).each {|x|
      {"<%= x %>", <%= x %>()},
% }
      {"$last_element", $last_element()}
    };
    return &map;
  }

  static const Map_* Map2()
  {
    static const Map_ map = {
% elements.zip(elements2).take(elements.size-1).each {|x,y|
      {"<%= y %>", <%= x %>()},
% }
      {"$last_element2", $last_element()}
    };
    return &map;
  }

  const char *ToS() const {
    static const char* texts[] = {
% elements.take(elements.size-1).each {|x|
      "<%= x %>",
% }
      "$last_element"
    };
    return (Contains(Value) ? texts[Value] : "unknown");
  };

  const char *ToS2() const {
    static const char* texts[] = {
% elements2.take(elements2.size-1).each {|x|
      "<%= x %>",
% }
      "$last_element2"
    };
    return (Contains(Value) ? texts[Value] : "unknown");
  };

  static $enum_name FromS(const char* name) {
    if (Map() ->count(name) != 0) return Map() ->at(name);
    if (Map2()->count(name) != 0) return Map2()->at(name);
    return $first_element();
  }

  friend std::ostream &operator<<(std::ostream &os, const $enum_name &me)
  {
    os << me.Value << ":" << me.ToS();
    return os;
  }
<%= comment_end %>
EOS
#===========================================

erb  = ERB.new(code, nil, '%')
code = erb.result(binding)
code = code.gsub("$enum_name",     enum_name)
code = code.gsub("$first_element", elements .first)
code = code.gsub("$last_element2", elements2.last)
code = code.gsub("$last_element",  elements .last)
text = text.sub( "$insert_code",   code)
File.write($src_file, text)

__END__
:end
@popd
@pause
