SET PATH SYSTEM PATH, USER, UTILS!

CREATE TABLE FOO (
	ID INTEGER NOT NULL PRIMARY KEY,
	VALUE INTEGER NOT NULL
)!

CALL CREATE_HISTORY_TABLE('FOO', 'DAY')!

VALUES ASSERT_TABLE_EXISTS('FOO_HISTORY')!
VALUES ASSERT_EQUALS(4, (SELECT COUNT(*) FROM SYSCAT.COLUMNS WHERE TABSCHEMA = CURRENT SCHEMA AND TABNAME = 'FOO_HISTORY'))!
VALUES ASSERT_EQUALS('EFFECTIVE_DAY', (SELECT COLNAME FROM SYSCAT.COLUMNS WHERE TABSCHEMA = CURRENT SCHEMA AND TABNAME = 'FOO_HISTORY' AND COLNO = 0))!
VALUES ASSERT_EQUALS('EXPIRY_DAY',    (SELECT COLNAME FROM SYSCAT.COLUMNS WHERE TABSCHEMA = CURRENT SCHEMA AND TABNAME = 'FOO_HISTORY' AND COLNO = 1))!
VALUES ASSERT_EQUALS('ID',            (SELECT COLNAME FROM SYSCAT.COLUMNS WHERE TABSCHEMA = CURRENT SCHEMA AND TABNAME = 'FOO_HISTORY' AND COLNO = 2))!
VALUES ASSERT_EQUALS('VALUE',         (SELECT COLNAME FROM SYSCAT.COLUMNS WHERE TABSCHEMA = CURRENT SCHEMA AND TABNAME = 'FOO_HISTORY' AND COLNO = 3))!

CALL CREATE_HISTORY_TRIGGERS('FOO', 'DAY')!

VALUES ASSERT_TRIGGER_EXISTS('FOO_INSERT')!
VALUES ASSERT_TRIGGER_EXISTS('FOO_UPDATE')!
VALUES ASSERT_TRIGGER_EXISTS('FOO_DELETE')!

INSERT INTO FOO VALUES (1, 1)!
INSERT INTO FOO VALUES (2, 1)!

VALUES ASSERT_EQUALS(1, (SELECT COUNT(*) FROM FOO_HISTORY WHERE ID = 1 AND EXPIRY_DAY = '9999-12-31'))!
VALUES ASSERT_EQUALS(1, (SELECT COUNT(*) FROM FOO_HISTORY WHERE ID = 2 AND EXPIRY_DAY = '9999-12-31'))!

DELETE FROM FOO WHERE ID = 1!
UPDATE FOO SET VALUE = 2 WHERE ID = 2!

VALUES ASSERT_EQUALS(0, (SELECT COUNT(*) FROM FOO_HISTORY WHERE ID = 1))!
VALUES ASSERT_EQUALS(1, (SELECT COUNT(*) FROM FOO_HISTORY WHERE ID = 2 AND EXPIRY_DAY = '9999-12-31'))!

DROP TABLE FOO_HISTORY!
DROP TRIGGER FOO_DELETE!
DROP TRIGGER FOO_UPDATE!
DROP TRIGGER FOO_INSERT!
DELETE FROM FOO!

CALL CREATE_HISTORY_TABLE('FOO', 'MICROSECOND')!
CALL CREATE_HISTORY_TRIGGERS('FOO', 'MICROSECOND')!

VALUES ASSERT_EQUALS('EFFECTIVE_MICROSECOND', (SELECT COLNAME FROM SYSCAT.COLUMNS WHERE TABSCHEMA = CURRENT SCHEMA AND TABNAME = 'FOO_HISTORY' AND COLNO = 0))!
VALUES ASSERT_EQUALS('EXPIRY_MICROSECOND',    (SELECT COLNAME FROM SYSCAT.COLUMNS WHERE TABSCHEMA = CURRENT SCHEMA AND TABNAME = 'FOO_HISTORY' AND COLNO = 1))!

INSERT INTO FOO VALUES (1, 1)!
INSERT INTO FOO VALUES (2, 1)!

VALUES ASSERT_EQUALS(1, (SELECT COUNT(*) FROM FOO_HISTORY WHERE ID = 1 AND EXPIRY_MICROSECOND = '9999-12-31 23:59:59.999999'))!
VALUES ASSERT_EQUALS(1, (SELECT COUNT(*) FROM FOO_HISTORY WHERE ID = 2 AND EXPIRY_MICROSECOND = '9999-12-31 23:59:59.999999'))!

DELETE FROM FOO WHERE ID = 1!
UPDATE FOO SET VALUE = 2 WHERE ID = 2!

VALUES ASSERT_NOT_EQUALS('9999-12-31 23:59:59.999999', (SELECT EXPIRY_MICROSECOND FROM FOO_HISTORY WHERE ID = 1))!
VALUES ASSERT_EQUALS(1, (SELECT COUNT(*) FROM FOO_HISTORY WHERE ID = 2 AND VALUE = 1))!
VALUES ASSERT_EQUALS(1, (SELECT COUNT(*) FROM FOO_HISTORY WHERE ID = 2 AND VALUE = 2))!

CALL CREATE_HISTORY_CHANGES('FOO_HISTORY')!

VALUES ASSERT_TABLE_EXISTS('FOO_CHANGES')!
VALUES ASSERT_EQUALS(4, (SELECT COUNT(*) FROM FOO_CHANGES))!
VALUES ASSERT_EQUALS(2, (SELECT COUNT(*) FROM FOO_CHANGES WHERE CHANGE = 'INSERT' AND NEW_ID IN (1, 2)))!
VALUES ASSERT_EQUALS(1, (SELECT COUNT(*) FROM FOO_CHANGES WHERE CHANGE = 'UPDATE' AND OLD_ID = 2 AND OLD_VALUE = 1 AND NEW_VALUE = 2))!
VALUES ASSERT_EQUALS(1, (SELECT COUNT(*) FROM FOO_CHANGES WHERE CHANGE = 'DELETE' AND OLD_ID = 1))!

-- XXX Need to test the rest of the resolutions...

