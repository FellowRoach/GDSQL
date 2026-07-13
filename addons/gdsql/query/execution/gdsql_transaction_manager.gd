class_name GDSQLTransactionManager
extends RefCounted

func begin() -> GDSQLStorageSession: return null
func commit(session: GDSQLStorageSession) -> GDSQLStorageCommitResult: return null
func rollback(session: GDSQLStorageSession) -> void: pass

