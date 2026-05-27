extends GdUnitTestSuite

## Tests for GDSQL.GXMLNode — raw XML parser node.

## 测试: 元素节点检测
func test_node_is_element() -> void:
	var n = GDSQL.GXMLNode.new()
	n.type = XMLParser.NODE_ELEMENT
	assert_bool(n.is_element()).is_true()
	assert_bool(n.is_text()).is_false()
	assert_bool(n.is_element_like()).is_true()


## 测试: 元素结束节点
func test_node_is_element_end() -> void:
	var n = GDSQL.GXMLNode.new()
	n.type = XMLParser.NODE_ELEMENT_END
	assert_bool(n.is_element_end()).is_true()
	assert_bool(n.is_element_like()).is_true()


## 测试: 文本节点
func test_node_is_text() -> void:
	var n = GDSQL.GXMLNode.new()
	n.type = XMLParser.NODE_TEXT
	assert_bool(n.is_text()).is_true()
	assert_bool(n.is_element_like()).is_false()


## 测试: 空白文本
func test_node_is_blank_text() -> void:
	var n = GDSQL.GXMLNode.new()
	n.type = XMLParser.NODE_TEXT
	n.data = "  \t  "
	assert_bool(n.is_blank_text()).is_true()


## 测试: 非空白文本
func test_node_not_blank_text() -> void:
	var n = GDSQL.GXMLNode.new()
	n.type = XMLParser.NODE_TEXT
	n.data = "hello"
	assert_bool(n.is_blank_text()).is_false()


## 测试: CDATA 节点
func test_node_is_cdata() -> void:
	var n = GDSQL.GXMLNode.new()
	n.type = XMLParser.NODE_CDATA
	assert_bool(n.is_cdata()).is_true()


## 测试: CDATA 提取内容
func test_node_get_cdata() -> void:
	var n = GDSQL.GXMLNode.new()
	n.type = XMLParser.NODE_CDATA
	n.raw = "<![CDATA[hello world]]>"
	assert_str(n.get_cdata()).is_equal("hello world")
