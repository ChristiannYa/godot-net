class_name UdpOneShotCounter

var _l: Logging = Logging.new()

var _cts: Dictionary = {
	"jump": {"ct": 0, "blen": 3},
}


func reg(field: String):
	if not _cts.has(field):
		_l.log("Cannot register '%s' because it does not exist" % field)
		return

	var entry: Dictionary = _cts[field]
	entry["ct"] = (entry["ct"] + 1) & Bits.mask(entry["blen"])


func ct(field: String) -> int:
	return _cts[field]["ct"]
