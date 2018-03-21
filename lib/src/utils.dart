Map<Symbol, dynamic> symbolize(Map<String, dynamic> map) {
  final result = {};

  if (null == map) {
    return result;
  }

  map.forEach((k, v) => result[new Symbol(k)] = v);

  return result;
}
