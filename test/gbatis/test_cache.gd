extends GdUnitTestSuite

## Unit tests for GBatisCache — LRU and FIFO caches used by mapper cache.

# --------------------------------------------------------------------------
# LRU cache via GBatisCache
# --------------------------------------------------------------------------

func _lru_cache(cap: int) -> GDSQL.GBatisCache:
	var c = GDSQL.GBatisCache.new({"eviction": "LRU", "size": str(cap)})
	c.clear_cache()
	return c

## 测试: LRU set/get
func test_lru_set_get() -> void:
	var c = _lru_cache(3)
	c.set_cache("m", {"p": 1}, "hello")
	var r = c.get_cache("m", {"p": 1})
	assert_bool(r[0]).is_true()
	assert_str(r[1]).is_equal("hello")


## 测试: LRU 容量淘汰
func test_lru_eviction() -> void:
	var c = _lru_cache(2)
	c.set_cache("a", {"k": 1}, "one")
	c.set_cache("b", {"k": 2}, "two")
	c.set_cache("c", {"k": 3}, "three")  # evicts "a"
	assert_bool(c.get_cache("a", {"k": 1})[0]).is_false()
	assert_bool(c.get_cache("b", {"k": 2})[0]).is_true()
	assert_bool(c.get_cache("c", {"k": 3})[0]).is_true()


## 测试: LRU 访问后重新排序
func test_lru_reorder() -> void:
	var c = _lru_cache(3)
	c.set_cache("a", {"k": 1}, "one")
	c.set_cache("b", {"k": 2}, "two")
	c.set_cache("c", {"k": 3}, "three")
	# Access "a" to make it MRU
	assert_bool(c.get_cache("a", {"k": 1})[0]).is_true()
	# Now "b" is LRU, adding "d" evicts "b"
	c.set_cache("d", {"k": 4}, "four")
	assert_bool(c.get_cache("b", {"k": 2})[0]).is_false()
	assert_bool(c.get_cache("a", {"k": 1})[0]).is_true()


## 测试: LRU 覆盖已存在键
func test_lru_overwrite() -> void:
	var c = _lru_cache(3)
	c.set_cache("x", {"k": 1}, "old")
	c.set_cache("x", {"k": 1}, "new")
	var r = c.get_cache("x", {"k": 1})
	assert_str(r[1]).is_equal("new")


## 测试: LRU 不存在键返回 false
func test_lru_missing() -> void:
	var c = _lru_cache(2)
	assert_bool(c.get_cache("no", {"k": 1})[0]).is_false()


## 测试: LRU clear_cache
func test_lru_clear() -> void:
	var c = _lru_cache(3)
	c.set_cache("x", {"k": 1}, "data")
	c.clear_cache()
	assert_bool(c.get_cache("x", {"k": 1})[0]).is_false()


# --------------------------------------------------------------------------
# FIFO cache via GBatisCache
# --------------------------------------------------------------------------

func _fifo_cache(cap: int) -> GDSQL.GBatisCache:
	var c = GDSQL.GBatisCache.new({"eviction": "FIFO", "size": str(cap)})
	c.clear_cache()
	return c

## 测试: FIFO set/get
func test_fifo_set_get() -> void:
	var c = _fifo_cache(3)
	c.set_cache("m", {"p": 1}, "val")
	var r = c.get_cache("m", {"p": 1})
	assert_bool(r[0]).is_true()


## 测试: FIFO 容量淘汰
func test_fifo_eviction() -> void:
	var c = _fifo_cache(2)
	c.set_cache("a", {"k": 1}, "one")
	c.set_cache("b", {"k": 2}, "two")
	c.set_cache("c", {"k": 3}, "three")
	assert_bool(c.get_cache("a", {"k": 1})[0]).is_false()


## 测试: FIFO clear
func test_fifo_clear() -> void:
	var c = _fifo_cache(3)
	c.set_cache("x", {"k": 1}, "data")
	c.clear_cache()
	assert_bool(c.get_cache("x", {"k": 1})[0]).is_false()
