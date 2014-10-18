#ifndef test_hpp
#define test_hpp

struct PiyoPiyo {
  enum {kNone, kPiyoValue, kValue2};
// begin generate code [enum_generator.bat] ====
  int Value;
  PiyoPiyo()                    : Value(kNone){}
  PiyoPiyo(int v)               : Value(v){}
  PiyoPiyo(const PiyoPiyo& v) : Value(v.Value){}
  PiyoPiyo(const char* v){Value = FromS(v);}

  enum {Count = 3};
  operator int() const {return Value;}

  static PiyoPiyo None() {return PiyoPiyo(kNone);}
  static PiyoPiyo PiyoValue() {return PiyoPiyo(kPiyoValue);}
  static PiyoPiyo Value2() {return PiyoPiyo(kValue2);}

  bool IsNone() const {return Value == kNone;}
  bool IsPiyoValue() const {return Value == kPiyoValue;}
  bool IsValue2() const {return Value == kValue2;}

  bool NotNone() const {return Value != kNone;}
  bool NotPiyoValue() const {return Value != kPiyoValue;}
  bool NotValue2() const {return Value != kValue2;}
    
  PiyoPiyo& operator=(int v) {Value = v; return *this;}

  bool operator ==(const PiyoPiyo& v) const {return Value == v.Value;}
  bool operator ==(int v)               const {return Value == v;}
  bool operator !=(const PiyoPiyo& v) const {return Value == v.Value;}
  bool operator !=(int v)               const {return Value == v;}

  bool Contains(int v)         const {return v >= 0 && v < Count;}
  bool Contains(const char* v) const {return Map()->count(0) != 0 || Map2()->count(0) != 0;}

  typedef std::array<PiyoPiyo, Count> Array_;
  static const Array_* Array()
  {
    static const Array_ array = {
      None(),
      PiyoValue(),
      Value2()
    };
    return &array;
  }

  typedef std::array<int, Count> ArrayI_;
  static const ArrayI_* ArrayI()
  {
    static const ArrayI_ array = {
      kNone,
      kPiyoValue,
      kValue2
    };
    return &array;
  }

  typedef std::map<std::string, PiyoPiyo> Map_;
  static const Map_* Map()
  {
    static const Map_ map = {
      {"None", None()},
      {"PiyoValue", PiyoValue()},
      {"Value2", Value2()}
    };
    return &map;
  }

  static const Map_* Map2()
  {
    static const Map_ map = {
      {"none", None()},
      {"piyo_value", PiyoValue()},
      {"value2", Value2()}
    };
    return &map;
  }

  const char *ToS() const {
    static const char* texts[] = {
      "None",
      "PiyoValue",
      "Value2"
    };
    return (Contains(Value) ? texts[Value] : "unknown");
  };

  const char *ToS2() const {
    static const char* texts[] = {
      "none",
      "piyo_value",
      "value2"
    };
    return (Contains(Value) ? texts[Value] : "unknown");
  };

  static PiyoPiyo FromS(const char* name) {
    if (Map() ->count(name) != 0) return Map() ->at(name);
    if (Map2()->count(name) != 0) return Map2()->at(name);
    return None();
  }

  friend std::ostream &operator<<(std::ostream &os, const PiyoPiyo &me)
  {
    os << me.Value << ":" << me.ToS();
    return os;
  }
// end   generate code [enum_generator.bat] ====
};

#endif // test_hpp
