VALUES ASSERT_IS_NULL(QUOTE_STRING(NULL))!
VALUES ASSERT_EQUALS(QUOTE_STRING('A string'), '''A string''')!
VALUES ASSERT_EQUALS(QUOTE_STRING('Frank''s string'), '''Frank''''s string''')!
VALUES ASSERT_EQUALS(QUOTE_STRING('A multi' || X'0A' || 'line string'), '''A multi'' || X''0A'' || ''line string''')!

VALUES ASSERT_IS_NULL(QUOTE_IDENTIFIER(NULL))!
VALUES ASSERT_EQUALS(QUOTE_IDENTIFIER('MY_TABLE'), 'MY_TABLE')!
VALUES ASSERT_EQUALS(QUOTE_IDENTIFIER('MY#TABLE'), 'MY#TABLE')!
VALUES ASSERT_EQUALS(QUOTE_IDENTIFIER('MyTable'), '"MyTable"')!
VALUES ASSERT_EQUALS(QUOTE_IDENTIFIER('My "Table"'), '"My ""Table"""')!

-- vim: set et sw=4 sts=4:
