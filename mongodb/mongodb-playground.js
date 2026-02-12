// MongoDB Shell Script - Comprehensive CRUD, DBA, Backup & Restore Operations
// Run in mongosh: mongosh < mongodb-playground.js
// For backup/restore commands, use terminal (mongodump, mongorestore, etc.)

use playground_db

// ============================================================================
// 1. CREATE - Insert Documents (JSON key-value pairs)
// ============================================================================

// Insert single document
db.users.insertOne({
  "name": "Alice",
  "age": 28,
  "email": "alice@example.com",
  "status": "active",
  "skills": ["JavaScript", "MongoDB"],
  "joinDate": new Date("2020-01-15"),
  "profile": {
    "country": "USA",
    "department": "Engineering"
  }
})

// Insert multiple documents
db.users.insertMany([
  {
    "name": "Bob",
    "age": 35,
    "email": "bob@example.com",
    "status": "active",
    "skills": ["Python", "SQL"],
    "joinDate": new Date("2019-05-20"),
    "profile": {
      "country": "Canada",
      "department": "DevOps"
    }
  },
  {
    "name": "Charlie",
    "age": 22,
    "email": "charlie@example.com",
    "status": "inactive",
    "skills": ["Java"],
    "joinDate": new Date("2021-03-10"),
    "profile": {
      "country": "UK",
      "department": "QA"
    }
  },
  {
    "name": "Diana",
    "age": 30,
    "email": "diana@example.com",
    "status": "active",
    "skills": ["Go", "Rust"],
    "joinDate": new Date("2018-11-01"),
    "profile": {
      "country": "Germany",
      "department": "Engineering"
    }
  },
  {
    "name": "Eve",
    "age": 27,
    "email": "eve@example.com",
    "status": "active",
    "skills": ["React", "Node.js"],
    "joinDate": new Date("2020-07-15"),
    "profile": {
      "country": "USA",
      "department": "Frontend"
    }
  }
])

// ============================================================================
// 2. READ - Query Documents
// ============================================================================

// Find all documents
db.users.find()

// Find with filter (status = 'active')
db.users.find({ "status": "active" })

// Find one document
db.users.findOne({ "name": "Alice" })

// Find with operators (age >= 25)
db.users.find({ "age": { "$gte": 25 } })

// Find with multiple conditions
db.users.find({ "status": "active", "age": { "$gt": 26 } })

// Count documents matching criteria
db.users.countDocuments({ "status": "active" })

// Find with text search (requires text index)
// db.users.find({ "$text": { "$search": "engineering" } })

// Find with regex pattern
db.users.find({ "email": { "$regex": "^a", "$options": "i" } })

// ============================================================================
// 3. UPDATE - Modify Documents
// ============================================================================

// Update single document (set field values)
db.users.updateOne(
  { "name": "Alice" },
  { "$set": { "age": 29, "status": "premium" } }
)

// Update multiple documents
db.users.updateMany(
  { "status": "inactive" },
  { "$set": { "status": "archived" } }
)

// Replace entire document
db.users.replaceOne(
  { "name": "Bob" },
  {
    "name": "Bob",
    "age": 36,
    "email": "bob.new@example.com",
    "status": "vip",
    "skills": ["Python", "SQL", "PostgreSQL"],
    "joinDate": new Date("2019-05-20"),
    "profile": {
      "country": "Canada",
      "department": "DevOps"
    }
  }
)

// Add element to array
db.users.updateOne(
  { "name": "Charlie" },
  { "$push": { "skills": "C++" } }
)

// Add multiple elements to array
db.users.updateOne(
  { "name": "Diana" },
  { "$push": { "skills": { "$each": ["C++", "TypeScript"] } } }
)

// Increment numeric field
db.users.updateMany(
  { "status": "active" },
  { "$inc": { "age": 1 } }
)

// Rename field
db.users.updateMany(
  {},
  { "$rename": { "joinDate": "dateJoined" } }
)

// ============================================================================
// 4. DELETE - Remove Documents
// ============================================================================

// Delete single document
db.users.deleteOne({ "name": "Charlie" })

// Delete multiple documents with criteria
db.users.deleteMany({ "status": "archived" })

// Delete all documents in collection (use with caution!)
// db.users.deleteMany({})

// ============================================================================
// 5. ADVANCED QUERIES & AGGREGATION
// ============================================================================

// Find with sorting (descending age)
db.users.find().sort({ "age": -1 })

// Find with limit and skip (pagination)
db.users.find().skip(1).limit(2)

// Find with sort and limit
db.users.find().sort({ "age": -1 }).limit(2)

// Projection (select specific fields only)
db.users.find({}, { "name": 1, "email": 1, "_id": 0 })

// Aggregation pipeline (group and calculate stats)
db.users.aggregate([
  { "$match": { "status": "active" } },
  { "$group": { "_id": null, "averageAge": { "$avg": "$age" }, "totalUsers": { "$sum": 1 } } }
])

// Aggregation with sorting in pipeline
db.users.aggregate([
  { "$match": { "status": "active" } },
  { "$sort": { "age": -1 } },
  { "$limit": 3 },
  { "$project": { "name": 1, "age": 1, "skills": 1 } }
])

// Group by department with statistics
db.users.aggregate([
  { "$group": {
      "_id": "$profile.department",
      "count": { "$sum": 1 },
      "avgAge": { "$avg": "$age" },
      "employees": { "$push": "$name" }
    }
  },
  { "$sort": { "count": -1 } }
])

// ============================================================================
// 6. INDEXING & PERFORMANCE OPTIMIZATION
// ============================================================================

// Create single field index
db.users.createIndex({ "email": 1 })

// Create ascending index (preferred for sorting/filtering)
db.users.createIndex({ "age": 1 })

// Create descending index
db.users.createIndex({ "joinDate": -1 })

// Create compound index (multiple fields)
db.users.createIndex({ "status": 1, "age": 1 })

// Create unique index (ensures no duplicates)
db.users.createIndex({ "email": 1 }, { "unique": true })

// Create text index (for text search)
db.users.createIndex({ "skills": "text", "name": "text" })

// Create sparse index (ignores documents missing the field)
db.users.createIndex({ "profile.department": 1 }, { "sparse": true })

// Create index with expiration (TTL - Time To Live)
db.sessions.createIndex({ "createdAt": 1 }, { "expireAfterSeconds": 3600 })

// List all indexes in collection
db.users.getIndexes()

// Get index statistics
db.users.aggregate([{ "$indexStats": {} }])

// Explain query execution plan (check if index is used)
db.users.find({ "email": "alice@example.com" }).explain("executionStats")

// Drop specific index
db.users.dropIndex("email_1")

// Drop all indexes (except _id)
// db.users.dropIndexes()

// ============================================================================
// 7. USER & AUTHENTICATION MANAGEMENT
// ============================================================================

// Create database user with specific role (admin context)
// Note: Must be in 'admin' database for user creation
// db.createUser({
//   "user": "appUser",
//   "pwd": "securePassword123",
//   "roles": [
//     { "role": "readWrite", "db": "playground_db" },
//     { "role": "dbAdmin", "db": "playground_db" }
//   ]
// })

// Create user with read-only access
// db.createUser({
//   "user": "readOnlyUser",
//   "pwd": "readPassword123",
//   "roles": [
//     { "role": "read", "db": "playground_db" }
//   ]
// })

// List all users
db.getUsers()

// Update user password (in admin context)
// db.changeUserPassword("appUser", "newPassword456")

// Grant additional roles to user
// db.grantRolesToUser("appUser", [{ "role": "backup", "db": "admin" }])

// Revoke roles from user
// db.revokeRolesFromUser("appUser", [{ "role": "dbAdmin", "db": "playground_db" }])

// Drop user
// db.dropUser("readOnlyUser")

// ============================================================================
// 8. BACKUP & RESTORE OPERATIONS (Command Line)
// ============================================================================

/*
=== BACKUP OPERATIONS ===

1. Full Database Backup (using mongodump - run in terminal):
   mongodump --db playground_db --out ./backup/full_backup

2. Backup with authentication:
   mongodump --db playground_db --username appUser --password securePassword123 --authenticationDatabase admin --out ./backup/authenticated_backup

3. Backup specific collection:
   mongodump --db playground_db --collection users --out ./backup/users_collection

4. Backup with compression:
   mongodump --db playground_db --archive=playground_db.archive --gzip

5. Backup with query filter (only active users):
   mongodump --db playground_db --collection users --query '{"status":"active"}' --out ./backup/active_users

6. Incremental backup using oplog (requires replica set):
   mongodump --oplog --out ./backup/incremental_backup

=== RESTORE OPERATIONS ===

1. Full database restore (using mongorestore):
   mongorestore --db playground_db ./backup/full_backup/playground_db

2. Restore with authentication:
   mongorestore --db playground_db --username appUser --password securePassword123 --authenticationDatabase admin ./backup/authenticated_backup/playground_db

3. Restore specific collection:
   mongorestore --db playground_db --collection users ./backup/users_collection/playground_db/users.bson

4. Restore from compressed archive:
   mongorestore --archive=playground_db.archive --gzip

5. Restore with drop (deletes existing data first):
   mongorestore --db playground_db --drop ./backup/full_backup/playground_db

6. Restore with oplog:
   mongorestore --oplogReplay ./backup/incremental_backup
*/

// ============================================================================
// 9. DATABASE MAINTENANCE & MONITORING
// ============================================================================

// Get database statistics
db.stats()

// Get collection statistics
db.users.stats()

// Check storage size
db.users.storageSize()

// Check document count
db.users.countDocuments()

// Get database size in bytes
db.stats().dataSize

// Get collection size with options
db.users.stats({ "indexDetails": true })

// Compact collection (reclaim space)
// db.runCommand({ "compact": "users" })

// Repair database (offline operation, use in terminal)
// mongod --repair --dbpath /var/lib/mongodb

// Validate collection
db.validateCollection("users")

// Run validation with detailed output
db.validateCollection("users", { "full": true })

// ============================================================================
// 10. REPLICATION BASICS (for Replica Sets)
// ============================================================================

/*
=== REPLICATION SETUP (Terminal commands) ===

1. Start MongoDB with replica set:
   mongod --replSet "rs0" --bind_ip localhost --port 27017

2. Initialize replica set:
   mongosh --eval "rs.initiate()"

3. Add members to replica set:
   rs.add("secondary1:27018")
   rs.add("secondary2:27019")

4. View replica set status:
   rs.status()

5. View replica set configuration:
   rs.conf()
*/

// Check replica set status (only works if in replica set)
// rs.status()

// Get replica set configuration
// rs.conf()

// Add secondary member (in rs shell)
// rs.add("secondary:27018")

// Remove member from replica set
// rs.remove("secondary:27018")

// ============================================================================
// 11. SHARDING BASICS (Distributed Data)
// ============================================================================

/*
=== SHARDING SETUP (Terminal commands) ===

1. Enable sharding on database:
   mongosh admin
   sh.enableSharding("playground_db")

2. Create sharded collection with shard key:
   sh.shardCollection("playground_db.users", { "email": 1 })

3. Check sharding status:
   sh.status()

4. View shard information:
   sh.getShardNames()

5. Monitor chunk distribution:
   db.printShardingStatus()
*/

// Enable sharding on database
// sh.enableSharding("playground_db")

// Create sharded collection
// sh.shardCollection("playground_db.users", { "email": 1 })

// Check sharding status
// sh.status()

// ============================================================================
// 12. MONITORING & DIAGNOSTICS
// ============================================================================

// Get current operations
db.currentOp()

// Get slow operations (longer than 100ms)
db.currentOp({ "millis": { "$gt": 100 } })

// Kill specific operation (by opid)
// db.killOp(opid)

// Get profiling level
db.getProfilingLevel()

// Enable profiling (slow queries > 100ms)
db.setProfilingLevel(1, { "slowms": 100 })

// Query profiling data
db.system.profile.find({ "millis": { "$gt": 50 } }).pretty()

// Disable profiling
db.setProfilingLevel(0)

// Get server status
db.serverStatus()

// Get memory stats
db.serverStatus().mem

// Get opcounter (operations count)
db.serverStatus().opcounters

// Check replication lag (in replica set)
// rs.printSecondaryReplicationInfo()

// ============================================================================
// 13. BULK OPERATIONS & TRANSACTIONS
// ============================================================================

// Create bulk operation
var bulk = db.users.initializeUnorderedBulkOp()

// Add operations to bulk
bulk.find({ "status": "inactive" }).update({ "$set": { "status": "archived" } })
bulk.find({ "age": { "$lt": 25 } }).update({ "$inc": { "age": 1 } })

// Execute bulk operations
// bulk.execute()

// Start transaction (MongoDB 4.0+, requires replica set)
/*
session = db.getMongo().startSession()
db.users.insertOne({ "name": "TestUser" }, { session: session })
db.users.updateOne({ "name": "TestUser" }, { "$set": { "age": 30 } }, { session: session })
session.commitTransaction()
session.endSession()
*/

// ============================================================================
// 14. DATA EXPORT & IMPORT
// ============================================================================

/*
=== EXPORT TO JSON (Terminal) ===

1. Export collection to JSON:
   mongoexport --db playground_db --collection users --out users.json

2. Export with query filter:
   mongoexport --db playground_db --collection users --query '{"status":"active"}' --out active_users.json

3. Export with pretty print:
   mongoexport --db playground_db --collection users --pretty --out users_pretty.json

4. Export with specific fields:
   mongoexport --db playground_db --collection users --fields=name,email --out name_email.csv --type=csv

=== IMPORT FROM JSON (Terminal) ===

1. Import JSON file:
   mongoimport --db playground_db --collection users --file users.json

2. Import with drop (replaces collection):
   mongoimport --db playground_db --collection users --file users.json --drop

3. Import JSON array:
   mongoimport --db playground_db --collection users --jsonArray --file users_array.json

4. Import CSV:
   mongoimport --db playground_db --collection users --type=csv --headerline --file users.csv
*/

// ============================================================================
// 15. SECURITY BEST PRACTICES
// ============================================================================

/*
=== SECURITY CHECKLIST ===

1. Enable authentication:
   mongod --auth

2. Use strong passwords:
   - Minimum 12 characters
   - Mix uppercase, lowercase, numbers, special chars

3. Create roles for least privilege:
   - readWrite for application users
   - read for reporting users
   - backup, restore for ops

4. Enable SSL/TLS:
   mongod --sslMode requireSSL --sslPEMKeyFile server.pem

5. Configure network access:
   - Use firewall rules
   - Bind to specific IP addresses (--bind_ip)
   - Use VPN for remote access

6. Audit logging:
   mongod --auditDestination syslog --auditFormat JSON

7. Encryption at rest:
   - Enable WiredTiger encryption
   - Use encrypted backups

8. Regular backups:
   - Daily incremental backups
   - Weekly full backups
   - Test restore procedures

9. Monitor and alert:
   - Set up alerts for errors
   - Monitor disk space
   - Track replication lag
*/

// ============================================================================
// 16. PERFORMANCE TUNING TIPS
// ============================================================================

/*
=== PERFORMANCE OPTIMIZATION STRATEGIES ===

1. Indexing Strategy:
   - Create indexes on frequently filtered fields
   - Use compound indexes for multi-field queries
   - Monitor index usage with $indexStats
   - Remove unused indexes to save memory

2. Query Optimization:
   - Use projection to limit returned fields
   - Use limit() and skip() for pagination
   - Avoid large $in arrays (use $nin with smaller set)
   - Analyze query plans with explain()

3. Data Model:
   - Embed frequently accessed related data
   - Use denormalization for read-heavy workloads
   - Keep documents reasonably sized (< 16MB)
   - Avoid large arrays that grow unbounded

4. Write Optimization:
   - Use bulk operations for multiple writes
   - Batch inserts when possible
   - Use write concern levels appropriately

5. Hardware Optimization:
   - Use SSD for data and journal
   - Adequate RAM for working set
   - Monitor disk I/O
   - Use NUMA-aware settings on large systems

6. Connection Pooling:
   - Use connection pools in applications
   - Configure appropriate pool size
   - Set connection timeouts

7. Memory Management:
   - Monitor WiredTiger cache size
   - Adjust cache size based on workload
   - Use mmapv1 carefully (deprecated in 4.4+)
*/

// ============================================================================
// 17. DISASTER RECOVERY PROCEDURES
// ============================================================================

/*
=== DISASTER RECOVERY PLAN ===

1. Pre-disaster preparation:
   - Regular backups (daily/weekly)
   - Store backups in multiple locations
   - Document recovery procedures
   - Test recovery procedures regularly

2. Data Loss Scenario:
   - Stop application to prevent data loss
   - Restore from most recent backup
   - Replay oplog if available (replica set)
   - Verify data integrity

3. Hardware Failure:
   - Failover to secondary (replica set)
   - Rebuild failed node with data sync
   - Replace hardware and rejoin

4. Corruption Detection:
   - Run db.validateCollection()
   - Check replication status
   - Restore from backup if needed
   - Rebuild indexes

5. Capacity Planning:
   - Monitor growth rate
   - Plan for data expansion
   - Implement sharding early
   - Test scaling procedures
*/

// ============================================================================
// 18. CLEANUP & FINAL STATE
// ============================================================================

// Show all collections in database
db.getCollectionNames()

// Show all documents with pretty formatting
db.users.find().pretty()

// Show count of remaining documents
db.users.countDocuments()

// Get database info
db.getName()

// Get server info
db.version()

// Drop collection (use with caution!)
// db.users.drop()

// Drop entire database (VERY DANGEROUS!)
// db.dropDatabase()

// ============================================================================
// USEFUL COMMANDS REFERENCE
// ============================================================================

/*
Common MongoDB Operations Quick Reference:

DATABASE:
  show dbs                      - List all databases
  use <db>                      - Switch database
  db.getName()                  - Get current database name
  db.stats()                    - Database statistics

COLLECTIONS:
  show collections              - List all collections
  db.createCollection("name")   - Create collection
  db.<collection>.drop()        - Drop collection

DOCUMENTS:
  db.<col>.insertOne({})        - Insert one
  db.<col>.find({})             - Find all
  db.<col>.updateOne()          - Update one
  db.<col>.deleteOne()          - Delete one
  db.<col>.countDocuments()     - Count documents

INDEXES:
  db.<col>.createIndex({})      - Create index
  db.<col>.dropIndex()          - Drop index
  db.<col>.getIndexes()         - List indexes

BACKUP/RESTORE (Terminal):
  mongodump --db <db> ...       - Backup database
  mongorestore --db <db> ...    - Restore database
  mongoexport --db <db> ...     - Export to JSON/CSV
  mongoimport --db <db> ...     - Import from JSON/CSV

PERFORMANCE:
  db.<col>.explain()            - Query execution plan
  db.setProfilingLevel()        - Enable query logging
  db.currentOp()                - Show running operations

USERS:
  db.createUser()               - Create user
  db.getUsers()                 - List users
  db.dropUser()                 - Delete user

REPLICATION (Replica Set):
  rs.status()                   - Replication status
  rs.conf()                     - Replication config
  rs.add()                      - Add member
  rs.remove()                   - Remove member

SHARDING:
  sh.enableSharding()           - Enable sharding
  sh.shardCollection()          - Shard collection
  sh.status()                   - Sharding status
*/
